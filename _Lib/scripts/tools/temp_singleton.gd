var script_class = "tool"

# see explanation above _lib.gd _init method
func _init():
    # add a signal _lib.gd can use to call pong()
    if (not Engine.has_signal("_lib_internal_temp_singleton")):
        Engine.add_user_signal("_lib_internal_temp_singleton", [])
    Engine.connect("_lib_internal_temp_singleton", self, "pong")
    # if lib.gd loads first at this point it will already have its Global and Script set so we just tell it to use its own
    if (Engine.has_signal("_lib_internal_post_init")):
        Engine.emit_signal("_lib_internal_post_init")

# if temp_singleton.gd loads first it this will provide its own instance to _lib.gd (with Global and Script available)
# otherwise this will just diconnect the signal 
func pong():
    Engine.disconnect("_lib_internal_temp_singleton", self, "pong")
    Engine.emit_signal("_lib_internal_post_init", self)