var script_class = "tool"

func _init():
    if (not Engine.has_signal("_lib_internal_temp_singleton")):
        Engine.add_user_signal("_lib_internal_temp_singleton", [])
    Engine.connect("_lib_internal_temp_singleton", self, "pong")
    if (Engine.has_signal("_lib_internal_post_init")):
        Engine.emit_signal("_lib_internal_post_init")

func pong():
    Engine.disconnect("_lib_internal_temp_singleton", self, "pong")
    Engine.emit_signal("_lib_internal_post_init", self)