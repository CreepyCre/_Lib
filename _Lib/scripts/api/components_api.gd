class_name ComponentsApi

const _TEXT_BOX_POS: Vector2 = Vector2(1.93729e296, 1.08346e301)

const FLAG_ALL:             int = 0b111111111111
const FLAG_WITH_NODE_ID:    int = 0b111111011100
const FLAG_PORTAL:          int = 0b100000010000

const FLAG_WORLD:           int = 0b000000000001
const FLAG_LEVEL:           int = 0b000000000010
const FLAG_PATTERN:         int = 0b000000000100
const FLAG_WALL:            int = 0b000000001000
const FLAG_PORTAL_FREE:     int = 0b000000010000
const FLAG_MATERIAL:        int = 0b000000100000
const FLAG_PATH:            int = 0b000001000000
const FLAG_PROP:            int = 0b000010000000
const FLAG_LIGHT:           int = 0b000100000000
const FLAG_ROOF:            int = 0b001000000000
const FLAG_TEXT:            int = 0b010000000000
const FLAG_PORTAL_WALL:     int = 0b100000000000

const TYPE_WORLD:           int = 0
const TYPE_LEVEL:           int = 1
const TYPE_PATTERN:         int = 2
const TYPE_WALL:            int = 3
const TYPE_PORTAL_FREE:     int = 4
const TYPE_MATERIAL:        int = 5
const TYPE_PATH:            int = 6
const TYPE_PROP:            int = 7
const TYPE_LIGHT:           int = 8
const TYPE_ROOF:            int = 9
const TYPE_TEXT:            int = 10
const TYPE_PORTAL_WALL:     int = 11

var _world: Node2D
var _scene_tree: SceneTree

var _components: Dictionary = {}
var _non_lazy_components: Array = []

var _save_data = {}

var _record = {}
var _active_record = {}
var _record_entries = {}
var _processing_record: bool = false

var _queued_history_record = [null, null]


func _init(mod_signaling_api, history_api, world: Node2D):
    _world = world

    mod_signaling_api.connect("save_begin", self, "_save_begin")
    mod_signaling_api.connect("save_end", self, "_save_end")
    history_api.connect("recorded", self, "_recorded")
    history_api.connect("dropped", self, "_dropped")
    history_api.connect("undo_begin", self, "_undo_begin")
    history_api.connect("undo_end", self, "_undo_end")
    history_api.connect("redo_begin", self, "_redo_begin")
    history_api.connect("redo_end", self, "_redo_end")

    _save_data = _hackbox_data()
    _scene_tree = world.get_tree()
    _scene_tree.connect("node_added", self, "_node_added")
    _scene_tree.connect("node_removed", self, "_node_removed")

func register(namespace: String, identifier: String, component_script: GDScript, flags: int, lazy: bool = true):
    var key = ComponentKey.new(self, component_script, flags)
    if not namespace in _components:
        _components[namespace] = {}
    var component_namespace = _components[namespace]
    component_namespace[identifier] = key
    if namespace in _save_data:
        var namespaced_save_data: Dictionary = _save_data[namespace]
        if identifier in namespaced_save_data:
            _load_component(key, namespaced_save_data[identifier])
            _save_data[namespace].erase(identifier)
            if (_save_data[namespace].empty()):
                _save_data.erase(namespace)
    
    if (lazy):
        return key
    
    _non_lazy_components.append(key)
    
    if (flags & FLAG_WITH_NODE_ID):
        for node in _world.NodeLookup.values():
            if (key.is_applicable(node)):
                key.get_component(node)
    if (flags & FLAG_WORLD):
        key.get_component(_world)
    if (flags & FLAG_LEVEL):
        for level in _world.AllLevels:
            key.get_component(level)
    if (flags & FLAG_MATERIAL):
        for level in _world.AllLevels:
            for layer in level.MaterialMeshes.get_children():
                for material_mesh in layer.get_children():
                    key.get_component(material_mesh)
    return key

func node_type(node: Node) -> int:
    if (not node.is_inside_tree()):
        return -1
    match _node_path_elements(node.get_path()):
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World"]:
            return TYPE_WORLD
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level]:
            if (node in _world.AllLevels):
                return TYPE_LEVEL
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "PatternShapes", var _layer, var _pattern]:
            # can theoretically fail if someone adds children to PatternShapes, should be fairly unlikely though
            return TYPE_PATTERN
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Walls", var _wall]:
            return TYPE_WALL
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Portals", var _portal]:
            return TYPE_PORTAL_FREE
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "MaterialMeshes", var _layer, var _material]:
            return TYPE_MATERIAL
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Pathways", var _material]:
            return TYPE_PATH
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Objects", var _prop]:
            return TYPE_PROP
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Lights", var _light]:
            return TYPE_LIGHT
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Roofs", var _roof]:
            return TYPE_ROOF
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", var _level, "Texts", var _text]:
            return TYPE_TEXT
        ["root", "Master", "ViewportContainer2D", "Viewport2D", "World", _, "Walls", var _wall, var _portal]:
            if node.WallID != null:
                return TYPE_PORTAL_WALL
    return -1

func _node_path_elements(path: NodePath) -> Array:
    var elements: Array = []
    for i in path.get_name_count():
        elements.append(path.get_name(i))
    return elements

func _hackbox_data() -> Dictionary:
    var texts = _world.AllLevels[0].Texts
    for text in texts.get_children():
        if (text.rect_position == _TEXT_BOX_POS):
            var result: Dictionary = JSON.parse(text.text).result
            _world.DeleteNodeByID(text.get_meta("node_id"))
            return result
    return {}

func _create_hackbox(save_data: Dictionary):
    var text: LineEdit = _world.AllLevels[0].Texts.CreateText()
    text.Load({
        "text": JSON.print(save_data),
        "position": var2str(_TEXT_BOX_POS),
        "font_name": "Aladin",
        "font_size": 1,
        "font_color": "00000000",
        "box_shape": 0
    })

func _delete_hackbox():
    var texts = _world.AllLevels[0].Texts
    for text in texts.get_children():
        if (text.rect_position == _TEXT_BOX_POS):
            _world.DeleteNodeByID(text.get_meta("node_id"))
            return

func _load_component(component_key, save_data: Array):
    for entry in save_data:
        var _node_type: int = entry["type"]
        match _node_type:
            TYPE_PATTERN, TYPE_WALL, TYPE_PORTAL_FREE, TYPE_PATH, TYPE_PROP, TYPE_LIGHT, TYPE_ROOF, TYPE_TEXT, TYPE_PORTAL_WALL:
                var node_id: int = entry["node_id"]
                if (node_id in _world.NodeLookup):
                    var node: Node = _world.NodeLookup[node_id]
                    if (node_type(node) == _node_type and bool((1 << _node_type) & component_key._flags)):
                        component_key._deserialize(node, entry["data"])
            TYPE_WORLD:
                if (FLAG_WORLD & component_key._flags):
                    component_key._deserialize(_world, entry["data"])
            TYPE_LEVEL:
                if (FLAG_LEVEL & component_key._flags):
                    var level: Node2D = _world.GetLevelByID(entry["level"])
                    if (level != null):
                        component_key._deserialize(level, entry["data"])
            TYPE_MATERIAL:
                var level: Node2D = _world.GetLevelByID(entry["level"])
                var layer: int = entry["layer"]
                var texture: String = entry["texture"]
                if (level != null):
                    # TODO: pre build dict so this is less expensive
                    var done: bool = false
                    for material_layer in level.MaterialMeshes.get_children():
                        if (done):
                            break
                        if (material_layer.name == "Layer " + str(layer)):
                            for material_mesh in material_layer.get_children():
                                if (material_mesh.TileTexture.resource_path == texture):
                                    done = true
                                    component_key._deserialize(material_mesh, entry["data"])
                                    break

func _node_added(node: Node):
    var _node_type: int = node_type(node)
    if (_node_type < 0):
        return
    # this way we don't have to do any jank to identify wall portals inbetween map saves/ loads
    if (_node_type == TYPE_PORTAL_WALL and not node.has_meta("node_id")):
        _world.AssignNodeID(node)
    if (_processing_record):
        yield(_scene_tree, "idle_frame")
        if (_active_record.has(_node_type)):
            var typed_record = _active_record[_node_type]
            match _node_type:
                TYPE_PATTERN, TYPE_WALL, TYPE_PORTAL_FREE, TYPE_PATH, TYPE_PROP, TYPE_LIGHT, TYPE_ROOF, TYPE_TEXT, TYPE_PORTAL_WALL:
                    var node_id = node.get_meta("node_id")
                    if (typed_record.has(node_id)):
                        var component_data_dict: Dictionary = typed_record[node_id]
                        typed_record.erase(node_id)
                        if (typed_record.empty()):
                            _active_record.erase(_node_type)
                        for component in component_data_dict:
                            if (not component.has_component(node)):
                                component._deserialize(node, component_data_dict[component])
                TYPE_LEVEL:
                    if (typed_record.has(node.ID)):
                        var component_data_dict: Dictionary = typed_record[node.ID]
                        typed_record.erase(node.ID)
                        if (typed_record.empty()):
                            _active_record.erase(_node_type)
                        for component in component_data_dict:
                            if (not component.has_component(node)):
                                component._deserialize(node, component_data_dict[component])
                TYPE_MATERIAL:
                    var layer = node.get_node("../").z_index
                    if (typed_record.has(layer)):
                        var texture_path: String = node.TileTexture.resource_path
                        var layer_record: Dictionary = typed_record[layer]
                        if (layer_record.has(texture_path)):
                            var component_data_dict: Dictionary = layer_record[texture_path]
                            layer_record.erase(texture_path)
                            if (layer_record.empty()):
                                typed_record.erase(layer)
                                if (typed_record.empty()):
                                    _active_record.erase(_node_type)
                            for component in component_data_dict:
                                if (not component.has_component(node)):
                                    component._deserialize(node, component_data_dict[component])
    else:
        yield(_scene_tree, "idle_frame")
    for component in _non_lazy_components:
        if (component.is_applicable(node)):
            component.get_component(node)
        
func _node_removed(node: Node):
    var _node_type: int = node_type(node)
    if (_node_type < 0):
        return
    for namespace_dict in _components.values():
        for component in namespace_dict.values():
            var result: Array = component._node_removed(node)
            if (not _processing_record or not result[0]):
                continue
            if (not _record.has(_node_type)):
                _record[_node_type] = {}
            var data = result[1]
            var typed_record: Dictionary = _record[_node_type]
            match _node_type:
                TYPE_PATTERN, TYPE_WALL, TYPE_PORTAL_FREE, TYPE_PATH, TYPE_PROP, TYPE_LIGHT, TYPE_ROOF, TYPE_TEXT, TYPE_PORTAL_WALL:
                    var node_id: int = node.get_meta("node_id")
                    if (not typed_record.has(node_id)):
                        typed_record[node_id] = {}
                    typed_record[node_id][component] = data
                TYPE_WORLD:
                    typed_record[component] = data
                TYPE_LEVEL:
                    if (not typed_record.has(node.ID)):
                        typed_record[node.ID] = {}
                    typed_record[node.ID][component] = data
                TYPE_MATERIAL:
                    var layer: int = node.get_node("../").z_index
                    if (not typed_record.has(layer)):
                        typed_record[layer] = {}
                    var layer_record: Dictionary = typed_record[layer]
                    var texture_path: String = node.TileTexture.resource_path
                    if (not layer_record.has(texture_path)):
                        layer_record[texture_path] = {}
                    layer_record[texture_path][component] = data

func _write_type(node: Node):
    var entry: Dictionary = {}
    var _node_type: int = node_type(node)
    entry["type"] = _node_type
    match _node_type:
        TYPE_PATTERN, TYPE_WALL, TYPE_PORTAL_FREE, TYPE_PATH, TYPE_PROP, TYPE_LIGHT, TYPE_ROOF, TYPE_TEXT, TYPE_PORTAL_WALL:
            if (not node.has_meta("node_id")):
                return null
            entry["node_id"] = node.get_meta("node_id")
        TYPE_WORLD:
            pass
        TYPE_LEVEL:
            entry["level"] = node.ID
        TYPE_MATERIAL:
            entry["layer"] = node.get_node("../").z_index
            entry["texture"] = node.TileTexture.resource_path
    return entry

func _recorded(record):
    _processing_record = true
    _queued_history_record[0] = record
    
func _save_begin():
    var data: Dictionary = {}
    for namespace in _components:
        var namespace_data = {}
        var namespace_components: Dictionary = _components[namespace]
        for key in namespace_components:
            namespace_data[key] = namespace_components[key]._serialize()
        data[namespace] = namespace_data
    _create_hackbox(data)

func _save_end():
    _delete_hackbox()

func _undo_begin(record):
    _processing_record = true
    if _record_entries.has(record):
        _active_record = _record_entries[record]
        _record_entries.erase(record)
    else:
        _active_record = {}

func _undo_end(record):
    _processing_record = false
    if (not _record.empty()):
        _record_entries[record] = _record
        _record = {}
    _load_wall_portal_record()

func _redo_begin(record):
    _processing_record = true
    if _record_entries.has(record):
        _active_record = _record_entries[record]
        _record_entries.erase(record)
    else:
        _active_record = {}

func _redo_end(record):
    _processing_record = false
    if (not _record.empty()):
        _record_entries[record] = _record
        _record = {}
    _load_wall_portal_record()

func _load_wall_portal_record():
    # attach to wall portals
    # everything else should have already entered the scene
    if (_active_record.has(TYPE_PORTAL_WALL)):
        var wall_portal_record = _active_record[TYPE_PORTAL_WALL]
        for node_id in wall_portal_record:
            if (not node_id in _world.NodeLookup):
                continue
            var node: Node = _world.NodeLookup[node_id]
            var component_data_dict: Dictionary = wall_portal_record[node_id]
            for component in component_data_dict:
                if (not component.has_component(node)):
                    component._deserialize(node, component_data_dict[component])

func _dropped(record, _type: int):
    if (_record_entries.has(record)):
        _record_entries.erase(record)

func _instance(mod_info):
    return InstancedComponentsApi.new(self, mod_info)

func _update(_delta):
    if (_queued_history_record[0] != null or _queued_history_record[1] != null):
        var rec = _queued_history_record.pop_back()
        _queued_history_record.push_front(null)
        if (rec != null):
            _record_entries[rec] = _record
            _record = {}
            if (_queued_history_record[1] == null):
                _processing_record = false


func _unload():
    _scene_tree.disconnect("node_added", self, "_node_added")
    _scene_tree.disconnect("node_removed", self, "_node_removed")

class InstancedComponentsApi:
    var _components_api
    var _mod_info

    func _init(components_api, mod_info):
        _components_api = components_api
        _mod_info = mod_info

    func register(identifier: String, component_script: GDScript, flags: int, lazy: bool = true):
        return _components_api.register(_mod_info.mod_meta["unique_id"], identifier, component_script, flags, lazy)

    func node_type(node: Node) -> int:
        return _components_api.node_type(node)
    
    func _get(property):
        return _components_api.get(property)

class ComponentKey:
    var _components_api
    var _component_script: GDScript
    var _flags: int
    var _tracked_nodes: Dictionary

    func _init(components_api, component_script: GDScript, flags: int):
        _components_api = components_api
        _component_script = component_script
        _flags = flags
    
    func is_applicable(node: Node):
        return bool((1 << _components_api.node_type(node)) & _flags)
    
    func has_component(node: Node):
        return node in _tracked_nodes
    
    func get_component(node: Node):
        if (not has_component(node)):
            if (_component_script.has_method("create")):
                _tracked_nodes[node] = _component_script.create(node)
            else:
                _tracked_nodes[node] = _component_script.new(node)
        return _tracked_nodes[node]
    
    func detach_component(node: Node):
        if (not has_component(node)):
            return
        var component = _tracked_nodes[node]
        _tracked_nodes.erase(node)
        if (component.has_method("detached")):
            component.detached(node)

    func _serialize() -> Array:
        var out: Array = []
        for node in _tracked_nodes:
            if (not is_instance_valid(node)):
                _tracked_nodes.erase(node)
                continue
            var entry = _serialize_node(node)
            if (entry == null):
                continue
            out.append(entry)
        return out
    
    func _serialize_node(node: Node):
        var component = _tracked_nodes[node]
        var entry = _components_api._write_type(node)
        if (entry == null):
            return null
        entry["data"] = component.serialize(node)
        return entry

    func _deserialize(node: Node, data):
        _tracked_nodes[node] = _component_script.deserialize(node, data)

    func _node_removed(node: Node):
        if has_component(node):
            var component = _tracked_nodes[node]
            var data = component.serialize(node)
            component.component_node_removed(node)
            _tracked_nodes.erase(node)
            return [true, data]
        return [false]