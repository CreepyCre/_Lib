class_name ModConfigApi

var _preferences_window_api
var _config_builder_script
var _mod_config_scene
var _details_nodes: Array = []
var _current_details = null
var _mod_menu: Control
var _mods_panel: Control
var _mod_v_sep: VSeparator
var _mod_list: ItemList
var _mod_config_buttons: Dictionary = {}
var _mod_config_panels: Dictionary = {}
var _active_mod_config = null

func _init(preferences_window_api, loader):
    _preferences_window_api = preferences_window_api
    _config_builder_script = loader.load_script("api/config/config_builder")
    _mod_config_scene = loader.load_scene("ModConfig")
    var config: ConfigFile = ConfigFile.new()
    config.load("user://config.ini")
    var mods_dir: String = config.get_value("Mods", "mods_directory")
    var active_mods: Array = config.get_value("Mods", "active_mods")
    var ddmod_files: Array = get_all_files(mods_dir, "ddmod")
    var file: File = File.new()
    _mod_menu = loader.load_scene("Mods").instance()
    _mods_panel = _mod_menu.get_node("ModPanel")
    _mod_list = _mods_panel.get_node("ModList")
    _mod_list.connect("item_selected", self, "_mod_selected")
    _mod_list.connect("nothing_selected", self, "_mod_selected")
    _mod_v_sep = _mods_panel.get_node("VSeparator")
    var mod_details_scene = loader.load_scene("ModDetails")
    var texture_normal: Texture = loader.load_icon("cog_normal.png")
    var texture_disabled: Texture = loader.load_icon("cog_disabled.png")
    for ddmod_file in ddmod_files:
        file.open(ddmod_file, File.READ)
        var mod_info: Dictionary = JSON.parse(file.get_as_text()).result
        file.close()
        if (not active_mods.has(mod_info.get("unique_id"))):
            continue
        var mod_details = mod_details_scene.instance()
        var settings_button: TextureButton = mod_details.get_node("InfoMargins/HBoxContainer/Settings")
        settings_button.texture_normal = texture_normal
        settings_button.texture_disabled = texture_disabled
        _mod_config_buttons[mod_info.get("unique_id")] = settings_button
        var icon_location: String = ddmod_file.get_base_dir() + "/preview.png"
        print(icon_location)
        if file.file_exists(icon_location):
            mod_details.get_node("InfoMargins/HBoxContainer/ModIcon").texture = loader.load_texture_full_path(icon_location)
        if mod_info.has("name"):
            _mod_list.add_item(mod_info.get("name"))
            mod_details.get_node("InfoMargins/HBoxContainer/Info/ModName").append_bbcode("[u]" + mod_info.get("name") + "[/u]")
        else:
            _mod_list.add_item(mod_info.get("unique_id"))
            mod_details.get_node("InfoMargins/HBoxContainer/Info/ModName").append_bbcode("[u]" + mod_info.get("unique_id") + "[/u]")
        if mod_info.has("version"):
            mod_details.get_node("InfoMargins/HBoxContainer/Info/Version").append_bbcode("[color=gray]Version " + mod_info.get("version") + "[/color]")
        if mod_info.has("author"):
            mod_details.get_node("InfoMargins/HBoxContainer/Info/Author").append_bbcode("[color=gray]By " + mod_info.get("author") + "[/color]")
        if mod_info.has("description"):
            mod_details.get_node("DescriptionScroller/Margins/Description").append_bbcode(mod_info.get("description"))
        _details_nodes.append(mod_details)
        _mods_panel.add_child(mod_details)
    preferences_window_api.create_category("Mods", _mod_menu)
    _mod_menu.connect("back_pressed", self, "_back_pressed")

func create_config(mod_id: String, title: String, config_file: String):
    var config_button = _mod_config_buttons[mod_id]
    config_button.set_disabled(false)
    config_button.connect("pressed", self, "_config_button_pressed", [mod_id])
    var config_builder = _config_builder_script.config(title, config_file, _mod_config_scene, _config_builder_script)
    var root: Control = config_builder.get_root()
    _preferences_window_api.connect("apply_pressed", config_builder.get_agent(), "save_cfg")
    _mod_config_panels[mod_id] = root
    root.hide()
    _mod_menu.add_child(root)
    return config_builder

func _config_button_pressed(mod_id: String):
    _active_mod_config = _mod_config_panels[mod_id]
    _mods_panel.hide()
    _active_mod_config.show()
    _preferences_window_api.show_back()
    pass

func _back_pressed():
    _mods_panel.show()
    if _active_mod_config != null:
        _active_mod_config.hide()
        _active_mod_config = null
    _preferences_window_api.show_close()

func _mod_selected(id: int = -1):
    if _current_details != null:
        _current_details.hide()
    if id < 0:
        _mod_v_sep.hide()
        _mod_list.unselect_all()
        _current_details = null
    else:
        _mod_v_sep.show()
        _current_details = _details_nodes[id]
        _current_details.show()

func get_all_files(path: String, file_ext := "", files := []):
        var dir = Directory.new()
    
        if dir.open(path) == OK:
            dir.list_dir_begin(true, true)
    
            var file_name = dir.get_next()
    
            while file_name != "":
                if dir.current_is_dir():
                    files = get_all_files(dir.get_current_dir().plus_file(file_name), file_ext, files)
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
    _mod_list.disconnect("item_selected", self, "_mod_selected")
    _mod_list.disconnect("nothing_selected", self, "_mod_selected")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)