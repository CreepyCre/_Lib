class_name Util
## https://creepycre.github.io/_Lib/Util/

const CLASS_NAME = "Util"
var LOGGER: Object

## see https://docs.python.org/3/library/string.html#format-string-syntax
const REPLACEMENT_FIELD_PATTERN = "(?<replacement_field>{(?<field_name>(?<arg_name>(?<arg_name_identifier>[a-zA-Z_][0-9a-zA-Z_]*)|(?<arg_name_index>0|[1-9][0-9]*))(?<field>(\\.[a-zA-Z_][0-9a-zA-Z_]*|\\[[^\\[\\]]+\\])*))?(:(?<format_spec>((?<fill>[^{}])?(?<align>[<>=^]))?(?<sign>\\[ +-])?(?<z>z)?(?<hashtag>#)?(?<zero>0)?(?<width>[1-9][0-9]*)?(?<grouping_option>[_,])?(\\.(?<precision>0|[1-9][0-9]*))?(?<type>[bcdeEfFgGnosxX%])?))?})"
# with conversion
#const REPLACEMENT_FIELD_PATTERN = "(?<replacement_field>{(?<field_name>(?<arg_name>(?<arg_name_identifier>[a-zA-Z_][0-9a-zA-Z_]*)|(?<arg_name_index>0|[1-9][0-9]*))(?<field>(\\.[a-zA-Z_][0-9a-zA-Z_]*|\\[[^\\[\\]]+\\])*))?(!(?<conversion>[s]))?(:(?<format_spec>((?<fill>[^{}])?(?<align>[<>=^]))?(?<sign>\\[ +-])?(?<z>z)?(?<hashtag>#)?(?<zero>0)?(?<width>[1-9][0-9]*)?(?<grouping_option>[_,])?(\\.(?<precision>0|[1-9][0-9]*))?(?<type>[bcdeEfFgGnosxX%])?))?})"
const FIELD_PATTERN = "(\\.(?<attribute_name>[a-zA-Z_][0-9a-zA-Z_]*)|\\[(?<element_name>[^\\[\\]1-9][^\\[\\]]*)|(?<element_index>0|[1-9][0-9])\\])"

var _regex: RegEx = RegEx.new()
var _field_regex: RegEx = RegEx.new()

var _loader_script: GDScript

func _init(logger: Object, loader_script: GDScript):
    LOGGER = logger.for_class(self)
    _loader_script = loader_script

    _regex.compile(REPLACEMENT_FIELD_PATTERN)
    _field_regex.compile(FIELD_PATTERN)

func create_loading_helper(root: String) -> Reference:
    return _loader_script.new(root)

func pythonic_format(format_string: String, args: Dictionary) -> String:
    var results: Array = _regex.search_all(format_string)
    for index in results.size():
        var regex_match: RegExMatch = results[index]
        var start_index: int = format_string.find(regex_match.get_string())
        var end_index: int = start_index + regex_match.get_string().length()
        format_string = format_string.left(start_index) + _resolve_replacement(regex_match, args, index) + format_string.right(end_index)
    return format_string

func _resolve_replacement(regex_match: RegExMatch, args: Dictionary, index: int) -> String:
    var groups: Dictionary = {}
    for group in regex_match.names:
        groups[group] = regex_match.get_string(regex_match.names[group])
    var arg
    if (groups.has("arg_name_index")):
        arg = args[int(groups["arg_name_index"])]
    elif (groups.has("arg_name_identifier")):
        arg = args[groups["arg_name_identifier"]]
    else:
        arg = args[index]
    if arg == null:
        return "null"
    
    if (groups.has("field")):
        for field_match in _field_regex.search_all(groups["field"]):
            var field_groups: Dictionary = {}
            for group in field_match.names:
                field_groups[group] = field_match.get_string(field_match.names[group])
            if (field_groups.has("attribute_name")):
                arg = arg.get(field_groups["attribute_name"])
            if (field_groups.has("element_name")):
                arg = arg[field_groups["element_name"]]
            if (field_groups.has("element_index")):
                arg = arg[field_groups["element_index"]]
            else:
                return "null"
            if arg == null:
                return "null"
    
    var alternate: bool = groups.has("hashtag")
    var grouping_option: String = groups["grouping_option"] if groups.has("grouping_option") else ""
    var precision_str: String = int(groups["precision"]) if groups.has("precision") else "6"
    var precision: int =  int(precision_str)
    var prefix: String = ""
    var infix: String = ""
    var align: String = ">"
    if (groups.has("type")):
        var type: String = groups["type"]
        match type:
            "s":
                align = "<"
                arg = "%s" % arg
            "b":
                if (alternate):
                    prefix = "0b"
                var integer: int = int(arg)
                arg = ""
                while integer != 0:
                    arg = ("1" if 1 & integer else "0") + arg
                    integer = integer >> 1
                arg = _apply_grouping(arg, grouping_option)
            "c":
                arg = "%c" % int(arg)
            "d":
                var num: int = int(arg)
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = _apply_grouping("%d" % num, grouping_option, 3)
            "o", "x", "X":
                if (alternate):
                    prefix = "0" + type
                var num: int = int(arg)
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = _apply_grouping(("%" + type) % num, grouping_option)
            "e", "E", "g", "G", "n":
                print("NOTATION '" + type + "'' NOT IMPLEMENTED YET")
                return "null"
            "f":
                var num: float = float(arg)
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = ("%." + precision_str + "f") % num
                if (precision_str == "0"):
                    arg = _apply_grouping(arg, grouping_option, 3) + ("." if alternate else "")
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = _apply_grouping(split_arg[0], grouping_option, 3)
                    arg = split_arg.join(".")
            "%":
                var num: float = float(arg) * 100
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = ("%." + precision_str + "f") % num
                if (precision_str == "0"):
                    arg = _apply_grouping(arg, grouping_option, 3) + ("." if alternate else "") + "%"
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = _apply_grouping(split_arg[0], grouping_option, 3)
                    arg = split_arg.join(".") + "%"
    else:
        match typeof(arg):
            TYPE_INT:
                var num: int = int(arg)
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = _apply_grouping("%d" % num, grouping_option, 3)
            TYPE_REAL:
                var num: float = float(arg)
                if (num < 0):
                    num = abs(num)
                    infix = "-"
                elif (groups.has("sign")):
                    var _sign: String = groups["sign"]
                    match _sign:
                        "+", " ":
                            infix = _sign
                arg = ("%." + precision_str + "f") % num
                if (precision_str == "0"):
                    arg = _apply_grouping(arg, grouping_option, 3) + ("." if alternate else "")
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = _apply_grouping(split_arg[0], grouping_option, 3)
                    arg = split_arg.join(".")
            _:
                align = "<"
                arg = "%s" % arg
    
    var padding: int = (int(groups["width"]) if groups.has("width") else 0) - prefix.length() - infix.length() - arg.length()
    if padding > 0:
        var fill_char: String = groups["fill"] if groups.has("fill") else " "
        if (groups.has("align")):
            align = groups["align"]
        elif (groups.has("zero")):
            align = "="
            fill_char = "0"
        match align:
            "<":
                arg += fill_char.repeat(padding)
            ">":
                prefix = fill_char.repeat(padding) + prefix
            "=":
                arg = fill_char.repeat(padding) + arg
            "^":
                var front: int = padding / 2
                var back: int = (padding + 1) / 2
                prefix = fill_char.repeat(front) + prefix
                arg += fill_char.repeat(back)
    return prefix + infix + arg

func _apply_grouping(arg: String, grouping_option: String, distance: int = 4):
    if (grouping_option.empty() or arg.empty()):
        return arg
    var parts: PoolStringArray = PoolStringArray()
    while arg.length() > 0:
        var index: int = (arg.length() - 1) % distance + 1
        
        parts.push_back(arg.left(index))
        arg = arg.right(index)
    return parts.join(grouping_option)

func _instance(mod_info):
    return InstancedUtil.new(self, mod_info)

class InstancedUtil:
    var _util
    var _mod_info

    func _init(util, mod_info):
        _util = util
        _mod_info = mod_info
    
    func create_loading_helper(root: String = _mod_info.mod.Global.Root + "../../") -> Reference:
        return _util.create_loading_helper(root)
    
    func pythonic_format(format_string: String, args: Dictionary) -> String:
        return _util.pythonic_format(format_string, args)