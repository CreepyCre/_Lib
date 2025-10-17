class_name LayerApi

const CLASS_NAME = "LayerApi"
var LOGGER: Object

const LOCKED_LAYERS = {
    -500: "Terrain",
    -300: "Caves",
    -200: "Floor",
       0: "Water",
     500: "Portals",
     600: "Walls",
     800: "Roofs"
}

enum ExistingTargetFlag {
    FAIL,
    SKIP,
    SLOPPY_MERGE,
    OVERWRITE
}

var _world: Node2D
var _select_tool
var _select_tool_panel
var _components_api
var _global_layers_component: GlobalLayersComponent

func _init(logger: Object, components_api, world, select_tool, select_tool_panel):
    LOGGER = logger.for_class(self)
    _world = world
    _select_tool = select_tool
    _select_tool_panel = select_tool_panel
    _components_api = components_api
    _global_layers_component = components_api.register("global_layers", GlobalLayersComponent, components_api.FLAG_WORLD).get_component(world)

    _rebuild_layer_filter()

    components_api.connect("level_added", self, "_level_added")

# TODO: make everything return history records

func add_layer(layer: int, name: String, level: Node2D = null) -> void:
    add_layers({layer: name}, level)

func add_layers(layers: Dictionary, level: Node2D = null) -> void:
    if (level != null):
        _add_layers(layers, level)
        return
    _global_layers_component.add_layers(layers)
    for level in _world.AllLevels:
        _add_layers(layers, level)
    

func _add_layers(layers: Dictionary, level: Node2D) -> void:
    var current_layers: Dictionary = get_layers(level)
    var new_layers: Dictionary = {}
    for layer in layers:
        if (not layer in current_layers):
            new_layers[layer] = layers[layer]
    level.LoadLayers(new_layers)
    _rebuild_layer_filter()

func remove_layer(layer: int, level: Node2D = null, delete_nodes: bool = true) -> void:
    remove_layers([layer], level, delete_nodes)

func remove_layers(layers: Array, level: Node2D = null, delete_nodes: bool = true) -> void:
    if (level != null):
        _remove_layers(layers, level, delete_nodes)
        return
    _global_layers_component.remove_layers(layers)
    for level in _world.AllLevels:
        _remove_layers(layers, level, delete_nodes)

func _remove_layers(layers: Array, level: Node2D, delete_nodes: bool) -> void:
    var current_layers: Dictionary = get_user_layers(level)
    var new_layers: Dictionary = {}
    for layer in current_layers:
        if (not layer in layers):
            new_layers[layer] = current_layers[layer]
    level.CreateDefaultLockedLayers()
    level.LoadLayers(new_layers)

    if (not delete_nodes):
        _rebuild_layer_filter()
        return
    for pattern_layer in level.PatternShapes.get_children():
        if (pattern_layer.z_index in layers):
            for child in pattern_layer.get_children():
                _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Walls.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Portals.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for material_layer in level.MaterialMeshes.get_children():
        if (material_layer.z_index in layers):
            for child in material_layer:
                child.Clear()
    level.CleanMaterialMeshes()

    for child in level.Pathways.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Objects.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Lights.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Roofs.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))

    for child in level.Texts.get_children():
        if (child.z_index in layers):
            _world.DeleteNodeByID(child.get_meta("node_id"))
    _rebuild_layer_filter()

## returns false if layer index change fails, caused by any of:
##  - target layer is a locked layer
##  - level already has target layer and existing_target_flag is FAIL
##  - level is null and layer does not exist as global layer
##  - level is null, existing_target_flag is FAIL and any layer already has target layer
func modify_layer_index(layer: int, target: int, level: Node2D = null, modify_z_index: bool = true, existing_target_flag: int = ExistingTargetFlag.FAIL) -> bool:
    if target in LOCKED_LAYERS:
        return false
    if (level != null):
        if existing_target_flag == ExistingTargetFlag.FAIL and target in get_user_layers(level):
            return false
        _modify_layer_index(layer, target, level, modify_z_index, existing_target_flag)
        return true

    if not layer in _global_layers_component.get_layers():
        return false
    if existing_target_flag == ExistingTargetFlag.FAIL:
        for level in _world.AllLevels:
            if target in get_user_layers(level):
                return false

    # override global layers
    var layer_name: String = _global_layers_component.get_layers()[layer]
    _global_layers_component.remove_layers([layer, target])
    _global_layers_component.add_layers({layer: layer_name})

    for level in _world.AllLevels:
        _modify_layer_index(layer, target, level, modify_z_index, existing_target_flag)
    return true

func _modify_layer_index(layer: int, target: int, level: Node2D, modify_z_index: bool, existing_target_flag: int):
    var user_layers: Dictionary = get_user_layers(level)
    if not layer in user_layers or existing_target_flag == ExistingTargetFlag.SKIP and target in user_layers:
        return

    var layer_name: String = user_layers[layer]
    if existing_target_flag == ExistingTargetFlag.SLOPPY_MERGE:
        _remove_layers([target], level, false)
    elif existing_target_flag == ExistingTargetFlag.OVERWRITE:
        _remove_layers([target], level, true)
    _remove_layers([layer], level, false)
    _add_layers({target: layer_name}, level)

    if not modify_z_index:
        return
    
    # TODO
    var target_pattern_layer: Node2D = level.PatternShapes.GetOrMakeLayer(target)
    for pattern_layer in level.PatternShapes.get_children():
        if (pattern_layer.z_index == layer):
            if layer < target:
                var children: Array = pattern_layer.get_children()
                children.invert()
                for child in children:
                    _components_api._silence(child)
                    pattern_layer.remove_child(child)
                    _components_api._silence(child)
                    target_pattern_layer.add_child(child)
                    target_pattern_layer.move_child(child, 0)
            else:
                for child in pattern_layer.get_children():
                    _components_api._silence(child)
                    pattern_layer.remove_child(child)
                    _components_api._silence(child)
                    target_pattern_layer.add_child(child)

    for material_layer in level.MaterialMeshes.get_children():
        if (material_layer.z_index == layer):
            for child in material_layer:
                level.GetOrMakeMaterialMesh(target, child.TileTexture, child.Smooth).Load(child.Save())
                child.Clear()
    level.CleanMaterialMeshes()
    
    for parent in [level.Walls, level.Portals, level.Pathways, level.Objects, level.Lights, level.Roofs, level.Texts]:
        _update_z_indices(layer, target, parent)
    _rebuild_layer_filter()

func _update_z_indices(from: int, to: int, parent: Node):
    var children: Array = parent.get_children()
    if from < to:
        children.invert()
        for child in children:
            if (child.z_index == from):
                child.z_index = to
                parent.move_child(child, 0)
    elif from > to:
        for child in children:
            if (child.z_index == from):
                child.z_index = to
                parent.move_child(child, parent.get_child_count())


func rename_layer(layer: int, name: String, level: Node2D = null) -> void:
    if (level != null):
        _rename_layer(layer, name, level)
        return
    for level in _world.AllLevels:
        _rename_layer(layer, name, level)

func _rename_layer(layer: int, name: String, level: Node2D):
    var layers: Dictionary = get_user_layers(level)
    if (not layers.has(layer)):
        # TODO: logging
        return
    layers[layer] = name
    level.CreateDefaultLockedLayers()
    level.LoadLayers(layers)
    _rebuild_layer_filter()


func get_layers(level: Node2D) -> Dictionary:
    var layers: Dictionary = get_user_layers(level)
    for layer in LOCKED_LAYERS:
        layers[layer] = LOCKED_LAYERS[layer]
    return layers

func get_user_layers(level: Node2D) -> Dictionary:
    return Dictionary(level.SaveLayers())

func _level_added(level: Node2D):
    if (level.Data == null):
        level.CreateDefaultLockedLayers()
        level.LoadLayers(_global_layers_component.get_layers())

func _rebuild_layer_filter():
    var layers: Dictionary = {}
    for level in _world.AllLevels:
        var level_layers = get_layers(level)
        for layer in level_layers:
            if layer in LOCKED_LAYERS:
                continue
            if not (layer in layers):
                layers[layer] = level_layers[layer]
            if not (layer in _select_tool.LayerFilter):
                _select_tool.LayerFilter[layer] = true

    var keys = layers.keys()
    keys.sort()
    var is_checked = _select_tool.LayerFilter
    var filters_menu: PopupMenu = _select_tool_panel.layersFilterMenu
    var all_checked = filters_menu.is_item_checked(0)

    filters_menu.clear()
    filters_menu.add_check_item("All")
    filters_menu.add_check_item("Locked Layers")
    filters_menu.set_item_metadata(1, 9999)
    filters_menu.set_item_checked(1, is_checked[9999])
    layers[9999] = "Locked Layers"

    for i in range(len(keys)):
        filters_menu.add_check_item(layers[keys[i]])
        filters_menu.set_item_metadata(i+2, keys[i])
        filters_menu.set_item_checked(i+2, is_checked[keys[i]])

    filters_menu.set_item_checked(0, all_checked)



class GlobalLayersComponent:
    var _layers: Dictionary = {
        -400:   "Below Ground",
        -100:   "Below Water",
         100:   "User Layer 1",
         200:   "User Layer 2",
         300:   "User Layer 3",
         400:   "User Layer 4",
         700:   "Above Walls",
         900:   "Above Roofs"
    }

    func _init(world: Node2D, layers: Dictionary = {}):
        for layer in layers:
            _layers[int(layer)] = layers[layer]
    
    func serialize(_node: Node) -> Dictionary:
        return _layers
    
    func add_layers(layers: Dictionary) -> void:
        for layer in layers:
            if (not layer in _layers):
                _layers[layer] = layers[layer]
    
    func remove_layers(layers: Array) -> void:
        for layer in layers:
            if (layer in _layers):
                _layers.erase(layer)
    
    func get_layers() -> Dictionary:
        return _layers