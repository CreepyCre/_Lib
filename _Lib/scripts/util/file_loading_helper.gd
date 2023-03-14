class_name FileLoadingHelper

var _root: String

func _init(root: String):
    _root = root

func init_api(api_name: String, arg0 = null, arg1 = null, arg2 = null, arg3 = null, arg4 = null, arg5 = null, arg6 = null, arg7 = null, arg8 = null, arg9 = null):
    if (arg9 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
    elif (arg8 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8)
    elif (arg7 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7)
    elif (arg6 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5, arg6)
    elif (arg5 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4, arg5)
    elif (arg4 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3, arg4)
    elif (arg3 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2, arg3)
    elif (arg2 != null):
        return load_script("api/" + api_name).new(arg0, arg1, arg2)
    elif (arg1 != null):
        return load_script("api/" + api_name).new(arg0, arg1)
    elif (arg0 != null):
        return load_script("api/" + api_name).new(arg0)
    else:
        return load_script("api/" + api_name).new()

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