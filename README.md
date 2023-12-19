<h1 align="center">
_Lib<br>

<a href="https://github.com/CreepyCre/_Lib"><img src="https://img.shields.io/badge/dynamic/json?color=informational&label=version&query=%24.version&url=https%3A%2F%2Fraw.githubusercontent.com%2FCreepyCre%2F_Lib%2Fmaster%2F_Lib%2Fscripts%2Ftools%2F_Lib.ddmod%3Fcallback%3D%3F" alt="Version"></a>
<a href="https://dungeondraft.net/"><img src="https://img.shields.io/badge/Dungeondraft-1.1.0.5%20Pudgy%20Phoenix-blueviolet" alt="Dungeondraft version"></a>
<a href="https://github.com/CreepyCre/_Lib/blob/master/LICENSE"><img src="https://img.shields.io/github/license/CreepyCre/_Lib?color=900c3f" alt="License"></a>
</h1>

This mod offers additional API to simplify implementing certain features like configs and improve mod compatibility.

Current API:
- [ApiApi](https://creepycre.github.io/_Lib/ApiApi/)
- [Logger](https://creepycre.github.io/_Lib/Logger/)
- [AccessorApi](https://creepycre.github.io/_Lib/AccessorApi/)
- [ComponentsApi](https://creepycre.github.io/_Lib/ComponentsApi/)
- [HistoryApi](https://creepycre.github.io/_Lib/HistoryApi/)
- [InputMapApi](https://creepycre.github.io/_Lib/InputMapApi/)
- [LayerApi](https://creepycre.github.io/_Lib/LayerApi/)
- [ModConfigApi](https://creepycre.github.io/_Lib/ModConfigApi/)
- [ModSignalingApi](https://creepycre.github.io/_Lib/ModSignalingApi/)
- [PreferencesWindowApi](https://creepycre.github.io/_Lib/PreferencesWindowApi/)
- [Util](https://creepycre.github.io/_Lib/Util/)

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

After registering your mod with _Lib you will now have an entry `Global.API` available that contains all of the _Lib APIs. For more info on how to use them check out the [documentation](https://creepycre.github.io/_Lib/).
