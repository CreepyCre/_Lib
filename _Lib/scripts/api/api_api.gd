class_name ApiApi

var debug_class_name: String = "ApiApi"
var apis: Dictionary = {}
var api_api_instances: Array = []

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
    for api_api_instance in api_api_instances:
        api_api_instance._unload()
    for api_id in apis:
        var api = apis[api_id]
        if (api.has_method("_unload")):
            api._unload()
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

## creates instanced ApiApi
func _instance(mod_info):
    var api_api_instance = InstancedApiApi.new(self, mod_info)
    api_api_instances.append(api_api_instance)
    connect("api_registered", api_api_instance, "_emit_api_registered")
    return api_api_instance
    
class InstancedApiApi:
    var _mod_info
    var _api_api
    var _instanced_apis: Dictionary = {}

    func _init(api_api, mod_info):
        _mod_info = mod_info
        _api_api = api_api
    
    signal api_registered(api_id, api)

    ## Registers a new API and emits [signal api_registered]
    func register(api_id: String, api: Object):
        _api_api.register(api_id, api)
    
    func _get(property):
        if (property in _instanced_apis):
            return _instanced_apis[property]
        var api = _api_api[property]
        if (not api.has_method("_instance")):
            return api
        var instanced_api = api._instance(_mod_info)
        _instanced_apis[property] = instanced_api
        return instanced_api
    
    func _get_property_list():
        return _api_api._get_property_list()
    
    func _unload():
        for api_id in _instanced_apis:
            var api = _instanced_apis[api_id]
            if (api.has_method("_unload")):
                api._unload()
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)
    
    func _emit_api_registered(api_id, api):
        emit_signal("api_registered", api_id, api)