class_name ConfigBuilder

var _agent: ConfigAgent
var _root: Control
var _node_stack: Array = []
var _current_node: Control
var _last_child_node: Control = null
var _references: Dictionary = {}

func _init(root: Control, config_file: String):
    _root = root
    _current_node = root
    _agent = ConfigAgent.new(_root, config_file)
    _root.set_parent_config_node(_agent)

static func config(title: String, config_file: String, mod_config_scene, self_script: Script) -> ConfigBuilder:
    var mod_config = mod_config_scene.instance()
    mod_config.get_node("TitlePanel/Title").text = title
    var v_box = mod_config.get_node("ConfigPanel/ScrollContainer/Config")
    var wrapped = WrappedControlConfigNode.new("", mod_config, v_box)
    wrapped.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wrapped.size_flags_vertical = Control.SIZE_EXPAND_FILL
    return self_script.new(wrapped, config_file)

func enter() -> ConfigBuilder:
    _node_stack.append(_current_node)
    _current_node = _last_child_node
    _last_child_node = _get_target(_last_child_node).get_children().back()
    return self

func exit() -> ConfigBuilder:
    _last_child_node = _current_node
    _current_node = _node_stack.pop_back()
    return self

func add_node(node: Control, legible_unique_name: bool = false) -> ConfigBuilder:
    if (_current_node.has_method("add_node")):
        _current_node.add_node(node, legible_unique_name)
    else:
        var target = _get_target(_current_node)
        target.add_child(node, legible_unique_name)
        node.owner = target
    if node.has_method("set_parent_config_node"):
        node.set_parent_config_node(_current_node)
    _last_child_node = node
    return self

func add_node_direct(node: Control, legible_unique_name: bool = false) -> ConfigBuilder:
    _current_node.add_child(node, legible_unique_name)
    node.owner = _current_node
    return self

func with(property: String, value) -> ConfigBuilder:
    if (_last_child_node.has_method("with")):
        _last_child_node.with(property, value)
    else:
        _last_child_node.set(property, value)
    return self

func flatten(value: bool = true) -> ConfigBuilder:
    if _last_child_node.has_method("flatten"):
        _last_child_node.flatten(value)
    return self

func get_current() -> Control:
    return _last_child_node

func ref(reference_name: String) -> ConfigBuilder:
    _references[reference_name] = _last_child_node
    return self

func get_ref(reference_name: String) -> Control:
    return _references[reference_name]

func call_on(method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null) -> ConfigBuilder:
    if (arg9 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elif (arg8 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elif (arg7 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elif (arg6 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    elif (arg5 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5)
    elif (arg4 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3, arg4)
    elif (arg3 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2, arg3)
    elif (arg2 != null):
        _last_child_node.call(method_name, arg0, arg1, arg2)
    elif (arg1 != null):
        _last_child_node.call(method_name, arg0, arg1)
    elif (arg0 != null):
        _last_child_node.call(method_name, arg0)
    else:
        _last_child_node.call(method_name)
    return self

func call_on_ref(reference_name: String, method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null) -> ConfigBuilder:
    var ref = _references[reference_name]
    if ref == null:
        return self
    if (arg9 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elif (arg8 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elif (arg7 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elif (arg6 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    elif (arg5 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5)
    elif (arg4 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3, arg4)
    elif (arg3 != null):
        ref.call(method_name, arg0, arg1, arg2, arg3)
    elif (arg2 != null):
        ref.call(method_name, arg0, arg1, arg2)
    elif (arg1 != null):
        ref.call(method_name, arg0, arg1)
    elif (arg0 != null):
        ref.call(method_name, arg0)
    else:
        ref.call(method_name)
    return self

func wrap(save_entry: String, root_node: Control, target_node = null) -> ConfigBuilder:
    if (save_entry == ""):
        return add_node(WrappedControlConfigNode.new(save_entry, root_node, target_node)).flatten()
    else:
        return add_node(WrappedControlConfigNode.new(save_entry, root_node, target_node))

func check_button(save_entry: String, default_value: bool, text: String = "") -> ConfigBuilder:
    return add_node(CheckButtonConfigNode.new(save_entry, default_value)).with("text", text)

func check_box(save_entry: String, default_value: bool, text: String = "") -> ConfigBuilder:
    return add_node(CheckBoxConfigNode.new(save_entry, default_value)).with("text", text)

func h_slider(save_entry: String, default_value: float) -> ConfigBuilder:
    return add_node(HSliderConfigNode.new(save_entry, default_value))

func v_slider(save_entry: String, default_value: float) -> ConfigBuilder:
    return add_node(VSliderConfigNode.new(save_entry, default_value))

func spin_box(save_entry: String, default_value: float) -> ConfigBuilder:
    return add_node(SpinBoxConfigNode.new(save_entry, default_value))

func aspect_ratio_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, AspectRatioContainer.new())

func center_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, CenterContainer.new())

func h_box_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, HBoxContainer.new())

func v_box_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, VBoxContainer.new())

func grid_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, GridContainer.new())

#func h_flow_container(save_entry: String = "") -> ConfigBuilder:
#    return wrap(save_entry, HFlowContainer.new())

#func v_flow_container(save_entry: String = "") -> ConfigBuilder:
#    return wrap(save_entry, VFlowContainer.new())

func h_split_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, HSplitContainer.new())

func v_split_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, VSplitContainer.new())

func margin_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, MarginContainer.new())

func panel_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, PanelContainer.new())

func scroll_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, ScrollContainer.new())

func tab_container(save_entry: String = "") -> ConfigBuilder:
    return wrap(save_entry, TabContainer.new())

# TODO
func color_rect() -> ConfigBuilder:
    return add_node(ColorRect.new())

func h_separator() -> ConfigBuilder:
    return add_node(HSeparator.new())

func v_separator() -> ConfigBuilder:
    return add_node(VSeparator.new())

func label(text: String = "") -> ConfigBuilder:
    return add_node(Label.new()).with("text", text)

func nine_patch_rect() -> ConfigBuilder:
    return add_node(NinePatchRect.new())

func panel() -> ConfigBuilder:
    return add_node(Panel.new())

func reference_rect() -> ConfigBuilder:
    return add_node(ReferenceRect.new())

# TODO
func rich_text_label() -> ConfigBuilder:
    return add_node(RichTextLabel.new())

func texture_rect(texture: Texture) -> ConfigBuilder:
    return add_node(TextureRect.new()).with("texture", texture)

func build(should_load: bool = true) -> ConfigAgent:
    if should_load:
        _agent.load_cfg()
    _agent._build_config_access()
    return _agent

func get_agent() -> ConfigAgent:
    return _agent

func get_root() -> Control:
    return _root

static func _get_target(node: Control):
    if node.has_method("get_target"):
        return node.get_target()
    else:
        return node

class ConfigAgent:
    var _root: Control
    var _config_file: String
    var _dirty: bool = false
    var _config_access

    func _init(root: Control, config_file: String):
        _root = root
        _config_file = config_file
    
    func mark_dirty():
        _dirty = true
    
    func save_cfg(force: bool = false):
        if (not _dirty and not force):
            return
        _dirty = false
        var file = File.new()
        file.open(_config_file, File.WRITE)
        file.store_string(JSON.print(_root.save_cfg(), "\t"))
        file.close()
    
    func load_cfg():
        var file = File.new()
        if (not file.file_exists(_config_file)):
            save_cfg(true)
            return
        file.open(_config_file, File.READ)
        _root.load_cfg(JSON.parse(file.get_as_text()).result)
        _dirty = false
    
    func serialize():
        return _root.save_cfg()
    
    func _get(property: String):
        return _config_access.get(property)
    
    func _set(property: String, value):
        _config_access.set(property, value)
    
    func _get_property_list():
        return _config_access._get_property_list()
    
    func _build_config_access():
        _config_access = _root.get_config_access()

class WrappedControlConfigNode:
    extends MarginContainer

    var _parent_config_node
    var _save_entry: String
    var _target_node: Control
    var _flatten: bool = false

    func _init(save_entry: String, root_node: Control, target_node = null):
        add_constant_override("margin_right", 0)
        add_constant_override("margin_top", 0)
        add_constant_override("margin_left", 0)
        add_constant_override("margin_bottom", 0)
        _save_entry = save_entry
        add_child(root_node)
        root_node.owner = self
        if target_node == null:
            _target_node = root_node
        elif target_node is String:
            _target_node = root_node.get_node(target_node)
        else:
            _target_node = target_node

    func set_parent_config_node(parent):
        _parent_config_node = parent

    func get_target() -> Control:
        return _target_node
    
    func get_save_entry() -> String:
        return _save_entry
    
    func flatten(value: bool = true):
        _flatten = value
    
    func is_flattened():
        return _flatten
    
    func save_cfg(data = {}):
        for node in _target_node.get_children():
            if node.has_method("save_cfg"):
                if node.has_method("is_flattened") and node.is_flattened():
                    node.save_cfg(data)
                else:
                    data[node.get_save_entry()] = node.save_cfg()
        return data
    
    func load_cfg(data):
        if data == null or not data is Dictionary:
            data = {}
        for node in _target_node.get_children():
            if node.has_method("load_cfg"):
                if node.has_method("is_flattened") and node.is_flattened():
                    node.load_cfg(data)
                else:
                    data[node.get_save_entry()] = node.load_cfg(data[node.get_save_entry()] if data.has(node.get_save_entry()) else null)
    
    func get_config_access():
        return ForwardedDictionaryConfig.new(self, _target_node.get_children())
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class CheckButtonConfigNode:
    extends CheckButton

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_value: bool):
        _save_entry = save_entry
        set_pressed_no_signal(default_value)

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return pressed
    
    func load_cfg(data):
        if (data != null):
            set_pressed_no_signal(data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return pressed
    
    func set_config_value(value):
        set_pressed_no_signal(value)
    
    func _pressed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class CheckBoxConfigNode:
    extends CheckBox

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_value: bool):
        _save_entry = save_entry
        set_pressed_no_signal(default_value)

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return pressed
    
    func load_cfg(data):
        if (data != null):
            set_pressed_no_signal(data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return pressed
    
    func set_config_value(value):
        set_pressed_no_signal(value)
        mark_dirty()
    
    func _pressed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class HSliderConfigNode:
    extends HSlider

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return value
    
    func load_cfg(data):
        if (data != null):
            value = data
    
    func get_config_access():
        return self
    
    func get_config_value():
        return value
    
    func set_config_value(val):
        value = val
        mark_dirty()
    
    func _value_changed(_ignored: float):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class VSliderConfigNode:
    extends VSlider

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return value
    
    func load_cfg(data):
        if (data != null):
            value = data
    
    func get_config_access():
        return self
    
    func get_config_value():
        return value
    
    func set_config_value(val):
        value = val
        mark_dirty()
    
    func _value_changed(_ignored: float):
        mark_dirty()

    func mark_dirty():
        _parent_config_node.mark_dirty()

class SpinBoxConfigNode:
    extends SpinBox

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return value
    
    func load_cfg(data):
        if (data != null):
            value = data
    
    func get_config_access():
        return self
    
    func get_config_value():
        return value
    
    func set_config_value(val):
        value = val
        mark_dirty()
    
    func _value_changed(_ignored: float):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class ForwardedDictionaryConfig:
    var _entries: Dictionary = {}
    var _owner: Control

    func _init(owner: Control, nodes: Array):
        _owner = owner
        add_entries(nodes)
        
    
    func add_entries(nodes: Array):
        for node in nodes:
            if node.has_method("get_config_access"):
                if node.has_method("is_flattened") and node.is_flattened():
                    add_entries(_get_target(node).get_children())
                else:
                    _entries[node.get_save_entry()] = node.get_config_access()
    
    func _get(property: String):
        return _entries[property].get_config_value()
    
    func _set(property: String, value):
        _entries[property].set_config_value(value)
        _owner.mark_dirty()
    
    func _get_property_list():
        var props = []
        for name in _entries:
            props.append({"name": name, "type": typeof(_entries[name].get_config_value())})
        return props
    
    func get_config_value():
        return self
    
    static func _get_target(node: Control):
        if node.has_method("get_target"):
            return node.get_target()
        else:
            return node