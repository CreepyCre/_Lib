static func static_foo():
    print("STATIC FOO!")

func foo():
    print("FOO!")

class ClassA:
    class ClassB:
        class ClassC:
            static func c():
                print("ClassC!")