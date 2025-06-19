class_name InputMapApi
## https://creepycre.github.io/_Lib/InputMapApi/

const CLASS_NAME = "InputMapApi"
var LOGGER: Object

var _agents: Dictionary = {}
var _event_emitters: Dictionary = {}
var _master_node: Node
var _mod_actions: Dictionary = {}

signal added_actions(actions)
signal erasing_actions(action)
signal erased_actions(actions)

func _init(logger: Object, master_node: Node):
    LOGGER = logger.for_class(self)
    _master_node = master_node
    # create ActionConfigSyncAgents for vanilla InputMap actions
    for action in InputMap.get_actions(): # action: String
        _create_agent(action, false)

static func _merge_dicts(from: Dictionary, to: Dictionary):
    for key in from:
        if not key in to:
            to[key] = from[key]
        elif (to[key] is Dictionary) and (from[key] is Dictionary):
            _merge_dicts(from[key], to[key])

## https://creepycre.github.io/_Lib/InputMapApi/#add_actions
func add_actions(actions, category):
    if not _mod_actions.has(category):
        _mod_actions[category] = actions
    else:
        _merge_dicts(actions, _mod_actions[category])
    var defined_actions: Array = _define_actions(actions)
    if len(defined_actions) > 0:
        emit_signal("added_actions", defined_actions)
    return

func erase_action(action: String):
    erase_actions([action])

func erase_actions(actions: Array):
    self.emit_signal("erasing_actions", actions)
    for action in actions:
        if _agents.has(action):
            _agents[action]._erase_action()
        for category in _mod_actions:
            _erase_action(action, _mod_actions[category])
        InputMap.erase_action(action)
    self.emit_signal("erased_actions", actions)


func _erase_action(action: String, definitions: Dictionary):
    for key in definitions:
        var val = definitions[key]
        if val is Dictionary:
            _erase_action(action, val)
        elif val == action: # would also require it to be String, so checking for String is redundant
            definitions.erase(key)
        elif val is Array and val[0] == action:
            definitions.erase(key)

# adds input actions from actions to InputMap recursively and creates their ActionConfigSyncAgent
func _define_actions(actions: Dictionary) -> Array:
    var defined_actions: Array = []
    for key in actions:
        var action = actions[key]
        # recurse if it is a dictionary
        if action is Dictionary:
            defined_actions.append_array(_define_actions(action))
        # action String defines action without keybind
        elif action is String:
            get_or_create_agent(action)
            defined_actions.append(action)
        # action String array contains action String as first entry, other entries will be deserialized as InputEventKey and added to the action
        elif action is Array:
            action = action.duplicate()
            var agent = get_or_create_agent(action.pop_front())
            for event in action:
                agent.add_event(deserialize_event(event))
            defined_actions.append(agent.get_action())
    return defined_actions

## Deserializes an InputEventKey from string. 
func deserialize_event(string: String) -> InputEventKey:
    var codes: Array = string.to_lower().split("+")
    var event: InputEventKey = InputEventKey.new()
    var key_string = codes.pop_back()
    if codes.has("alt"):
        event.alt = true
    if codes.has("ctrl"):
        event.control = true
    if codes.has("cmd"):
        event.command = true
    if codes.has("shift"):
        event.shift = true
    event.set_scancode(int(key_string) if key_string.is_valid_integer() else OS.find_scancode_from_string(key_string.capitalize()))
    return event

## Serializes event into a String. 
func serialize_event(event: InputEventKey) -> String:
    var code: int = event.get_scancode_with_modifiers()
    return ("Alt+" if code & KEY_MASK_ALT != 0 else "")\
        + ("Ctrl+" if code & KEY_MASK_CTRL != 0 else "")\
        + ("Cmd+" if code & KEY_MASK_META != 0 else "")\
        + ("Shift+" if code & KEY_MASK_SHIFT != 0 else "")\
        + str(code & KEY_CODE_MASK)

## Turns event into a human readable String representation. 
func event_as_string(event: InputEventKey) -> String:
    var code: int = event.get_scancode_with_modifiers()
    return ("Alt+" if code & KEY_MASK_ALT != 0 else "")\
        + ("Ctrl+" if code & KEY_MASK_CTRL != 0 else "")\
        + ("Cmd+" if code & KEY_MASK_META != 0 else "")\
        + ("Shift+" if code & KEY_MASK_SHIFT != 0 else "")\
        + OS.get_scancode_string(code & KEY_CODE_MASK)

## Checks wether an action has an agent.
func has_agent(action: String) -> bool:
    return _agents.has(action)

## Gets the ActionConfigSyncAgent for action. 
func get_agent(action: String) -> ActionConfigSyncAgent:
    return _agents[action]

## Gets or creates the ActionConfigSyncAgent for action. 
func get_or_create_agent(action: String, deadzone: float = 0.5) -> ActionConfigSyncAgent:
    if _agents.has(action):
        return _agents[action]
    elif InputMap.has_action(action):
        return _create_agent(action, false)
    else:
        InputMap.add_action(action, deadzone)
        return _create_agent(action, true)

## Gets the InputEventEmitterNode attached to node or creates one if necessary. 
func get_or_append_event_emitter(node: Node) -> InputEventEmitterNode:
    if _event_emitters.has(node):
        return _event_emitters[node]
    var emitter: InputEventEmitterNode = InputEventEmitterNode.new()
    node.add_child(emitter)
    emitter.owner = node
    _event_emitters[node] = emitter
    return emitter

## Gets the InputEventEmitterNode attached to the Master node (owner of Editor & World) or creates one if necessary. 
func master_event_emitter() -> InputEventEmitterNode:
    return get_or_append_event_emitter(_master_node)

# creates ActionConfigSyncAgent for action, erase_on_unload determines whether action is erased from InputMap on mod unload
func _create_agent(action: String, erase_on_unload = true) -> ActionConfigSyncAgent:
    var agent: ActionConfigSyncAgent = ActionConfigSyncAgent.new(action, erase_on_unload)
    _agents[action] = agent
    return agent

func _unload():
    LOGGER.info("Unloading %s.", [CLASS_NAME])
    # disconnect all signals
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)
    # unload ActionConfigSyncAgents
    for action in _agents:
        _agents[action]._unload()
    _agents.clear()
    # detach and unload InputEventEmitterNodes
    for node in _event_emitters:
        var emitter = _event_emitters[node]
        node.remove_child(emitter)
        emitter._unload()
    _event_emitters.clear()

func _instance(mod_info):
    return InstancedInputMapApi.new(self, mod_info.mod_meta["name"])

class InstancedInputMapApi:
    var _input_map_api
    var _mod_name

    signal added_actions(actions)
    signal erasing_actions(action)
    signal erased_actions(actions)

    func _init(input_map_api, mod_name):
        _input_map_api = input_map_api
        _mod_name = mod_name
        
        _input_map_api.connect("added_actions", self, "_emit_sig", ["added_actions"])
        _input_map_api.connect("erasing_actions", self, "_emit_sig", ["erasing_actions"])
        _input_map_api.connect("erased_actions", self, "_emit_sig", ["erased_actions"])
    
    func _emit_sig(val, sig):
        emit_signal(sig, val)
    
    ## deprecated
    func define_actions(category: String, actions: Dictionary):
        add_actions(actions, category)

    func add_actions(actions, category: String = _mod_name):
        _input_map_api.add_actions(actions, category)
    
    func erase_action(action: String):
        _input_map_api.erase_action(action)
    
    func deserialize_event(string: String) -> InputEventKey:
        return _input_map_api.deserialize_event(string)

    func serialize_event(event: InputEventKey) -> String:
        return _input_map_api.serialize_event(event)

    func event_as_string(event: InputEventKey) -> String:
        return _input_map_api.event_as_string(event)

    func get_agent(action: String) -> ActionConfigSyncAgent:
        return _input_map_api.get_agent(action)

    func get_or_create_agent(action: String, deadzone: float = 0.5) -> ActionConfigSyncAgent:
        return _input_map_api.get_or_create_agent(action, deadzone)

    func get_or_append_event_emitter(node: Node) -> InputEventEmitterNode:
        return _input_map_api.get_or_append_event_emitter(node)

    func master_event_emitter() -> InputEventEmitterNode:
        return _input_map_api.master_event_emitter()

    func _unload():
        # disconnect all signals
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)

## Responsible for synchronization of shortcuts between multiple shortcut config nodes.
## https://creepycre.github.io/_Lib/InputMapApi/ActionConfigSyncAgent/
class ActionConfigSyncAgent:
    var _action: String
    var _erase_on_unload: bool
    var _saved: bool

    signal switched(from, to, index)
    signal deleted(index)
    signal added()
    signal erasing_action()

    func _init(action: String, erase_on_unload = true, saved = false):
        _action = action
        _erase_on_unload = erase_on_unload
        _saved = saved
    
    func get_action() -> String:
        return _action
    
    func get_action_list() -> Array:
        return InputMap.get_action_list(_action)
    
    # shortcut config tree sync
    func switch(from: InputEventKey, to: InputEventKey, index: int):
        emit_signal("switched", from, to, index)
    
    # shortcut config tree sync
    func deleted_item(index: int):
        emit_signal("deleted", index)
    
    # shortcut config tree sync
    func added_item():
        emit_signal("added")
    
    func add_event(event: InputEventKey):
        InputMap.action_add_event(_action, event)
    
    func _erase_action():
        emit_signal("erasing_action")
        # disconnect all signals
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)
    
    func _unload():
        # disconnect all signals
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)
        # erase action from InputMap if needed. Usually only vanilla actions won't be erased.
        if _erase_on_unload and InputMap.has_action(_action):
            InputMap.erase_action(_action)
    
    func is_saved() -> bool:
        return _saved

# refer to https://docs.godotengine.org/en/stable/tutorials/inputs/inputevent.html for order of input signals
class InputEventEmitterNode:
    extends Node

    # signals forward _input, _unhandled_input and _unhandled_key_input methods respectively
    signal signal_input(event, emitter)
    signal unhandled_input(event, emitter)
    signal unhandled_key_input(event, emitter)
    
    # stop input event propagation
    func accept_event():
        get_tree().set_input_as_handled()

    func _input(event):
        emit_signal("signal_input", event, self)
    
    func _unhandled_input(event):
        emit_signal("unhandled_input", event, self)

    func _unhandled_key_input(event):
        emit_signal("unhandled_key_input", event, self)

    func _unload():
        # disconnect all signals
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)
