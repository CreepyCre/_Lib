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

var _world: Node2D
var _global_layers_component: GlobalLayersComponent

func _init(logger: Object, components_api, world):
    LOGGER = logger.for_class(self)
    _world = world
    _global_layers_component = components_api.register("global_layers", GlobalLayersComponent, components_api.FLAG_WORLD).get_component(world)

    components_api.connect("level_added", self, "_level_added")

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
        return
    for pattern_layer in level.PatternShapes.get_children():
        if (pattern_layer.z_index in layers):
            for child in pattern_layer:
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

    for child in level.Walls.get_children():
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

    func _init(level: Node2D, layers: Dictionary = {}):
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