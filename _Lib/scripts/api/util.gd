class_name Util

var _loader_script: GDScript

func _init(loader_script: GDScript):
    _loader_script = loader_script

func create_loading_helper(root: String) -> Reference:
    return _loader_script.new(root)

func _instance(mod_info):
    return InstancedUtil.new(self, mod_info)

class InstancedUtil:
    var _util
    var _mod_info

    func _init(util, mod_info):
        _util = util
        _mod_info = mod_info
    
    func create_loading_helper(root: String = _mod_info.mod.Global.Root + "../..") -> Reference:
        return _util.create_loading_helper(root)