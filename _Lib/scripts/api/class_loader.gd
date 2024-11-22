class_name ClassLoader

const CLASS_NAME = "ClassLoader"
var LOGGER: Object

const IMPORT_REGEX = "class[ \t]+([a-zA-Z]+)[ \t]*:[ \t]*const[ \t]+import[ \t]+=[ \t]+\"(([^:\"]+):)?(([^:\"\\\/]+\\\/)+)([^:\"\\\/]+)?\""

var _unique_id_to_root: Dictionary
var _file_id_to_script: Dictionary = {}
var _import_regex: RegEx = RegEx.new()

var source_transformers: Array = []

func _init(logger: Object, unique_id_to_root: Dictionary):
    LOGGER = logger.for_class(self)
    _unique_id_to_root = unique_id_to_root
    _import_regex.compile(IMPORT_REGEX)

    source_transformers.append(funcref(self, "_transform_imports"))
    source_transformers.append(funcref(self, "_replace_new"))

func load_or_get(mod_id: String, script_path: String) -> GDScript:
    script_path = script_path.rstrip("/")
    var file_id = mod_id + ":/" + script_path
    if file_id in _file_id_to_script:
        return _file_id_to_script[file_id]
    if not (mod_id in _unique_id_to_root):
        LOGGER.error("Could not load [%s:/%s] since mod with id \"%s\" does not exist!", [mod_id ,script_path, mod_id])
        return null
    var to_be_loaded = GDScript.new()
    to_be_loaded.take_over_path(file_id)
    _file_id_to_script[file_id] = to_be_loaded

    var file_path = _unique_id_to_root[mod_id] + "/../" + script_path
    var file: File = File.new()
    if not file.file_exists(file_path):
        LOGGER.error("Could not load [%s:/%s] since file \"%s\" does not exist!", [mod_id ,script_path, file_path])
        return null
    file.open(file_path, File.READ)
    var raw_source_code = file.get_as_text()
    file.close()
    to_be_loaded.source_code = _transform_source(raw_source_code, {
        "mod_id": mod_id,
        "path": file_path + "/"
    })
    to_be_loaded.reload()
    return to_be_loaded

func _transform_source(source_code: String, context) -> String:
    for transformer in source_transformers:
        source_code = transformer.call_func(source_code, context)
    return source_code

func _transform_imports(source_code: String, context) -> String:
    var import_statement_matches: Array = _import_regex.search_all(source_code)
    var source_code_pieces: Array = []
    var final_index: int = 0
    for reg_match in import_statement_matches:
        var clazz_name: String = reg_match.get_string(1)
        var mod_id: String = reg_match.get_string(3)
        var script_path: String = reg_match.get_string(4).rstrip("/")
        var clazz_path: String = reg_match.get_string(6)

        if mod_id == "":
            mod_id = context["mod_id"]
        load_or_get(mod_id, script_path)

        source_code_pieces.append(source_code.substr(final_index, reg_match.get_start() - final_index))
        if clazz_path == "":
            source_code_pieces.append("const %s = preload(\"%s:/%s\")" % [clazz_name, mod_id, script_path])
        else:
            source_code_pieces.append("const %s = preload(\"%s:/%s\").%s" % [clazz_name, mod_id, script_path, clazz_path])

        final_index = reg_match.get_end()
    source_code_pieces.append(source_code.substr(final_index))
    return PoolStringArray(source_code_pieces).join("")

func _replace_new(source_code: String, _ignore):
    return source_code.replace("._new(", ".new(")

func _instance(mod_info) -> InstancedClassLoader:
    return InstancedClassLoader.new(self, mod_info.mod_meta["unique_id"])

class InstancedClassLoader:
    var _class_loader: ClassLoader
    var _unique_id: String

    func _init(class_loader: ClassLoader, unique_id: String):
        _class_loader = class_loader
        _unique_id = unique_id

    func load_or_get(mod_id: String, script_path = null) -> GDScript:
        if script_path == null:
            script_path = mod_id
            mod_id = _unique_id
        return _class_loader.load_or_get(mod_id, script_path)