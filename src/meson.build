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
    'ComboEntry.vala',
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
    config_file,
    sources,
    dependencies: dependencies,
    install: true
)
