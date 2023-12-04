class_name HistoryApi

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

# editor is Global.Editor
func _init(editor: CanvasLayer):
    # we can reuse this one to undo/ redo the vanilla DungeonDraft history entries
    _vanilla_history_record = VanillaHistoryRecord.new(editor)
    # contains undo/ redo buttons
    _menu_align = editor.get_node("VPartition/MenuBar/MenuAlign")

    # prepare homebrew undo button
    _undo_button = editor.undoButton
    _replacement_undo_button = _get_replacement_button(_undo_button)
    _replacement_undo_button.connect("pressed", self, "undo")

    # prepare homebrew redo button
    _redo_button = editor.redoButton
    _replacement_redo_button = _get_replacement_button(_redo_button)
    _replacement_redo_button.connect("pressed", self, "redo")

## Adds history_record to the undo history.
## history_record needs to implement undo() and redo() methods.
func record(history_record):
    # new record voids redo history
    redo_history = []
    history.append(history_record)
    # drop oldest record if there's more than 100
    if (history.size() > 100):
        history.remove(0)

    # update undo/ redo button state
    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = true

## Undoes relevant record in history by calling its undo() method
## Is called by undo button or undo shortcut
func undo() -> bool:
    # make sure we don't trigger our vanilla record detection wrongfully
    _ignore_history_changed = true
    # safeguard
    if (history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    # undo history_record and move it into the redo history
    var history_record = history.pop_back()
    history_record.undo()
    redo_history.append(history_record)

    # update undo/ redo button state
    _replacement_undo_button.disabled = history.empty()
    _replacement_redo_button.disabled = false

    return true

## Redoes relevant record in history by calling its redo() method
## Is called by undo button or undo shortcut
func redo() -> bool:
    # make sure we don't trigger our vanilla record detection wrongfully
    _ignore_history_changed = true
    # safeguard
    if (redo_history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    # redo history_record and move it into the undo history
    var history_record = redo_history.pop_back()
    history_record.redo()
    history.append(history_record)

    # update undo/ redo button state
    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = redo_history.empty()

    return true

# call to make sure we aren't spamming undos/ redos
func _aquire_lock() -> bool:
    if (_locked):
        return false
    else:
        _lock()
        return true

func _lock():
    _locked = true

    # wait three idle frames before allowing next undo/ redo
    yield(_menu_align.get_tree(), "idle_frame")
    yield(_menu_align.get_tree(), "idle_frame")
    yield(_menu_align.get_tree(), "idle_frame")

    _locked = false

# creates our homebrew buttons to replace the original unload/ reload buttons
func _get_replacement_button(button: Button):
    # create new button, copy the properties over and put it next to the original button
    var out = Button.new()
    _copy_props(button, out, ["margin_left", "margin_right", "margin_bottom", "custom_constants/hseparation", "shortcut", "disabled", "text", "icon"])
    _menu_align.add_child_below_node(button, out)
    # enable and hide button
    # hidden buttons can't press (even via shortcut) so we don't have to disconnect any signals
    button.disabled = false
    button.hide()
    
    return out
    
# copies properties defined in props from from to to
func _copy_props(from: Object, to: Object, props: Array):
    for prop in props:
        to.set(prop, from.get(prop))

func _update(_delta):
    if (_redo_button.disabled):
        _redo_button.disabled = false
        # if this button is disabled unexpectedly then a new record was added to the vanilla history, so we add a corresponding record
        if (not _ignore_history_changed):
            record(_vanilla_history_record)
    
    _ignore_history_changed = false

func _unload():
    # bring back original undo button
    _undo_button.disabled = true
    _undo_button.show()
    # destroy homebrew undo button
    _replacement_undo_button.disconnect("pressed", self, "_try_undo")
    _menu_align.remove_child(_replacement_undo_button)

    # bring back original redo button
    _redo_button.disabled = true
    _redo_button.show()
    # destroy homebrew redo button
    _replacement_redo_button.disconnect("pressed", self, "_try_redo")
    _menu_align.remove_child(_replacement_redo_button)

# corresponds to a record in the vanilla history
class VanillaHistoryRecord:
    var _editor

    func _init(editor):
        _editor = editor

    # equivalent to pressing original undo button
    func undo():
        _editor._on_UndoButton_pressed()
    
    # equivalent to pressing original redo button
    func redo():
        _editor._on_RedoButton_pressed()
