---
_: _
---
root: ..
enums:      LogLevel {OFF, FATAL, ERROR, WARN, INFO, DEBUG}
constants:  PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix")
            MILLIS_PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix_millis")
methods:    void set_formatter(prefix_formatter: FuncRef = PREFIX_FORMATTER=)
            Logger with_formatter(prefix_formatter: FuncRef = PREFIX_FORMATTER=)
            void debug(clazz: String, line: int, message: String, args: Array)
            void info(clazz: String, line: int, message: String, args: Array)
            void warn(clazz: String, line: int, message: String, args: Array)
            void error(clazz: String, line: int, message: String, args: Array)
            void fatal(clazz: String, line: int, message: String, args: Array)
            ClassLogger for_class(clazz)

It's a Logger.

## Description
This is a Logger that logs with a standardised prefix in the form of:
```gdscript
[hh:mm:ss] [LEVEL] [Mod Name] [<optional ModClass>:<optional line number>]: message
```
It is recommended to use :link:`#for_class` to provide a unique logger for each individual GDScript.
It's also possible to provide a unique prefix formatter using :link:`#set_formatter` or :link:`#with_formatter`

## Methods

:methods:

## Enumerations

:enum:anchor:`LogLevel`
<span class="indent">
Denotes the log level.
</span>

## Constants

:constants:

## Method Descriptions

:method:anchor:`for_class`: <br>
<span class="indent">
Creates a :link:`ClassLogger` which pre-supplies the :param:`clazz` for the logging methods. :param:`clazz` may be either a :link:`String` containing the class name or a relevant instance of the class/ the GDScript itself with a CLASS_NAME constant providing the name as a :link:`String`.
</span>

:method:anchor:`debug`: <br>
<span class="indent">
Logs a message at debug level. :param:`clazz` denotes the :link:`GDScript` that is being logged from, :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`clazz`, :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`info`: <br>
<span class="indent">
Logs a message at info level. :param:`clazz` denotes the :link:`GDScript` that is being logged from, :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`clazz`, :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`warn`: <br>
<span class="indent">
Logs a message at warn level. :param:`clazz` denotes the :link:`GDScript` that is being logged from, :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`clazz`, :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`error`: <br>
<span class="indent">
Logs a message at error level. :param:`clazz` denotes the :link:`GDScript` that is being logged from, :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`clazz`, :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`fatal`: <br>
<span class="indent">
Logs a message at fatal level. :param:`clazz` denotes the :link:`GDScript` that is being logged from, :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`clazz`, :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`set_formatter`: <br>
<span class="indent">
Sets :param:`prefix_formatter` as this loggers prefix formatter. The prefix formatter is a :link:`FuncRef` to any method with signature:
</span>
```gdscript
func format_prefix(level: int, mod_name: String, clazz = null, line: int = -1)
```
<span class="indent">
Should :param:`clazz` or :param:`line` be equal to their default value, then this signifies that they are missing, so they should be omitted when formatting the log prefix.
</span>

:method:anchor:`with_formatter`: <br>
<span class="indent">
Creates and returns a new Logger with :param:`prefix_formatter` as the loggers prefix formatter. The prefix formatter is a :link:`FuncRef` to any method with signature:
</span>
```gdscript
func format_prefix(level: int, mod_name: String, clazz = null, line: int = -1)
```
<span class="indent">
Should :param:`clazz` or :param:`line` be equal to their default value, then this signifies that they are missing, so they should be omitted when formatting the log prefix.
</span>
