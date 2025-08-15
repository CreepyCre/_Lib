class_name ApiApi

const CLASS_NAME = "ApiApi"
var LOGGER: Object

var apis: Dictionary = {}
var api_api_instances: Array = []

signal api_registered(api_id, api)

func _init(logger: Object):
    LOGGER = logger.for_class(self)

## Registers a new API and emits [signal api_registered]
func register(api_id: String, api: Object):
    apis[api_id] = api
    if api.has_method("_is_lazy") and not api._is_lazy():
        for instance in api_api_instances:
            instance.get(api_id)
    emit_signal("api_registered", api_id, api)

func _get(property):
    # make APIs available as properties
    return apis.get(property)

func _get_property_list():
    var property_list: Array = []
    for api_id in apis:
        property_list.append({"name": api_id, "type": typeof(apis[api_id])})
    return property_list

func _update(delta):
    # forward _update call to APIs with _update method
    for api_id in apis:
        var api = apis[api_id]
        if (api.has_method("_update")):
            api._update(delta)

func _unload():
    LOGGER.info("Unloading %s.", [CLASS_NAME])
    # unload InstancedApiApi objects
    for api_api_instance in api_api_instances:
        api_api_instance._unload()
    # unload all APIs
    for api_id in apis:
        var api = apis[api_id]
        if (api.has_method("_unload")):
            api._unload()
    # disconnect all signal connections
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

## creates instanced ApiApi
func _instance(mod_info):
    var api_api_instance = InstancedApiApi.new(LOGGER, self, mod_info)
    api_api_instances.append(api_api_instance)
    # forward signal to InstancedApiApi
    connect("api_registered", api_api_instance, "_emit_api_registered")
    for api_id in apis:
        if apis[api_id].has_method("_is_lazy") and not apis[api_id]._is_lazy():
            api_api_instance.get(api_id)
    return api_api_instance

# Wrapper for ApiApi that supplies some default parameters
class InstancedApiApi:

    const CLASS_NAME = "InstancedApiApi"
    var LOGGER: Object

    var _mod_info
    var _api_api
    var _instanced_apis: Dictionary = {}

    func _init(logger: Object, api_api, mod_info):
        LOGGER = logger.for_class(self)
        _mod_info = mod_info
        _api_api = api_api
    
    signal api_registered(api_id, api)

    ## Registers a new API and emits [signal api_registered]
    func register(api_id: String, api: Object):
        LOGGER.info("Registering %s from %s", [api_id, _mod_info.mod_meta["name"]])
        _api_api.register(api_id, api)
    
    func _get(property):
        # return instanced api if already available
        if (property in _instanced_apis):
            return _instanced_apis[property]
        var api = _api_api[property]
        # if api can't be instanced just return it
        if (not api.has_method("_instance")):
            return api
        # create api instance
        var instanced_api = api._instance(_mod_info)
        _instanced_apis[property] = instanced_api
        return instanced_api
    
    func _get_property_list():
        return _api_api._get_property_list()
    
    func _unload():
        # unload instanced apis
        for api_id in _instanced_apis:
            var api = _instanced_apis[api_id]
            if (api.has_method("_unload")):
                api._unload()
        # disconnect all signal connections
        for signal_dict in get_signal_list():
            var signal_name = signal_dict.name
            for callable_dict in get_signal_connection_list(signal_name):
                disconnect(signal_name, callable_dict.target, callable_dict.method)

    func _emit_api_registered(api_id, api):
        emit_signal("api_registered", api_id, api)