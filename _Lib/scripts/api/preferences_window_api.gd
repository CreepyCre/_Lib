class_name PreferencesWindowApi

class ScalingAgent: const import = "api/scaling_api.gd/ScalingAgent"
class PropertyScaler: const import = "api/scaling_api.gd/PropertyScaler"

const CLASS_NAME = "PreferencesWindowApi"
var LOGGER: Object

var _preferences: WindowDialog
var _v_align: VBoxContainer
var _category_button_h_align: HBoxContainer
var _general: VBoxContainer
var _general_button: Button
var _interface: VBoxContainer
var _interface_button: Button
var _shortcuts: VBoxContainer
var _shortcuts_button: Button
var _buttons: HBoxContainer
var _apply_button: Button
var _close_button: Button
var _back_button: Button

var _categories: Array = []
var _current_category = null

signal back_pressed()
signal apply_pressed()
signal about_to_show()

func _init(logger: Object, _pref: WindowDialog, ui_scaling_agent: ScalingAgent):
    LOGGER = logger.for_class(self)
    # get all them nodes
    _preferences = _pref
    _v_align = _preferences.get_node("Margins/VAlign")
    _category_button_h_align = _v_align.get_node("HAlign")
    _general = _v_align.get_node("General")
    _general_button = _category_button_h_align.get_node("GeneralButton")
    _interface = _v_align.get_node("Interface")
    _interface_button = _category_button_h_align.get_node("InterfaceButton")
    _shortcuts = _v_align.get_node("Shortcuts")
    _shortcuts_button = _category_button_h_align.get_node("ShortcutsButton")
    _buttons = _v_align.get_node("Buttons")
    _apply_button = _buttons.get_node("SaveButton")
    _close_button = _buttons.get_node("CloseButton")

    _apply_button.connect("pressed", self, "_apply_pressed")

    # homebrew back button; it replaces the preferences window close button based on context
    _back_button = Button.new()
    _back_button.text = "Back"
    _back_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _back_button.rect_min_size = _close_button.rect_min_size
    _back_button.hide()
    _back_button.connect("pressed", self, "_back_pressed")
    _buttons.add_child(_back_button)
    _back_button.owner = _buttons

    # ensure buttons scale correctly
    ui_scaling_agent.register(PropertyScaler._new(_back_button, "rect_min_size"))

    # make default buttons call _category_pressed
    _general_button.connect("pressed", self, "_category_pressed")
    _interface_button.connect("pressed", self, "_category_pressed")
    _shortcuts_button.connect("pressed", self, "_category_pressed")

    # reroute about_to_show signal to own _on_preferences_about_to_show method
    _preferences.disconnect("about_to_show", _preferences, "_on_Preferences_about_to_show")
    _preferences.connect("about_to_show", self, "_on_preferences_about_to_show")


## https://creepycre.github.io/_Lib/PreferencesWindowApi/#create_category
## use provided category container or _create_default_container()
func create_category(name: String, container: Control = _create_default_container()) -> Control:
    # create button for category
    var id: int = _categories.size()
    var button: Button = _create_button(id, name)
    _category_button_h_align.add_child(button)
    container.button = _category_button_h_align

    # add back_pressed signal to container and add category to _categories
    container.add_user_signal("back_pressed", [])
    _categories.append({"button": button, "container": container, "show_back": false})

    # put container into preferences window
    _v_align.add_child_below_node(_shortcuts, container)
    container.owner = _v_align
    container.hide()
    return container

## Makes the close button show and hides the back button. Each tab has their close/ back button visibility maintained seperately. 
func show_close():
    _show_close()
    _current_category["show_back"] = false

func _show_close():
    _back_button.hide()
    _close_button.show()

## Makes a back button show in the preferences window instead of the normal close button. Each tab has their close/ back button visibility maintained seperately. 
func show_back():
    _show_back()
    _current_category["show_back"] = true

func _show_back():
    _close_button.hide()
    _back_button.show()

## Returns the PreferencesWindow WindowDialog. 
func get_preferences_window() -> WindowDialog:
    return _preferences

func _create_default_container() -> VBoxContainer:
    var container: VBoxContainer = VBoxContainer.new()
    container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    container.size_flags_vertical = Control.SIZE_EXPAND_FILL
    return container

func _create_button(id: int, name: String) -> Button:
    var button: Button = Button.new()
    # connect button to _category_pressed and use id as default parameter
    button.connect("pressed", self, "_category_pressed", [id])
    button.text = name
    button.toggle_mode = true
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    return button

func _category_pressed(id: int = -1):
    # negative id means one of the vanilla tabs was selected, we just need to hide our own now
    if id < 0:
        if _current_category != null:
            _current_category["button"].set_pressed_no_signal(false) 
            _current_category["container"].hide()
            _current_category = null
            _show_close()
        return
    # if a vanilla category was active before just hide all vanilla categories
    if _current_category == null:
        _general.hide()
        _general_button.set_pressed_no_signal(false) 
        _interface.hide()
        _interface_button.set_pressed_no_signal(false) 
        _shortcuts.hide()
        _shortcuts_button.set_pressed_no_signal(false) 
    else: # if a mod category was active before hide that mod category
        _current_category["button"].set_pressed_no_signal(false) 
        _current_category["container"].hide()
    # get the selected category and show its container
    _current_category = _categories[id]
    _current_category["button"].set_pressed_no_signal(true) 
    _current_category["container"].show()
    # update close/ back button visibility
    if (_current_category["show_back"]):
        _show_back()
    else:
        _show_close()

func _back_pressed():
    emit_signal("back_pressed")
    # let any mod using this api decide how to handle back button presses itself
    if _current_category != null:
        _current_category["container"].emit_signal("back_pressed")

func _apply_pressed():
    emit_signal("apply_pressed")

func _on_preferences_about_to_show():
    _preferences._on_Preferences_about_to_show()
    emit_signal("about_to_show")

func _unload():
    # revert preferences about_to_show signal rerouting
    _preferences.connect("about_to_show", _preferences, "_on_Preferences_about_to_show")
    _preferences.disconnect("about_to_show", self, "_on_preferences_about_to_show")

    # disconnect all signals
    _apply_button.disconnect("pressed", self, "_apply_pressed")
    _back_button.disconnect("pressed", self, "_back_pressed")
    _general_button.disconnect("pressed", self, "_category_pressed")
    _interface_button.disconnect("pressed", self, "_category_pressed")
    _shortcuts_button.disconnect("pressed", self, "_category_pressed")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)
    
    # remove back button
    _buttons.remove_child(_back_button)
    _back_button.free()
    _close_button.show()

    # return to general tab if mod tab was active
    if _current_category != null:
        _general_button.emit_signal("pressed")
    
    # destroy all mod categories
    for category in _categories:
        var button: Button = category["button"]
        var container: Control = category["container"]
        _category_button_h_align.remove_child(button)
        button.free()
        _v_align.remove_child(container)
        # also free via meta setting?
        if (container.has_method("_unload")):
            if (container._unload()):
                container.free()
