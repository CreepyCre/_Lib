class_name Util

var _loader_script: GDScript

func _init(loader_script: GDScript):
    _loader_script = loader_script

func create_loading_helper(root: String) -> Reference:
    return _loader_script.new(root)