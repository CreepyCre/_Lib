---
_: _
---
root: ..
methods: void register(String api, Object api)
signals: api_registered(String api_id, Object api)

A Registry for all _Lib APIs.

## Description
All _Lib APIs are registered to and accessed from the ApiApi. It is accessed via `Global.API` and can also be used by mods to registers APIs of their own. APIs registered to the ApiApi can be directly referenced from it.

### Example:
```gdscript
# register the ModApi
Global.API.register("ModApi", mod_api_instance)
# call some method on the ModApi
Global.API.ModApi.some_method()
```


## Methods

:methods:

## Signals

:signal:anchor:`api_registered`: <br>
<span class="indent">
Emitted when an API is registered.
</span>

## Method Descriptions

:method:anchor:`register`: <br>
<span class="indent">
Registers an API under the name :param:`api`
</span>

