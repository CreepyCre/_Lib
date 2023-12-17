---
_: _
---
root: ..
constants:  LOCKED_LAYERS: Dictionary = {-500: "Terrain",-300: "Caves",-200: "Floor",0: "Water",500: "Portals",600: "Walls",800: "Roofs"}
methods:    void add_layer(layer: int, name: String, level: Level = null)
            void add_layers(layers: Dictionary, level: Level = null)
            void remove_layer(layer: int, level: Level = null, delete_nodes: bool = true)
            void remove_layers(layers: Array, level: Level = null, delete_nodes: bool = true)
            void rename_layer(layer: int, name: String, level: Level = null)
            Dictionary get_layers(level: Level)
            Dictionary get_user_layers(level: Level)

Offers methods for adding/ removing user layers.

## Description
The LayerApi offers methods for adding and removing user layers. It's important to note the internal methods used are not officially supported by Dungeondraft and the Api will likely be superseded by Dungeondraft core Api in the future.

## Methods

:methods:

## Constants

:constants:

## Method Descriptions

:method:anchor:`add_layer`: <br>
<span class="indent">
Shorthand for adding a single layer via :link:`#add_layers`.
</span>

:method:anchor:`add_layers`: <br>
<span class="indent">
Adds the layers provided in :param:`layers` where the keys are the z_index and the values are the layer names. When specifiying :param:`level` the layers will only be added to that specific :link:`Level`.
</span>

:method:anchor:`remove_layer`: <br>
<span class="indent">
Shorthand for removing a single layer via :link:`#remove_layers`.
</span>

:method:anchor:`remove_layers`: <br>
<span class="indent">
Removes the layers provided in :param:`layers` by their z_index. When specifiying :param:`level` the layers will only be removed from that specific :link:`Level`.
</span>

:method:anchor:`rename_layer`: <br>
<span class="indent">
Renames layer :param:`layer` to :param:`name`. When specifiying :param:`level` the layer will only be renamed in that specific :link:`Level`.
</span>

:method:anchor:`get_layers`: <br>
<span class="indent">
Gets all layers in :param:`level`.
</span>

:method:anchor:`get_user_layers`: <br>
<span class="indent">
Gets all user (= non-locked) layers in :param:`level`.
</span>