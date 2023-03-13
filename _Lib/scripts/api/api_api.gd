class_name ApiApi

var debug_class_name: String = "ApiApi"
var apis: Dictionary = {}

signal api_registered(api_id, api)

## Registers a new API and emits [signal api_registered]
func register(api_id: String, api: Object):
    apis[api_id] = api
    emit_signal("api_registered", api_id, api)

func _get(property):
    return apis.get(property)

func _get_property_list():
    var property_list: Array = []
    for api_id in apis:
        property_list.append({"name": api_id, "type": typeof(apis[api_id])})
    return property_list


func _unload():
    for api_id in apis:
        var api = apis[api_id]
        if (api.has_method("_unload")):
            api._unload()
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)