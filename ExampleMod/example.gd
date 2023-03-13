var script_class = "tool"

func start():
    if (not Engine.has_signal("_lib_register_mod")):
        return
    Engine.emit_signal("_lib_register_mod", self)

    var config = self.Global.API.ModConfigApi.create_config("CreepyCre.ExampleMod", "Example Mod Config", self.Global.Root + "config.json")\
                .check_button("key1", false, "Some Option IDK")\
                .check_box("key2", false, "Some other Option IDK")\
                .h_separator()\
                .label("TEXT\n\n\n\n\n\nTEST\n\n\n\nTEST\n\n\n\nscroll?")\
                .spin_box("key3", 69)\
                .h_slider("key4", 42)\
            .build()

    print(JSON.print(config.serialize(), "\t"))
    print(config.key1)
    print(config.key2)
    print(config.key3)
    print(config.key4)


    self.Global.API.PreferencesWindowApi.create_category("CATEGORY")