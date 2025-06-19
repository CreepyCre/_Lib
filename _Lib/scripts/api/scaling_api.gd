class_name ScalingApi

const CLASS_NAME = "ScalingApi"
var LOGGER: Object

var _ui_scaling_agent: ScalingAgent = ScalingAgent.new()
var _picker_scaling_agent: ScalingAgent = ScalingAgent.new()
var _scale_slider: HSlider = HSlider.new()
var _picker_slider: HSlider = HSlider.new()

var _handled: Array = []

enum NodeType {
    TYPE_TOOLBAR
    TYPE_TOOLSET_BUTTON
    TYPE_HOTBAR_BUTTON
}

func _init(logger: Object, editor: CanvasLayer, enlarge_ui: bool):
    LOGGER = logger.for_class(self)

    # replace enlarge ui button
    var node_parent = editor.get_node("Windows/Preferences/Margins/VAlign/Interface")
    var node_enlarge_ui: Control = node_parent.get_node("EnlargeUI")
    node_enlarge_ui.hide()
    # TODO: make a UI builder akin to the config builder
    var hsplit = HBoxContainer.new()
    node_parent.add_child_below_node(node_enlarge_ui, hsplit)
    var hbox = HBoxContainer.new()
    hsplit.add_child(hbox)
    hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    var label = Label.new()
    hbox.add_child(label)
    label.text = "UI Scale: "

    var _scale_label: Label = Label.new()
    hbox.add_child(_scale_label)
    _scale_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _scale_label.align = Label.ALIGN_RIGHT

    hsplit.add_child(_scale_slider)
    _scale_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _scale_slider.size_flags_vertical = Control.SIZE_FILL
    _scale_slider.connect("value_changed", self, "update_scale_label", [_scale_label])


    var hsplit2 = HBoxContainer.new()
    node_parent.add_child_below_node(hsplit, hsplit2)
    hbox = HBoxContainer.new()
    hsplit2.add_child(hbox)
    hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL

    label = Label.new()
    hbox.add_child(label)
    label.text = "Picker Scale: "

    _scale_label = Label.new()
    hbox.add_child(_scale_label)
    _scale_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _scale_label.align = Label.ALIGN_RIGHT

    hsplit2.add_child(_picker_slider)
    _picker_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _picker_slider.size_flags_vertical = Control.SIZE_FILL
    _picker_slider.connect("value_changed", self, "update_scale_label", [_scale_label])




    var ui_scaler = funcref(self, "_mult_half") if enlarge_ui else funcref(self, "_mult")

    var menu_bar: Control = editor.get_node("VPartition/MenuBar")

    # fonts
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.default_font, 16))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Heading", "Fonts"), 20))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Title", "Fonts"), 24))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Subtitle", "Fonts"), 16))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Subelement", "Fonts"), 12))

    # BoxContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "BoxContainer"))
    # Button
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "Button"))
    # CheckBox
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "CheckBox"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "checked", "CheckBox"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "unchecked", "CheckBox"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "radio_checked", "CheckBox"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "radio_unchecked", "CheckBox"))
    # CheckButton
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "CheckButton"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "off", "CheckButton"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "on", "CheckButton"))
    # TODO: ColorPicker
    # TODO: ColorPickerButton
    # Dialogs
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "button_margin", "Dialogs"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "margin", "Dialogs"))
    # FileDialog
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "folder", "FileDialog"))
    # GridContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "GridContainer"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "vseparation", "GridContainer"))
    # HBoxContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "HBoxContainer"))
    # HSeparator
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "HSeparator"))
    # HSlider
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "grabber", "HSlider"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "grabber_highlight", "HSlider"))
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("slider", "HSlider"), "content_margin_top", 2))
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("slider", "HSlider"), "content_margin_bottom", 2))
    # HSplitContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "HSplitContainer"))
    # ItemList
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "ItemList"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "icon_margin", ""))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "vseparation", ""))
    # Label
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "line_spacing", "Label"))
    # LinkButton
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "underline_spacing", "LinkButton"))
    # MarginContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "margin_bottom", "MarginContainer"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "margin_left", "MarginContainer"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "margin_right", "MarginContainer"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "margin_top", "MarginContainer"))
    # MenuButton
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "MenuButton"))
    # OptionButton
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "arrow_margin", "OptionButton"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "OptionButton"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "arrow", "OptionButton"))
    # PopupMenu
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "PopupMenu"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "vseparation", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "checked", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "unchecked", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "radio_checked", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "radio_unchecked", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "submenu", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "visibility_hidden", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "visibility_visible", "PopupMenu"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "visibility_xray", "PopupMenu"))
    # SpinBox
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "updown", "SpinBox"))
    # TabContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "TabContainer"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "top_margin", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "decrement", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "decrement_highlight", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "increment", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "increment_highlight", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "menu", "TabContainer"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "menu_hl", "TabContainer"))
    # Tabs
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "Tabs"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "top_margin", "Tabs"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "close", "Tabs"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "decrement", "Tabs"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "decrement_highlight", "Tabs"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "increment", "Tabs"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "increment_highlight", "Tabs"))
    # TextEdit
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "line_spacing", "TextEdit"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "tab", "TextEdit"))
    # ToolButton
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "ToolButton"))
    # Tree
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "button_margin", "Tree"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "hseparation", "Tree"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "item_margin", "Tree"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "scroll_border", "Tree"))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "vseparation", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "checked", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "unchecked", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "arrow", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "arrow_collapsed", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "arrow_up", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "select_arrow", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "updown", "Tree"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "select_option", "Tree"))
    # VBoxContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "VBoxContainer"))
    # VSeparator
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "VSeparator"))
    # VSlider
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "grabber", "VSlider"))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "grabber_highlight", "VSlider"))
    # VSplitContainer
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "separation", "VSplitContainer"))
    # WindowDialog
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("panel", "WindowDialog"), "border_width_top", 28))
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("panel", "WindowDialog"), "expand_margin_top", 28))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "title_height", "WindowDialog", 28))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "close_h_ofs", "WindowDialog", 22))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "close_v_ofs", "WindowDialog", 22))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "close", "WindowDialog", "res://ui/icons2x/buttons/close.png", Vector2(16, 16)))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "close_highlight", "WindowDialog", "res://ui/icons2x/buttons/close.png", Vector2(16, 16)))

    # Hotbar
    var hotbar = editor.get_node_or_null("Floatbar/Hotbar/HotbarGrid")
    if hotbar != null:
        for child in hotbar.get_children():
            if _node_type(child) == NodeType.TYPE_HOTBAR_BUTTON:
                _hotbar_button(child)

    # WindowDialog scale
    for window in editor.Windows.values():
        _ui_scaling_agent.register(PropertyScaler.new(window, "rect_size", null, ui_scaler))
        _setup_window_scaling(window)
    _ui_scaling_agent.register(ThemeOverrideConstantScaler.new(editor.Windows["Help"].get_node("MarginContainer"), "margin_right"))
    _ui_scaling_agent.register(ThemeOverrideConstantScaler.new(editor.Windows["Help"].get_node("MarginContainer"), "margin_top"))
    _ui_scaling_agent.register(ThemeOverrideConstantScaler.new(editor.Windows["Help"].get_node("MarginContainer"), "margin_left"))
    _ui_scaling_agent.register(ThemeOverrideConstantScaler.new(editor.Windows["Help"].get_node("MarginContainer"), "margin_bottom"))
    _ui_scaling_agent.register(PropertyScaler.new(editor.Windows["Help"].get_node("MarginContainer/VBoxContainer/TextureRect/Version"), "rect_position"))

    # menu buttons
    _ui_scaling_agent.register(MenuBarScaler.new(menu_bar))
    for button in menu_bar.get_node("MenuAlign").get_children():
        if button is Button:
            if button.icon == null:
                continue
            var path = button.icon.resource_path
            if not "icons2x".is_subsequence_of(path):
                path = path.replace("icons", "icons2x")
            _ui_scaling_agent.register(ButtonIconScaler.new(button, path, Vector2(24, 24)))
    
    # floatbar
    _ui_scaling_agent.register(PropertyScaler.new(editor.get_node("Floatbar/Floatbar"), "rect_size", null, ui_scaler))
    var align = editor.get_node("Floatbar/Floatbar/Align")
    # simple Buttons
    for button in ["GuideToggle", "RulerToggle", "LevelDown", "LevelUp"]:
        _ui_scaling_agent.register(ButtonIconScaler.new(align.get_node(button)))
    # dropdowns
    for dropdown in ["ZoomOptions", "LevelOptions"]:
        _ui_scaling_agent.register(PropertyScaler.new(align.get_node(dropdown), "rect_min_size"))
        _ui_scaling_agent.register(PropertyIconScaler.new(align.get_node(dropdown + "/Icon"), "texture"))
    # checkbox
    for checkbox in ["GridToggle", "SnapToggle", "LightingToggle", "CompareToggle"]:
        var box = align.get_node(checkbox)
        _ui_scaling_agent.register(ThemeOverrideIconScaler.new(box, "checked"))
        _ui_scaling_agent.register(ThemeOverrideIconScaler.new(box, "unchecked"))
    _ui_scaling_agent.register(PropertyScaler.new(editor.get_node("Floatbar/Bottom"), "rect_min_size", null, ui_scaler))
    # controls
    _setup_control_scaling(editor, ui_scaler)
    _ui_scaling_agent.register(ToolsetScaler.new(editor.Toolset))
    
    for child in editor.Toolset.get_children():
        if _node_type(child) == NodeType.TYPE_TOOLSET_BUTTON:
            _toolset_button(child)

    for child in editor.Toolset.anchor.get_children():
        if _node_type(child) == NodeType.TYPE_TOOLBAR:
            _toolbar(child)

    editor.get_tree().connect("node_added", self, "_node_added")

    # all the object pickers
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["FloorShapeTool"].Controls["SmartTileId"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["FloorShapeTool"].Controls["WallTexture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["WallTool"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["PortalTool"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["CaveBrush"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["PatternShapeTool"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["RoofTool"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["TerrainBrush"].Controls["TerrainID"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["MaterialBrush"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["LightTool"].Controls["Texture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["MapSettings"].Controls["BuildingWear"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["SelectTool"].Controls["WallTexture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["SelectTool"].Controls["PortalTexture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["SelectTool"].Controls["PatternTexture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.Tools["SelectTool"].Controls["LightTexture"], "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.ObjectLibraryPanel.get_node("Margins/VAlign/ObjectsMenu"), "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.ObjectLibraryPanel, "rect_min_size", null, ui_scaler))
    _picker_scaling_agent.register(PropertyScaler.new(editor.PathLibraryPanel.get_node("Margins/VAlign/PathsMenu"), "icon_scale"))
    _picker_scaling_agent.register(PropertyScaler.new(editor.PathLibraryPanel, "rect_min_size", null, ui_scaler))

func _setup_control_scaling(node: Node, ui_scaler):
    for child in node:
        _setup_control_scaling(node, ui_scaler)
        if (child is OptionButton) or (child is SpinBox):
            _ui_scaling_agent.register(PropertyScaler.new(child, "rect_min_size", null, ui_scaler))

func _setup_window_scaling(node: Node):
    for child in node.get_children():
        _setup_window_scaling(child)
    if node is Control and node.rect_min_size:
        _ui_scaling_agent.register(PropertyScaler.new(node, "rect_min_size"))
    if node is Button and node.icon is Texture:
        _ui_scaling_agent.register(ButtonIconScaler.new(node))
    if node is TextureRect and node.texture is Texture:
        _ui_scaling_agent.register(PropertyIconScaler.new(node, "texture"))

func _toolset_button(node: Node):
    if node in _handled:
        return
    _handled.append(node)
    _ui_scaling_agent.register(PropertyScaler.new(node, "rect_min_size", Vector2(0, 48)))
    _ui_scaling_agent.register(SetScaler.new(funcref(node, "SetLabelOffset"), 48, node.label.rect_position.x))

func _toolbar(node: Node):
    if node in _handled:
        return
    _handled.append(node)
    _ui_scaling_agent.register(PropertyScaler.new(node, "rect_min_size", Vector2(225, 0)))

func _hotbar_button(node: Node):
    if node in _handled:
        return
    _handled.append(node)
    if node.icon != null:
        _ui_scaling_agent.register(ButtonIconScaler.new(node))
    

func _node_added(node: Node):
    match _node_type(node):
        NodeType.TYPE_TOOLBAR:
            _toolbar(node)
        NodeType.TYPE_TOOLSET_BUTTON:
            _toolset_button(node)
        NodeType.TYPE_HOTBAR_BUTTON:
            _hotbar_button(node)

func _node_type(node):
    if not (node is Node):
        return -1
    match _node_path_elements(node.get_path()):
        ["root", "Master", "Editor", "VPartition", "Panels", "Tools", "Anchor", var toolbar]:
            if _node_type(node.ToolsetButton) == NodeType.TYPE_TOOLSET_BUTTON:
                return NodeType.TYPE_TOOLBAR
        ["root", "Master", "Editor", "VPartition", "Panels", "Tools", "Anchor", "Toolset", var button]:
            if node.name.ends_with("ToolsetButton"):
                return NodeType.TYPE_TOOLSET_BUTTON
        ["root", "Master", "Editor", "Floatbar", "Hotbar", "HotbarGrid", var button]:
            if node is Button:
                return NodeType.TYPE_HOTBAR_BUTTON
    return -1

func _node_path_elements(path: NodePath) -> Array:
    var elements: Array = []
    for i in path.get_name_count():
        elements.append(path.get_name(i))
    return elements

func update_scale_label(value, scale_label):
    scale_label.text = "%4d%%" % (value * 100)

func get_ui_scaling_agent() -> ScalingAgent:
    return _ui_scaling_agent

func get_picker_scaling_agent() -> ScalingAgent:
    return _picker_scaling_agent

func _mult(value, scale):
    return value * scale

func _mult_half(value, scale):
    return value * scale / 2

func _unload():
    _ui_scaling_agent._unload()
    _picker_scaling_agent._unload()
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

class ScalingAgent:
    var _scale: float = 1
    var scalers: Array = []

    func register(scaler):
        scalers.append(scaler)
        scaler.call_func(_scale)
        return self
    
    func unregister(scaler) -> void:
        scalers.erase(scaler)

    func scale(new_scale: float) -> void:
        _scale = new_scale
        for scaler in scalers:
            if scaler.has_method("scale"):
                scaler.scale(new_scale)
            else:
                scaler.call_func(new_scale)

    func _unload():
        for scaler in scalers:
            if scaler.has_method("unload"):
                scaler.unload()

class ScalableImageTexture extends ImageTexture:
    var _default_size: Vector2

    func _init(texture, default_size = null):
        self.create_from_image(load(texture).get_data() if texture is String else texture.get_data())
        _default_size = self.get_size() if default_size == null else default_size

    func scale(new_scale):
        self.set_size_override(_default_size * new_scale)

class FontScaler:
    var _font: DynamicFont
    var _default_size: int
    var original_size: int
    var original_extra_spacing_top: int
    var original_extra_spacing_bottom: int

    func _init(font: DynamicFont, default_size = null):
        _font = font
        original_size = font.size
        original_extra_spacing_top = font.extra_spacing_top
        original_extra_spacing_bottom = font.extra_spacing_bottom
        _default_size = original_size if default_size == null else default_size
    
    func scale(new_scale):
        var font_size: int = int(round(_default_size * new_scale))
        _font.size = font_size
        var spacing = int(round(clamp(font_size, 0, 16) / 4 - 4))
        _font.extra_spacing_top = spacing
        _font.extra_spacing_bottom = spacing
        _font.update_changes()
    
    func unload():
        _font.size = original_size
        _font.update_changes()

class PropertyScaler:
    var _target: Object
    var _property: String
    var _default_value
    var _value_scaler
    var original_value

    func _init(target: Object, property: String, default_value = null, value_scaler = funcref(self, "_mult")):
        _target = target
        _property = property
        _value_scaler = value_scaler
        original_value = _target.get(property)
        _default_value = original_value if default_value == null else default_value
    
    func scale(new_scale):
        _target.set(_property, _value_scaler.call_func(_default_value, new_scale))
    
    func unload():
        _target.set(_property, original_value)
    
    func _mult(value, scale):
        return value * scale

class ThemeConstantScaler:
    var _theme: Theme
    var _name: String
    var _node_type: String
    var _default_value: int
    var original_value: int

    func _init(theme: Theme, name: String, node_type: String, default_value = null):
        _theme = theme
        _name = name
        _node_type = node_type
        original_value = theme.get_constant(name, node_type)
        _default_value = original_value if default_value == null else default_value
    
    func scale(new_scale):
        _theme.set_constant(_name, _node_type, int(round(_default_value * new_scale)))
    
    func unload():
        _theme.set_constant(_name, _node_type, original_value)

class ThemeIconScaler:
    var _theme: Theme
    var _name: String
    var _node_type: String
    var scalable_icon: ScalableImageTexture
    var original_icon: Texture

    func _init(theme: Theme, name: String, node_type: String, texture_path = null, default_icon_size = null):
        _theme = theme
        _name = name
        _node_type = node_type
        original_icon = theme.get_icon(name, node_type)
        if texture_path is Vector2:
            default_icon_size = texture_path
        scalable_icon = ScalableImageTexture.new(original_icon.resource_path if not (texture_path is String) else texture_path, original_icon.get_size() if default_icon_size == null else default_icon_size)
        theme.set_icon(name, node_type, scalable_icon)
    
    func scale(new_scale):
        scalable_icon.scale(new_scale)
    
    func unload():
        _theme.set_icon(_name, _node_type, original_icon)

class ThemeOverrideConstantScaler:
    var _control: Control
    var _name: String
    var _default_value: int
    var original_value: int

    func _init(control: Control, name: String, default_value = null):
        _control = control
        _name = name
        original_value = control.get_constant(name)
        _default_value = original_value if default_value == null else default_value

    func scale(new_scale):
        _control.add_constant_override(_name, int(round(_default_value * new_scale)))
    
    func unload():
        _control.add_constant_override(_name, original_value)

class ThemeOverrideIconScaler:
    var _control: Control
    var _name: String
    var scalable_icon: ScalableImageTexture
    var original_icon: Texture

    func _init(control: Control, name: String, texture_path = null, default_icon_size = null):
        _control = control
        _name = name
        original_icon = control.get_icon(name)
        if texture_path is Vector2:
            default_icon_size = texture_path
        scalable_icon = ScalableImageTexture.new(original_icon.resource_path if not (texture_path is String) else texture_path, original_icon.get_size() if default_icon_size == null else default_icon_size)
        control.add_icon_override(name, scalable_icon)
    
    func scale(new_scale):
        scalable_icon.scale(new_scale)
    
    func unload():
        if original_icon == null:
            _control.remove_icon_override(_name)
        else:
            _control.add_icon_override(_name, original_icon)
        

class MenuBarScaler:
    const TOTAL_Y_MARGIN = 8
    
    var _menu_bar: Control
    var original_size: Vector2

    var default_size: int = 32

    func _init(menu_bar):
        _menu_bar = menu_bar
        original_size = menu_bar.rect_size
    
    func scale(new_scale):
        _menu_bar.rect_min_size = Vector2(0, round((default_size - TOTAL_Y_MARGIN) * new_scale + TOTAL_Y_MARGIN))

    func unload():
        _menu_bar.rect_min_size = Vector2.ZERO
        _menu_bar.rect_size = original_size

class SetScaler:
    var _setter
    var _default_value
    var _original_value

    func _init(setter, default_value, original_value):
        _setter = setter
        _default_value = default_value
        _original_value = default_value if original_value == null else original_value
    
    func scale(new_scale):
        _setter.call_func(new_scale * _default_value)
    
    func unload():
        _setter.call_func(_original_value)

"""
class SetGetIconScaler:
    var _setter
    var _getter
    var original_icon: Texture
    var scalable_icon: ScalableImageTexture

    func _init(setter, getter, texture_path = null, default_icon_size = null):
        _setter = setter
        _getter = getter
        original_icon = getter.call_func()

        if texture_path is Vector2:
            default_icon_size = texture_path
        if not (texture_path is String):
            texture_path = original_icon.resource_path
        scalable_icon = ScalableImageTexture.new(texture_path, default_icon_size)
        _setter.call_func(scalable_icon)
    
    func scale(new_scale):
        scalable_icon.scale(new_scale)

    func unload():
        _setter.call_func(scalable_icon)
"""

class PropertyIconScaler:
    var _target
    var _property: String
    var original_icon: Texture
    var scalable_icon: ScalableImageTexture

    func _init(target, property, texture = null, default_icon_size = null):
        _target = target
        _property = property
        original_icon = target.get(property)

        if texture is Vector2:
            default_icon_size = texture
        scalable_icon = ScalableImageTexture.new(texture if texture is String else original_icon, default_icon_size)
        _target.set(_property, scalable_icon)
    
    func scale(new_scale):
        scalable_icon.scale(new_scale)

    func unload():
        _target.set(_property, original_icon)

class ButtonIconScaler:
    extends PropertyIconScaler

    func _init(button: Button, texture_path = null, default_icon_size = null).(button, "icon", texture_path, default_icon_size):
        pass

class ToolsetScaler:
    var _toolset
    var full_scaler: PropertyScaler
    var shrunk_scaler: PropertyScaler

    func _init(toolset):
        _toolset = toolset
        full_scaler = PropertyScaler.new(toolset, "buttonFullSize", 48)
        shrunk_scaler = PropertyScaler.new(toolset, "buttonShrunkSize", 32)
    
    func scale(new_scale):
        full_scaler.scale(new_scale)
        shrunk_scaler.scale(new_scale)
        if _toolset.IsShrunk:
            _toolset.rect_min_size = Vector2(_toolset.buttonShrunkSize, 0)
        else:
            _toolset.rect_min_size = Vector2(_toolset.buttonFullSize, 0)

# TODO: DELETE
"""
class MenuButtonXScaler:
    const TOTAL_X_MARGIN = 16

    var _button: Button
    var _default_icon_size: Vector2
    
    var original_icon = null
    var original_expand_icon: bool

    func _init(button: Button, default_icon_size = null, icon = null):
        _button = button
        if default_icon_size == null:
            _default_icon_size = _button.icon.get_size()
        else:
            _default_icon_size = default_icon_size

        if icon != null:
            original_icon = _button.icon
            _button.icon = icon
        original_expand_icon = _button.expand_icon
        _button.expand_icon = true

    func scale(new_scale):
        _button.rect_min_size = Vector2(round(_default_icon_size.x * new_scale + TOTAL_X_MARGIN + _button.get_font("font").get_string_size(_button.text).x), 0)

    func unload():
        if original_icon != null:
            _button.icon = original_icon
        _button.expand_icon = original_expand_icon
        _button.rect_min_size = Vector2.ZERO
"""