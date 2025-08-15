class_name ModRegistry

const CLASS_NAME = "ModRegistry"
var LOGGER: Object

var _api_api
var _path_to_unique_id
var _unique_id_to_ddmod
var _unique_id_to_mod_info = {}
var _registered_mods = []

signal registered(mod_info)

func _init(logger: Object, api_api, path_to_unique_id: Dictionary, unique_id_to_ddmod: Dictionary):
    LOGGER = logger.for_class(self)
    _api_api = api_api
    _path_to_unique_id = path_to_unique_id
    _unique_id_to_ddmod = unique_id_to_ddmod

    # create and connect to mod registration signal
    if (not Engine.has_signal("_lib_register_mod")):
        Engine.add_user_signal("_lib_register_mod", [{"name": "mod", "type": TYPE_OBJECT}])
    Engine.connect("_lib_register_mod", self, "register")

## Registers a mod. This is indirectly called when using the Engine signal to register a mod, no clue why you'd want to call this directly.
func register(mod: Reference, global_instance = null):
    # write stuff to mod.Global by default
    if (global_instance == null):
        global_instance = mod.Global
    var mod_root: String = global_instance.Root.rstrip("/")
    var mod_info
    # create ModInfo with the .ddmod file dictionary we collected in _init
    if (mod_root in _path_to_unique_id):
        mod_info = ModInfo.new(mod, get_ddmod(_path_to_unique_id[mod_root]))
        _unique_id_to_mod_info[mod_info.mod_meta["unique_id"]] = mod_info
    else:
        mod_info = ModInfo.new(mod)
    # add mod to registry 
    _registered_mods.append(mod_info)
    # add InstancedApiApi to mod global dictionary
    global_instance["API"] = _api_api._instance(mod_info)
    emit_signal("registered", mod_info)

func get_mod_info(mod_id: String):
    return _unique_id_to_mod_info[mod_id]

func get_mod_list():
    return _registered_mods.duplicate()

func get_ddmod(mod_id: String):
    return _unique_id_to_ddmod[mod_id]

func get_ddmods():
    return _unique_id_to_ddmod

func _unload():
    LOGGER.info("Unloading %s.", [CLASS_NAME])
    # disconnect all signals
    Engine.disconnect("_lib_register_mod", self, "register")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)

## Data class for storing the mod script and the mods ddmod json entries
class ModInfo:
    var mod
    var mod_meta: Dictionary

    func _init(_mod, ddmod_json: Dictionary = {}):
        mod = _mod
        mod_meta = ddmod_json