---
_: _
---
root: ../..
methods:    Component create(node: Node)
            Component deserialize(node: Node, data: Variant)

## Description
Can be used during :link:`Component` registration instead of its :link:`GDScript` to gain more fine control over :link:`Component` creation and deserialization.

## Methods

:methods:

## Method Descriptions

:method:anchor:`create`: <br>
<span class="indent">
Creates and returns a :link:`Component` attached to :param:`node`.
</span>

:method:anchor:`deserialize`: <br>
<span class="indent">
Deserialized :link:`Component` on :param:`node` from :param:`data`.
</span>