var script_class = "tool"

var api
var loader
var _global: Dictionary
var _script

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
    # get a FileLoadingHelper
    var loader_script = load(_global.Root + "../util/file_loading_helper.gd")
    loader = loader_script.new(_global.Root + "../../")


    var _master = _global.Editor.owner
    # see _loading_box_visibility_changed()
    _master.get_node(_master.loadingBoxPath).connect("visibility_changed", self, "_loading_box_visibility_changed")

    api = init_api("api_api")
    api.register("AccessorApi", init_api("accessor_api"))
    api.register("ModRegistry", init_api("mod_registry", api, _script.GetActiveMods()))
    api.register("Util", init_api("util", loader_script))
    api.register("ModSignalingApi", init_api("mod_signaling_api", _global.Editor.Infobar))
    api.register("InputMapApi", init_api("input_map_api", _global.Editor.owner))
    api.register("PreferencesWindowApi", init_api("preferences_window_api", _global.Editor.Windows.Preferences))
    api.register("ModConfigApi", init_api("mod_config_api", api.PreferencesWindowApi, api.InputMapApi, loader, _script.GetActiveMods()))
    api.register("HistoryApi", init_api("history_api", _global.Editor, api.AccessorApi.config()))
    api.register("ComponentsApi", init_api("components_api", api.ModSignalingApi, _global.World))

    api.ModRegistry.register(self, _global)

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
func init_api(api_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
    if (arg9 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elif (arg8 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elif (arg7 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elif (arg6 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    elif (arg5 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5)
    elif (arg4 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4)
    elif (arg3 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2, arg3)
    elif (arg2 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1, arg2)
    elif (arg1 != null):
        return loader.load_script("api/" + api_name).new(arg0, arg1)
    elif (arg0 != null):
        return loader.load_script("api/" + api_name).new(arg0)
    else:
        return loader.load_script("api/" + api_name).new()

func _unload():
    # disconnect our unload detector
    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).disconnect("visibility_changed", self, "_loading_box_visibility_changed")
    # unload everything recursively
    _global.API.ModSignalingApi.emit_signal("unload")
    _global.API._unload()