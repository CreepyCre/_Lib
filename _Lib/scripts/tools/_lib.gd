var script_class = "tool"

const CLASS_NAME = "_LibMain"
var LOGGER = null

var api
var instanced_class_loader
var config
var _global: Dictionary
var _script

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

    # unload on scene unload
    var _master = _global.Editor.owner
    _master.connect("tree_exiting", self, "_unload")

    uppercase_letter.compile(UPPERCASE_LETTER)


    # create the Logger
    var general_logger = load(_global.Root + "../api/logger.gd").new()
    LOGGER = general_logger.InstancedLogger.new(general_logger, "_Lib")

    # create AccessorApi
    LOGGER.info("Initializing AccessorApi")
    var accessor_api = load(_global.Root + "../api/accessor_api.gd").new(LOGGER)

    LOGGER.info("Indexing active mods")
    var active_mods: Dictionary = {}
    var core_mods: Dictionary = {}
    index_active_mods(active_mods, core_mods, accessor_api.config().get_value("Mods", "mods_directory"))

    # create the ClassLoader
    LOGGER.info("Initializing ClassLoader")
    var unique_id_to_root: Dictionary = {}
    for mod_id in active_mods:
        unique_id_to_root[mod_id] = active_mods[mod_id].root
    var class_loader = load(_global.Root + "../api/class_loader.gd").new(LOGGER, unique_id_to_root)
    instanced_class_loader = class_loader.InstancedClassLoader.new(class_loader, "CreepyCre._Lib")

    LOGGER.info("Creating ApiApi")
    api = instanced_class_loader.load_or_get("api/api_api.gd/").new(LOGGER)
    api.connect("api_registered", self, "api_registered")
    LOGGER.info("Registering ClassLoader")
    api.register("ClassLoader", class_loader)
    LOGGER.info("Registering Logger. Who came first?")
    api.register("Logger", general_logger)
    LOGGER.info("Registering ModRegistry")
    set_up_api("ModRegistry", api, active_mods)
    api.ModRegistry.register(self, _global)
    LOGGER.info("Registering AccessorApi")
    api.register("AccessorApi", accessor_api)
    LOGGER.info("Registering Util")
    set_up_api("Util", _master)
    var loading_helper = api.Util.create_loading_helper(_global.Root + "../../")
    LOGGER.info("Loading _Lib icons.")
    load_icons(loading_helper)
    LOGGER.info("Registering ModSignalingApi")
    set_up_api("ModSignalingApi", _global.Editor.Infobar)
    LOGGER.info("Registering InputMapApi")
    set_up_api("InputMapApi", _global.Editor.owner)
    LOGGER.info("Registering MenuBarApi")
    set_up_api("MenuBarApi", _global.Editor.get_node("VPartition/MenuBar/MenuAlign"))
    LOGGER.info("Registering PreferencesWindowApi")
    set_up_api("PreferencesWindowApi", _global.Editor.Windows.Preferences)
    LOGGER.info("Registering ModConfigApi")
    set_up_api("ModConfigApi", api.PreferencesWindowApi, api.InputMapApi, loading_helper, core_mods, funcref(api.Util, "copy_dir"))
    LOGGER.info("Registering HistoryApi")
    set_up_api("HistoryApi", _global.Editor)
    LOGGER.info("Registering ComponentsApi")
    set_up_api("ComponentsApi", api.ModSignalingApi, api.HistoryApi, _global.World, _global.ModMapData)
    LOGGER.info("Registering LayerApi")
    set_up_api("LayerApi", _global.API.ComponentsApi, _global.World, _global.Editor.Tools["SelectTool"], _global.Editor.Toolset.GetToolPanel("SelectTool"))
    LOGGER.info("Registering UpdateChecker")
    set_up_api("UpdateChecker", _global.API.Util, loading_helper, core_mods, _global.API.MenuBarApi)
    var update_checker = _global.API.UpdateChecker
    update_checker.register(update_checker.builder()\
                                            .fetcher(update_checker.github_fetcher("CreepyCre", "_Lib"))\
                                            .downloader(update_checker.github_downloader("CreepyCre", "_Lib"))\
                                            .build())

    var no_show_button: Button = api.UpdateChecker._mod_versions_window.get_node("MarginContainer/VBoxContainer/HBoxContainer/NoShow")

    # set up _Lib config
    var builder = _global.API.ModConfigApi.create_config()
    config = builder\
                .h_box_container().enter()\
                    .label("Log Level")\
                    .option_button("log_level", api.Logger.get_log_level(), api.Logger._CONFIG_LOOKUP.keys())\
                        .connect_prop("updated", api.Logger, "set_log_level")\
                .exit()\
                .check_box("show_mod_versions_on_launch", true, "Show mod versions window on launch.")\
                    .connect_to_prop("loaded", no_show_button, "visible")\
                    .connect_to_prop("updated", no_show_button, "visible")\
                .build()
    
    api.Logger.set_log_level(config.log_level)
    if not config.show_mod_versions_on_launch:
        api.UpdateChecker._show_mod_versions.disable()
    no_show_button.connect("pressed", self, "disable_show_mod_versions_on_launch")
    LOGGER.info("Finished Loading.")

func format_slider_label(value, label: Label):
    label.text = "%4d%%" % (value * 100)

func disable_show_mod_versions_on_launch():
    config.show_mod_versions_on_launch = false
    config.save_cfg(true)

func api_registered(api_id: String, the_api: Object):
    match api_id:
        "ScalingApi":
            LOGGER.info("Setting up UI scaling.")
            api.PreferencesWindowApi.scaling_api_registered(the_api)
            api.ModConfigApi.scaling_api_registered(the_api)

func start():
    pass

func update(delta):
    api._update(delta)

# loads all _Lib textures and adds them into the default theme.
func load_icons(loader):
    register_icon("Config", loader.load_icon("cog_normal.png"))
    register_icon("ConfigDisabled", loader.load_icon("cog_disabled.png"))
    var throbber: AnimatedTexture = AnimatedTexture.new()
    throbber.frames = 8
    throbber.fps = 8
    for frame in [1, 2, 3, 4, 5, 6, 7, 8]:
        throbber.set_frame_texture(frame - 1, Misc.get_global().Theme.get_icon("Progress%d" % frame, "EditorIcons"))
    register_icon("Throbber", throbber)

func register_icon(name: String, texture: Texture):
    Misc.get_global().Theme.set_icon(name, "CreepyCre._Lib", texture)

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

func index_active_mods(active_mods: Dictionary, core_mods: Dictionary, mods_dir):
    # discover all ddmod files within mods folders
    var ddmod_files: Array = _get_all_files(OS.get_executable_path().get_base_dir().plus_file("mods"), "ddmod")
    if mods_dir != null:
        for file in _get_all_files(mods_dir, "ddmod"):
            if not file in ddmod_files:
                ddmod_files.append(file)
    
    # read in all ddmod files, index them via unique_id
    var all_mod_infos: Dictionary = {}
    var file: File = File.new()
    for ddmod_file in ddmod_files:
        # read in .ddmod files as json into dictionary
        file.open(ddmod_file, File.READ)
        var ddmod_json: Dictionary = JSON.parse(file.get_as_text()).result
        file.close()

        all_mod_infos[ddmod_json["unique_id"]] = ModInfo.new(null, ddmod_file.get_base_dir().rstrip("/"), ddmod_json)
    
    # index all active mods (recursively in case of dependencies)
    for mod_id in _script.GetActiveMods():
        _index_mod(active_mods, core_mods, mod_id, all_mod_infos)

func _index_mod(active_mods: Dictionary, core_mods: Dictionary, mod_id: String, all_mod_infos: Dictionary):
    # checks if mod even exists
    if not mod_id in all_mod_infos:
        LOGGER.error("Could not find ddmod file while indexing mod with id \"%s\"!", [mod_id])
        return
    var mod_info = all_mod_infos[mod_id]
    # this ordering ensures that dependencies are indexed first
    if "dependencies" in mod_info.mod_meta:
        for mod_id in mod_info.mod_meta["dependencies"]:
            _index_mod(active_mods, core_mods, mod_id, all_mod_infos)
    if mod_id in active_mods:
         return
    active_mods[mod_id] = mod_info
    # build module tree, this is why the ordering is important
    if "parent" in mod_info.mod_meta:
        active_mods[mod_info.mod_meta["parent"]].modules[mod_id] = mod_info
    else:
        core_mods[mod_id] = mod_info
    
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
    # unload everything recursively
    api.ModSignalingApi.emit_signal("unload")
    LOGGER.info("Unloading _Lib components.")
    api._unload()

class Misc:
    static func get_global():
        return Global

## Data class for storing the mod script and the mods ddmod json entries
class ModInfo:
    var mod # optional
    var root
    var mod_meta: Dictionary
    var modules: Dictionary

    func _init(_mod, _root, ddmod_json: Dictionary = {}):
        mod = _mod
        root = _root
        mod_meta = ddmod_json