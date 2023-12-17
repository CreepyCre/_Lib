---
_: _
---
root: ../..
methods:    static Component create(node: Node)
            Variant serialize(node: Node)
            static Component deserialize(node: Node, data: Variant)
            void detached(node: Node)
            void component_node_removed(node: Node)

## Description
Let's you attach persistent data to nodes. The :link:`ComponentsApi` will call a components constructor with the node as parameter for component creation should no :link:`#create` method exist.

## Methods

:methods:

## Method Descriptions

:method:anchor:`create`: <br>
<span class="indent">
Optional method offering more fine control over component creation than just having a constructor.
</span>

:method:anchor:`serialize`: <br>
<span class="indent">
Implement to return serialized Component data.
</span>

:method:anchor:`deserialize`: <br>
<span class="indent">
Implement to deserialize a Component on :param:`node` from :param:`data`
</span>

:method:anchor:`detached`: <br>
<span class="indent">
Optional method that is called just before the component is detached from :param:`node`.
</span>

:method:anchor:`component_node_removed`: <br>
<span class="indent">
Optional method that is called when :param:`node` (the node this Component is attached to) is removed from the scene tree
</span>