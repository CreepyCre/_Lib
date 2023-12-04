class_name HistoryApi

var _editor
var _vanilla_history_record

var _menu_align: HBoxContainer
var _undo_button: Button
var _redo_button: Button

var _replacement_undo_button: Button
var _replacement_redo_button: Button

var _ignore_history_changed: bool = true

var history: Array = []
var redo_history: Array = []

var _locked: bool = false

func _init(editor: CanvasLayer):
    _editor = editor
    _vanilla_history_record = VanillaHistoryRecord.new(editor)

    _menu_align = editor.get_node("VPartition/MenuBar/MenuAlign")

    _undo_button = editor.undoButton
    _replacement_undo_button = _get_replacement_button(_undo_button)
    _replacement_undo_button.connect("pressed", self, "undo")

    _redo_button = editor.redoButton
    _replacement_redo_button = _get_replacement_button(_redo_button)
    _replacement_redo_button.connect("pressed", self, "redo")

func record(history_record):
    redo_history = []
    history.append(history_record)
    if (history.size() > 100):
        history.remove(0)

    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = true

func undo() -> bool:
    _ignore_history_changed = true
    # safeguard
    if (history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    var history_record = history.pop_back()
    history_record.undo()
    redo_history.append(history_record)

    _replacement_undo_button.disabled = history.empty()
    _replacement_redo_button.disabled = false

    return true

func redo() -> bool:
    _ignore_history_changed = true
    # safeguard
    if (redo_history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    var history_record = redo_history.pop_back()
    history_record.redo()
    history.append(history_record)

    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = redo_history.empty()

    return true

func _aquire_lock() -> bool:
    if (_locked):
        return false
    else:
        _lock()
        return true
    
func _lock():
    _locked = true

    yield(_editor.get_tree(), "idle_frame")
    yield(_editor.get_tree(), "idle_frame")
    yield(_editor.get_tree(), "idle_frame")

    _locked = false

func _get_replacement_button(button: Button):
    var out = Button.new()
    _copy_props(button, out, ["margin_left", "margin_right", "margin_bottom", "custom_constants/hseparation", "shortcut", "disabled", "text", "icon"])
    _menu_align.add_child_below_node(button, out)
    button.disabled = false
    button.hide()
    
    return out
    
    
func _copy_props(from, to, props):
    for prop in props:
        to.set(prop, from.get(prop))

func _update(_delta):
    if (_undo_button.disabled):
        _undo_button.disabled = false
    if (_redo_button.disabled):
        _redo_button.disabled = false
        # if this button is disabled unexpectedly then a new record was added to the vanilla history
        if (not _ignore_history_changed):
            record(_vanilla_history_record)
    
    _ignore_history_changed = false

func _unload():
    _undo_button.disabled = true
    _undo_button.show()
    _replacement_undo_button.disconnect("pressed", self, "_try_undo")
    _menu_align.remove_child(_replacement_undo_button)

    _redo_button.disabled = true
    _redo_button.show()
    _replacement_redo_button.disconnect("pressed", self, "_try_redo")
    _menu_align.remove_child(_replacement_redo_button)

class VanillaHistoryRecord:
    var _editor

    func _init(editor):
        _editor = editor

    func undo():
        _editor._on_UndoButton_pressed()
    
    func redo():
        _editor._on_RedoButton_pressed()
