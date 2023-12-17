class_name Logger

const CLASS_NAME = "Logger"

enum LogLevel {
    OFF,
    FATAL,
    ERROR,
    WARN,
    INFO,
    DEBUG
}

enum {
    OFF,
    FATAL,
    ERROR,
    WARN,
    INFO,
    DEBUG
}

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

const LOG_PREFIX = "[%02d:%02d:%02d]"
const LOG_PREFIX_MILLIS = "[%02d:%02d:%02d:%03d]"
const LOG_INFIX = " [%s] [%s]"
const NO_CLASS = ": "
const CLASS = " [%s]: "
const CLASS_LINE = " [%s:%d]: "

var _pretty_log: bool = "--prettylog" in OS.get_cmdline_args()

var _config: ConfigFile = ConfigFile.new()
var _log_level: int = INFO

var PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix")
var MILLIS_PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix_millis")

# end goal is:
# [hh:mm:ss] [LEVEL] [Mod Name] [ModClass:<optional line number>]: message
func _init():
    if (File.new().file_exists("user://_Lib.ini")):
        var err_code: int = _config.load("user://_Lib.ini")
        if (err_code):
            self.log(ERROR, "_Lib", CLASS_NAME, -1, "Could not load 'user://_Lib.ini', Error Code '%d'.", [err_code])
        else:
            _log_level = _config.get_value("Logger", "log_level", INFO)

func log(level: int, mod_name: String, clazz, line: int, message: String, args = []):
    _log(PREFIX_FORMATTER, level, mod_name, clazz, line, message, args)

func _log(pref_formatter: FuncRef, level: int, mod_name: String, clazz, line: int, message: String, args = []):
    if (level > DEBUG):
        level = DEBUG
    if (level > _log_level):
        return
    log_raw(level, _format_message(pref_formatter, message % args, level, mod_name, clazz, line))


func log_raw(level: int, message: String):
    if _pretty_log:
        message = LEVEL_COLORS[level] + message + RESET
    print(message)

func get_log_level():
    return _log_level

func set_log_level(level):
    if (_log_level != level):
        _log_level = level
        _config.set_value("Logger", "log_level", level)
        _config.save("user://_Lib.ini")

func build_prefix(level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String
    if (clazz != null):
        if (line >= 0):
            return (_build_time() + LOG_INFIX + CLASS_LINE) % [LEVEL_STRINGS[level], mod_name, clazz, line]
        else:
            return (_build_time() + LOG_INFIX + CLASS) % [LEVEL_STRINGS[level], mod_name, clazz]
    else:
        return (_build_time() + LOG_INFIX + NO_CLASS) % [LEVEL_STRINGS[level], mod_name]

func _build_time():
    var datetime: Dictionary = OS.get_datetime()
    return LOG_PREFIX % [datetime["hour"], datetime["minute"], datetime["second"]]

func build_prefix_millis(level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String
    if (clazz != null):
        if (line >= 0):
            return (_build_time_millis() + LOG_INFIX + CLASS_LINE) % [LEVEL_STRINGS[level], mod_name, clazz, line]
        else:
            return (_build_time_millis() + LOG_INFIX + CLASS) % [LEVEL_STRINGS[level], mod_name, clazz]
    else:
        return (_build_time_millis() + LOG_INFIX + NO_CLASS) % [LEVEL_STRINGS[level], mod_name]

func _build_time_millis():
    var datetime: Dictionary = OS.get_datetime()
    return LOG_PREFIX_MILLIS % [datetime["hour"], datetime["minute"], datetime["second"], OS.get_system_time_msecs() % 1000]

func _format_message(pref_formatter: FuncRef, message: String, level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String = pref_formatter.call_func(level, mod_name, clazz, line)
    return prefix + message.replace("\n", "\n" + " ".repeat(prefix.length()))

func _instance(mod_info):
    return InstancedLogger.new(self, mod_info.mod_meta["name"])

class InstancedLogger:
    var _logger
    var _mod_name
    var _clazz_loggers: Dictionary = {}
    var _prefix_formatter: FuncRef

    func _init(logger, mod_name: String, prefix_formatter: FuncRef = null):
        _logger = logger
        _mod_name = mod_name
        if (prefix_formatter == null):
            _prefix_formatter = logger.PREFIX_FORMATTER
        else:
            _prefix_formatter = prefix_formatter
    
    func set_formatter(prefix_formatter: FuncRef = _logger.PREFIX_FORMATTER):
        _prefix_formatter = prefix_formatter
    
    func with_formatter(prefix_formatter: FuncRef = _logger.PREFIX_FORMATTER) -> InstancedLogger:
        return InstancedLogger.new(_logger, _mod_name, prefix_formatter)
    
    func debug(clazz, line, message = null, args = null):
        _log(_prefix_formatter, DEBUG, clazz, line, message, args)

    func info(clazz, line, message = null, args = null):
        _log(_prefix_formatter, INFO, clazz, line, message, args)
        
    func warn(clazz, line, message = null, args = null):
        _log(_prefix_formatter, WARN, clazz, line, message, args)
        
    func error(clazz, line, message = null, args = null):
        _log(_prefix_formatter, ERROR, clazz, line, message, args)
    
    func fatal(clazz, line, message = null, args = null):
        _log(_prefix_formatter, FATAL, clazz, line, message, args)
    
    func _log(prefix_formatter: FuncRef, level: int, clazz, line, message = null, args = null):
        if (args == null):
            if (message == null):
                if (line is String): # parameters 1 place to the left & args missing
                    _logger._log(prefix_formatter, level, _mod_name, clazz, -1, line)
                else: # parameters 2 places to the left
                    _logger._log(prefix_formatter, level, _mod_name, null, -1, clazz, line)
            else: 
                if (message is String): # args missing
                    _logger._log(prefix_formatter, level, _mod_name, clazz, line, message)
                else: # parameters 1 place to the left
                    _logger._log(prefix_formatter, level, _mod_name, clazz, -1, line, message)
        else:
            _logger._log(prefix_formatter, level, _mod_name, clazz, line, message, args)
    
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
    
    func _get(property):
        return _logger.get(property)

        

class ClassInstancedLogger:
    var _instanced_logger
    var _clazz
    var _prefix_formatter: FuncRef

    func _init(instanced_logger, clazz, prefix_formatter: FuncRef = null):
        _instanced_logger = instanced_logger
        _clazz = clazz
        if (prefix_formatter == null):
            _prefix_formatter = instanced_logger._prefix_formatter
        else:
            _prefix_formatter = prefix_formatter
    
    func set_formatter(prefix_formatter: FuncRef = _instanced_logger._prefix_formatter):
        _prefix_formatter = prefix_formatter
    
    func with_formatter(prefix_formatter: FuncRef = _instanced_logger._prefix_formatter) -> ClassInstancedLogger:
        return ClassInstancedLogger.new(_instanced_logger, _clazz, prefix_formatter)

    func debug(line, message = null, args = null):
        _instanced_logger._log(_prefix_formatter, DEBUG, _clazz, line, message, args)

    func info(line, message = null, args = null):
        _instanced_logger._log(_prefix_formatter, INFO, _clazz, line, message, args)
        
    func warn(line, message = null, args = null):
        _instanced_logger._log(_prefix_formatter, WARN, _clazz, line, message, args)
        
    func error(line, message = null, args = null):
        _instanced_logger._log(_prefix_formatter, ERROR, _clazz, line, message, args)
    
    func fatal(line, message = null, args = null):
        _instanced_logger._log(_prefix_formatter, FATAL, _clazz, line, message, args)
    
    func for_class(clazz) -> ClassInstancedLogger:
        return _instanced_logger.for_class(clazz)
    
    func _get(property):
        return _instanced_logger.get(property)