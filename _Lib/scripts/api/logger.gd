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

const LOG_PREFIX = "[%02d:%02d:%02d] [%s] [%s]"
const NO_CLASS = ": "
const CLASS = " [%s]: "
const CLASS_LINE = " [%s:%d]: "

var _pretty_log: bool = "--prettylog" in OS.get_cmdline_args()

var _config: ConfigFile = ConfigFile.new()
var _log_level: int

# end goal is:
# [hh:mm:ss] [LEVEL] [Mod Name] [ModClass:<optional line number>]: message
func _init():
    if (File.new().file_exists("user://_Lib.ini")):
        _config.load("user://_Lib.ini")
    _log_level = _config.get_value("Logger", "log_level", INFO)

func log(level: int, mod_name: String, clazz, line: int, message: String, args = []):
    if (level > DEBUG):
        level = DEBUG
    if (level > _log_level):
        return
    log_raw(level, _format_message(message, level, mod_name, clazz, line), args)

func log_raw(level: int, message: String, args: Array):
    message = message % args
    if _pretty_log:
        message = LEVEL_COLORS[level] + message + RESET
    print(message)

func set_log_level(level):
    _log_level = level
    _config.set_value("Logger", "log_level", level)
    _config.save("user://_Lib.ini")

func _build_prefix(level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var datetime: Dictionary = OS.get_datetime()
    var prefix: String
    if (clazz != null):
        if (line >= 0):
            return (LOG_PREFIX + CLASS_LINE) % [datetime["hour"], datetime["minute"], datetime["second"], LEVEL_STRINGS[level], mod_name, clazz, line]
        else:
            return (LOG_PREFIX + CLASS) % [datetime["hour"], datetime["minute"], datetime["second"], LEVEL_STRINGS[level], mod_name, clazz]
    else:
        return (LOG_PREFIX + NO_CLASS) % [datetime["hour"], datetime["minute"], datetime["second"], LEVEL_STRINGS[level], mod_name]

func _format_message(message: String, level: int, mod_name: String, clazz = null, line: int = -1) -> String:
    var prefix: String = _build_prefix(level, mod_name, clazz, line)
    return prefix + message.replace("\n", "\n" + " ".repeat(prefix.length()))

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