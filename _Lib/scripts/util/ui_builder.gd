class_name UiBuilder

var _root: Control
var _node_stack: Array = []
var _current_node: Control
var _last_child_node: Control = null
var _references: Dictionary = {}

var _property_forwarder: PropertyForwarder = PropertyForwarder.new()

func _init(root = null):
    _root = root
    _current_node = root

func target_child_node(node: Control): # -> Self
    _last_child_node = node
    return self

func enter(): # -> Self
    _node_stack.append(_current_node)
    _current_node = _last_child_node
    var children = _last_child_node.get_children()
    _last_child_node = children.back() if children.size() > 0 else null
    return self

func exit(): # -> Self
    _last_child_node = _current_node
    _current_node = _node_stack.pop_back()
    return self

func add_node(node: Control, legible_unique_name: bool = false): # -> Self
    if _last_child_node != null:
        _current_node.add_child_below_node(_last_child_node, node, legible_unique_name)
    else:
        _current_node.add_child(node, legible_unique_name)
    _last_child_node = node
    return self

func with(property: String, value): # -> Self
    _last_child_node.set(property, value)
    return self

func size_flags_h(flags: int): # -> Self
    _last_child_node.size_flags_horizontal = flags
    return self

func size_flags_v(flags: int): # -> Self
    _last_child_node.size_flags_vertical = flags
    return self

func size_expand_fill(): # -> Self
    return size_flags_h(Control.SIZE_EXPAND_FILL).size_flags_v(Control.SIZE_EXPAND_FILL)

func rect_min_size(min_size: Vector2): # -> Self
    _last_child_node.rect_min_size = min_size
    return self

func rect_min_x(min_x: float): # -> Self
    _last_child_node.rect_min_size = Vector2(min_x, _last_child_node.rect_min_size.y)
    return self

func rect_min_y(min_y: float): # -> Self
    _last_child_node.rect_min_size = Vector2(_last_child_node.rect_min_size.x, min_y)
    return self

func rect_size(size: Vector2): # -> Self
    _last_child_node.rect_min_size = size
    return self

func rect_x(x: float): # -> Self
    _last_child_node.rect_size = Vector2(x, _last_child_node.rect_size.y)
    return self

func rect_y(y: float): # -> Self
    _last_child_node.rect_size = Vector2(_last_child_node.rect_size.x, y)
    return self

func get_current() -> Control:
    return _last_child_node

func ref(reference_name: String): # -> Self
    _references[reference_name] = _last_child_node
    return self

func get_ref(reference_name: String) -> Control:
    return _references[reference_name]

func call_on(method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null): # -> Self
    return _call_on(_last_child_node, method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)

func call_on_ref(reference_name: String, method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null): # -> Self
    var ref = _references[reference_name]
    if ref == null:
        return self
    else:
        return _call_on(ref, method_name, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)

func _call_on(target, method_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null): # -> Self
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

func connect_current(signal_name: String, target: Object, method_name: String, binds: Array = [], flags: int = 0): # -> Self
    _last_child_node.connect(signal_name, target, method_name, binds, flags)
    return self

func connect_ref(reference_name: String, signal_name: String, target: Object, method_name: String, binds: Array = [], flags: int = 0): # -> Self
    var ref = _references[reference_name]
    if ref != null:
        ref.connect(signal_name, target, method_name, binds, flags)
    return self

func connect_to_prop(signal_name: String, target, property: String): # -> Self
    _last_child_node.connect(signal_name, _property_forwarder, "_forward_prop", [target, property])
    return self

func connect_ref_to_prop(reference_name: String, signal_name: String, target, property: String): # -> Self
    var ref = _references[reference_name]
    if ref != null:
        ref.connect(signal_name, _property_forwarder, "_forward_prop", [target, property])
    return self

func add_color_override(name: String, color: Color): # -> Self
    _last_child_node.add_color_override(name, color)
    return self

func add_constant_override(name: String, constant: int): # -> Self
    _last_child_node.add_constant_override(name, constant)
    return self

func add_font_override(name: String, font: Font): # -> Self
    _last_child_node.add_font_override(name, font)
    return self

func add_icon_override(name: String, texture: Texture): # -> Self
    _last_child_node.add_icon_override(name, texture)
    return self

func add_shader_override(name: String, shader: Shader): # -> Self
    _last_child_node.add_shader_override(name, shader)
    return self

func add_stylebox_override(name: String, stylebox: StyleBox): # -> Self
    _last_child_node.add_stylebox_override(name, stylebox)
    return self

func check_button(text: String = ""): # -> Self
    return add_node(CheckButton.new()).with("text", text)

func check_box(text: String = ""): # -> Self
    return add_node(CheckBox.new()).with("text", text)

func h_slider(): # -> Self
    return add_node(HSlider.new())

func v_slider(): # -> Self
    return add_node(VSlider.new())

func spin_box(): # -> Self
    return add_node(SpinBox.new())

func color_picker(): # -> Self
    return add_node(ColorPicker.new())

func color_picker_button(): # -> Self
    return add_node(ColorPickerButton.new())

func option_button(options: Array): # -> Self
    var optionButton: OptionButton = OptionButton.new()
    for entry in options:
        var index = optionButton.get_item_count()
        if entry is String:
            optionButton.add_item(entry)
            optionButton.set_item_metadata(index, entry)
        elif entry is Dictionary:
            if entry.has("icon"):
                optionButton.add_icon_item(entry["icon"], entry["label"])
            else:
                optionButton.add_item(entry["label"])
            if entry.has("meta"):
                optionButton.set_item_metadata(index, entry["meta"])
            else:
                optionButton.set_item_metadata(index, entry["label"])
    return add_node(optionButton)

func line_edit(): # -> Self
    return add_node(LineEdit.new())

func text_edit(): # -> Self
    return add_node(TextEdit.new())
    
func aspect_ratio_container(): # -> Self
    return add_node(AspectRatioContainer.new())

func center_container(): # -> Self
    return add_node(CenterContainer.new())

func h_box_container(): # -> Self
    return add_node(HBoxContainer.new())

func v_box_container(): # -> Self
    return add_node(VBoxContainer.new())

func grid_container(): # -> Self
    return add_node(GridContainer.new())

#func h_flow_container(): # -> Self
#    return add_node(HFlowContainer.new())

#func v_flow_container(): # -> Self
#    return add_node(VFlowContainer.new())

func h_split_container(): # -> Self
    return add_node(HSplitContainer.new())

func v_split_container(): # -> Self
    return add_node(VSplitContainer.new())

func margin_container(): # -> Self
    return add_node(MarginContainer.new())

func panel_container(): # -> Self
    return add_node(PanelContainer.new())

func scroll_container(): # -> Self
    return add_node(ScrollContainer.new())

func tab_container(): # -> Self
    return add_node(TabContainer.new())

func color_rect(color: Color): # -> Self
    return add_node(ColorRect.new()).with("color", color)

func h_separator(): # -> Self
    return add_node(HSeparator.new())

func v_separator(): # -> Self
    return add_node(VSeparator.new())

func label(text: String = ""): # -> Self
    return add_node(Label.new()).with("text", text)

func nine_patch_rect(): # -> Self
    return add_node(NinePatchRect.new())

func panel(): # -> Self
    return add_node(Panel.new())

func reference_rect(): # -> Self
    return add_node(ReferenceRect.new())

func rich_text_label(bbcode_text: String = ""): # -> Self
    return add_node(RichTextLabel.new()).with("bbcode_enabled", true).with("bbcode_text", bbcode_text)

func texture_rect(texture: Texture): # -> Self
    return add_node(TextureRect.new()).with("texture", texture)

func build(should_free: bool = true) -> Control:
    if should_free:
        self.call_deferred("free")
    return _root

func get_root() -> Control:
    return _root

class PropertyForwarder:
    func _forward_prop(value, target, key):
        target.set(key, value)