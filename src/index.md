<h1 style="margin-bottom: -60px">
Home
</h1>

<h1 align="center">

<img align="center" src="https://img.shields.io/github/last-commit/creepycre/_Lib/docs?label=last%20wiki%20update" alt="last wiki update"></img>
<img align="center" src="https://img.shields.io/github/deployments/creepycre/_Lib/github-pages" alt="state"></img>

</h1>

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
- [HistoryApi](./HistoryApi)
- [InputMapApi](./InputMapApi)
- [ModConfigApi](./ModConfigApi)
- [ModSignalingApi](./ModSignalingApi)
- [PreferencesWindowApi](./PreferencesWindowApi)
- [Util](./Util)