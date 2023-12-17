---
_: _
---
root: ../..
enums:      LogLevel {OFF, FATAL, ERROR, WARN, INFO, DEBUG}
constants:  PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix")
            MILLIS_PREFIX_FORMATTER: FuncRef = funcref(self, "build_prefix_millis")
methods:    void set_formatter(prefix_formatter: FuncRef = PREFIX_FORMATTER=)
            ClassLogger with_formatter(prefix_formatter: FuncRef = PREFIX_FORMATTER=)
            void debug(line: int, message: String, args: Array)
            void info(line: int, message: String, args: Array)
            void warn(line: int, message: String, args: Array)
            void error(line: int, message: String, args: Array)
            void fatal(line: int, message: String, args: Array)
            ClassLogger for_class(clazz)

It's a Logger with the class already supplied.

## Description
This is a ClassLogger that logs with a standardised prefix in the form of:
```gdscript
[hh:mm:ss] [LEVEL] [Mod Name] [ModClass:<optional line number>]: message
```
A ClassLogger already has 'ModClass' supplied through being created using :link:`#for_class`.
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
Logs a message at debug level. :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`info`: <br>
<span class="indent">
Logs a message at info level. :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`warn`: <br>
<span class="indent">
Logs a message at warn level. :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`error`: <br>
<span class="indent">
Logs a message at error level. :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`line` and :param:`args` may each be omitted.
</span>

:method:anchor:`fatal`: <br>
<span class="indent">
Logs a message at fatal level. :param:`line` denotes the line number and :param:`args` is the parameters the :param:`message` will be formatted with. :param:`line` and :param:`args` may each be omitted.
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
Creates and returns a new ClassLogger with :param:`prefix_formatter` as the loggers prefix formatter. The prefix formatter is a :link:`FuncRef` to any method with signature:
</span>
```gdscript
func format_prefix(level: int, mod_name: String, clazz = null, line: int = -1)
```
<span class="indent">
Should :param:`clazz` or :param:`line` be equal to their default value, then this signifies that they are missing, so they should be omitted when formatting the log prefix.
</span>
