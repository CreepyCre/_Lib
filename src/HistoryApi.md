---
_: _
---
root: ..
methods:    void record(history_record: Object)
            bool undo()
            bool redo()
            

Let's you add records to the undo history.

## Description

The HistoryApi makes it possible to add undo/redo records which seemlessly integrate with DungeonDrafts built in History. A record is represented by any :link:`Object` that has `undo()` and `redo()` methods.

## Methods

:methods:

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