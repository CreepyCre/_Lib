---
_: _
---
root: ../..
methods:    bool is_applicable(node: Node)
            bool has_component(node: Node)
            Component get_component(node: Node)
            void detach_component(node: Node)

## Description
Let's you access components on applicable nodes.

## Methods

:methods:

## Method Descriptions

:method:anchor:`is_applicable`: <br>
<span class="indent">
Check whether this :link:`Component` is applicable to :param:`node`.
</span>

:method:anchor:`has_component`: <br>
<span class="indent">
Checks whether this :link:`Component` is attached to :param:`node`.
</span>

:method:anchor:`get_component`: <br>
<span class="indent">
Returns the corresponding :link:`Component` attached to :param:`node` or creates one if necessary.
</span>

:method:anchor:`detach_component`: <br>
<span class="indent">
Will detach a :link:`Component` from :param:`node` and call :link:`Component#component_node_removed` just before.
</span>