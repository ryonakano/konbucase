config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

dependencies = [
    dependency('granite-7'),
    dependency('gtk4'),
    dependency('gtksourceview-5')
]

sources = files(
    'Widgets' / 'ComboEntry.vala',
    'Application.vala',
    'Define.vala',
    'MainWindow.vala',
    'StyleManager.vala'
)

if get_option('use_submodule')
    chcase_subproject = subproject('chcase')
    chcase_deps = chcase_subproject.get_variable('libchcase')
    dependencies += chcase_deps
else
    dependencies += dependency('chcase')
endif

executable(
    meson.project_name(),
    asresources,
    config_file,
    sources,
    # Workaround for a bug in meson < 1.4.0
    # https://gitlab.gnome.org/jwestman/blueprint-compiler/-/issues/18
    # https://github.com/mesonbuild/meson/commit/ae857e841b0a6b9b595583e74f5e21676bb83f9d
    vala_args: [
        '--gresourcesdir=data/resources'
    ],
    dependencies: dependencies,
    install: true
)
