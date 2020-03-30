# KonbuCase
![](Screenshot.png)

## Building and Installation
### For Developers
You'll need the following dependencies:

* libgtk-3.0-dev
* libgranite-dev (>= 5.2.3)
* meson
* valac

Run `meson build` to configure the build environment. Change to the build directory and run `ninja` to build

    meson build --prefix=/usr
    cd build
    ninja

To install, use `ninja install`, then execute with `com.github.ryonakano.konbucase`

    sudo ninja install
    com.github.ryonakano.konbucase
