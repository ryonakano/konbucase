# KonbuCase
![App window in the light mode](data/screenshots/pantheon/screenshot-light.png#gh-light-mode-only)

![App window in the dark mode](data/screenshots/pantheon/screenshot-dark.png#gh-dark-mode-only)

KonbuCase is a small text tool app that allows you convert case in your text.

Features include:

* Click "Copy to Clipboard" button to copy the all texts in the text view without selecting them
* Convert your text between camelCase, PascalCase, Sentence case, snake_case, kebab-case, and space-separated

## Installation
### From AppCenter or Flathub (Recommended)
Click the button to get KonbuCase on AppCenter if you're on elementary OS:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.konbucase)

You can install KonbuCase from Flathub if you're on another distribution:

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/com.github.ryonakano.konbucase)

### From Community Packages
Community packages maintained by volunteers are also available on some distributions:

[![Packaging status](https://repology.org/badge/vertical-allrepos/konbucase.svg)](https://repology.org/project/konbucase/versions)

### From Source Code (Flatpak)
If you would like to test latest source code, clone the repository and then run the following command:

```
flatpak remote-add --user --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
flatpak remote-add --user --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
flatpak install -y --user flathub org.flatpak.Builder
flatpak run org.flatpak.Builder builddir-flatpak --user --install --force-clean --install-deps-from=appcenter com.github.ryonakano.konbucase.yml
```

### From Source Code (Native)
You'll need the following dependencies to build:

* blueprint-compiler
* [libchcase](https://github.com/ryonakano/chcase)
    * automatically downloaded on build
* libgranite-7-dev
* libgtk4-dev
* libgtksourceview-5-dev
* meson (>= 0.57.0)
* valac

Run `meson setup` to configure the build environment and run `meson compile` to build:

```bash
meson setup builddir --prefix=/usr
meson compile -C builddir
```

To install, use `meson install`, then execute with `com.github.ryonakano.konbucase`

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
