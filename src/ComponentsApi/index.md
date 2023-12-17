---
_: _
---
root: ..
methods:    ComponentKey register(identifier: String, component_script, flags: int, lazy: bool = true)
            ComponentsApi.NodeType node_type(node: Node)
enums:      NodeType {TYPE_WORLD, TYPE_LEVEL, TYPE_PATTERN, TYPE_WALL, TYPE_PORTAL_FREE, TYPE_PORTAL_WALL, TYPE_MATERIAL, TYPE_PATH, TYPE_PROP, TYPE_LIGHT, TYPE_ROOF, TYPE_TEXT}
constants:  FLAG_ALL:             int = 0b111111111111
            FLAG_WITH_NODE_ID:    int = 0b111110111100
            FLAG_PORTAL:          int = 0b000000110000
            FLAG_WORLD:           int = 0b000000000001
            FLAG_LEVEL:           int = 0b000000000010
            FLAG_PATTERN:         int = 0b000000000100
            FLAG_WALL:            int = 0b000000001000
            FLAG_PORTAL_FREE:     int = 0b000000010000
            FLAG_PORTAL_WALL:     int = 0b000000100000
            FLAG_MATERIAL:        int = 0b000001000000
            FLAG_PATH:            int = 0b000010000000
            FLAG_PROP:            int = 0b000100000000
            FLAG_LIGHT:           int = 0b001000000000
            FLAG_ROOF:            int = 0b010000000000
            FLAG_TEXT:            int = 0b100000000000
signals:    level_added(node)
            pattern_added(node)
            wall_added(node)
            portal_free_added(node)
            portal_wall_added(node)
            material_added(node)
            path_added(node)
            prop_added(node)
            light_added(node)
            roof_added(node)
            text_added(node)

An Api for attaching persistent data to map objects.

## Description
The ComponentsApi makes it possible to attach a :link:`Component` to a map object such as a :link:`Prop` or :link:`Wall`.

## Methods

:methods:

## Signals

:signal:anchor:`level_added`: <br>
<span class="indent">
Emitted when a :link:`Level` is added to the :link:`World`.
</span>

:signal:anchor:`pattern_added`: <br>
<span class="indent">
Emitted when a :link:`PatternShape` is added to any :link:`Level`.
</span>

:signal:anchor:`wall_added`: <br>
<span class="indent">
Emitted when a :link:`Wall` is added to any :link:`Level`.
</span>

:signal:anchor:`portal_free_added`: <br>
<span class="indent">
Emitted when a free standing :link:`Portal` is added to any :link:`Level`.
</span>

:signal:anchor:`portal_wall_added`: <br>
<span class="indent">
Emitted when a wall bound :link:`Portal` is added to any :link:`Level`.
</span>

:signal:anchor:`material_added`: <br>
<span class="indent">
Emitted when a :link:`MaterialMesh` is added to any :link:`Level`.
</span>

:signal:anchor:`path_added`: <br>
<span class="indent">
Emitted when a :link:`Pathway` is added to any :link:`Level`.
</span>

:signal:anchor:`prop_added`: <br>
<span class="indent">
Emitted when a :link:`Prop` is added to any :link:`Level`.
</span>

:signal:anchor:`light_added`: <br>
<span class="indent">
Emitted when a :link:`Light2D` is added to any :link:`Level`.
</span>

:signal:anchor:`roof_added`: <br>
<span class="indent">
Emitted when a :link:`Roof` is added to any :link:`Level`.
</span>

:signal:anchor:`text_added`: <br>
<span class="indent">
Emitted when a :link:`Text` is added to any :link:`Level`.
</span>

## Enumerations

:enum:anchor:`NodeType`
<span class="indent">
Denotes the type of a map node. May be directly converted to the corresponding flag using bit shift:
```gdscript
var prop_flag = 1 << TYPE_PROP
```
</span>

## Constants

:constants:

## Method Descriptions

:method:anchor:`register`: <br>
<span class="indent">
Registers a new component with :param:`identifier` as its unique identifier. :param:`component_factory` may be either the :link:`GDScript` of a :link:`Component` or a :link:`ComponentFactory`. It will be used to instantiate and deserialize the :link:`Component` :param:`flags` is any combination of node type flags to determine which types of nodes the component is applicable to. Setting :param:`lazy` to false will cause the component to be automatically attached to any node shortly after it enters the scene.
The returned :link:`ComponentKey` can be used to access the :link:`Component` on applicable nodes.
</span>

:method:anchor:`node_type`: <br>
<span class="indent">
Returns the :link:`#NodeType` of :param:`node`.
</span>