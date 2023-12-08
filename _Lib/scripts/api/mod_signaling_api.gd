class_name ModSignalingAPI

var debug_class_name: String = "ModSignalingAPI"
var _deferred_connections: Dictionary = {}

var _infobar
var _begun_save: bool = false

## Emitted when a signal is registered to the mod signaling api.
signal signal_registered(signal_id)
## Emitted when the map unloads, which also causes mods to unload/ reload.
signal unload()
## Emitted when map saving begins
signal save_begin()
## Emitted when map saving ends
signal save_end()

func _init(infobar: PanelContainer):
    _infobar = infobar
    infobar.busyIcon.connect("visibility_changed", self, "_busy_icon_visibility_changed")

## Connect to a signal either immediately or whenever the signal is actually registered
func connect_deferred(signal_id: String, target: Object, method: String, binds: Array = [], flags: int = 0):
    if has_signal(signal_id):
        connect(signal_id, target, method, binds, flags)
    else: # store attempted connection in dictionary for connecting later
        if _deferred_connections.has(signal_id):
            _deferred_connections[signal_id] = _deferred_connections[signal_id] + [{"target": target, "method": method, "binds": binds, "flags": flags}]
        else:
            _deferred_connections[signal_id] = [{"target": target, "method": method, "binds": binds, "flags": flags}]

func add_user_signal(signal_id: String, arguments: Array = []):
    .add_user_signal(signal_id, arguments)
    # connect all deferred connections
    if _deferred_connections.has(signal_id):
        for callable in _deferred_connections.get(signal_id):
            connect(signal_id, callable["target"], callable["method"], callable["binds"], callable["flags"])
    emit_signal("signal_registered", signal_id)

func _busy_icon_visibility_changed():
    match _infobar.cornerInfo.text:
        "Saving...", "Backing up...":
            _begun_save = true
            emit_signal("save_begin")

func _update():
    if (_begun_save and not _infobar.spinBusyIcon):
        _begun_save = false
        emit_signal("save_end")


func _unload():
    _infobar.busyIcon.disconnect("visibility_changed", self, "_busy_icon_visibility_changed")
    _deferred_connections.clear()
    # disconnect all signals
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)