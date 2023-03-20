---
_: _
---
root: ..
methods:    void define_actions(category: String, actions: Dictionary)
            InputEventKey deserialize_event(string: String)
            String serialize_event(event: InputEventKey)
            String event_as_string(event: InputEventKey)
            ActionConfigSyncAgent get_agent(action: String)
            ActionConfigSyncAgent get_or_create_agent(action: String, deadzone: float = 0.5=)
            InputEventEmitterNode get_or_append_event_emitter(node: Node)
            InputEventEmitterNode master_event_emitter()

An Api for attaching :link:`InputEventEmitterNode`s that emit signals for cancellable input events.

## Description

The InputMapApi makes it possible to attach an :link:`InputEventEmitterNode` as a child of a node using :method:short:`get_or_append_event_emitter`. It additionally handles synchronization of ShortcutConfigNodes and has some methods for serializing and deserializing :link:`InputEventKey`s.

## Methods

:methods:

## Method Descriptions

:method:anchor:`define_actions`: <br>
<span class="indent">
Registers actions to the :link:`InputMap` from a :link:`Dictionary` and adds them to the Shortcuts menu. :param:`actions` may consist of nested dictionaries to define categories inside the Shortcuts menu. Shortcut entries can either be a :link:`String` defining the action name or an :link:`Array`. The arrays first entry defines the action name while the following entries define the default shortcuts, either as a :link:`String` denoting the shortcut or a :link:`InputEventKey`.
Example:

```gdscript
var input_definitions: Dictionary = {
    "Some Shortcut": ["shortcut1", "Ctrl+P", "L"],
    "Some Category":{
        "Other Shortcut": "shortcut2",
        "Third Shortcut": "shortcut3"
    }
}
self.Global.API.InputMapApi.define_actions("Example Mod", input_definitions)
```
</span>

:method:anchor:`deserialize_event`: <br>
<span class="indent">
Deserializes an :link:`InputEventKey` from :param:`string`.
</span>

:method:anchor:`serialize_event`: <br>
<span class="indent">
Serializes :param:`event` into a :link:`String`.
</span>

:method:anchor:`event_as_string`: <br>
<span class="indent">
Turns :param:`event` into a human readable :link:`String` representation.
</span>

:method:anchor:`get_agent`: <br>
<span class="indent">
Gets the :link:`ActionConfigSyncAgent` for :param:`action`.
</span>

:method:anchor:`get_or_create_agent`: <br>
<span class="indent">
Gets or creates the :link:`ActionConfigSyncAgent` for :param:`action`.
</span>

:method:anchor:`get_or_append_event_emitter`: <br>
<span class="indent">
Gets the :link:`InputEventEmitterNode` attached to :param:`node` or creates one if necessary.
</span>

:method:anchor:`master_event_emitter`: <br>
<span class="indent">
Gets the :link:`InputEventEmitterNode` attached to the Master node (owner of Editor & World) or creates one if necessary.
</span>