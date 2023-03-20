---
_: _
---
root: ..
methods:    Control create_category(name: String, container: Control = _create_default_container()=)
            void show_close()
            void show_back()
            WindowDialog get_preferences_window()
signals:    back_pressed()
            apply_pressed()
            about_to_show()

An Api that makes adding additional tabs to the preferences window easy.


## Description

The PreferencesWindowApi makes it possible to easily add new tabs to the preferences window using :method:short:`create_category`. The attached container can then interact with the preferences window using the provided methods and signals.


## Methods

:methods:


## Signals

:signal:anchor:`back_pressed`: <br>
<span class="indent">
Emitted whenever the back button is pressed.
</span>

:signal:anchor:`apply_pressed`: <br>
<span class="indent">
Emitted whenever the apply button is pressed.
</span>

:signal:anchor:`about_to_show`: <br>
<span class="indent">
Emitted right before the preferences window would open up. Use this signal to for example rebuild :link:`Tree`s.
</span>


## Method Descriptions

:method:anchor:`create_category`: <br>
<span class="indent">
Creates a new category in the preferences window under the name :param:`name`. Attaches :param:`container` if given or generates a blank :link:`VBoxContainer` as the new category panel and returns it.
</span>

:method:anchor:`show_close`: <br>
<span class="indent">
Makes the close button show and hides the back button. Each tab has their close/ back button visibility maintained seperately.
</span>

:method:anchor:`show_back`: <br>
<span class="indent">
Makes a back button show in the preferences window instead of the normal close button. Each tab has their close/ back button visibility maintained seperately.
</span>

:method:anchor:`get_preferences_window`: <br>
<span class="indent">
Returns the PreferencesWindow :link:`WindowDialog`.
</span>
