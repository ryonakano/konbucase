config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('APP_VERSION', app_version)
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
    input: 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

granite_dep = dependency('granite-7', version: '>= 7.2.0', required: get_option('granite'))
if granite_dep.found()
    add_project_arguments('--define=USE_GRANITE', language: 'vala')
endif

dependencies = [
    granite_dep,
    dependency('libadwaita-1', version: '>= 1.5'),
    dependency('gtk4'),
    dependency('gtksourceview-5'),
]

if get_option('use_submodule')
    chcase_subproject = subproject('chcase')
    chcase_deps = chcase_subproject.get_variable('libchcase')
    dependencies += chcase_deps
else
    dependencies += dependency('chcase')
endif

sources = files(
    'Model/MainWindowModel.vala',
    'Model/TextPaneModel.vala',
    'View/MainWindow.vala',
    'View/TextPane.vala',
    'Application.vala',
    'Define.vala',
    'Util.vala',
)

executable(
    app_id,
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
