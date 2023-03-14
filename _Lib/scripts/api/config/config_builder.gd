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
    var wrapped = WrappedControlConfigNode.new("", mod_config, "ConfigPanel/ScrollContainer/Config")
    wrapped.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wrapped.size_flags_vertical = Control.SIZE_EXPAND_FILL
    return self_script.new(wrapped, config_file)

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

func rect_size(min_size: Vector2) -> ConfigBuilder:
    _last_child_node.rect_min_size = min_size
    return self

func rect_x(min_x: float) -> ConfigBuilder:
    _last_child_node.rect_size = Vector2(min_x, _last_child_node.rect_size.y)
    return self

func rect_y(min_y: float) -> ConfigBuilder:
    _last_child_node.rect_size = Vector2(_last_child_node.rect_size.x, min_y)
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

func connect_ref(reference_name:String, signal_name: String, target: Object, method_name: String, binds: Array = [], flags: int = 0) -> ConfigBuilder:
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
        return add_node(ContainerExtensionConfigNode.extend(save_entry, node)).flatten()
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

    signal loaded(value)

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
            emit_signal("loaded", data)
    
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

    signal loaded(value)

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
            emit_signal("loaded", data)
    
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

    signal loaded(value)

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
            emit_signal("loaded", data)
    
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

    signal loaded(value)

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
            emit_signal("loaded", data)
    
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

    signal loaded(value)

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
            emit_signal("loaded", data)
    
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

class ColorPickerConfigNode:
    extends ColorPicker

    signal loaded(value)

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_color: Color):
        _save_entry = save_entry
        color = default_color
        connect("color_changed", self, "_color_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return "#" + color.to_html()
    
    func load_cfg(data):
        if (data != null):
            color = Color(data.lstrip("#"))
            emit_signal("loaded", color)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return color
    
    func set_config_value(val):
        color = val
        mark_dirty()
    
    func _color_changed(_ignored: Color):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class ColorPickerButtonConfigNode:
    extends ColorPickerButton

    signal loaded(value)

    var _parent_config_node
    var _save_entry: String
    var _picker: ColorPicker

    func _init(save_entry: String, default_color: Color):
        _save_entry = save_entry
        _picker = get_picker()
        _picker.color = default_color
        connect("color_changed", self, "_color_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return "#" + _picker.color.to_html()
    
    func load_cfg(data):
        if (data != null):
            _picker.color = Color(data.lstrip("#"))
            emit_signal("loaded", _picker.color)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _picker.color
    
    func set_config_value(val):
        _picker.color = val
        mark_dirty()
    
    func _color_changed(_ignored: Color):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class OptionButtonConfigNode:
    extends OptionButton

    signal loaded(value)

    var _parent_config_node
    var _save_entry: String
    var _label_to_index: Dictionary = {}

    func _init(save_entry: String, default_option: int, options: Array = []):
        _save_entry = save_entry
        for entry in options:
            var index = get_item_count()
            if entry is String:
                add_item(entry)
                set_item_metadata(index, entry)
            elif entry is Dictionary:
                if entry.has("icon"):
                    add_icon_item(entry["icon"], entry["label"])
                    if not _label_to_index.has(entry["label"]):
                        _label_to_index[entry["label"]] = index
                else:
                    add_item(entry["label"])
                if entry.has("meta"):
                    set_item_metadata(index, entry["meta"])
                else:
                    set_item_metadata(index, entry["label"])
                if not _label_to_index.has(entry["label"]):
                    _label_to_index[entry["label"]] = index
        selected = default_option
        connect("item_selected", self, "_item_selected")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return selected
    
    func load_cfg(data):
        if (data != null):
            selected = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return get_item_metadata(selected)
    
    func set_config_value(val):
        if _label_to_index.has(val):
            selected = _label_to_index["val"]
            mark_dirty()
    
    func _item_selected(_ignored: int):
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class LineEditConfigNode:
    extends LineEdit

    signal loaded(value)

    var _parent_config_node
    var _save_entry: String
    var _text: String

    func _init(save_entry: String, default_text: String, require_hit_enter: bool = true):
        _save_entry = save_entry
        text = default_text
        _text = default_text
        if require_hit_enter:
            connect("text_entered", self, "_text_entered")
        else:
            connect("text_changed", self, "_text_entered")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return _text
    
    func load_cfg(data):
        if (data != null):
            _text = data
            text = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return _text
    
    func set_config_value(val):
        _text = val
        text = val
        mark_dirty()
    
    func _text_entered(new_text: String):
        _text = new_text
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

class TextEditConfigNode:
    extends TextEdit

    signal loaded(value)

    var _parent_config_node
    var _save_entry: String

    func _init(save_entry: String, default_text: String):
        _save_entry = save_entry
        text = default_text
        connect("text_changed", self, "_text_changed")

    func set_parent_config_node(parent):
        _parent_config_node = parent
    
    func get_save_entry() -> String:
        return _save_entry
    
    func save_cfg():
        return text
    
    func load_cfg(data):
        if (data != null):
            text = data
            emit_signal("loaded", data)
    
    func get_config_access():
        return self
    
    func get_config_value():
        return text
    
    func set_config_value(val):
        text = val
        mark_dirty()
    
    func _text_changed():
        mark_dirty()
    
    func mark_dirty():
        _parent_config_node.mark_dirty()

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