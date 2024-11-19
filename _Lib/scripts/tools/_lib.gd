var script_class = "tool"

const CLASS_NAME = "_LibMain"
var LOGGER = null

var api
var instanced_class_loader
var config
var _global: Dictionary
var _script

var unique_id_to_root = {}
var path_to_ddmod_json = {}

const UPPERCASE_LETTER: String = "[^A-Z]([A-Z])"
var uppercase_letter: RegEx = RegEx.new()

# All _init methods run before any start() methods.
# _init method also runs before each individuals scripts Global and Script are set, so we don't have them available here.
# Global and Script are set before the next tool script runs its _init method.
# Therefore if we use signals to ping pong between two tool scripts (this one and and temp_singleton.gd) in their _init methods
# one of the tool scripts is guaranteed to have their Global and Script set which we then use in _post_init.
# We also ensure tool script load order is irrelevant by emitting signals both ways.
func _init():
    # add a signal temp_singleton.gd can use to call _post_init
    if (not Engine.has_signal("_lib_internal_post_init")):
        Engine.add_user_signal("_lib_internal_post_init", [{"name": "script_instance", "type": TYPE_OBJECT}])
    Engine.connect("_lib_internal_post_init", self, "_post_init")
    # emit signal to temp_singleton.gd if it loaded first
    if (Engine.has_signal("_lib_internal_temp_singleton")):
        Engine.emit_signal("_lib_internal_temp_singleton")

# effective _init method
func _post_init(script_instance: Reference = self):
    # disconnect signal so _post_init won't be called again
    Engine.disconnect("_lib_internal_post_init", self, "_post_init")
    # to ensure temp_singleton.gd disconnects from this signal
    Engine.emit_signal("_lib_internal_temp_singleton")

    # use these from now on
    _global = script_instance.Global
    _script = script_instance.Script

    # read in .ddmod files
    aquire_active_ddmod_files()

    var _master = _global.Editor.owner
    # see _loading_box_visibility_changed()
    _master.get_node(_master.loadingBoxPath).connect("visibility_changed", self, "_loading_box_visibility_changed")

    uppercase_letter.compile(UPPERCASE_LETTER)


    # create the Logger
    var general_logger = load(_global.Root + "../api/logger.gd").new()
    LOGGER = general_logger.InstancedLogger.new(general_logger, "_Lib")

    # create the ClassLoader
    LOGGER.info("Initializing ClassLoader")
    var class_loader = load(_global.Root + "../api/class_loader.gd").new(LOGGER, unique_id_to_root)
    instanced_class_loader = class_loader.InstancedClassLoader.new(class_loader, "CreepyCre._Lib")

    LOGGER.info("Creating ApiApi")
    api = instanced_class_loader.load_or_get("api/api_api.gd/").new(LOGGER)
    LOGGER.info("Registering ClassLoader")
    api.register("ClassLoader", class_loader)
    LOGGER.info("Registering Logger. Who came first?")
    api.register("Logger", general_logger)
    LOGGER.info("Registering ModRegistry")
    set_up_api("ModRegistry", api, path_to_ddmod_json)
    api.ModRegistry.register(self, _global)
    LOGGER.info("Registering AccessorApi")
    set_up_api("AccessorApi")
    LOGGER.info("Registering Util")
    set_up_api("Util")
    LOGGER.info("Registering ModSignalingApi")
    set_up_api("ModSignalingApi", _global.Editor.Infobar)
    LOGGER.info("Registering InputMapApi")
    set_up_api("InputMapApi", _global.Editor.owner)
    LOGGER.info("Registering PreferencesWindowApi")
    set_up_api("PreferencesWindowApi", _global.Editor.Windows.Preferences)
    LOGGER.info("Registering ModConfigApi")
    set_up_api("ModConfigApi", api.PreferencesWindowApi, api.InputMapApi, api.Util.create_loading_helper(_global.Root + "../../"), _script.GetActiveMods(), funcref(api.Util, "copy_dir"))
    LOGGER.info("Registering HistoryApi")
    set_up_api("HistoryApi", _global.Editor, api.AccessorApi.config())
    LOGGER.info("Registering ComponentsApi")
    set_up_api("ComponentsApi", api.ModSignalingApi, api.HistoryApi, _global.World, _global.ModMapData)
    LOGGER.info("Registering LayerApi")
    set_up_api("LayerApi", _global.API.ComponentsApi, _global.World)

    # set up _Lib config
    var builder = _global.API.ModConfigApi.create_config()
    config = builder\
                .h_box_container().enter()\
                    .label("Log Level: ")\
                    .option_button("log_level", api.Logger.get_log_level(), api.Logger._CONFIG_LOOKUP.keys())\
                        .connect_current("updated", api.Logger, "set_log_level")\
                .exit()\
                .build()
    
    api.Logger.set_log_level(config.log_level)

func start():
    pass

func update(delta):
    api._update(delta)

# this is a trick to detect when mods are unloaded
# it happens only when another map is loaded wich fully unloads and then loads mods again
# we do this by detecting when the loading box becomes visible
func _loading_box_visibility_changed():
    # check if new map is actually being loaded
    if not self.Global.Editor.owner.IsLoadingMap:
        return
    _unload()

# varargs hack
func set_up_api(api_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
    var snake_case = camel_to_snake_case(api_name)
    if (arg9 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9))
    elif (arg8 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8))
    elif (arg7 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7))
    elif (arg6 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4, arg5, arg6))
    elif (arg5 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4, arg5))
    elif (arg4 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3, arg4))
    elif (arg3 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2, arg3))
    elif (arg2 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1, arg2))
    elif (arg1 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0, arg1))
    elif (arg0 != null):
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER, arg0))
    else:
        api.register(api_name, instanced_class_loader.load_or_get("api/" + snake_case + ".gd/").new(LOGGER))

func camel_to_snake_case(string: String) -> String:
    var matches: Array = uppercase_letter.search_all(string)
    var string_pieces: Array = []
    var final_index: int = 0
    for reg_match in matches:
        string_pieces.append(string.substr(final_index, reg_match.get_start() - final_index + 1))
        string_pieces.append("_")
        final_index = reg_match.get_end() - 1
    string_pieces.append(string.substr(final_index))
    return PoolStringArray(string_pieces).join("").to_lower()

func aquire_active_ddmod_files():
    var active_mods = _script.GetActiveMods()
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
        path_to_ddmod_json[folder] = ddmod_json
        unique_id_to_root[ddmod_json["unique_id"]] = folder

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

func _unload():
    # disconnect our unload detector
    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).disconnect("visibility_changed", self, "_loading_box_visibility_changed")
    # unload everything recursively
    _global.API.ModSignalingApi.emit_signal("unload")
    _global.API._unload()

