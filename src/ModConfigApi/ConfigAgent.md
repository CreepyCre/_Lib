---
_: _
---
root: ../..
methods:    void save_cfg(force: bool = false=)
            void load_cfg()
            void mark_dirty()

Provides access to config values.


## Description

The ConfigAgents main purpose is to provide access to config values. It mirrors the exact layout of the actual config. For example, if a config looks like:
```gdscript
{
    "key1" : "value1"
    "sub_category": {
        "key2" : 123,
        "key3" : true
    }
}
```
Then the values may be accessed and set as follows:
```gdscript
config.key1 = "new_value"
config.sub_category.key2 = 101
config.sub_category.key3 = false
```
The values are directly retrieved from and stored to the config nodes that make up the config screen.

## Methods

:methods:

## Method Descriptions

:method:anchor:`save_cfg`: <br>
<span class="indent">
Saves the config to its config file. Set :param:`force` to true to force saving even if the config is unchanged.
</span>

:method:anchor:`load_cfg`: <br>
<span class="indent">
Loads the config from its config file.
</span>

:method:anchor:`mark_dirty`: <br>
<span class="indent">
Marks the config as dirty so it will be saved on the next :link:`#save_cfg` call.
</span>