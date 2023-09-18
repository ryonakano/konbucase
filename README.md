# KonbuCase
![Light mode](data/screenshots/pantheon/screenshot-light.png)

KonbuCase is a simple case converting app. Features include:

* Click "Copy to Clipboard" button to copy the all texts in the text view without selecting them
* Convert your text between camelCase, PascalCase, Sentence case, snake_case, kebab-case, and space-separated

## Installation
### For Users
On elementary OS? Click the button to get KonbuCase on AppCenter:

[![Get it on AppCenter](https://appcenter.elementary.io/badge.svg)](https://appcenter.elementary.io/com.github.ryonakano.konbucase)

You can also download the app from Flathub, in case you're using another distribution.

[<img src="https://flathub.org/assets/badges/flathub-badge-en.svg" width="160" alt="Download on Flathub">](https://flathub.org/apps/details/com.github.ryonakano.konbucase)

Community packages maintained by volunteers are also available on some distributions:

[![Packaging status](https://repology.org/badge/vertical-allrepos/konbucase.svg)](https://repology.org/project/konbucase/versions)

### For Developers
You'll need the following dependencies:

* [libchcase](https://github.com/ryonakano/chcase)
    * automatically downloaded on build
* libgranite-7-dev
* libgtk4-dev
* libgtksourceview-5-dev
* meson (>= 0.57.0)
* [libryokucha](https://github.com/ryonakano/ryokucha)
    * automatically downloaded on build
* valac

Run `meson setup` to configure the build environment and run `ninja` to build

```bash
meson setup builddir --prefix=/usr
ninja -C builddir
```

To install, use `ninja install`, then execute with `com.github.ryonakano.konbucase`

```bash
ninja install -C builddir
com.github.ryonakano.konbucase
```

## Contributing
There are many ways you can contribute, even if you don't know how to code.

### Reporting Bugs or Suggesting Improvements
Simply [create a new issue](https://github.com/ryonakano/konbucase/issues/new) describing your problem and how to reproduce or your suggestion. If you are not used to do, [this section](https://docs.elementary.io/contributor-guide/feedback/reporting-issues) is for you.

### Writing Some Code
We follow [the coding style of elementary OS](https://docs.elementary.io/develop/writing-apps/code-style) and [its Human Interface Guidelines](https://docs.elementary.io/hig/). Try to respect them.

### Translation
We accept translations of this project through [Weblate](https://weblate.org/). We would appreciate it if you would join our translation work!

Click the following graphs to get started:

| Main: Texts in the app itself | Extra: Texts in the desktop entry and the software center |
| --- | --- |
| [![Translation status](https://hosted.weblate.org/widgets/rosp/-/konbucase-main/multi-auto.svg)](https://hosted.weblate.org/projects/rosp/konbucase-main) | [![Translation status](https://hosted.weblate.org/widgets/rosp/-/konbucase-extra/multi-auto.svg)](https://hosted.weblate.org/projects/rosp/konbucase-extra) |

## The Story of the App Name
![](data/Konbu.png)

I always feel the pronunciations "Konbu" and "Conv" (Convert) sound similar (you may not feel though…). This app is a **case conv**erter, so I named this app "KonbuCase".
