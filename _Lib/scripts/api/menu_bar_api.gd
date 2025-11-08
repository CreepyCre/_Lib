class_name MenuBarApi

const CLASS_NAME = "MenuBarApi"
var LOGGER: Object

var _menu_align: Control

var _handles: Dictionary = {}
var _sync: Dictionary = {}

func _init(logger: Object, menu_align: Control):
    LOGGER = logger.for_class(self)

    _menu_align = menu_align

func get_button(menu_name: String) -> MenuButton:
    return get_menu(menu_name)._menu_button

func get_menu(menu_name: String) -> PopupMenuHandle:
    if menu_name in _handles:
        return _handles[menu_name]
    var button_name: String = menu_name + "Button"
    if _menu_align.has_node(button_name):
        var button: Button = _menu_align.get_node(button_name)
        if button is MenuButton:
            _handles[menu_name] = PopupMenuHandle.new(button)
        else:
            button.hide()

            var menu_button: MenuButton = MenuButton.new()
            menu_button.text = button.text
            menu_button.icon = button.icon
            menu_button.flat = false
            _menu_align.add_child_below_node(button, menu_button)

            var menu_handle: PopupMenuHandle = PopupMenuHandle.new(menu_button)
            _handles[menu_name] = menu_handle

            var proxy_item: PopupItemHandle = menu_handle.add_icon_item(button.icon, button.text)
            proxy_item.set_disabled(button.disabled)
            _sync[button] = proxy_item
            proxy_item.connect("pressed", button, "emit_signal", ["pressed"])
    else:
        var menu_button = MenuButton.new()
        menu_button.text = menu_name
        menu_button.flat = false
        _menu_align.add_child_below_node(_menu_align.get_node("MenuButton"), menu_button)
        _handles[menu_name] = PopupMenuHandle.new(menu_button)
    return _handles[menu_name]
    
func _update(_delta):
    for from in _sync:
        var to: PopupItemHandle = _sync[from]
        if from.disabled != to.is_disabled():
            to.set_disabled(from.disabled)
            pass

class PopupMenuHandle:
    var _menu_button: MenuButton
    var _popup_menu: PopupMenu
    var _handles: Dictionary = {}

    func _init(menu_button: MenuButton):
        _menu_button = menu_button
        _popup_menu = menu_button.get_popup()
        _popup_menu.connect("id_focused", self, "_id_focused")
        _popup_menu.connect("id_pressed", self, "_id_pressed")
    
    func _id_focused(id: int):
        _handle(id).emit_signal("focused")
    
    func _id_pressed(id: int):
        _handle(id).emit_signal("pressed")
    
    func _handle(id: int = -1) -> PopupItemHandle:
        if id < 0:
            id = _popup_menu.get_item_id(_popup_menu.get_item_count() - 1)
        if not id in _handles:
            _handles[id] = PopupItemHandle.new(self, id)
        return _handles[id]

    func add_check_item(label: String, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_check_item(label, -1, accel)
        return _handle()

    func add_check_shortcut(shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_check_shortcut(shortcut, -1, global)
        return _handle()

    func add_icon_check_item(texture: Texture, label: String, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_icon_check_item(texture, label, -1, global)
        return _handle()

    func add_icon_check_shortcut(texture: Texture, shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_icon_check_shortcut(texture, shortcut, -1, global)
        return _handle()

    func add_icon_item(texture: Texture, label: String, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_icon_item(texture, label, -1, accel)
        return _handle()

    func add_icon_radio_check_item(texture: Texture, label: String, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_icon_radio_check_item(texture, label, -1, accel)
        return _handle()

    func add_icon_radio_check_shortcut(texture: Texture, shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_icon_radio_check_shortcut(texture, shortcut, -1, global)
        return _handle()

    func add_icon_shortcut(texture: Texture, shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_icon_shortcut(texture, shortcut, -1, global)
        return _handle()

    func add_item(label: String, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_item(label, -1, accel)
        return _handle()

    func add_multistate_item(label: String, max_states: int, default_state: int = 0, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_multistate_item(label, max_states, default_state, -1, accel)
        return _handle()

    func add_radio_check_item(label: String, accel: int = 0) -> PopupItemHandle:
        _popup_menu.add_radio_check_item(label, -1, accel)
        return _handle()

    func add_radio_check_shortcut(shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_radio_check_shortcut(shortcut, -1, global)
        return _handle()

    func add_separator(label: String = "") -> PopupItemHandle:
        _popup_menu.add_separator(label, -1)
        return _handle()

    func add_shortcut(shortcut: ShortCut, global: bool = false) -> PopupItemHandle:
        _popup_menu.add_shortcut(shortcut, -1, global)
        return _handle()

    func add_submenu_item(label: String, submenu: String) -> PopupItemHandle:
        _popup_menu.add_submenu_item(label, submenu, -1)
        return _handle()
    
    func get_current_index() -> int:
        return _popup_menu.get_current_index()
    
    func get_item(idx: int) -> PopupItemHandle:
        return _handle(_popup_menu.get_item_id(idx))
    
    func get_item_count() -> int:
        return _popup_menu.get_item_count()
    
    func get_popup_menu() -> PopupMenu:
        return _popup_menu
    
    func is_hide_on_window_lose_focus() -> bool:
        return _popup_menu.is_hide_on_window_lose_focus()

    func remove_item(idx: int):
        var id: int = _popup_menu.get_item_id(idx)
        if id in _handles:
            _handles[id]._id = -1
            _handles.erase(id)
        _popup_menu.remove_item(idx)
    
    func set_hide_on_window_lose_focus(enable: bool):
        _popup_menu.set_hide_on_window_lose_focus(enable)


class PopupItemHandle:
    var _parent: PopupMenuHandle
    var _popup_menu: PopupMenu
    var _id: int

    signal focused()
    signal pressed()

    func _init(parent: PopupMenuHandle, id: int):
        _parent = parent
        _popup_menu = parent._popup_menu
        _id = id
    
    func get_accelerator() -> int:
        return _popup_menu.get_item_accelerator(get_index())
    
    func get_icon() -> Texture:
        return _popup_menu.get_item_icon(get_index())
    
    func get_id() -> int:
        return _id

    func get_index() -> int:
        return _popup_menu.get_item_index(_id)
    
    func get_metadata() -> int:
        return _popup_menu.get_item_metadata(get_index())
    
    func get_shortcut() -> ShortCut:
        return _popup_menu.get_item_shortcut(get_index())
    
    func get_submenu() -> String:
        return _popup_menu.get_item_submenu(get_index())
    
    func get_text() -> String:
        return _popup_menu.get_item_text(get_index())
    
    func get_tooltip() -> String:
        return _popup_menu.get_item_tooltip(get_index())
    
    func is_checkable() -> bool:
        return _popup_menu.is_item_checkable(get_index())
    
    func is_checked() -> bool:
        return _popup_menu.is_item_checked(get_index())
    
    func is_disabled() -> bool:
        return _popup_menu.is_item_disabled(get_index())
    
    func is_radio_checkable() -> bool:
        return _popup_menu.is_item_radio_checkable(get_index())
    
    func is_separator() -> bool:
        return _popup_menu.is_item_separator(get_index())
    
    func is_shortcut_disabled() -> bool:
        return _popup_menu.is_item_shortcut_disabled(get_index())
    
    func remove() -> bool:
        return _parent.remove_item(get_index())
    
    func set_accelerator(accel: int):
        _popup_menu.set_item_accelerator(get_index(), accel)
    
    func set_as_checkable(enable: bool):
        _popup_menu.set_item_as_checkable(get_index(), enable)

    func set_as_radio_checkable(enable: bool):
        _popup_menu.set_item_as_radio_checkable(get_index(), enable)
    
    func set_as_separator(enable: bool):
        _popup_menu.set_item_as_separator(get_index(), enable)
    
    func set_checked(checked: bool):
        _popup_menu.set_item_checked(get_index(), checked)
    
    func set_disabled(disabled: bool):
        _popup_menu.set_item_disabled(get_index(), disabled)
    
    func set_icon(icon: Texture):
        _popup_menu.set_item_icon(get_index(), icon)
    
    func set_metadata(metadata):
        _popup_menu.set_item_metadata(get_index(), metadata)
    
    func set_multistate(state: int):
        _popup_menu.set_item_multistate(get_index(), state)
    
    func set_shortcut(shortcut: ShortCut, global: bool = false):
        _popup_menu.set_item_shortcut(get_index(), shortcut, global)
    
    func set_shortcut_disabled(disabled):
        _popup_menu.set_item_shortcut_disabled(get_index(), disabled)
    
    func set_submenu(submenu: String):
        _popup_menu.set_item_submenu(get_index(), submenu)
    
    func set_text(text: String):
        _popup_menu.set_item_text(get_index(), text)
    
    func set_tooltip(tooltip: String):
        _popup_menu.set_item_tooltip(get_index(), tooltip)
    
    func toggle_checked():
        _popup_menu.toggle_item_checked(get_index())
    
    func toggle_multistate():
        _popup_menu.toggle_item_multistate(get_index())