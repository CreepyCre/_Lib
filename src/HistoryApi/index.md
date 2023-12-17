---
_: _
---
root: ..
methods:    void record(history_record: Object, max_count: int = null, record_type: Variant = null)
            bool undo()
            bool redo()
enums:      HistoryType {UNDO, REDO}
signals:    recorded(history_record)
            dropped(history_record, type)
            undo_begin(history_record)
            undo_end(history_record)
            redo_begin(history_record)
            redo_end(history_record)
            

Let's you add records to the undo history.

## Description

The HistoryApi makes it possible to add undo/redo records which seemlessly integrate with DungeonDrafts built in History. A record is represented by any :link:`Object` that has `undo()` and `redo()` methods.

## Methods

:methods:

## Signals

:signal:anchor:`recorded`: <br>
<span class="indent">
Emitted when a new record is added to the history.
</span>

:signal:anchor:`dropped`: <br>
<span class="indent">
Emitted when a record is dropped from the history, either due to exceeding the length of the history or due to being in the redo history when a new Record is recorded.
</span>

:signal:anchor:`undo_begin`: <br>
<span class="indent">
Emitted before a records :link:`Record.undo` method is called.
</span>

:signal:anchor:`undo_end`: <br>
<span class="indent">
Emitted before a records :link:`Record.undo` method has finished processing.
</span>

:signal:anchor:`redo_begin`: <br>
<span class="indent">
Emitted before a records :link:`Record.redo` method is called.
</span>

:signal:anchor:`redo_end`: <br>
<span class="indent">
Emitted before a records :link:`Record.redo` method has finished processing.
</span>

## Enumerations

:enum:anchor:`HistoryType`
<span class="indent">
Denotes the type of history a record is currently recorded in.
</span>

## Method Descriptions

:method:anchor:`record`: <br>
<span class="indent">
Adds :param:`history_record` to the history.
</span>

:method:anchor:`undo`: <br>
<span class="indent">
Calls `undo()` on the next relevant record of the history.
</span>

:method:anchor:`redo`: <br>
<span class="indent">
Calls `redo()` on the next relevant record of the history.
</span>