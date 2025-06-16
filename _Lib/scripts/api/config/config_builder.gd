class_name ConfigBuilder

var _agent: ConfigAgent
var _input_map_api
var _root: Control
var _node_stack: Array = []
var _current_node: Control
var _last_child_node: Control = null
var _references: Dictionary = {}

func _init(root: Control, config_file: String, input_map_api):
    _root = root
    _current_node = root
    _agent = ConfigAgent.new(_root, config_file)
    _input_map_api = input_map_api
    _root.set_parent_config_node(_agent)

func enter() -> ConfigBuilder:
    _node_stack.append(_current_node)
    _current_node = _last_child_node
    var children = _get_target(_last_child_node).get_children()
    _last_child_node = children.back() if children.size() > 0 else null
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

func size_flags_h(flags: int) -> ConfigBuilder:
    _last_child_node.size_flags_horizontal = flags
    return self

func size_flags_v(flags: int) -> ConfigBuilder:
    _last_child_node.size_flags_vertical = flags
    return self

func size_expand_fill() -> ConfigBuilder:
    return size_flags_h(Control.SIZE_EXPAND_FILL).size_flags_v(Control.SIZE_EXPAND_FILL)

func rect_min_size(min_size: Vector2) -> ConfigBuilder:
    _last_child_node.rect_min_size = min_size
    return self

func rect_min_x(min_x: float) -> ConfigBuilder:
    _last_child_node.rect_min_size = Vector2(min_x, _last_child_node.rect_min_size.y)
    return self

func rect_min_y(min_y: float) -> ConfigBuilder:
    _last_child_node.rect_min_size = Vector2(_last_child_node.rect_min_size.x, min_y)
    return self

func rect_size(size: Vector2) -> ConfigBuilder:
    _last_child_node.rect_min_size = size
    return self

func rect_x(x: float) -> ConfigBuilder:
    _last_child_node.rect_size = Vector2(x, _last_child_node.rect_size.y)
    return self

func rect_y(y: float) -> ConfigBuilder:
    _last_child_node.rect_size = Vector2(_last_child_node.rect_size.x, y)
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
    return _call_on(_last_child_node, method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)

func call_on_ref(reference_name: String, method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null) -> ConfigBuilder:
    var ref = _references[reference_name]
    if ref == null:
        return self
    else:
        return _call_on(ref, method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)

func _call_on(target, method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null) -> ConfigBuilder:
    if (arg9 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elif (arg8 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elif (arg7 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elif (arg6 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    elif (arg5 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4, arg5)
    elif (arg4 != null):
        target.call(method_name, arg0, arg1, arg2, arg3, arg4)
    elif (arg3 != null):
        target.call(method_name, arg0, arg1, arg2, arg3)
    elif (arg2 != null):
        target.call(method_name, arg0, arg1, arg2)
    elif (arg1 != null):
        target.call(method_name, arg0, arg1)
    elif (arg0 != null):
        target.call(method_name, arg0)
    else:
        target.call(method_name)
    return self

func connect_current(signal_name: String, target: Object, method_name: String, binds: Array = [], flags: int = 0) -> ConfigBuilder:
    _last_child_node.connect(signal_name, target, method_name, binds, flags)
    return self

func connect_ref(reference_name: String, signal_name: String, target: Object, method_name: String, binds: Array = [], flags: int = 0) -> ConfigBuilder:
    var ref = _references[reference_name]
    if ref != null:
        ref.connect(signal_name, target, method_name, binds, flags)
    return self

func connect_to_prop(signal_name: String, target, property: String) -> ConfigBuilder:
    _last_child_node.connect(signal_name, _agent, "_forward_prop", [target, property])
    return self

func connect_ref_to_prop(reference_name: String, signal_name: String, target, property: String) -> ConfigBuilder:
    var ref = _references[reference_name]
    if ref != null:
        ref.connect(signal_name, _agent, "_forward_prop", [target, property])
    return self

func add_color_override(name: String, color: Color) -> ConfigBuilder:
    _last_child_node.add_color_override(name, color)
    return self

func add_constant_override(name: String, constant: int) -> ConfigBuilder:
    _last_child_node.add_constant_override(name, constant)
    return self

func add_font_override(name: String, font: Font) -> ConfigBuilder:
    _last_child_node.add_font_override(name, font)
    return self

func add_icon_override(name: String, texture: Texture) -> ConfigBuilder:
    _last_child_node.add_icon_override(name, texture)
    return self

func add_shader_override(name: String, shader: Shader) -> ConfigBuilder:
    _last_child_node.add_shader_override(name, shader)
    return self

func add_stylebox_override(name: String, stylebox: StyleBox) -> ConfigBuilder:
    _last_child_node.add_stylebox_override(name, stylebox)
    return self

func wrap(save_entry: String, root_node: Control, target_node = null) -> ConfigBuilder:
    if (save_entry == ""):
        return add_node(WrappedControlConfigNode.new(save_entry, root_node, target_node)).flatten()
    else:
        return add_node(WrappedControlConfigNode.new(save_entry, root_node, target_node))

func extend(save_entry: String, node: Control) -> ConfigBuilder:
    if (save_entry == ""):
        return add_node(ContainerExtensionConfigNode.extend("", node)).flatten()
    else:
        return add_node(ContainerExtensionConfigNode.extend(save_entry, node))

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

func color_picker(save_entry: String, default_value: Color) -> ConfigBuilder:
    return add_node(ColorPickerConfigNode.new(save_entry, default_value))

func color_picker_button(save_entry: String, default_value: Color) -> ConfigBuilder:
    return add_node(ColorPickerButtonConfigNode.new(save_entry, default_value))

func option_button(save_entry: String, default_value: int, options: Array) -> ConfigBuilder:
    return add_node(OptionButtonConfigNode.new(save_entry, default_value, options))

func line_edit(save_entry: String, default_value: String, require_hit_enter: bool = true) -> ConfigBuilder:
    return add_node(LineEditConfigNode.new(save_entry, default_value, require_hit_enter))

func text_edit(save_entry: String, default_value: String) -> ConfigBuilder:
    return add_node(TextEditConfigNode.new(save_entry, default_value))

func shortcuts(save_entry: String, definitions: Dictionary) -> ConfigBuilder:
    return add_node(ShortcutsConfigNode.new(save_entry, definitions, _input_map_api))
    
func aspect_ratio_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, AspectRatioContainer.new())

func center_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, CenterContainer.new())

func h_box_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, HBoxContainer.new())

func v_box_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, VBoxContainer.new())

func grid_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, GridContainer.new())

#func h_flow_container(save_entry: String = "") -> ConfigBuilder:
#    return extend(save_entry, HFlowContainer.new())

#func v_flow_container(save_entry: String = "") -> ConfigBuilder:
#    return extend(save_entry, VFlowContainer.new())

func h_split_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, HSplitContainer.new())

func v_split_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, VSplitContainer.new())

func margin_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, MarginContainer.new())

func panel_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, PanelContainer.new())

func scroll_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, ScrollContainer.new())

func tab_container(save_entry: String = "") -> ConfigBuilder:
    return extend(save_entry, TabContainer.new())

func color_rect(color: Color) -> ConfigBuilder:
    return add_node(ColorRect.new()).with("color", color)

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

func rich_text_label(bbcode_text: String = "") -> ConfigBuilder:
    return add_node(RichTextLabel.new()).with("bbcode_enabled", true).with("bbcode_text", bbcode_text)

func texture_rect(texture: Texture) -> ConfigBuilder:
    return add_node(TextureRect.new()).with("texture", texture)

func build(should_load: bool = true, should_free: bool = true) -> ConfigAgent:
    if should_load:
        _agent.load_cfg()
    _agent._build_config_access()
    if should_free:
        self.call_deferred("free")
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
        var file: File = File.new()
        if (not file.file_exists(_config_file)):
            if _root.has_method("_on_preferences_about_to_show"):
                _root._on_preferences_about_to_show()
            var dir: Directory = Directory.new()
            var config_dir: String = _config_file.get_base_dir()
            if not dir.dir_exists(config_dir):
                dir.make_dir_recursive(config_dir)
            save_cfg(true)
            return
        file.open(_config_file, File.READ)
        _root.load_cfg(JSON.parse(file.get_as_text()).result)
        _dirty = false
    
    #func serialize():
    #    return _root.save_cfg()
    
    func _get(property: String):
        return _config_access.get(property)
    
    func _set(property: String, value):
        _config_access.set(property, value)
    
    func _get_property_list():
        return _config_access._get_property_list()
    
    func _build_config_access():
        _config_access = _root.get_config_access()
    
    func _forward_prop(value, target, key):
        target.set(key, value)

class ContainerExtensionConfigNode:
    extends Control

    var _parent_config_node
    var _save_entry: String
    var _flatten: bool = false

    static func extend(save_entry: String, node: Control) -> Control:
        node.set_script(ContainerExtensionConfigNode)
        node._save_entry = save_entry
        return node

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func flatten(value: bool = true):
        _flatten = value
    
    func is_flattened():
        return _flatten
    
    func save_cfg(data = {}):
        for node in get_children():
            if node.has_method("save_cfg"):
                if node.has_method("is_flattened") and node.is_flattened():
                    node.save_cfg(data)
                else:
                    data[node.get_save_entry()] = node.save_cfg()
        return data
    
    func load_cfg(data):
        if data == null or not data is Dictionary:
            data = {}
        for node in get_children():
            if node.has_method("load_cfg"):
                if node.has_method("is_flattened") and node.is_flattened():
                    node.load_cfg(data)
                else:
                    data[node.get_save_entry()] = node.load_cfg(data[node.get_save_entry()] if data.has(node.get_save_entry()) else null)
    
    func get_config_access():
        return ForwardedDictionaryConfig.new(self, get_children())
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        for node in get_children():
            if node.has_method("_on_preferences_about_to_show"):
                node._on_preferences_about_to_show()

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
    
    func _on_preferences_about_to_show():
        for node in _target_node.get_children():
            if node.has_method("_on_preferences_about_to_show"):
                node._on_preferences_about_to_show()

class CheckButtonConfigNode:
    extends CheckButton

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: bool

    func _init(save_entry: String, default_value: bool):
        _save_entry = save_entry
        set_pressed_no_signal(default_value)
        _cached_value = default_value

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != pressed):
            _cached_value = pressed
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            set_pressed_no_signal(data)
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(value):
        set_pressed_no_signal(value)
        _cached_value = value
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _pressed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        set_pressed_no_signal(_cached_value)

class CheckBoxConfigNode:
    extends CheckBox

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: bool

    func _init(save_entry: String, default_value: bool):
        _save_entry = save_entry
        set_pressed_no_signal(default_value)
        _cached_value = default_value

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != pressed):
            _cached_value = pressed
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            set_pressed_no_signal(data)
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(value):
        set_pressed_no_signal(value)
        _cached_value = value
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _pressed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        set_pressed_no_signal(_cached_value)

class HSliderConfigNode:
    extends HSlider

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: float

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        _cached_value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != value):
            _cached_value = value
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            value = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        value = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _value_changed(_ignored: float):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        value = _cached_value

class VSliderConfigNode:
    extends VSlider

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: float

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        _cached_value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != value):
            _cached_value = value
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            value = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        value = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _value_changed(_ignored: float):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        value = _cached_value

class SpinBoxConfigNode:
    extends SpinBox

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: float

    func _init(save_entry: String, default_value: float):
        _save_entry = save_entry
        value = default_value
        _cached_value = default_value
        connect("value_changed", self, "_value_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != value):
            _cached_value = value
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            value = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        value = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _value_changed(_ignored: float):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        value = _cached_value

class ColorPickerConfigNode:
    extends ColorPicker

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: Color

    func _init(save_entry: String, default_color: Color):
        _save_entry = save_entry
        color = default_color
        _cached_value = default_color
        connect("color_changed", self, "_color_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != color):
            _cached_value = color
            emit_signal("updated", _cached_value)
        return "#" + _cached_value.to_html()
    
    func load_cfg(data):
        if (data != null):
            color = Color(data.lstrip("#"))
            _cached_value = color
            emit_signal("loaded", color)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        color = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _color_changed(_ignored: Color):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        color = _cached_value

class ColorPickerButtonConfigNode:
    extends ColorPickerButton

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _picker: ColorPicker
    var _cached_value: Color

    func _init(save_entry: String, default_color: Color):
        _save_entry = save_entry
        _picker = get_picker()
        _picker.color = default_color
        _cached_value = default_color
        connect("color_changed", self, "_color_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != _picker.color):
            _cached_value = _picker.color
            emit_signal("updated", _cached_value)
        return "#" + _cached_value.to_html()
    
    func load_cfg(data):
        if (data != null):
            _picker.color = Color(data.lstrip("#"))
            _cached_value = _picker.color
            emit_signal("loaded", _picker.color)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        _picker.color = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _color_changed(_ignored: Color):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        _picker.color = _cached_value

class OptionButtonConfigNode:
    extends OptionButton

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: int
    var _label_to_index: Dictionary = {}

    func _init(save_entry: String, default_option: int, options: Array = []):
        _save_entry = save_entry
        for entry in options:
            var index = get_item_count()
            if entry is String:
                add_item(entry)
                set_item_metadata(index, entry)
                if not _label_to_index.has(entry):
                    _label_to_index[entry] = index
            elif entry is Dictionary:
                if entry.has("icon"):
                    add_icon_item(entry["icon"], entry["label"])
                else:
                    add_item(entry["label"])
                if entry.has("meta"):
                    set_item_metadata(index, entry["meta"])
                else:
                    set_item_metadata(index, entry["label"])
                if not _label_to_index.has(entry["label"]):
                    _label_to_index[entry["label"]] = index
        selected = default_option
        _cached_value = default_option
        connect("item_selected", self, "_item_selected")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != selected):
            _cached_value = selected
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            selected = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return get_item_metadata(_cached_value)
    
    func set_config_value(val):
        if val is int:
            selected = val
            _cached_value = val
        elif _label_to_index.has(val):
            var index: int = _label_to_index[val]
            selected = index
            _cached_value = index
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _item_selected(_ignored: int):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

    func _on_preferences_about_to_show():
        selected = _cached_value

class LineEditConfigNode:
    extends LineEdit

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _text: String
    var _cached_value: String

    func _init(save_entry: String, default_text: String, require_hit_enter: bool = true):
        _save_entry = save_entry
        text = default_text
        _text = default_text
        _cached_value = default_text
        if require_hit_enter:
            connect("text_entered", self, "_text_entered")
        else:
            connect("text_changed", self, "_text_entered")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != _text):
            _cached_value = _text
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            _text = data
            text = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        _text = val
        text = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _text_entered(new_text: String):
        _text = new_text
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

    func _on_preferences_about_to_show():
        text = _cached_value
        _text = _cached_value

class TextEditConfigNode:
    extends TextEdit

    signal loaded(value)
    signal updated(value)

    var _parent_config_node
    var _save_entry: String
    var _cached_value: String

    func _init(save_entry: String, default_text: String):
        _save_entry = save_entry
        text = default_text
        _cached_value = default_text
        connect("text_changed", self, "_text_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        if (_cached_value != text):
            _cached_value = text
            emit_signal("updated", _cached_value)
        return _cached_value
    
    func load_cfg(data):
        if (data != null):
            text = data
            _cached_value = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _cached_value
    
    func set_config_value(val):
        text = val
        _cached_value = val
        mark_dirty()
        emit_signal("updated", _cached_value)
    
    func _text_changed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _on_preferences_about_to_show():
        text = _cached_value

class ShortcutsConfigNode:
    extends Tree

    var _parent_config_node
    var _save_entry: String
    var _definitions: Dictionary
    var _blocker: Control = Control.new()
    var _input_map_api
    var _waiting_for_input: bool = false
    var _pressed_item: TreeItem = null
    var _action_to_item: Dictionary = {}
    var _busy: bool = false

    var _edit_icon: Texture
    var _add_icon: Texture
    var _remove_icon: Texture

    func _init(save_entry: String, definitions: Dictionary, input_map_api):
        var theme = load(ProjectSettings.get_setting("gui/theme/custom"))
        _edit_icon = theme.get_icon("Edit", "EditorIcons")
        _add_icon = theme.get_icon("Add", "EditorIcons")
        _remove_icon = theme.get_icon("Remove", "EditorIcons")

        _save_entry = save_entry
        _definitions = definitions
        _blocker.hide()
        add_child(_blocker)
        _blocker.owner = self
        _input_map_api = input_map_api

        set_hide_root(true)
        set_columns(4)
        set_column_title(0, "Action")
        set_column_title(1, "Key")
        set_column_expand(2, false)
        set_column_min_width(2, 28)
        set_column_expand(3, false)
        set_column_min_width(3, 28)
        set_column_titles_visible(true)
        connect("button_pressed", self, "_on_tree_button_pressed")

        _make_actions_save(definitions)

        input_map_api.connect("added_actions", self, "_added_actions")
        input_map_api.connect("erased_actions", self, "_erased_actions")
        
        

    func _make_actions_save(definitions):
        for key in definitions:
            var def = definitions[key]
            if def is Dictionary:
                _make_actions_save(def)
                continue
            if def is Array:
                def = def[0]
            _input_map_api.get_or_create_agent(def)._saved = true

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return _save_cfg(_definitions)
    
    func _save_cfg(definitions):
        var out: Dictionary = {}
        for key in definitions:
            var config_key: String = key.to_lower().replace(" ", "_")
            var def = definitions[key]
            if def is Dictionary:
                out[config_key] = _save_cfg(def)
                continue
            if def is Array:
                def = def[0]
            if not _action_to_item.has(def):
                continue
            var values: Array = []
            var item: TreeItem = _action_to_item[def]
            InputMap.action_erase_events(def)
            var event: InputEventKey = item.get_meta("event") if item.has_meta("event") else null
            if not event == null and not InputMap.action_has_event(def, event):
                InputMap.action_add_event(def, event)
                values.append(_serialize_event(event))
            item = item.get_children()
            while item != null:
                event = item.get_meta("event") if item.has_meta("event") else null
                if not event == null and not InputMap.action_has_event(def, event):
                    InputMap.action_add_event(def, event)
                    values.append(_serialize_event(event))
                item = item.get_next()
            out[config_key] = values
        return out
    
    func load_cfg(data):
        if data is Dictionary:
            _load_cfg(data, _definitions)
    
    func _load_cfg(data, definitions):
        for key in definitions:
            var config_key: String = key.to_lower().replace(" ", "_")
            if not data.has(config_key):
                continue
            var dat = data[config_key]
            var def = definitions[key]
            if def is Dictionary:
                if dat is Dictionary:
                    _load_cfg(dat, def)
                else:
                    continue
            if def is Array:
                def = def[0]
            if dat is String:
                InputMap.action_erase_events(def)
                InputMap.action_add_event(def, _deserialize_event(dat))
            elif dat is Array:
                InputMap.action_erase_events(def)
                for event in dat:
                    InputMap.action_add_event(def, _deserialize_event(event))
            
    func _deserialize_event(string: String) -> InputEventKey:
        var codes: Array = string.to_lower().split("+")
        var event: InputEventKey = InputEventKey.new()
        var key_string = codes.pop_back()
        var alt: int = KEY_MASK_ALT if codes.has("alt") else 0
        var ctrl: int = KEY_MASK_CTRL if codes.has("ctrl") else 0
        var cmd: int = KEY_MASK_META if codes.has("cmd") else 0
        var shift: int = KEY_MASK_SHIFT if codes.has("shift") else 0
        var key: int = int(key_string) if key_string.is_valid_integer() else OS.find_scancode_from_string(key_string.capitalize())
        event.set_scancode(alt + ctrl + cmd + shift + key)
        return event
    
    func _serialize_event(event: InputEventKey) -> String:
        var code: int = event.get_scancode_with_modifiers()
        return ("Alt+" if code & KEY_MASK_ALT != 0 else "")\
            + ("Ctrl+" if code & KEY_MASK_CTRL != 0 else "")\
            + ("Cmd+" if code & KEY_MASK_META != 0 else "")\
            + ("Shift+" if code & KEY_MASK_SHIFT != 0 else "")\
            + str(code & KEY_CODE_MASK)


    func _event_as_string(event: InputEventKey) -> String:
        if (event == null):
            return ""
        var code: int = event.get_scancode_with_modifiers()
        return ("Alt+" if code & KEY_MASK_ALT != 0 else "")\
            + ("Ctrl+" if code & KEY_MASK_CTRL != 0 else "")\
            + ("Cmd+" if code & KEY_MASK_META != 0 else "")\
            + ("Shift+" if code & KEY_MASK_SHIFT != 0 else "")\
            + OS.get_scancode_string(code & KEY_CODE_MASK)


    func mark_dirty():
        _parent_config_node.mark_dirty()
    
    func _added_actions(_actions: Array):
        _make_actions_save(_definitions)
        _rebuild_tree()

    # TODO: use signal form ConfigSyncAgent instead
    func _erased_actions(actions: Array):
        for action in actions:
            if action in _action_to_item:
                _rebuild_tree()
                return
    
    func _on_preferences_about_to_show():
        _rebuild_tree()

    func _rebuild_tree():
        clear()
        for action in _action_to_item:
            var agent = _input_map_api.get_or_create_agent(action)
            agent.disconnect("switched", self, "_switched")
            agent.disconnect("added", self, "_added_item")
            agent.disconnect("deleted", self, "_deleted_item")
        _action_to_item.clear()
        var root: TreeItem = create_item()
        _add_actions_to_tree(root, _definitions)

    func _add_actions_to_tree(root: TreeItem, actions: Dictionary):
        for name in actions:
            var entry = actions[name]
            if entry is Dictionary:
                var category: TreeItem = create_item(root)
                category.set_text(0, name)
                category.set_selectable(0, false)
                category.set_selectable(1, false)
                category.set_selectable(2, false)
                category.set_selectable(3, false)
                _add_actions_to_tree(category, entry)
            else:
                if entry is Array:
                    entry = entry[0]
                var agent = _input_map_api.get_agent(entry)
                var action_list: Array = InputMap.get_action_list(entry).duplicate()
    
                var action_item: TreeItem = create_item(root)
                agent.connect("switched", self, "_switched", [action_item])
                agent.connect("added", self, "_added_item", [action_item])
                agent.connect("deleted", self, "_deleted_item", [action_item])
                _action_to_item[entry] = action_item
                action_item.set_meta("agent", agent)
                action_item.set_meta("index", 0)
                action_item.set_text(0, name)
                action_item.set_selectable(0, false)
                action_item.set_selectable(1, false)
                if action_list.size() == 0:
                    action_item.set_meta("event", null)
                    if agent.is_saved():
                        action_item.add_button(2, _edit_icon)
                    else:
                        action_item.set_selectable(2, false)
                    action_item.set_selectable(3, false)
                else:
                    var first_event = action_list.pop_front()
                    action_item.set_meta("event", first_event)
                    action_item.set_text(1, _event_as_string(first_event))
                    if agent.is_saved():
                        action_item.add_button(2, _edit_icon)
                        action_item.add_button(3, _add_icon, 0)
                    else:
                        action_item.set_selectable(2, false)
                        action_item.set_selectable(3, false)
                    var index: int = 1
                    for event in action_list:
                        var event_item: TreeItem = create_item(action_item)
                        # probably want to move the agent.clear() to somewhere that is called when closing the preferences window
                        agent.clear()
                        event_item.set_meta("agent", agent)
                        event_item.set_meta("index", index)
                        event_item.set_meta("event", event)
                        event_item.set_selectable(0, false)
                        event_item.set_text(1, _event_as_string(event))
                        event_item.set_selectable(1, false)
                        if agent.is_saved():
                            event_item.add_button(2, _edit_icon)
                            event_item.add_button(3, _remove_icon)
                        else:
                            event_item.set_selectable(2, false)
                            event_item.set_selectable(3, false)
                        index += 1
    
    func _switched(from, to, index: int, item: TreeItem):
        if _busy:
            return
        mark_dirty()
        if index == 0:
            item.set_text(1, _event_as_string(to))
            item.set_meta("event", to)
            if from == null and to != null:
                item.set_selectable(3, true)
                item.add_button(3, _add_icon, 0)
            if from != null and to == null:
                item.set_selectable(3, false)
                item.erase_button(3, 0)
        else:
            var sub_item: TreeItem = item.get_children()
            while sub_item != null:
                if sub_item.get_meta("index") == index:
                    sub_item.set_text(1, _event_as_string(to))
                    sub_item.set_meta("event", to)
                    break
                sub_item = sub_item.get_next()

    func _on_tree_button_pressed(item: TreeItem, column: int, id: int):
        var agent = item.get_meta("agent")
        if column == 2:
            _pressed_item = item
            _waiting_for_input = true
            item.set_selectable(1, true)
            item.select(1)
            item.set_text(1, "--- press new shortcut key ---")
        elif column == 3:
            _busy = true
            var index: int = item.get_meta("index")
            if index == 0:
                item.set_collapsed(false)
                var new_item: TreeItem = create_item(item)
                new_item.set_meta("agent", agent)
                new_item.set_selectable(0, false)
                new_item.set_selectable(1, true)
                new_item.select(1)
                new_item.set_text(1, "--- press new shortcut key ---")
                new_item.add_button(2, _edit_icon)
                new_item.add_button(3, _remove_icon)
                var child_item: TreeItem = item.get_children()
                var new_index = 1
                while child_item != null:
                    new_index += 1
                    child_item = child_item.get_next()
                new_item.set_meta("index", new_index)
                agent.added_item()
                _pressed_item = new_item
                _waiting_for_input = true
            else:
                var child_item: TreeItem = item.get_next()
                item.free()
                var next_index = index + 1
                while child_item != null:
                    child_item.set_meta("index", next_index)
                    next_index += 1
                    child_item = child_item.get_next()
                agent.deleted_item(index)
            _busy = false
    
    func _added_item(root: TreeItem):
        var agent = root.get_meta("agent")
        if _busy:
            return
        var new_item: TreeItem = create_item(root)
        new_item.set_meta("agent", agent)
        new_item.set_selectable(0, false)
        new_item.set_selectable(1, false)
        new_item.add_button(2, _edit_icon)
        new_item.add_button(3, _remove_icon)
        var child_item: TreeItem = root.get_children()
        var new_index = 1
        while child_item != null:
            new_index += 1
            child_item = child_item.get_next()
        new_item.set_meta("index", new_index)

    func _deleted_item(index: int, root: TreeItem):
        if _busy:
            return
        var item = root.get_children()
        while (item != null and item.get_meta("index") != index):
            item = item.get_next()
        if (item == null):
            return
        var child_item: TreeItem = item.get_next()
        item.free()
        var next_index = index + 1
        while child_item != null:
            child_item.set_meta("index", next_index)
            next_index += 1
            child_item = child_item.get_next()
    
    func _input(event: InputEvent):
        if (_waiting_for_input and event is InputEventMouseButton and event.doubleclick and event.button_index == BUTTON_RIGHT):
            _switch_event(null)
            get_tree().set_input_as_handled()

    func _unhandled_key_input(event: InputEventKey):
        if (_waiting_for_input and not event.is_pressed()):
            _switch_event(event)
            get_tree().set_input_as_handled()
    
    func _switch_event(event):
        _busy = true
        _pressed_item.set_selectable(1, false)
        _pressed_item.deselect(1)
        _pressed_item.set_text(1, _event_as_string(event))
        _waiting_for_input = false
        var agent = _pressed_item.get_meta("agent")
        var prev_event = _pressed_item.get_meta("event") if _pressed_item.has_meta("event") else null
        if event != null:
            event.pressed = true
        _pressed_item.set_meta("event", event)
        var index: int = _pressed_item.get_meta("index")
        agent.switch(prev_event, event, index)
        if prev_event == null and event != null and index == 0:
            _pressed_item.set_selectable(3, true)
            _pressed_item.add_button(3, _add_icon, 0)
        if prev_event != null and event == null and index == 0:
            _pressed_item.set_selectable(3, false)
            _pressed_item.erase_button(3, 0)
        mark_dirty()
        _busy = false


class ForwardedDictionaryConfig:
    var __entries: Dictionary = {}
    var __nodes: Dictionary = {}
    var __owner: Control

    func _init(owner: Control, nodes: Array):
        __owner = owner
        add_entries(nodes)
    
    func add_entries(nodes: Array):
        for node in nodes:
            if node.has_method("get_config_access"):
                if node.has_method("is_flattened") and node.is_flattened():
                    add_entries(_get_target(node).get_children())
                else:
                    __entries[node.get_save_entry()] = node.get_config_access()
                    # allows users to access a node corresponding to a config entry directly be using _<save_entry>
                    # intended for connecting to signals
                    __nodes["_" + node.get_save_entry()] = node
    
    func _get(property: String):
        if __entries.has(property):
            return __entries[property].get_config_value()
        else:
            return __nodes[property]
    
    func _set(property: String, value):
        __entries[property].set_config_value(value)
        __owner.mark_dirty()
    
    func _get_property_list():
        var props = []
        for name in __entries:
            props.append({"name": name, "type": typeof(__entries[name].get_config_value())})
        return props
    
    func get_config_value():
        return self
    
    static func _get_target(node: Control):
        if node.has_method("get_target"):
            return node.get_target()
        else:
            return node