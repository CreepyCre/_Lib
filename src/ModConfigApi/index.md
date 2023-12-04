---
_: _
---
root: ..
methods:    ConfigBuilder create_config(config_file: String = "user://mod_config/" + mod_meta["unique_id"].to_lower().replace(" ", "").replace(".", "_") + ".json"=, title: String = mod_meta["name"]=, mod_id: String = mod_meta["unique_id"]=)

An Api that enables creating a mod config accessible from the "Mods" menu.

## Description

The ModConfigApi manages mod configs. It's only method creates a :link:`ConfigBuilder` that offers methods for building a mod config that is automatically saved into a given file by the ModConfigApi. See :link:`ConfigBuilder` for a detailed explanation on the usage.

## Methods

:methods:

## Method Descriptions

:method:anchor:`create_config`: <br>
<span class="indent">
Creates a new :link:`ConfigBuilder` for the mod with id :param:`mod_id`. The mod config will automatically be saved into and loaded from :param:`config_file`.
</span>