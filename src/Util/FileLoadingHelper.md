---
_: _
---
root: ../..
methods:    GDScript load_script(script_path: String)
            PackedScene load_scene(scene_path: String)
            Texture load_icon(icon_path: String)
            Texture load_texture(texture_path: String)

Provides utility methods for loading resources and scripts.

## Description

A FileLoadingHelper provides shorthand methods for loading resources and scripts from predefined folders.

## Methods

:methods:

## Method Descriptions

:method:anchor:`load_script`: <br>
<span class="indent">
Loads the script at:
> root > "scripts" > :param:`script_path` + ".gd"
</span>

:method:anchor:`load_scene`: <br>
<span class="indent">
Loads the scene at:
> root > "scenes" > :param:`scene_path` + ".tscn"
</span>

:method:anchor:`load_icon`: <br>
<span class="indent">
Loads the icon at:
> root > "textures" > "icons" > :param:`icon_path`
</span>

:method:anchor:`load_texture`: <br>
<span class="indent">
Loads the texture at:
> root > "textures" > :param:`texture_path`
</span>