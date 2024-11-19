class_name ModConfigApi
## https://creepycre.github.io/_Lib/ModConfigApi/

class ConfigBuilder: const import = "api/config/config_builder.gd/"
class WrappedControlConfigNode: const import = "api/config/config_builder.gd/WrappedControlConfigNode"

const CLASS_NAME = "ModConfigApi"
var LOGGER: Object

var _preferences_window_api
var _input_map_api
var _copy_dir_func: FuncRef

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
var _shortcuts_node: VBoxContainer
var _shortcuts_tree_node: Tree
var _mod_tree: Tree
var _edit_icon: Texture
var _add_icon: Texture
var _remove_icon: Texture

var _blocker
var _waiting_for_input: bool = false
var _pressed_item: TreeItem = null
var _agents: Array = []
var _busy: bool = false

func _init(logger: Object, preferences_window_api, input_map_api, loader, active_mods: Array, copy_dir_func: FuncRef):
    LOGGER = logger.for_class(self)
    # grab some of the vanilla icons
    var theme = load(ProjectSettings.get_setting("gui/theme/custom"))
    _edit_icon = theme.get_icon("Edit", "EditorIcons")
    _add_icon = theme.get_icon("Add", "EditorIcons")
    _remove_icon = theme.get_icon("Remove", "EditorIcons")

    _preferences_window_api = preferences_window_api
    _input_map_api = input_map_api
    _copy_dir_func = copy_dir_func

    # load resources
    var texture_normal: Texture = loader.load_icon("cog_normal.png")
    var texture_disabled: Texture = loader.load_icon("cog_disabled.png")
    
    # load and prepare scenes
    _mod_config_scene = loader.load_scene("ModConfig")
    _mod_menu = loader.load_scene("Mods").instance()
    _mods_panel = _mod_menu.get_node("ModPanel")
    _mod_list = _mods_panel.get_node("ModList")
    _mod_list.connect("item_selected", self, "_mod_selected")
    _mod_list.connect("nothing_selected", self, "_mod_selected")
    _mod_v_sep = _mods_panel.get_node("VSeparator")
    var mod_details_scene = loader.load_scene("ModDetails")

    # read mod dir from config and find all .ddmod files
    var config: ConfigFile = ConfigFile.new()
    config.load("user://config.ini")
    var mods_dir: String = config.get_value("Mods", "mods_directory")
    var ddmod_files: Array = _get_all_files(mods_dir, "ddmod")
    var file: File = File.new()

    # read in .ddmod files as json and use the entries to construct mod details screen
    for ddmod_file in ddmod_files:
        file.open(ddmod_file, File.READ)
        var mod_info: Dictionary = JSON.parse(file.get_as_text()).result
        file.close()
        # ignore mod if not active
        if (not active_mods.has(mod_info.get("unique_id"))):
            continue
        var mod_details = mod_details_scene.instance()
        var settings_button: TextureButton = mod_details.get_node("InfoMargins/HBoxContainer/Settings")
        settings_button.texture_normal = texture_normal
        settings_button.texture_disabled = texture_disabled
        _mod_config_buttons[mod_info.get("unique_id")] = settings_button
        var icon_location: String = ddmod_file.get_base_dir() + "/preview.png"
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
    
    # use PreferencesWindowApi to add mod menu to preferences window and connect the back button signal
    preferences_window_api.create_category("Mods", _mod_menu)
    _mod_menu.connect("back_pressed", self, "_back_pressed")

    # aquire the vanilla InputEvent blocker
    var _preferences_window: WindowDialog = preferences_window_api.get_preferences_window()
    _blocker = _preferences_window.blocker

    # hide vanilla shortcuts config tree
    _shortcuts_node = _preferences_window.get_node("Margins/VAlign/Shortcuts")
    _shortcuts_tree_node = _shortcuts_node.get_node("Tree")
    _shortcuts_tree_node.hide()


    # we are making our own
    _mod_tree = Tree.new()
    _mod_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    _mod_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
    _mod_tree.set_hide_root(true)
    _mod_tree.set_columns(4)
    _mod_tree.set_column_title(0, "Action")
    _mod_tree.set_column_title(1, "Key")
    _mod_tree.set_column_expand(2, false)
    _mod_tree.set_column_min_width(2, 28)
    _mod_tree.set_column_expand(3, false)
    _mod_tree.set_column_min_width(3, 28)
    _mod_tree.set_column_titles_visible(true)
    _shortcuts_node.add_child(_mod_tree)
    _mod_tree.owner = _shortcuts_node
    _mod_tree.connect("button_pressed", self, "_on_mod_tree_button_pressed")
    input_map_api.get_or_append_event_emitter(_mod_tree).connect("unhandled_key_input", self, "_unhandled_key_input")
    preferences_window_api.connect("about_to_show", self, "_on_preferences_about_to_show")
    preferences_window_api.get_preferences_window().set_process_unhandled_key_input(false)

    # TODO: make this lazy
    input_map_api.connect("added_actions", self, "rebuild_tree")
    input_map_api.connect("erased_actions", self, "rebuild_tree")

## Creates a new ConfigBuilder for the mod with id mod_id. The mod config will automatically be saved into and loaded from config_file. 
func create_config(config_file: String, title: String, mod_id: String):
    # enable mod config button
    var config_button = _mod_config_buttons[mod_id]
    config_button.set_disabled(false)
    config_button.connect("pressed", self, "_config_button_pressed", [mod_id])
    
    #create ConfigBuilder and add the configs root node to the mod menu
    var mod_config = _mod_config_scene.instance()
    mod_config.get_node("TitlePanel/Title").text = title
    var wrapped = [WrappedControlConfigNode][0].new("", mod_config, "ConfigPanel/ScrollContainer/Config")
    wrapped.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    wrapped.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var config_builder = [ConfigBuilder][0].new(wrapped, config_file, _input_map_api)

    var root: Control = config_builder.get_root()
    _preferences_window_api.connect("apply_pressed", config_builder.get_agent(), "save_cfg")
    _mod_config_panels[mod_id] = root
    root.hide()
    _mod_menu.add_child(root)
    return config_builder

func _on_preferences_about_to_show():
    rebuild_tree()

func rebuild_tree(_ignored = null):
    # clear the entire shortcut config tree and everything related to it first
    for agent in _agents:
        if agent.is_connected("switched", self, "_switched"):
            agent.disconnect("switched", self, "_switched")
        if agent.is_connected("added", self, "_added_item"):
            agent.disconnect("added", self, "_added_item")
        if agent.is_connected("deleted", self, "_deleted_item"):
            agent.disconnect("deleted", self, "_deleted_item")
    _agents.clear()
    for mod in _mod_config_panels:
        var panel = _mod_config_panels[mod]
        if panel.has_method("_on_preferences_about_to_show"):
            panel._on_preferences_about_to_show()
    _mod_tree.clear()
    # then rebuild it
    var root: TreeItem = _mod_tree.create_item()
    var dungeondraft_root_item: TreeItem = _mod_tree.create_item()
    dungeondraft_root_item.set_text(0, "Dungeondraft")
    dungeondraft_root_item.set_selectable(0, false)
    dungeondraft_root_item.set_selectable(1, false)
    dungeondraft_root_item.set_selectable(2, false)
    dungeondraft_root_item.set_selectable(3, false)

    # create shortcut tree items based on vanilla shortcut tree items
    var default_item: TreeItem = _shortcuts_tree_node.get_root().get_children()
    while default_item != null:
        var item: TreeItem = _mod_tree.create_item(dungeondraft_root_item)
        item.set_meta("agent", default_item)
        item.set_text(0, default_item.get_text(0))
        item.set_selectable(0, false)

        item.set_text(1, default_item.get_text(1))
        item.set_selectable(1, false)

        item.add_button(2, _edit_icon)
        item.set_selectable(3, false)
        default_item = default_item.get_next()
    
    # create shortcut tree items based on actions registed to InputMapApi
    _add_actions_to_tree(root, _input_map_api._mod_actions)

func _add_actions_to_tree(root: TreeItem, actions: Dictionary):
    for name in actions:
        var entry = actions[name]
        if entry is Dictionary:
            var category: TreeItem = _mod_tree.create_item(root)
            category.set_text(0, name)
            category.set_selectable(0, false)
            category.set_selectable(1, false)
            category.set_selectable(2, false)
            category.set_selectable(3, false)
            _add_actions_to_tree(category, entry)
        else:
            if entry is Array:
                entry = entry[0]
            var agent = _input_map_api.get_agent(entry)
            var action_list: Array = InputMap.get_action_list(entry)

            var action_item: TreeItem = _mod_tree.create_item(root)
            agent.connect("switched", self, "_switched", [action_item])
            agent.connect("added", self, "_added_item", [action_item])
            agent.connect("deleted", self, "_deleted_item", [action_item])
            _agents.append(agent)
            action_item.set_meta("agent", agent)
            action_item.set_meta("index", 0)
            action_item.set_text(0, name)
            action_item.set_selectable(0, false)
            action_item.set_selectable(1, false)
            if action_list.size() == 0:
                if agent.is_saved():
                    action_item.add_button(2, _edit_icon)
                else:
                    action_item.set_selectable(2, false)
                action_item.set_selectable(3, false)
            else:
                var first_event = action_list.pop_front()
                action_item.set_meta("event", first_event)
                action_item.set_text(1, _input_map_api.event_as_string(first_event))
                if agent.is_saved():
                    action_item.add_button(2, _edit_icon)
                    action_item.add_button(3, _add_icon)
                else:
                    action_item.set_selectable(2, false)
                    action_item.set_selectable(3, false)
                var index: int = 1
                for event in action_list:
                    var event_item: TreeItem = _mod_tree.create_item(action_item)
                    event_item.set_meta("agent", agent)
                    event_item.set_meta("index", index)
                    event_item.set_meta("event", event)
                    event_item.set_selectable(0, false)
                    event_item.set_text(1, _input_map_api.event_as_string(event))
                    event_item.set_selectable(1, false)
                    if agent.is_saved():
                        event_item.add_button(2, _edit_icon)
                        event_item.add_button(3, _remove_icon)
                    else:
                        event_item.set_selectable(2, false)
                        event_item.set_selectable(3, false)
                    index += 1

func _on_mod_tree_button_pressed(item: TreeItem, column: int, id: int):
    var meta = item.get_meta("agent")
    if column == 2:
        if meta is TreeItem:
            _preferences_window_api.get_preferences_window()._on_Tree_button_pressed(meta, column, id)
        _pressed_item = item
        _waiting_for_input = true
        item.set_selectable(1, true)
        item.select(1)
        item.set_text(1, "--- press new shortcut key ---")
    elif column == 3:
        _busy = true
        var agent = meta
        var index: int = item.get_meta("index")
        if index == 0:
            item.set_collapsed(false)
            var new_item: TreeItem = _mod_tree.create_item(item)
            new_item.set_meta("agent", agent)
            new_item.set_selectable(0, false)
            new_item.add_button(2, _edit_icon)
            new_item.add_button(3, _remove_icon)
            new_item.set_selectable(1, true)
            new_item.select(1)
            new_item.set_text(1, "--- press new shortcut key ---")
            var child_item: TreeItem = item.get_children()
            var new_index = 1
            while child_item != null:
                new_index += 1
                child_item = child_item.get_next()
            new_item.set_meta("index", new_index)
            agent.added_item()
            _pressed_item = new_item
            _waiting_for_input = true
        else:
            var child_item: TreeItem = item.get_next()
            item.free()
            var next_index = index + 1
            while child_item != null:
                child_item.set_meta("index", next_index)
                next_index += 1
                child_item = child_item.get_next()
            agent.deleted_item(index)
        _busy = false


func _unhandled_key_input(event: InputEventKey, agent):
    if (_waiting_for_input and not event.is_pressed()):
        _pressed_item.set_selectable(1, false)
        _pressed_item.deselect(1)
        _pressed_item.set_text(1, _input_map_api.event_as_string(event))
        _waiting_for_input = false
        var meta = _pressed_item.get_meta("agent")
        if not meta is TreeItem:
            _busy = true
            var prev_event = _pressed_item.get_meta("event") if _pressed_item.has_meta("event") else null
            event.pressed = true
            var index: int = _pressed_item.get_meta("index")
            meta.switch(prev_event, event, index)
            if prev_event == null and index == 0:
                _pressed_item.set_selectable(3, true)
                _pressed_item.add_button(3, _add_icon)
            _busy = false
        agent.accept_event()
    _preferences_window_api.get_preferences_window()._UnhandledKeyInput(event)

func _switched(from: InputEventKey, to: InputEventKey, index: int, item: TreeItem):
    if _busy:
        return
    if index == 0:
        item.set_text(1, _input_map_api.event_as_string(to) if to != null else "")
        item.set_meta("event", to)
        if from == null:
            item.set_selectable(3, true)
            item.add_button(3, _add_icon)
    else:
        var sub_item: TreeItem = item.get_children()
        while sub_item != null:
            if sub_item.get_meta("index") == index:
                sub_item.set_text(1, _input_map_api.event_as_string(to) if to != null else "")
                sub_item.set_meta("event", to)
                break
            sub_item = sub_item.get_next()

func _added_item(root: TreeItem):
    if _busy:
        return
    var agent = root.get_meta("agent")
    var new_item: TreeItem = _mod_tree.create_item(root)
    new_item.set_meta("agent", agent)
    new_item.set_selectable(0, false)
    new_item.set_selectable(1, false)
    new_item.add_button(2, _edit_icon)
    new_item.add_button(3, _remove_icon)
    var child_item: TreeItem = root.get_children()
    var new_index = 1
    while child_item != null:
        new_index += 1
        child_item = child_item.get_next()
    new_item.set_meta("index", new_index)
    agent.added_item(agent)

func _deleted_item(index: int, root: TreeItem):
    if _busy:
        return
    var item = root.get_children()
    while (item != null and item.get_meta("index") != index):
        item = item.get_next()
    if (item == null):
        return
    var child_item: TreeItem = item.get_next()
    item.free()
    var next_index = index + 1
    while child_item != null:
        child_item.set_meta("index", next_index)
        next_index += 1
        child_item = child_item.get_next()

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
    _preferences_window_api.get_preferences_window().set_process_unhandled_key_input(true)
    _mod_list.disconnect("item_selected", self, "_mod_selected")
    _mod_list.disconnect("nothing_selected", self, "_mod_selected")
    for signal_dict in get_signal_list():
        var signal_name = signal_dict.name
        for callable_dict in get_signal_connection_list(signal_name):
            disconnect(signal_name, callable_dict.target, callable_dict.method)
    
    _shortcuts_node.remove_child(_mod_tree)
    _shortcuts_tree_node.show()

## creates instanced ModConfigApi
func _instance(mod_info):
    return InstancedModConfigApi.new(LOGGER, self, mod_info)


class InstancedModConfigApi:

    const CLASS_NAME = "InstancedModConfigApi"
    var LOGGER: Object

    var _mod_config_api
    var _mod_info

    func _init(logger: Object, mod_config_api, mod_info):
        LOGGER = logger.for_class(self)
        _mod_config_api = mod_config_api
        _mod_info = mod_info
    
    func create_config(config_file: String = "user://mod_config/" + _mod_info.mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_") + ".json", title: String = _mod_info.mod_meta["name"], mod_id: String = _mod_info.mod_meta["unique_id"]):
        # backwards compat for _Lib 1.0.0-beta where the argument order was reversed
        if (mod_id.ends_with(".json")):
            return _mod_config_api.create_config(mod_id, title, config_file)
        
        return _mod_config_api.create_config(config_file, title, mod_id)

    func get_or_create_path(path = "user://mod_config/" + _mod_info.mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_"), default = null):
        if path == null:
            path = "user://mod_config/" + _mod_info.mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_")
        if path.is_rel_path():
            path = "user://mod_config/" + _mod_info.mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_") + "/" + path
        elif not path.is_abs_path(): # if the provided path is not even a path, just return the default one
            path = "user://mod_config/" + _mod_info.mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_")
        
        var dir: Directory = Directory.new()
        if dir.dir_exists(path) or dir.file_exists(path): # path already exists
            return path
        
        if default == null: # nothing to copy, assume the target path is a directory
            dir.make_dir_recursive(path)
            return path
        
        if default.is_rel_path():
            default = _mod_info.mod.Global.Root + "../../" + default
        
        elif not default.is_abs_path():
            LOGGER.error("default path \"%s\" for \"%s\" is malformed!", [default, _mod_info.mod_meta["name"]])
            return null # treat null as error
        
        var base_dir: String = path.get_base_dir()
        if not dir.dir_exists(base_dir):
            dir.make_dir_recursive(base_dir)

        if dir.file_exists(default):
            dir.copy(default, path)
        elif dir.dir_exists(default):
            _mod_config_api._copy_dir_func.call_func(default, path)
        else:
            LOGGER.error("default path \"%s\" for \"%s\" does not exist!", [default, _mod_info.mod_meta["name"]])
            return null # treat null as error

        return path