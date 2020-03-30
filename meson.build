project('com.github.ryonakano.konbucase',
    'vala', 'c',
    version: '0.1.0'
)

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

executable(
    meson.project_name(),
    asresources,
    'src/Services/Buffer.vala',
    'src/Application.vala',
    'src/MainWindow.vala',
    dependencies: [
        dependency('granite', version: '>=5.2.3'),
        dependency('gdk-3.0'),
        dependency('gtk+-3.0'),
        dependency('gtksourceview-3.0'),
    ],
    install: true
)

subdir('po')
