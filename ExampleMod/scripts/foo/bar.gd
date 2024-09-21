class Foo: const import = "foo/foo.gd/"
class AlsoFoo: const import = "CreepyCre.ExampleMod:foo/foo.gd/"
class ClassC: const import = "foo/foo.gd/ClassA.ClassB.ClassC"

static func do_stuff():
    Foo.static_foo()
    Bar.new().foo()
    ClassC.c()

class Bar extends AlsoFoo:
    pass