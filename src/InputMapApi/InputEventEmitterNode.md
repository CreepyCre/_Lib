---
_: _
---
root: ../..
methods:    void accept_event()
signals:    input(InputEvent event, InputEventEmitterNode emitter)
            unhandled_input(InputEvent event, InputEventEmitterNode emitter)
            unhandled_key_input(InputEventKey event, InputEventEmitterNode emitter)

A Node that emits cancellable input event signals.


## Description

An InputEventEmitterNode can be attached as the child of any node via the :link:`InputMapApi`. Any time the :link:`Node#_input`, :link:`Node#_unhandled_input` or :link:`Node#_unhandled_key_input` method is called on it it will emit a signal accordingly. The signals provide the InputEventEmitterNode whose :method:short:`accept_event` method can then be called to prevent further propagation of the :link:`InputEvent`.


## Methods

:methods:


## Signals

:signal:anchor:`input`: <br>
<span class="indent">
Emitted when :link:`Node#_input` is called on this Node.
</span>

:signal:anchor:`unhandled_input`: <br>
<span class="indent">
Emitted when :link:`Node#_unhandled_input` is called on this Node.
</span>

:signal:anchor:`unhandled_key_input`: <br>
<span class="indent">
Emitted when :link:`Node#_unhandled_key_input` is called on this Node.
</span>


## Method Descriptions

:method:anchor:`accept_event`: <br>
<span class="indent">
Call to prevent further propagation of the received :link:`InputEvent`.
</span>