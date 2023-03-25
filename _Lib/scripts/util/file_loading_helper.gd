class_name FileLoadingHelper

var _root: String

func _init(root: String):
    _root = root

func load_script(script_path: String) -> Script:
    return _load("scripts/" + script_path + ".gd")

func load_scene(scene_path: String):
    return _load("scenes/" + scene_path + ".tscn")

func load_icon(icon_path: String) -> Texture:
    return load_texture("icons/" + icon_path)


func load_texture(texture_path: String) -> Texture:
    return load_texture_full_path(_root + "textures/" + texture_path)

func load_texture_full_path(texture_path: String) -> Texture:
    var image = Image.new()
    image.load(texture_path)
    var texture = ImageTexture.new()
    texture.create_from_image(image, 0)
    return texture

func _load(path: String):
    return load(_root + path)