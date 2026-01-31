class_name ModRegistry

const CLASS_NAME = "ModRegistry"
var LOGGER: Object

var _api_api
var _active_mods: Dictionary = {}
var _registered_mods: Dictionary = {}
var _root_to_mod_info: Dictionary = {}

signal registered(mod_info)

func _init(logger: Object, api_api: Object, active_mods: Dictionary):
    LOGGER = logger.for_class(self)
    _api_api = api_api
    _active_mods = active_mods
    for mod_info in active_mods.values():
        _root_to_mod_info[mod_info.root] = mod_info

    # create and connect to mod registration signal
    if (not Engine.has_signal("_lib_register_mod")):
        Engine.add_user_signal("_lib_register_mod", [{"name": "mod", "type": TYPE_OBJECT}])
    Engine.connect("_lib_register_mod", self, "register")

## Registers a mod. This is indirectly called when using the Engine signal to register a mod, no clue why you'd want to call this directly.
func register(mod: Reference, global_instance = null):
    # write stuff to mod.Global by default
    if (global_instance == null):
        global_instance = mod.Global
    var mod_root: String = global_instance.Root.rstrip("/")
    var mod_info
    # create ModInfo with the .ddmod file dictionary we collected in _init
    if (mod_root in _root_to_mod_info):
        mod_info = _root_to_mod_info[mod_root]
        mod_info.mod = mod
    else:
        LOGGER.error("Failed to register mod in directory \"%s\" since ddmod file could not be found!", [mod_root])
        return
    # add mod to registry
    _registered_mods[mod_info.mod_meta["unique_id"]] = mod_info
    # add InstancedApiApi to mod global dictionary
    global_instance["API"] = _api_api._instance(mod_info)
    emit_signal("registered", mod_info)

func get_active_mods() -> Dictionary:
    return _active_mods.duplicate()

func get_registered_mods() -> Dictionary:
    return _registered_mods.duplicate()

func get_mod_info(mod_id: String):
    return _active_mods[mod_id]

func get_ddmod(mod_id: String) -> Dictionary:
    return _active_mods[mod_id].mod_meta

func _unload():
    LOGGER.info("Unloading %s.", [CLASS_NAME])
    # disconnect all signals
    Engine.disconnect("_lib_register_mod", self, "register")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)