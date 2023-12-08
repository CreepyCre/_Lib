class_name Logger

const CLASS_NAME = "Logger"

const OFF:      int = -1
const FATAL:    int = 0
const ERROR:    int = 1
const WARN:     int = 2
const INFO:     int = 3
const DEBUG:    int = 4

const LEVEL_STRINGS: Dictionary = {
    FATAL:  "FATAL",
    ERROR:  "ERROR",
    WARN:   "WARN",
    INFO:   "INFO",
    DEBUG:  "DEBUG",
}

const _CONFIG_LOOKUP: Dictionary = {
    "off":      OFF,
    "fatal":    FATAL,
    "error":    ERROR,
    "warn":     WARN,
    "info":     INFO,
    "debug":    DEBUG,
}

const LEVEL_COLORS: Dictionary = {
    FATAL:  "[1;31m",  # red & bold
    ERROR:  "[0;31m",  # red
    WARN:   "[0;33m",  # yellow
    INFO:   "",          #
    DEBUG:  "[0;32m",  # green
}

const RESET: String = "[0m"

## see https://docs.python.org/3/library/string.html#format-string-syntax
const REPLACEMENT_FIELD_PATTERN = "(?<replacement_field>{(?<field_name>(?<arg_name>(?<arg_name_identifier>[a-zA-Z_][0-9a-zA-Z_]*)|(?<arg_name_index>0|[1-9][0-9]*))(?<field>(\\.[a-zA-Z_][0-9a-zA-Z_]*|\\[[^\\[\\]]+\\])*))?(:(?<format_spec>((?<fill>[^{}])?(?<align>[<>=^]))?(?<sign>\\[ +-])?(?<z>z)?(?<hashtag>#)?(?<zero>0)?(?<width>[1-9][0-9]*)?(?<grouping_option>[_,])?(\\.(?<precision>0|[1-9][0-9]*))?(?<type>[bcdeEfFgGnosxX%])?))?})"
# with conversion
#const REPLACEMENT_FIELD_PATTERN = "(?<replacement_field>{(?<field_name>(?<arg_name>(?<arg_name_identifier>[a-zA-Z_][0-9a-zA-Z_]*)|(?<arg_name_index>0|[1-9][0-9]*))(?<field>(\\.[a-zA-Z_][0-9a-zA-Z_]*|\\[[^\\[\\]]+\\])*))?(!(?<conversion>[s]))?(:(?<format_spec>((?<fill>[^{}])?(?<align>[<>=^]))?(?<sign>\\[ +-])?(?<z>z)?(?<hashtag>#)?(?<zero>0)?(?<width>[1-9][0-9]*)?(?<grouping_option>[_,])?(\\.(?<precision>0|[1-9][0-9]*))?(?<type>[bcdeEfFgGnosxX%])?))?})"
const FIELD_PATTERN = "(\\.(?<attribute_name>[a-zA-Z_][0-9a-zA-Z_]*)|\\[(?<element_name>[^\\[\\]1-9][^\\[\\]]*)|(?<element_index>0|[1-9][0-9])\\])"
const LOG_PREFIX = "[{__HOUR__:02d}:{__MINUTE_:02d}:{__SECOND__:02d}] [{__LOG_LEVEL__}] [{__MOD_NAME__}]"
const NO_CLASS = ": "
const CLASS = " [{__CLASS__}]: "
const CLASS_LINE = " [{__CLASS__}:{__LINE__:d}]: "

var _regex: RegEx = RegEx.new()
var _field_regex: RegEx = RegEx.new()
var _pretty_log: bool = "--prettylog" in OS.get_cmdline_args()

var _config: ConfigFile = ConfigFile.new()
var _log_level: int

# end goal is:
# [hh:mm:ss] [LEVEL] [Mod Name] [ModClass:<optional line number>]: message
func _init():
    _regex.compile(REPLACEMENT_FIELD_PATTERN)
    _field_regex.compile(FIELD_PATTERN)

    if (File.new().file_exists("user://_Lib.ini")):
        _config.load("user://_Lib.ini")
    _log_level = _config.get_value("Logger", "log_level", INFO)

    pass

func log(level: int, mod_name: String, clazz, line: int, message: String, args = {}):
    if (level > DEBUG):
        level = DEBUG
    if (level > _log_level):
        return
    log_raw(level, _format_message(message, level, mod_name, clazz, line), args)

func log_raw(level: int, message: String, args):
    if (level > DEBUG):
        level = DEBUG
    var dict: Dictionary = {}
    if args is Array:
        for i in args.size():
            dict[i] = args[i]
    else:
        dict = args

    message = pythonic_format(message, dict)
    if _pretty_log:
        message = LEVEL_COLORS[level] + message + RESET
    print(message)

func set_log_level(level):
    _log_level = level
    _config.set_value("Logger", "log_level", level)
    _config.save("user://_Lib.ini")

func _build_prefix(level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String
    if (clazz != null):
        if (line >= 0):
            prefix = LOG_PREFIX + CLASS_LINE
        else:
            prefix = LOG_PREFIX + CLASS
    else:
        prefix = LOG_PREFIX + NO_CLASS
    
    var datetime: Dictionary = OS.get_datetime()
    return pythonic_format(prefix, {
        "__HOUR__": datetime["hour"],
        "__MINUTE_": datetime["minute"],
        "__SECOND__": datetime["second"],
        "__LOG_LEVEL__": LEVEL_STRINGS[level],
        "__MOD_NAME__": mod_name,
        "__CLASS__": clazz,
        "__LINE__": line,
    })

func _format_message(message: String, level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String = _build_prefix(level, mod_name, clazz, line)
    return prefix + message.replace("\n", "\n" + " ".repeat(prefix.length()))

    


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
                arg = apply_grouping(arg, grouping_option)
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
                arg = apply_grouping("%d" % num, grouping_option, 3)
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
                arg = apply_grouping(("%" + type) % num, grouping_option)
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
                    arg = apply_grouping(arg, grouping_option, 3) + ("." if alternate else "")
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = apply_grouping(split_arg[0], grouping_option, 3)
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
                    arg = apply_grouping(arg, grouping_option, 3) + ("." if alternate else "") + "%"
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = apply_grouping(split_arg[0], grouping_option, 3)
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
                arg = apply_grouping("%d" % num, grouping_option, 3)
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
                    arg = apply_grouping(arg, grouping_option, 3) + ("." if alternate else "")
                else:
                    var split_arg: PoolStringArray = PoolStringArray(arg.split("."))
                    split_arg[0] = apply_grouping(split_arg[0], grouping_option, 3)
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

func apply_grouping(arg: String, grouping_option: String, distance: int = 4):
    if (grouping_option.empty() or arg.empty()):
        return arg
    var parts: PoolStringArray = PoolStringArray()
    while arg.length() > 0:
        var index: int = (arg.length() - 1) % distance + 1
        
        parts.push_back(arg.left(index))
        arg = arg.right(index)
    return parts.join(grouping_option)

func _instance(mod_info):
    return InstancedLogger.new(self, mod_info)

class InstancedLogger:
    var _logger
    var _mod_name
    var _clazz_loggers: Dictionary = {}

    func _init(logger, mod_info):
        _logger = logger
        _mod_name = mod_info.mod_meta["name"]
    
    func debug(clazz, line, message: = null, args = null):
        _log(DEBUG, clazz, line, message, args)

    func info(clazz, line, message: = null, args = null):
        _log(INFO, clazz, line, message, args)
        
    func warn(clazz, line, message: = null, args = null):
        _log(WARN, clazz, line, message, args)
        
    func error(clazz, line, message: = null, args = null):
        _log(ERROR, clazz, line, message, args)
    
    func fatal(clazz, line, message: = null, args = null):
        _log(FATAL, clazz, line, message, args)
    
    func _log(level: int, clazz, line, message = null, args = null):
        if (args == null):
            if (message == null):
                if (line is String): # parameters 1 place to the left & args missing
                    _logger.log(level, _mod_name, clazz, -1, line)
                else: # parameters 2 places to the left
                    _logger.log(level, _mod_name, null, -1, clazz, line)
            else: 
                if (message is String): # args missing
                    _logger.log(level, _mod_name, clazz, line, message)
                else: # parameters 1 place to the left
                    _logger.log(level, _mod_name, clazz, -1, line, message)
        else:
            _logger.log(level, _mod_name, clazz, line, message, args)
    
    func for_class(clazz) -> ClassInstancedLogger:
        if (clazz is Reference):
            clazz = clazz.get_script()
        if (clazz is GDScript):
            clazz = clazz.CLASS_NAME
        if clazz in _clazz_loggers:
            return _clazz_loggers[clazz]
        var class_instanced_logger = ClassInstancedLogger.new(self, clazz)
        _clazz_loggers[clazz] = class_instanced_logger
        return class_instanced_logger

        

class ClassInstancedLogger:
    var _instanced_logger
    var _clazz

    func _init(instanced_logger, clazz):
        _instanced_logger = instanced_logger
        _clazz = clazz
    
    func debug(line, message = null, args = null):
        _instanced_logger._log(DEBUG, _clazz, line, message, args)

    func info(line, message = null, args = null):
        _instanced_logger._log(INFO, _clazz, line, message, args)
        
    func warn(line, message = null, args = null):
        _instanced_logger._log(WARN, _clazz, line, message, args)
        
    func error(line, message = null, args = null):
        _instanced_logger._log(ERROR, _clazz, line, message, args)
    
    func fatal(line, message = null, args = null):
        _instanced_logger._log(FATAL, _clazz, line, message, args)
    
    func for_class(clazz) -> ClassInstancedLogger:
        return _instanced_logger.for_class(clazz)