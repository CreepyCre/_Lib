---
_: _
---
root: ../..
methods:    bool undo()
            bool redo()
            void dropped(type: HistoryApi.HistoryType)
            int max_count()
            Variant record_type()
            int idle_frames()

Represents a record that can be recorded to the :link:`HistoryApi`.

## Description

There is no actual Record class, this page simply serves as a blueprint for implementing a record.

A Record represents an entry in the :link:`HistoryApi`. It is required to implement :method:short:`undo` and :method:short:`redo` methods which are supposed to undo/ redo a change to the map. A record may also provide a :method:short:`record_type` method that returns a key for differentiating different record types. The records script is used as its record type if no other type is provided. Should a specific record type be added to the history more times than :method:short:`max_count` allows, then the oldest record of that type (and all other older records) will be dropped. Should a record implement a :method:short:`dropped` method it will be called when it is dropped, where :param:``

## Methods

:methods:

## Method Descriptions

:method:anchor:`undo`: <br>
<span class="indent">
Called by the :link:`HistoryApi` to start the undo process of the Record.
</span>

:method:anchor:`redo`: <br>
<span class="indent">
Called by the :link:`HistoryApi` to start the redo process of the Record.
</span>

:method:anchor:`dropped`: <br>
<span class="indent">
Called by the :link:`HistoryApi` when the Record is dropped from the history, either due to exceeding the length of the history or due to being in the redo history when a new Record is recorded. The supplied :link:`HistoryApi.HistoryType` denotes whether the record was in the undo or redo history at time of dropping.
</span>

:method:anchor:`max_count`: <br>
<span class="indent">
Called by the :link:`HistoryApi` to determine the maximum amount of records of this type that can be recorded before the oldest records will be discarded from the history.
</span>

:method:anchor:`record_type`: <br>
<span class="indent">
Called by the :link:`HistoryApi`. It's return value is used as a key to to compare :method:short:`max_count` against. Different types of records may implement this method incase they want to share the same maximum history records.
</span>

:method:anchor:`idle_frames`: <br>
<span class="indent">
In case a Record needs a certain amount of frames to fully process its :link:`#undo` or :link:`#redo` method a Record may implement this method to denote a certain amount of idle frames to wait before emitting :link:`HistoryApi.undo_end` or :link:`HistoryApi.redo_end`.
</span>