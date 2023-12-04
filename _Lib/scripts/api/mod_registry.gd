class_name ModRegistry

var _api_api
var _path_to_ddmod_json = {}
var _unique_id_to_mod_info = {}
var _registered_mods = []

signal mod_registered(mod_info)

func _init(api_api, active_mods):
    _api_api = api_api

    # create and connect to mod registration signal
    if (not Engine.has_signal("_lib_register_mod")):
        Engine.add_user_signal("_lib_register_mod", [{"name": "mod", "type": TYPE_OBJECT}])
    Engine.connect("_lib_register_mod", self, "register_mod")

    # read in some mod directory from DungeonDraft config file
    var config: ConfigFile = ConfigFile.new()
    config.load("user://config.ini")
    var mods_dir: String = config.get_value("Mods", "mods_directory")
    # get list of .ddmod files
    var ddmod_files: Array = _get_all_files(mods_dir, "ddmod")
    
    var file: File = File.new()
    for ddmod_file in ddmod_files:
        # read in .ddmod files as json into dictionary
        file.open(ddmod_file, File.READ)
        var ddmod_json: Dictionary = JSON.parse(file.get_as_text()).result
        file.close()

        # skip mod if not active
        if (not ddmod_json["unique_id"] in active_mods):
            continue
        
        # add ddmod_json to dictionary with the folder path as key
        # we can use this later to identify a mod from its root path
        var folder = ddmod_file.get_base_dir().rstrip("/")
        _path_to_ddmod_json[folder] = ddmod_json
        

## Registers a mod. This is indirectly called when using the Engine signal to register a mod, no clue why you'd want to call this directly.
func register_mod(mod: Reference, global_instance = null):
    # write stuff to mod.Global by default
    if (global_instance == null):
        global_instance = mod.Global
    var mod_root: String = global_instance.Root.rstrip("/")
    var mod_info
    # create ModInfo with the .ddmod file dictionary we collected in _init
    if (mod_root in _path_to_ddmod_json):
        mod_info = ModInfo.new(mod, _path_to_ddmod_json[mod_root])
        _unique_id_to_mod_info[mod_info.mod_meta["unique_id"]] = mod_info
    else:
        mod_info = ModInfo.new(mod)
    # add mod to registry 
    _registered_mods.append(mod_info)
    # add InstancedApiApi to mod global dictionary
    global_instance["API"] = _api_api._instance(mod_info)
    emit_signal("mod_registered", mod_info)

func get_mod_info(mod_id: String):
    return _unique_id_to_mod_info[mod_id]

func get_mod_list():
    return _registered_mods.duplicate()

func _unload():
    # disconnect all signals
    Engine.disconnect("_lib_register_mod", self, "register_mod")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)
            
# utility method for recursively finding all files with file extension file_ext in path
static func _get_all_files(path: String, file_ext := "", files := []):
    var dir = Directory.new()

    if dir.open(path) == OK:
        dir.list_dir_begin(true, true)

        var file_name = dir.get_next()

        while file_name != "":
            if dir.current_is_dir():
                files = _get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, files)
            else:
                if file_ext and file_name.get_extension() != file_ext:
                    file_name = dir.get_next()
                    continue

                files.append(dir.get_current_dir().plus_file(file_name))

            file_name = dir.get_next()
    else:
        print("An error occurred when trying to access %s." % path)

    return files

## Data class for storing the mod script and the mods ddmod json entries
class ModInfo:
    var mod
    var mod_meta: Dictionary

    func _init(_mod, ddmod_json: Dictionary = {}):
        mod = _mod
        mod_meta = ddmod_json