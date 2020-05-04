project('com.github.ryonakano.konbucase',
    'vala', 'c',
    version: '0.1.1'
)

granite_dep = dependency('granite')
if granite_dep.version() >= '5.4.0'
    add_project_arguments(['--define', 'GRANITE_HAS_DARK_PREF'], language: 'vala')
endif

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

asresources = gnome.compile_resources(
    'as-resources',
    join_paths('data', meson.project_name() + '.gresource.xml'),
    source_dir: 'data',
    c_name: 'as'
)

gtksourceview_dep = dependency('gtksourceview-4', required: false)
if gtksourceview_dep.found() == false
    gtksourceview_dep = dependency('gtksourceview-3.0')
endif

executable(
    meson.project_name(),
    asresources,
    'src/Services/Converter.vala',
    'src/Services/TextType.vala',
    'src/Widgets/ComboEntry.vala',
    'src/Application.vala',
    'src/MainWindow.vala',
    dependencies: [
        granite_dep,
        dependency('gdk-3.0'),
        dependency('gtk+-3.0'),
        gtksourceview_dep,
    ],
    install: true
)

subdir('data')
subdir('po')

meson.add_install_script('meson/post_install.py')
