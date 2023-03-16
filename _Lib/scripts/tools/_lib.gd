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
    loader = load(_global.Root + "../util/file_loading_helper.gd").new(_global.Root + "../../")

    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).connect("visibility_changed", self, "_loading_box_visibility_changed")

    api = loader.init_api("api_api")
    api.register("ModSignalingAPI", loader.init_api("mod_signaling_api"))
    api.ModSignalingAPI.add_user_signal("unload")
    api.register("InputMapApi", loader.init_api("input_map_api", _global.Editor.owner))
    api.register("PreferencesWindowApi", loader.init_api("preferences_window_api", _global.Editor.Windows.Preferences))
    api.register("ModConfigApi", loader.init_api("mod_config_api", api.PreferencesWindowApi, api.InputMapApi, loader))

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

func _unload():
    var _master = _global.Editor.owner
    _master.get_node(_master.loadingBoxPath).disconnect("visibility_changed", self, "_loading_box_visibility_changed")
    Engine.disconnect("_lib_register_mod", self, "register_mod")
    self.Global.API.ModSignalingApi.emit_signal("unload")
    self.Global.API._unload()