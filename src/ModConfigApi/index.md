---
_: _
---
root: ..
methods:    ConfigBuilder create_config(mod_id: String, title: String, config_file: String)

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