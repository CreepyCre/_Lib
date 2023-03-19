Welcome to the _Lib wiki!

_Lib is a Dungeondraft mod that offers additional API to simplify implementing certain features like configs and improve mod compatibility.

## Using _Lib
To be able to access _Lib's Api put the following at the top of your mods `start()` method:
```gdscript
Engine.emit_signal("_lib_register_mod", self)
```
Alternatively check if the signal exists first to ensure _Lib is actually enabled:
```gdscript
if not Engine.has_signal("_lib_register_mod"):
    return
Engine.emit_signal("_lib_register_mod", self)
```

After registering your mod with _Lib you will now have an entry `Global.API` available that contains all of the _Lib APIs.

## Current API
- [ApiApi](./ApiApi)
- [InputMapApi](./InputMapApi)
- [ModConfigApi](./ModConfigApi)
- [ModSignalingApi](./ModSignalingApi)
- [PreferencesWindowApi](./PreferencesWindowApi)