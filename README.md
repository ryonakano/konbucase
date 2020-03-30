# KonbuCase
KonbuCase is a case converting app designed for elementary OS.

![](data/Screenshot.png)

Features include:

* Click "Copy to Clipboard" button to copy the all texts in the text view without selecting them
* Undo and redo for case changes

## Building and Installation
### For Developers
You'll need the following dependencies:

* libgranite-dev
* libgtk-3.0-dev
* libgtksourceview-3.0-dev
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.konbucase`

    sudo ninja install
    com.github.ryonakano.konbucase

## Contributing
There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements
Simply [create a new issue](https://github.com/ryonakano/konbucase/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://elementary.io/docs/code/reference#reporting-bugs) is for you.

### Writing Some Code
We follow the [coding style of elementary OS](https://elementary.io/docs/code/reference#code-style) and [its Human Interface Guidelines](https://elementary.io/docs/human-interface-guidelines#human-interface-guidelines), please try to respect them.

### Translating This App
I accept translations through Pull Requests. If you're not sure how to do, [the guideline I made](po/README.md) might be helpful.

## The Story of the App Name
I always feel the pronunciations "Konbu" and "Conv" (Convert) sound similar (you may not feel though…). This app is a case converter, so I named this app "KonbuCase".
