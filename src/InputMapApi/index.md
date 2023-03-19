---
_: _
---
root: ..
methods:    void define_actions(category: String, actions: Dictionary)
            InputEventKey deserialize_event(string: String)
            String serialize_event(event: InputEventKey)
            String event_as_string(event: InputEventKey)
            ActionConfigSyncAgent get_agent(action: String)
            ActionConfigSyncAgent get_or_create_agent(action: String, deadzone: float)
            InputEventEmitterNode get_or_append_event_emitter(node: Node)
            InputEventEmitterNode master_event_emitter()

<link rel="stylesheet" href="../../wiki.css">

An Api for attaching :link:`InputEventEmitterNode`s that emit signals for cancellable input events.

## Description

The InputMapApi makes it possible to attach an :link:`InputEventEmitterNode` as a child of a node using :method:short:`get_or_append_event_emitter`. It additionally handles synchronization of ShortcutConfigNodes and has some methods for serializing and deserializing :link:`InputEventKey`s.

## Methods

:methods:

## Method Descriptions

:method:anchor:`define_actions`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`deserialize_event`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`serialize_event`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`get_agent`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`get_or_create_agent`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`get_or_append_event_emitter`:

<span class="indent">
W.I.P.
</span>

:method:anchor:`master_event_emitter`:

<span class="indent">
W.I.P.
</span>