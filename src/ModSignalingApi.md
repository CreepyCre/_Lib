---
_: _
---
root: ..
methods:    void connect_deferred(signal_id: String, target: Object, method: String, binds: Array = []=, flags: int = 0)
            void add_user_signal(signal_id: String, arguments: Array = []=)
signals:    signal_registered(String signal_id)

Enables inter-mod communication.

## Description

The ModSignalingApi is intended to be used for inter-mod communication. It uses the existing signal system but offers :link:`#connect_deffered` to connect to a signal either immediately or whenever it actually becomes available. It furthermore emits :signal:`signal_registered` when a new user signal is added to it.

## Methods

:methods:

## Signals

:signal:anchor:`signal_registered`: <br>
<span class="indent">
Emitted whenever a new user signal is added to the ModSignalingAPi.
</span>

## Method Descriptions

:method:anchor:`connect_deferred`: <br>
<span class="indent">
Forwards the call directly to :link:`Object#connect` if a signal :param:`signal_id` exists. Otherwise queues the call and runs it when a user signal :param:`signal_id` is added.
</span>

:method:anchor:`add_user_signal`: <br>
<span class="indent">
Overrides :link:`Object#add_user_signal`. Additionally emits :signal:`signal_registered` after the user signal has been added.
</span>