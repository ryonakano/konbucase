project('com.github.ryonakano.konbucase',
    'vala', 'c',
    version: '4.1.1',
    meson_version: '>=0.57.0'
)

app_nickname = 'konbucase'

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

dependencies = [
    dependency('granite-7'),
    dependency('gtk4'),
    dependency('gtksourceview-5')
]

sources = files(
    'src' / 'Widgets' / 'ComboEntry.vala',
    'src' / 'Application.vala',
    'src' / 'MainWindow.vala',
    'src' / 'StyleSwitcher.vala',
    'src' / 'TextType.vala'
)

if get_option('use_submodule')
    chcase_subproject = subproject('chcase')
    chcase_deps = chcase_subproject.get_variable('libchcase')
    dependencies += chcase_deps

    ryokucha_subproject = subproject('ryokucha')
    ryokucha_deps = ryokucha_subproject.get_variable('libryokucha')
    dependencies += ryokucha_deps
else
    dependencies += dependency('chcase')
    dependencies += dependency('ryokucha')
endif

executable(
    meson.project_name(),
    config_file,
    sources,
    dependencies: dependencies,
    install: true
)

subdir('data')
subdir('po')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
