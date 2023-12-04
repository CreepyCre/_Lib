---
_: _
---
root: ../..
methods:    ConfigBuilder enter()
            ConfigBuilder exit()
            ConfigBuilder add_node(node: Control, legible_unique_name: bool = false=)
            ConfigBuilder add_node_direct(node: Control, legible_unique_name: bool = false=)
            ConfigBuilder with(property: String, value)
            ConfigBuilder size_flags_h(flags: int)
            ConfigBuilder size_flags_v(flags: int)
            ConfigBuilder size_expand_fill()
            ConfigBuilder rect_min_size(min_size: Vector2)
            ConfigBuilder rect_min_x(min_x: float)
            ConfigBuilder rect_min_y(min_y: float)
            ConfigBuilder rect_size(size: Vector2)
            ConfigBuilder rect_x(x: float)
            ConfigBuilder rect_y(y: float)
            ConfigBuilder flatten(value: bool = true=)
            Control get_current()
            ConfigBuilder ref(reference_name: String)
            Control get_ref(reference_name: String)
            ConfigBuilder call_on(method_name: String, args...)
            ConfigBuilder call_on_ref(reference_name: String, method_name: String, args...)
            ConfigBuilder connect_current(signal_name: String, target: Object, method_name: String, binds: Array = []=, flags: int = 0=)
            ConfigBuilder connect_ref(reference_name: String, signal_name: String, target: Object, method_name: String, binds: Array = []=, flags: int = 0=)
            ConfigBuilder connect_to_prop(signal_name: String, target, property: String)
            ConfigBuilder connect_ref_to_prop(reference_name: String, signal_name: String, target, property: String)
            ConfigBuilder add_color_override(name: String, color: Color)
            ConfigBuilder add_constant_override(name: String, constant: int)
            ConfigBuilder add_font_override(name: String, font: Font)
            ConfigBuilder add_icon_override(name: String, texture: Texture)
            ConfigBuilder add_shader_override(name: String, shader: Shader)
            ConfigBuilder add_stylebox_override(name: String, stylebox: StyleBox)
            ConfigBuilder wrap(save_entry: String, root_node: Control, target_node = null=)
            ConfigBuilder extend(save_entry: String, node: Control)
            ConfigBuilder check_button(save_entry: String, default_value: bool, text: String = ""=)
            ConfigBuilder check_box(save_entry: String, default_value: bool, text: String = ""=)
            ConfigBuilder h_slider(save_entry: String, default_value: float)
            ConfigBuilder v_slider(save_entry: String, default_value: float)
            ConfigBuilder spin_box(save_entry: String, default_value: float)
            ConfigBuilder color_picker(save_entry: String, default_value: Color)
            ConfigBuilder color_picker_button(save_entry: String, default_value: Color)
            ConfigBuilder option_button(save_entry: String, default_value: int, options: Array)
            ConfigBuilder line_edit(save_entry: String, default_value: String, require_hit_enter: bool = true=)
            ConfigBuilder text_edit(save_entry: String, default_value: String)
            ConfigBuilder shortcuts(save_entry: String, definitions: Dictionary)
            ConfigBuilder aspect_ratio_container(save_entry: String = ""=)
            ConfigBuilder center_container(save_entry: String = ""=)
            ConfigBuilder h_box_container(save_entry: String = ""=)
            ConfigBuilder v_box_container(save_entry: String = ""=)
            ConfigBuilder grid_container(save_entry: String = ""=)
            ConfigBuilder h_split_container(save_entry: String = ""=)
            ConfigBuilder v_split_container(save_entry: String = ""=)
            ConfigBuilder margin_container(save_entry: String = ""=)
            ConfigBuilder panel_container(save_entry: String = ""=)
            ConfigBuilder scroll_container(save_entry: String = ""=)
            ConfigBuilder tab_container(save_entry: String = ""=)
            ConfigBuilder color_rect(color: Color)
            ConfigBuilder h_separator()
            ConfigBuilder v_separator()
            ConfigBuilder label(text: String = ""=)
            ConfigBuilder nine_patch_rect()
            ConfigBuilder panel()
            ConfigBuilder reference_rect()
            ConfigBuilder rich_text_label(bbcode_text: String = ""=)
            ConfigBuilder texture_rect(texture: Texture)
            ConfigAgent build(should_load: bool = true=, should_free: bool = true=)
            ConfigAgent get_agent()
            Control get_root()

Makes it possible to construct a config menu in a fairly human readable manner.


## Description

The ConfigBuilder is used to create mod configs. It is supposed to provide an intuitive and human readable api for doing so. To achieve this, it relies on method chaining so the code for setting up a config may look structurally similar to the resulting config file. The following general types of methods are provided:

- Scene tree navigation (:method:short:`enter` and :method:short:`exit`)
- Node attachment and creation (e.g. :method:short:`add_node`)
- Node configuration (e.g. :method:short:`size_expand_fill` and :method:short:`with`)
- Node referencing (see :method:short:`ref`)

A ConfigBuilder is obtained by creating a mod config using the ModConfigApi:
```gdscript
var mod_id: String = "CreepyCre.ExampleMod"
var config_title: String = "Example Mod Config"
var config_file: String = self.Global.Root + "config.json"
var builder = self.Global.API.ModConfigApi.create_config(mod_id, config_title, config_file)
```

:link:`Control` nodes may then be created and appended to the config screen using their appropriate methods. The config can be built at the end using<br>:method:short:`build`:
```gdscript
# multiline method chaining does not allow comments inbetween
var config = builder\
    .label("Hello World!")\
    .check_button("key1", true, "This is a check Button!")\
    .build()
```
Writing a `\` at the end of a line allows for method chaining across multiple lines. Config nodes such as the :link:`CheckButton` created through<br>:method:short:`check_button`<br>take a :param:`save_entry` and :param:`default_value` as parameters. The :param:`save_entry` is the key the setting will be saved under in the config file. 

For appending nodes as children of other nodes :method:short:`enter` and :method:short:`exit` allow hopping into and out of nodes:
```gdscript
builder\
    .v_box_container().enter()\
        .h_box_container().enter()\
            .label("Hello World!")\
        .exit()\
    .exit()
```
Mind the indentation in this example. Though it serves no actual purpose indenting methods indicating the depth of the node entered is recommended for increased readability.

Also mind the optional :param:`save_entry` parameter available for container type node creation. Supplying :param:`save_entry` will create sub categories for all contained config nodes. For example:
```gdscript
var config = builder\
            .h_box_container("category").enter()\
                .check_button("key1", true, "Hello")\
                .check_box("key2", true, "World")\
            .exit()\
            .line_edit("key3", "This is the default text.")\
            .build()
```

Will result in the following config:
```gdscript
{
    "category": {
        "key1": true,
        "key2": true
    }
    "key3": "This is the default text."
}
```

Config values may then be accessed and modified through the :link:`ConfigAgent` returned when building the config:
```gdscript
# access value
print(config.category.key1)
# change value
config.category.key1 = false
```

For styling the nodes there are some shorthand methods available like<br>:method:short:`size_flags_h` or :method:short:`rect_min_size`.<br>For accessing properties and methods that do not have shorthand equivalents use<br>:method:short:`with` and :method:short:`call_on` which both perform actions on the last node created. :link:`#with` directly sets the given :param:`property` to :param:`value` while :link:`#call_on` forwards its parameters to :link:`Object#call`:
```gdscript
# hidden spin box. idk why you'd want this, it's just an example
builder.spin_box("key", 70)\
        .with("suffix","dpi")\
        .call_on("hide")
```

For connecting node signals use :link:`#connect_current` and :link:`#connect_to_prop`. While :link:`#connect_current` forwards its parameters to connect, :link:`#connect_to_prop` actually forwards the signal to a utility methods that always updates the property :param:`property` of :param:`target` with the emitted value. 

How would you handle connecting different config nodes signals together? To avoid having to keep references to nodes which would interrupt code flow use :method:short:`ref`. It assigns the key :param:`reference_name` to the last node so it may later be retrieved using :method:short:`get_ref` or be called on using<br>:method:short:`call_on_ref`,<br>:method:short:`connect_ref` and<br>:method:short:`connect_ref_to_prop`. E.g.:
```gdscript
builder\
    .label().ref("slider_label")\
    .h_slider("key", 42).size_flags_h(Control.SIZE_EXPAND_FILL)\
        .connect_to_prop("loaded", builder.get_ref("slider_label"), "text")\
        .connect_to_prop("value_changed", builder.get_ref("slider_label"), "text")\
```
In this example the text label has been connected to the sliders `loaded` and `value_changed` signals to make it display the current slider value.

## Methods

:methods:


## Method Descriptions

:method:anchor:`enter`: <br>
<span class="indent">
Enters the last :link:`Control` appended so new nodes will be created as its children.
</span>

:method:anchor:`exit`: <br>
<span class="indent">
Exits the node previously entered.
</span>

:method:anchor:`add_node`: <br>
<span class="indent">
Adds :param:`node` as child of the node currently entered.
</span>

:method:anchor:`add_node_direct`: <br>
<span class="indent">
Directly adds :param:`node` as child of the node currently entered bypassing the get_target() call.
</span>

:method:anchor:`with`: <br>
<span class="indent">
Sets the property :param:`property` to :param:`value` on the most recent node.
</span>

:method:anchor:`size_flags_h`: <br>
<span class="indent">
Sets the property :link:`Control#size_flags_horizontal` to :param:`flags` on the most recent node.
</span>

:method:anchor:`size_flags_v`: <br>
<span class="indent">
Sets the property :link:`Control#size_flags_vertical` to :param:`flags` on the most recent node.
</span>

:method:anchor:`size_expand_fill`: <br>
<span class="indent">
Shorthand for:
```gdscript
.size_flags_h(Control.SIZE_EXPAND_FILL)\
.size_flags_v(Control.SIZE_EXPAND_FILL)
```
</span>

:method:anchor:`rect_min_size`: <br>
<span class="indent">
Sets the property :link:`Control#rect_min_size` to :param:`min_size` on the most recent node.
</span>

:method:anchor:`rect_min_x`: <br>
<span class="indent">
Shorthand for:
```gdscript
.rect_min_size(Vector2(min_x, builder.get_current().rect_min_size.y))
```
</span>

:method:anchor:`rect_min_y`: <br>
<span class="indent">
Shorthand for:
```gdscript
.rect_min_size(Vector2(builder.get_current().rect_min_size.x, min_y))
```

</span>

:method:anchor:`rect_size`: <br>
<span class="indent">
Sets the property :link:`Control#rect_size` to :param:`size` on the most recent node.
</span>

:method:anchor:`rect_x`: <br>
<span class="indent">
Shorthand for:
```gdscript
.rect_size(Vector2(x, builder.get_current().rect_size.y))
```
</span>

:method:anchor:`rect_y`: <br>
<span class="indent">
Shorthand for:
```gdscript
.rect_size(Vector2(builder.get_current().rect_size.x, y))
```
</span>

:method:anchor:`flatten`: <br>
<span class="indent">
Calls flatten(:param:`value`) on the most recent node. Setting :param:`value` to `true` will make the most recent node flatten its child config entries into its parent node.
</span>

:method:anchor:`get_current`: <br>
<span class="indent">
Returns the most recent node.
</span>

:method:anchor:`ref`: <br>
<span class="indent">
Gives the most recent node the identifier :param:`reference_name` so it can be retrieved later using :method:short:`get_ref`
</span>

:method:anchor:`get_ref`: <br>
<span class="indent">
Returns the node with identifier :param:`reference_name`.
</span>

:method:anchor:`call_on`: <br>
<span class="indent">
Calls method :param:`method_name` with arguments :param:`args` on the most recent node.
</span>

:method:anchor:`call_on_ref`: <br>
<span class="indent">
Calls method :param:`method_name` with arguments :param:`args` on node with identifier :param:`reference_name`.
</span>

:method:anchor:`connect_current`: <br>
<span class="indent">
Calls :link:`Object#connect` on the most recent node using identical paramters.
</span>

:method:anchor:`connect_ref`: <br>
<span class="indent">
Calls :link:`Object#connect` on the node with identifier :param:`reference_name` using identical paramters besides :param:`reference_name`.
</span>

:method:anchor:`connect_to_prop`: <br>
<span class="indent">
Connects the signal :param:`signal_name` from the most recent node such that the emitted value is applied to property :parameter:`property` in :parameter:`target`.
</span>

:method:anchor:`connect_ref_to_prop`: <br>
<span class="indent">
Connects the signal :param:`signal_name` from the node with identifier :param:`reference_name` such that the emitted value is applied to property :parameter:`property` in :parameter:`target`.
</span>

:method:anchor:`add_color_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_color_override` on the most recent node.
</span>

:method:anchor:`add_constant_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_constant_override` on the most recent node.
</span>

:method:anchor:`add_font_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_font_override` on the most recent node.
</span>

:method:anchor:`add_icon_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_icon_override` on the most recent node.
</span>

:method:anchor:`add_shader_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_shader_override` on the most recent node.
</span>

:method:anchor:`add_stylebox_override`: <br>
<span class="indent">
Forwards call to :link:`Control#add_stylebox_override` on the most recent node.
</span>

:method:anchor:`wrap`: <br>
<span class="indent">
Wraps a scene in a WrappedControlConfigNode where :param:`root_node` is the scene root and :param:`target_node` is where new child nodes will be appended by the ConfigBuilder. The wrapped scenes config nodes will be saved into the category :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`extend`: <br>
<span class="indent">
Appends :param:`node` as a child of the currently entered node and gives it config node capabilities by settings its script to ContainerExtensionConfigNode.
</span>

:method:anchor:`check_button`: <br>
<span class="indent">
Appends a :link:`CheckButton` config node with config key :param:`save_entry`, default value :param:`default_value` and text :param:`text`.
</span>

:method:anchor:`check_box`: <br>
<span class="indent">
Appends a :link:`CheckBox` config node with config key :param:`save_entry`, default value :param:`default_value` and text :param:`text`.
</span>

:method:anchor:`h_slider`: <br>
<span class="indent">
Appends an :link:`HSlider` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`v_slider`: <br>
<span class="indent">
Appends a :link:`VSlider` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`spin_box`: <br>
<span class="indent">
Appends a :link:`SpinBox` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`color_picker`: <br>
<span class="indent">
Appends a :link:`ColorPicker` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`color_picker_button`: <br>
<span class="indent">
Appends a :link:`ColorPickerButton` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`option_button`: <br>
<span class="indent">
Appends an :link:`OptionButton` config node with config key :param:`save_entry`, default value :param:`default_value` and options :param:`options`. The entries of :param:`options` can either be :link:`String`s for a plain labelled option or dictionaries with possible entries `"label"`, `"icon"` and `"meta"`. Accessing the config value from the :link:`ConfigAgent` will return the selected options meta if available or its label. The selected option can be changed through the :link:`ConfigAgent` by setting it to either its index or its label:

```gdscript
agent.some_option_button = 2 # this works
agent.some_option_button = "label goes here" # this also works
```

</span>

:method:anchor:`line_edit`: <br>
<span class="indent">
Appends a :link:`LineEdit` config node with config key :param:`save_entry` and default value :param:`default_value`. :param:`require_hit_enter` configures whether the Enter key must be hit to update the config value.
</span>

:method:anchor:`text_edit`: <br>
<span class="indent">
Appends a :link:`TextEdit` config node with config key :param:`save_entry` and default value :param:`default_value`.
</span>

:method:anchor:`shortcuts`: <br>
<span class="indent">
Appends a :link:`Tree` config node with config key :param:`save_entry` that contains shortcuts defined via :param:`definitions`. :param:`definitions` has to be structured equivalent to :param:`actions` in :link:`InputMapApi#define_actions`, though any default shortcuts will be ignored here.
</span>

:method:anchor:`aspect_ratio_container`: <br>
<span class="indent">
Appends an :link:`AspectRatioContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`center_container`: <br>
<span class="indent">
Appends a :link:`CenterContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`h_box_container`: <br>
<span class="indent">
Appends a :link:`HBoxContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`v_box_container`: <br>
<span class="indent">
Appends a :link:`VBoxContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`grid_container`: <br>
<span class="indent">
Appends a :link:`GridContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`h_split_container`: <br>
<span class="indent">
Appends an :link:`HSplitContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`v_split_container`: <br>
<span class="indent">
Appends a :link:`VSplitContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`margin_container`: <br>
<span class="indent">
Appends a :link:`MarginContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`panel_container`: <br>
<span class="indent">
Appends a :link:`PanelContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`scroll_container`: <br>
<span class="indent">
Appends a :link:`ScrollContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`tab_container`: <br>
<span class="indent">
Appends a :link:`TabContainer` with config key :param:`save_entry`. Setting :param:`save_entry` to "" flattens the node.
</span>

:method:anchor:`color_rect`: <br>
<span class="indent">
Appends a :link:`ColorRect` with :param:`color` as its color.
</span>

:method:anchor:`h_separator`: <br>
<span class="indent">
Appends an :link:`HSeparator`.
</span>

:method:anchor:`v_separator`: <br>
<span class="indent">
Appends a :link:`VSeparator`.
</span>

:method:anchor:`label`: <br>
<span class="indent">
Appends a :link:`Label` with text :param:`text`.
</span>

:method:anchor:`nine_patch_rect`: <br>
<span class="indent">
Appends a :link:`NinePatchRect`.
</span>

:method:anchor:`panel`: <br>
<span class="indent">
Appends a :link:`Panel`.
</span>

:method:anchor:`reference_rect`: <br>
<span class="indent">
Appends a :link:`ReferenceRect`.
</span>

:method:anchor:`rich_text_label`: <br>
<span class="indent">
Appends a bbcode enabled :link:`RichTextLabel` with :param:`bbcode_text` as its bbcode_text.
</span>

:method:anchor:`texture_rect`: <br>
<span class="indent">
Appends a :link:`TextureRect` with texture :param:`texture`.
</span>

:method:anchor:`build`: <br>
<span class="indent">
Builds the config panel and returns the :link:`ConfigAgent`. If :param:`should_load` is set to true the config will be loaded upon building it. If :param:`should_free` is set to true the ConfigBuilder will be freed after the config has been built.
</span>

:method:anchor:`get_agent`: <br>
<span class="indent">
Returns the :link:`ConfigAgent`
</span>

:method:anchor:`get_root`: <br>
<span class="indent">
Returns the root node of the config.
</span>