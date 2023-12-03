class_name ModSignalingAPI

var debug_class_name: String = "ModSignalingAPI"
var _deferred_connections: Dictionary = {}

## Emitted whenever a signal is registered to the mod signaling api.
signal signal_registered(signal_id)
## Emitted whenever the map unloads, which also causes mods to unload/ reload.
signal unload()

## Connect to a signal either immediately or whenever the signal is actually registered
func connect_deferred(signal_id: String, target: Object, method: String, binds: Array = [], flags: int = 0):
    if has_signal(signal_id):
        connect(signal_id, target, method, binds, flags)
    else:
        if _deferred_connections.has(signal_id):
            _deferred_connections[signal_id] = _deferred_connections[signal_id] + [{"target": target, "method": method, "binds": binds, "flags": flags}]
        else:
            _deferred_connections[signal_id] = [{"target": target, "method": method, "binds": binds, "flags": flags}]

func add_user_signal(signal_id: String, arguments: Array = []):
    .add_user_signal(signal_id, arguments)
    if _deferred_connections.has(signal_id):
        for callable in _deferred_connections.get(signal_id):
            connect(signal_id, callable["target"], callable["method"], callable["binds"], callable["flags"])
    emit_signal("signal_registered", signal_id)

func _unload():
    _deferred_connections.clear()
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)