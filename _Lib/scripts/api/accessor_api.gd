class_name AccessorApi

var _visitor_indices: Dictionary = {}
var _config: ConfigFile

func accept(visitor: Object) -> Object:
    if (not visitor in _visitor_indices):
        _visitor_indices[visitor] = 0

    var obj = Node.new()
    var max_id: int = obj.get_instance_id()
    obj.queue_free()

    for id in range(_visitor_indices[visitor], max_id):
        obj = instance_from_id(id)
        if (not is_instance_valid(obj)):
            continue
        if (visitor.visit(obj)):
            continue
        return _check_track(visitor, id)
    return _check_track(visitor, max_id)

func _check_track(visitor: Object, id) -> Object:
    if (visitor.has_method("track") and not visitor.track()):
        _visitor_indices.erase(visitor)
    else:
        _visitor_indices[visitor] = id + 1
    return visitor


func config() -> ConfigFile:
    if (_config == null):
        _config = accept(ConfigFileVisitor.new()).result()
    return _config

func _unload():
    _visitor_indices.clear()

class ConfigFileVisitor:
    var _result: ConfigFile

    func visit(obj: Object) -> bool:
        if (not (obj is ConfigFile) or not obj.has_section("New")):
            return true
        _result = obj
        return false

    func track() -> bool:
        return _result == null

    func result() -> ConfigFile:
        return _result