#! /usr/bin/env python3

import os
import subprocess

install_prefix = os.environ['MESON_INSTALL_PREFIX']
schemadir = os.path.join(install_prefix, 'share', 'glib-2.0', 'schemas')
icon_cache_dir = os.path.join(install_prefix, 'share', 'icons', 'hicolor')

if not os.environ.get('DESTDIR'):
    print('Compiling the gsettings schemas...')
    subprocess.call(['glib-compile-schemas', schemadir])

    print('Updating desktop icon cache…')
    subprocess.call(['gtk-update-icon-cache', '-qtf', icon_cache_dir])
