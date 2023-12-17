---
_: _
---
root: ../..
methods:    bool visit(obj: Object)
            bool track()

## Description
This represents any :link:`Object` implementing :method:short:`visit` and :method:short:`track` methods.

## Methods

:methods:

## Method Descriptions

:method:anchor:`visit`: <br>
<span class="indent">
Sequentially called with every existing :link:`Object` as parameter. Loop will be aborted when returning false.
</span>

:method:anchor:`track`: <br>
<span class="indent">
Called when visit loop is aborted or has finished. If this returns true the next time this same visitor is used with the AccessorApi it will skip all previously visited :link:`Object`.
</span>