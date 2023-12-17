---
_: _
---
root: ../..
methods:    Object accept(visitor: ObjectVisitor)
            ConfigFile config()

Api for iterating over all godot :link:`Object` to aquire usually inaccessible references.

## Description
The AccessorApi offers the ability to iterate over all instances of :link:`Object` using a visitor pattern. It is intended for aquiring some references that would usually be inaccessible inside C# objects.

## Methods

:methods:

## Method Descriptions

:method:anchor:`accept`: <br>
<span class="indent">
This will have the AccessorApi make your :param:`visitor` visit all :link:`Object`.
</span>

:method:anchor:`config`: <br>
<span class="indent">
Returns the :link:`ConfigFile` reference used for Dungeondrafts own config. Any changes to existing config entries will be lost, however, new entries will be saved alongside the default entries. Can be used to read the current config settings.
</span>