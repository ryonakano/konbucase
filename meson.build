project('com.github.ryonakano.konbucase',
    'vala', 'c',
    version: '4.2.0',
    meson_version: '>=0.57.0'
)

app_name = 'KonbuCase'
app_id = meson.project_name()
if get_option('development')
    app_name += ' (Development)'
    app_id += '.Devel'
endif

i18n = import('i18n')
gnome = import('gnome')

add_project_arguments(
    '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
    language: 'c'
)

subdir('data')
subdir('po')
subdir('src')

gnome.post_install(
    glib_compile_schemas: true,
    gtk_update_icon_cache: true
)
