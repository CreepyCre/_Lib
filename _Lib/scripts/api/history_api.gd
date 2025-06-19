class_name HistoryApi

const CLASS_NAME = "HistoryApi"
var LOGGER: Object

enum HistoryType {
    UNDO,
    REDO
}

enum {
    UNDO,
    REDO
}

enum RecordType {
    DEFAULT
}

var history
var history_mirror: Array = []
var _master
var custom_record_clazz

var _menu_align: HBoxContainer
var _undo_button: Button
var _redo_button: Button

var _replacement_undo_button: Button
var _replacement_redo_button: Button

signal recorded(history_record)
signal dropped(history_record, type)
signal undo_begin(history_record)
signal undo_end(history_record)
signal redo_begin(history_record)
signal redo_end(history_record)

# editor is Global.Editor
func _init(logger: Object, editor: CanvasLayer):
    LOGGER = logger.for_class(self)
    history = editor.History
    _master = editor.owner
    custom_record_clazz = history.CreateCustomRecord(null).get_script()
    history.Clear()

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
    _verify_history()
    var wrapper = RecordWrapper.new(self, history_record, max_count, record_type)
    history_mirror.append(history.CreateCustomRecord(wrapper))
    _record(wrapper)
    _verify_history()

    
    # update undo/ redo button state
    _replacement_redo_button.disabled = _redo_button.disabled
    _replacement_undo_button.disabled = _undo_button.disabled

## Undoes relevant record in history by calling its undo() method
## Is called by undo button or undo shortcut
func undo() -> bool:
    _verify_history()
    if _master.IsBusy or history.locked:
        return false
    history.Undo()
    _replacement_redo_button.disabled = _redo_button.disabled
    _replacement_undo_button.disabled = _undo_button.disabled
    
    return true

## Redoes relevant record in history by calling its redo() method
## Is called by undo button or undo shortcut
func redo() -> bool:
    _verify_history()
    if _master.IsBusy or history.locked:
        return false
    history.Redo()
    _replacement_redo_button.disabled = _redo_button.disabled
    _replacement_undo_button.disabled = _undo_button.disabled
    
    return true

# creates our homebrew buttons to replace the original unload/ reload buttons
func _get_replacement_button(button: Button):
    # create new button, copy the properties over and put it next to the original button
    var out = Button.new()
    _copy_props(button, out, ["margin_left", "margin_right", "margin_bottom", "custom_constants/hseparation", "shortcut", "disabled", "text", "icon"])
    _menu_align.add_child_below_node(button, out)
    # enable and hide button
    # hidden buttons can't press (even via shortcut) so we don't have to disconnect any signals
    button.hide()
    
    return out
    
# copies properties defined in props from from to to
func _copy_props(from: Object, to: Object, props: Array):
    for prop in props:
        to.set(prop, from.get(prop))

func _update(_delta):
    _verify_history()
    _replacement_redo_button.disabled = _redo_button.disabled
    _replacement_undo_button.disabled = _undo_button.disabled

func _verify_history():
    var recorded: Array = []
    var i: int = history.history.size() - 1
    while i >= 0 and not history.history[i].ScriptInstance is RecordWrapper and not history.history[i].ScriptInstance is CSharpRecordWrapper:
        if history.history[i].ScriptInstance == null:
            var record = custom_record_clazz.new()
            record.ScriptInstance = CSharpRecordWrapper.new(self, history.history[i])
            history.history[i] = record
            recorded.push_front(record.ScriptInstance)
        else:
            var wrapper = RecordWrapper.new(self, history.history[i].ScriptInstance)
            history.history[i].ScriptInstance = wrapper
            recorded.push_front(wrapper)
        i = i - 1
    for record in recorded:
        _record(record)
    # verify dropped
    while history_mirror.size() > 0 and not history_mirror.back() in history.history:
        var record = history_mirror.pop_back().ScriptInstance
        record.dropped(REDO)
        emit_signal("dropped", record, REDO)
    while history_mirror.size() > 0 and not history_mirror.front() in history.history:
        var record = history_mirror.pop_front().ScriptInstance
        record.dropped(UNDO)
        emit_signal("dropped", record, UNDO)
    history_mirror = history.history.duplicate()

func _record(record):
    var max_count:int = record.max_count()
    if max_count < 1:
        emit_signal("recorded", record)
        return
    var record_type = record.record_type()
    var count: int = 0
    var to_be_dropped: Array = []
    var i = history.history.size() - 1
    while i >= 0:
        if history.history[i].ScriptInstance.record_type() == record_type:
            count = count + 1
        if count > max_count:
            break
        i = i - 1
    if i >= 0:
        to_be_dropped = history.history.slice(0, i)
        history.history = history.history.slice(i + 1, history.history.size() - 1)
        history.bookmark -= 0 + 1
    emit_signal("recorded", record)
    for record in to_be_dropped:
        record.ScriptInstance.dropped(UNDO)
        emit_signal("dropped", record.ScriptInstance, UNDO)

func _unload():
    LOGGER.info("Unloading %s.", [CLASS_NAME])
    # TODO: delete redundant scene cleanup, scene is reloaded on unload anyways.
    # bring back original undo button
    _undo_button.disabled = true
    _undo_button.show()
    # destroy homebrew undo button
    _replacement_undo_button.disconnect("pressed", self, "undo")
    _menu_align.remove_child(_replacement_undo_button)

    # bring back original redo button
    _redo_button.disabled = true
    _redo_button.show()
    # destroy homebrew redo button
    _replacement_redo_button.disconnect("pressed", self, "redo")
    _menu_align.remove_child(_replacement_redo_button)

    # disconnect all signals
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

class RecordWrapper:
    var _history_api
    var _record
    var _max_count
    var _record_type

    func _init(history_api, rec, max_count = null, record_type = null):
        _history_api = history_api
        _record = rec
        if max_count != null and not max_count is int:
            record_type = max_count
            max_count = null
        _max_count = max_count
        _record_type = record_type

    func undo():
        _history_api._verify_history()
        _history_api.emit_signal("undo_begin", self)
        var result = _record.undo()
        if result is GDScriptFunctionState:
            yield(result, "completed")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        _history_api.emit_signal("undo_end", self)
    
    func redo():
        _history_api._verify_history()
        _history_api.emit_signal("redo_begin", self)
        var result = _record.redo()
        if result is GDScriptFunctionState:
            yield(result, "completed")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        _history_api.emit_signal("redo_end", self)

    func get_record():
        return _record
    
    func dropped(type: int):
        if (_record.has_method("dropped")):
            _record.dropped(type)

    func max_count() -> int:
        if (_max_count != null):
            return _max_count
        if _record.has_method("max_count"):
            return _record.max_count()
        return -1
    
    func record_type():
        if _record_type != null:
            return _record_type
        if _record.has_method("record_type"):
            return _record.record_type()
        if _max_count == null:
            return RecordType.DEFAULT
        return _record.get_script()

# corresponds to a record in the vanilla history
class VanillaHistoryRecord:
    var _editor

    func _init(editor):
        _editor = editor

    # equivalent to pressing original undo button


class CSharpRecordWrapper:
    var _history_api
    var _record

    func _init(history_api, rec):
        _history_api = history_api
        _record = rec

    func undo():
        _history_api._verify_history()
        _history_api.emit_signal("undo_begin", self)
        _record.Undo()
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        _history_api.emit_signal("undo_end", self)
    
    func redo():
        _history_api._verify_history()
        _history_api.emit_signal("redo_begin", self)
        _record.Redo()
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        yield(_history_api._menu_align.get_tree(), "idle_frame")
        _history_api.emit_signal("redo_end", self)

    func get_record():
        return _record
    
    func dropped(_type: int):
        pass

    func max_count() -> int:
        return -1
    
    func record_type():
        return RecordType.DEFAULT