class_name HistoryApi

const UNDO: int = 0
const REDO: int = 1

var _config: ConfigFile
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

signal recorded(history_record)
signal dropped(history_record, type)
signal undo_begin(history_record)
signal undo_end(history_record)
signal redo_begin(history_record)
signal redo_end(history_record)

# editor is Global.Editor
func _init(editor: CanvasLayer, config: ConfigFile):
    _config = config
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
func record(history_record: Object, max_count = null, record_type = null):
    # wrap record if methods are missing
    if (not history_record.has_method("max_count")):
        max_count = -1
    if (not history_record.has_method("record_type")):
        record_type = history_record.get_script()
    # ensure every record is a unique instance, small hack to make a record itself usable as identifier.
    history_record = RecordWrapper.new(history_record, max_count, record_type)
    # new record voids redo history
    var old_redo_history: Array = redo_history
    redo_history = []
    history.append(history_record)
    emit_signal("recorded", history_record)
    # drop oldest record if there's more than configurated
    var dropped_history: Array = []
    while (history.size() > _config.get_value("Preferences", "max_undos", 32)):
        dropped_history.append(history.pop_front())
    
    # shorten history if one of the record types goes over its max count
    var counts: Dictionary = {}
    var slice: int = 0
    for i in range(history.size() - 1, -1, -1):
        var rec = history[i]
        var rec_type = rec.record_type()
        var count = 0
        if (rec_type in counts):
            count = counts[rec_type] + 1
        else:
            count = 1
        
        if ((rec.max_count() > 0) and count > (rec.max_count())):
            slice = i + 1
            break
        counts[rec_type] = count
    
    for i in slice:
        dropped_history.append(history.pop_front())
    
    for rec in old_redo_history:
        if (rec.has_method("dropped")):
            rec.dropped(REDO)
        emit_signal("dropped", rec, REDO)
    
    for rec in dropped_history:
        if (rec.has_method("dropped")):
            rec.dropped(UNDO)
        emit_signal("dropped", rec, UNDO)

    # update undo/ redo button state
    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = true

## Undoes relevant record in history by calling its undo() method
## Is called by undo button or undo shortcut
func undo() -> bool:
    # safeguard
    if (history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    # make sure we don't trigger our vanilla record detection wrongfully
    _ignore_history_changed = true
    # undo history_record and move it into the redo history
    var history_record = history.pop_back()
    emit_signal("undo_begin", history_record)
    history_record.undo()
    redo_history.append(history_record)

    # update undo/ redo button state
    _replacement_undo_button.disabled = history.empty()
    _replacement_redo_button.disabled = false

    emit_signal("undo_end", history_record)

    return true

## Redoes relevant record in history by calling its redo() method
## Is called by undo button or undo shortcut
func redo() -> bool:
    # safeguard
    if (redo_history.empty()):
        return false
    if (not _aquire_lock()):
        return false
    # make sure we don't trigger our vanilla record detection wrongfully
    _ignore_history_changed = true
    # redo history_record and move it into the undo history
    var history_record = redo_history.pop_back()
    emit_signal("redo_begin", history_record)
    history_record.redo()
    history.append(history_record)

    # update undo/ redo button state
    _replacement_undo_button.disabled = false
    _replacement_redo_button.disabled = redo_history.empty()

    emit_signal("redo_end", history_record)

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

    # clear history
    history.clear()
    redo_history.clear()

    # disconnect all signals
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

class RecordWrapper:
    var _record
    var _max_count
    var _record_type

    func _init(rec, max_c, record_type):
        _record = rec
        _max_count = max_c
        _record_type = record_type

    func undo():
        _record.undo()
    
    func redo():
        _record.redo()
    
    func dropped(type: int):
        if (_record.has_method("dropped")):
            _record.dropped(type)

    func max_count() -> int:
        if (_max_count != null):
            return _max_count
        return _record.max_count()
    
    func record_type():
        if (_record_type != null):
            return _record_type
        return _record.record_type()
    
    func idle_frames() -> int:
        if (_record.has_method("idle_frames")):
            return _record.idle_frames()
        return 0

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

    func idle_frames() -> int:
        return 1
