var script_class = "tool"

var api
var loader
var _global: Dictionary
var _script

func _init():
    if (not Engine.has_signal("_lib_register_mod")):
        Engine.add_user_signal("_lib_register_mod", [{"name": "mod", "type": TYPE_OBJECT}])
    Engine.connect("_lib_register_mod", self, "register_mod")

    if (not Engine.has_signal("_lib_internal_post_init")):
        Engine.add_user_signal("_lib_internal_post_init", [{"name": "script_instance", "type": TYPE_OBJECT}])
    Engine.connect("_lib_internal_post_init", self, "_post_init")
    if (Engine.has_signal("_lib_internal_temp_singleton")):
        Engine.emit_signal("_lib_internal_temp_singleton")

func _post_init(script_instance: Reference = self):
    Engine.disconnect("_lib_internal_post_init", self, "_post_init")
    # to ensure it actually disconnects
    Engine.emit_signal("_lib_internal_temp_singleton")

    _global = script_instance.Global
    _script = script_instance.Script
    var loader_script = load(_global.Root + "../util/file_loading_helper.gd")
    loader = loader_script.new(_global.Root + "../../")

    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).connect("visibility_changed", self, "_loading_box_visibility_changed")

    api = init_api("api_api")
    api.register("Util", init_api("util", loader_script))
    api.register("ModSignalingApi", init_api("mod_signaling_api"))
    api.register("InputMapApi", init_api("input_map_api", _global.Editor.owner))
    api.register("PreferencesWindowApi", init_api("preferences_window_api", _global.Editor.Windows.Preferences))
    api.register("ModConfigApi", init_api("mod_config_api", api.PreferencesWindowApi, api.InputMapApi, loader))

    register_mod(self, _global)

func start():
    pass

func register_mod(mod: Reference, global_instance = null):
    if (global_instance == null):
        global_instance = mod.Global
    add_global(global_instance, "API", api)

func add_global(global_instance: Dictionary, key, instance, path: Array = []):
    var target = global_instance
    for step in path:
        target = target[step]
    target[key] = instance

func _loading_box_visibility_changed():
    if not self.Global.Editor.owner.IsLoadingMap:
        return
    _unload()

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
    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).disconnect("visibility_changed", self, "_loading_box_visibility_changed")
    Engine.disconnect("_lib_register_mod", self, "register_mod")
    _global.API.ModSignalingApi.emit_signal("unload")
    _global.API._unload()