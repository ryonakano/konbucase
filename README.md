# KonbuCase
![App window in the light mode](data/screenshots/gnome/screenshot-light.png#gh-light-mode-only)

![App window in the dark mode](data/screenshots/gnome/screenshot-dark.png#gh-dark-mode-only)

KonbuCase is a small text tool app that allows you convert case in your text.

Features include:

* Click "Copy to Clipboard" button to copy the all texts in the text view without selecting them
* Convert your text between camelCase, PascalCase, Sentence case, snake_case, kebab-case, and space-separated

## Installation
### From Flathub or AppCenter (Recommended)
You can install KonbuCase from Flathub:

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/com.github.ryonakano.konbucase)

You should install KonbuCase from AppCenter if you're on elementary OS. This build is optimized for elementary OS:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.konbucase)

### From Community Packages
Community packages maintained by volunteers are also available on some distributions:

[![Packaging status](https://repology.org/badge/vertical-allrepos/konbucase.svg)](https://repology.org/project/konbucase/versions)

### From Source Code (Flatpak)
You'll need `flatpak` and `flatpak-builder` commands installed on your system.

Run `flatpak remote-add` to add Flathub remote for dependencies:

```
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
```

To build and install, use `flatpak-builder`, then execute with `flatpak run`:

```
flatpak-builder builddir --user --install --force-clean --install-deps-from=flathub build-aux/flathub/com.github.ryonakano.konbucase.Devel.yml
flatpak run com.github.ryonakano.konbucase.Devel
```

### From Source Code (Native)
You'll need the following dependencies:

* blueprint-compiler
* [libchcase](https://github.com/ryonakano/chcase)
* libadwaita-1-dev (>= 1.4)
* libgranite-7-dev (>= 7.2.0, required only when you build with `granite` feature enabled)
* libgtk4-dev
* libgtksourceview-5-dev
* meson (>= 0.58.0)
* valac

Run `meson setup` to configure the build environment and run `meson compile` to build:

```bash
meson setup builddir --prefix=/usr
meson compile -C builddir
```

To install, use `meson install`, then execute with `com.github.ryonakano.konbucase`:

```bash
meson install -C builddir
com.github.ryonakano.konbucase
```

## Contributing
Please refer to [the contribution guideline](CONTRIBUTING.md) if you would like to:

- submit bug reports / feature requests
- propose coding changes
- translate the project

## Get Support
Need help in use of the app? Refer to [the discussions page](https://github.com/ryonakano/konbucase/discussions) to search for existing discussions or [start a new discussion](https://github.com/ryonakano/konbucase/discussions/new/choose) if none is relevant.

## The Story of the App Name
![Drawing of Konbu](data/Konbu.png)

I always feel the pronunciations "Konbu" and "Conv" (Convert) sound similar (you may not feel though…). This app is a **case conv**erter, so I named this app "KonbuCase".
