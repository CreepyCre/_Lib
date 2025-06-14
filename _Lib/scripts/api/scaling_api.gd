class_name ScalingApi

const CLASS_NAME = "ScalingApi"
var LOGGER: Object

var _ui_scaling_agent: ScalingAgent = ScalingAgent.new()
var _scale_slider: HSlider = HSlider.new()

func _init(logger: Object, editor: CanvasLayer, enlarge_ui: bool):
    LOGGER = logger.for_class(self)

    # replace enlarge ui button
    var node_parent = editor.get_node("Windows/Preferences/Margins/VAlign/Interface")
    var node_enlarge_ui: Control = node_parent.get_node("EnlargeUI")
    node_enlarge_ui.hide()
    # TODO: make a UI builder akin to the config builder
    var hbox = HBoxContainer.new()
    node_parent.add_child_below_node(node_enlarge_ui, hbox)

    var label = Label.new()
    hbox.add_child(label)
    label.text = "UI Scale: "

    var _scale_label: Label = Label.new()
    hbox.add_child(_scale_label)

    hbox.add_child(_scale_slider)
    _scale_slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _scale_slider.size_flags_vertical = Control.SIZE_FILL
    _scale_slider.min_value = 0.5
    _scale_slider.max_value = 4
    _scale_slider.step = 0.25
    _scale_slider.connect("value_changed", self, "update_scale_label", [_scale_label])

    var ui_scaler = funcref(self, "_mult_half") if enlarge_ui else funcref(self, "_mult")

    var menu_bar: Control = editor.get_node("VPartition/MenuBar")

    # fonts
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.default_font, 16))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Heading", "Fonts", 20)))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Title", "Fonts", 24)))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Subtitle", "Fonts", 16)))
    _ui_scaling_agent.register(FontScaler.new(Global.Theme.get_font("Subelement", "Fonts", 12)))
    # slidlers
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("slider", "HSlider"), "content_margin_top", 2))
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("slider", "HSlider"), "content_margin_bottom", 2))
    # WindowDialog
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("panel", "WindowDialog"), "border_width_top", 28))
    _ui_scaling_agent.register(PropertyScaler.new(Global.Theme.get_stylebox("panel", "WindowDialog"), "expand_margin_top", 28))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "title_height", "WindowDialog", 28))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "close_h_ofs", "WindowDialog", 22))
    _ui_scaling_agent.register(ThemeConstantScaler.new(Global.Theme, "close_v_ofs", "WindowDialog", 22))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "close", "WindowDialog", "res://ui/icons2x/buttons/close.png", Vector2(16, 16)))
    _ui_scaling_agent.register(ThemeIconScaler.new(Global.Theme, "close_highlight", "WindowDialog", "res://ui/icons2x/buttons/close.png", Vector2(16, 16)))

    # WindowDialog scale
    for window in editor.Windows.values():
        _ui_scaling_agent.register(PropertyScaler.new(window, "rect_size", null, ui_scaler))

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
    #checkbox
    for checkbox in ["GridToggle", "SnapToggle", "LightingToggle", "CompareToggle"]:
        var box = align.get_node(checkbox)
        _ui_scaling_agent.register(ThemeOverrideIconScaler.new(box, "checked"))
        _ui_scaling_agent.register(ThemeOverrideIconScaler.new(box, "unchecked"))
    _ui_scaling_agent.register(PropertyScaler.new(editor.get_node("Floatbar/Bottom"), "rect_min_size", null, ui_scaler))

func update_scale_label(value, scale_label):
    scale_label.text = value

func get_ui_scaling_agent() -> ScalingAgent:
    return _ui_scaling_agent

func _mult(value, scale):
    return value * scale

func _mult_half(value, scale):
    return value * scale / 2

func _unload():
    _ui_scaling_agent._unload()
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

    func _init(texture_path, default_size = null):
        self.create_from_image(load(texture_path).get_data())
        _default_size = self.get_size() if default_size == null else default_size

    func scale(new_scale):
        self.set_size_override(_default_size * new_scale)

class FontScaler:
    var _font: DynamicFont
    var _default_size: int
    var original_size: int

    func _init(font: DynamicFont, default_size = null):
        _font = font
        original_size = font.size
        _default_size = original_size if default_size == null else default_size
    
    func scale(new_scale):
        _font.size = int(round(original_size * new_scale))
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

    func _init(target, property, texture_path = null, default_icon_size = null):
        _target = target
        _property = property
        original_icon = target.get(property)

        if texture_path is Vector2:
            default_icon_size = texture_path
        if not (texture_path is String):
            texture_path = original_icon.resource_path
        scalable_icon = ScalableImageTexture.new(texture_path, default_icon_size)
        _target.set(_property, scalable_icon)
    
    func scale(new_scale):
        scalable_icon.scale(new_scale)

    func unload():
        _target.set(_property, original_icon)

    

class ButtonIconScaler:
    extends PropertyIconScaler

    func _init(button: Button, texture_path = null, default_icon_size = null).(button, "icon", texture_path, default_icon_size):
        pass

# TODO: DELETE
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