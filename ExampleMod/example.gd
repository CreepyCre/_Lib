var script_class = "tool"

var counter: int = 0

func start():
    if (not Engine.has_signal("_lib_register_mod")):
        return
    Engine.emit_signal("_lib_register_mod", self)
    
    var input_definitions: Dictionary = {
        "Release the Kraken": ["release_kraken", "Ctrl+P", "L"],
        "Some Category":{
            "Unscrew Lightbulbs": "unscrew_lightbulbs",
            "Put in Complaints": "put_complaints"
        }
    }
    self.Global.API.InputMapApi.define_actions("Example Mod", input_definitions)

    # Can't do comments inbetween the lines here, sadge
    # we can use enter() and exit() to go into and out of any nodes created
    # creating an unnamed container will automatically flatten it's config nodes into the parent container:
    #   .h_box_container().enter()
    # a named container will get a subsection in the config:
    #   .v_box_container("sub_section").enter()
    var builder = self.Global.API.ModConfigApi.create_config(self.Global.Root + "config.json")
    var config = builder\
                .shortcuts("shortcuts", input_definitions).rect_min_y(330)\
                .h_box_container().enter()\
                    .check_button("key1", true, "Some Option IDK")\
                    .v_separator()\
                    .check_box("key2", true, "Some other Option IDK").size_flags_h(Control.SIZE_EXPAND_FILL)\
                .exit()\
                .h_separator()\
                .label("LABEL")\
                .option_button("option", 2, ["a", "b", {"label": "c", "icon": load("res://icon.png"), "meta": {"this_is": "a_dict"}}])\
                .line_edit("line_edit", "This is the default text.")\
                .scroll_container().rect_min_y(100).rect_y(100).enter()\
                    .text_edit("text_edit", "A\nB\nC").size_expand_fill()\
                .exit()\
                .v_box_container("sub_section").enter()\
                    .spin_box("key1", 69)\
                    .h_box_container().enter()\
                        .label().ref("slider_label")\
                        .h_slider("slider_val", 42).size_flags_h(Control.SIZE_EXPAND_FILL)\
                            .connect_to_prop("loaded", builder.get_ref("slider_label"), "text")\
                            .connect_to_prop("value_changed", builder.get_ref("slider_label"), "text")\
                    .exit()\
                .exit()\
                .h_box_container().enter()\
                    .color_picker("color1", Color(0, 0, 0, 1))\
                    .color_picker_button("color2", Color(1, 1, 1, 1)).size_flags_h(Control.SIZE_EXPAND_FILL)\
                .exit()\
            .build()
    # builder is freed sometime after build() is called, dereference
    builder = null
    print(config.key1)
    # we can also access the node itself by prepending the key with an underscore
    print(config._key1)
    print(config.key2)
    print(config.color1)
    print(config.color2)
    print(config.option)
    print(config.sub_section)
    print(config.sub_section.key1)
    print(config.sub_section.slider_val)

    config.option = 0 # this works
    config.option = "c" # this also works

    # short example of the PreferencesWindowApi
    var label = Label.new()
    label.text = "TESTO"
    var config_container = self.Global.API.PreferencesWindowApi.create_category("CATEGORY")
    config_container.add_child(label)
    label.owner = config_container

    var component_key = self.Global.API.ComponentsApi.register("test_component", PropComponent, self.Global.API.ComponentsApi.FLAG_ALL, false)
    # you can now use:
    # component_key.get_component(some_prop)
    # to get the instance of PropComponent tied to that specific Prop

# Input/ HistoryApi example
func update(_delta):
    if (Input.is_action_just_released("release_kraken", true)):
        self.Global.API.HistoryApi.record(DummyRecord.new(counter), 10)
        counter = counter + 1
    

class DummyRecord:
    var _num: String

    func _init(num):
        _num = str(num)

    func undo():
        print("undo " + _num)

    func redo():
        print("redo " + _num)

class PropComponent:
    var _num: int

    # can also use static func create(node: Node) instead
    func _init(_node: Node, num: int = OS.get_unix_time()):
        _num = num
        print("component prop num " + str(num))
    
    static func deserialize(_node: Node, data) -> PropComponent:
        print("deserializing")
        return PropComponent.new(_node, data)
        
    func serialize(_node: Node):
        return _num