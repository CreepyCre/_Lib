---
_: _
---
root: ../..
methods:    String get_action()
            Array get_action_list()
            void switch(from: InputEventKey, to: InputEventKey, index: int)
            void deleted_item(index: int)
            void added_item()
            void add_event(event: InputEventKey)
            bool is_saved()
signals:    switched(from: InputEventKey, to: InputEventKey, index: int)
            deleted(index: int)
            added()

Responsible for synchronization of shortcuts between multiple shortcut config nodes.


## Description

Every action defined through the :link:`InputMapApi` has its own ActionConfigSyncAgent created. It is used by the :link:`ModConfigApi` to ensure shortcut config nodes displaying the same shortcut stay synchronized with eachother.


## Methods

:methods:


## Signals

:signal:anchor:`switched`: <br>
<span class="indent">
Emitted when :method:short:`switch` is called when a shortcut is changed in a shortcut config and forwards the parameters. :param:`from` and :param:`to` are the previous and new :link:`InputEventKey` respectively. :param:`index` is the index of the item changed in the actions event list indexed by their order in the config tree.
</span>

:signal:anchor:`deleted`: <br>
<span class="indent">
Emitted when :method:short:`deleted_item` is called when a shortcut is deleted in a shortcut config and forwards the parameters. :param:`index` denotes the index of the item deleted in the actions event list indexed by their order in the config tree.
</span>

:signal:anchor:`added`: <br>
<span class="indent">
Emitted when :method:short:`added_item` is called when a shortcut is deleted in a shortcut config and forwards the parameters.
</span>


## Method Descriptions

:method:anchor:`get_action`: <br>
<span class="indent">
Returns the action this ActionConfigSyncAgent handles as a :link:`String`.
</span>

:method:anchor:`get_action_list`: <br>
<span class="indent">
Retuns the :link:`InputEvent` :link:`Array` bound to this ActionConfigSyncAgents action.
</span>

:method:anchor:`switch`: <br>
<span class="indent">
Emits :signal:`switched`. Call to indicate that at the index :param:`from` has been switched with :param:`to`.
</span>

:method:anchor:`deleted_item`: <br>
<span class="indent">
Emits :signal:`deleted`. Call to indicate that the shortcut at :param:`index` has been cleared.
</span>

:method:anchor:`added_item`: <br>
<span class="indent">
Emits :signal:`added`. Call to indicate that a new shortcut has been added to this ActionConfigSyncAgents action.
</span>

:method:anchor:`add_event`: <br>
<span class="indent">
Adds :param:`event` to this ActionConfigSyncAgents action.
</span>

:method:anchor:`is_saved`: <br>
<span class="indent">
Returns a bool that indicates whether the action is being saved to any config. Shortcut config nodes only allow modifying shortcuts that are actually being saved.
</span>