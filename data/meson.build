icon_sizes = ['16', '24', '32', '48', '64', '128']

# TODO: Prepare development icons?
foreach i : icon_sizes
    install_data(
        'icons' / i / meson.project_name() + '.svg',
        rename: app_id + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps'
    )
endforeach

desktop_conf = configuration_data()
desktop_conf.set('APP_NAME', app_name)
desktop_conf.set('APP_ID', app_id)
desktop_file_in = configure_file(
    input: 'konbucase.desktop.in.in',
    output: '@0@.desktop.in'.format(app_id),
    configuration: desktop_conf
)

i18n.merge_file(
    input: desktop_file_in,
    output: '@0@.desktop'.format(app_id),
    po_dir: meson.project_source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

metainfo_conf = configuration_data()
metainfo_conf.set('APP_NAME', app_name)
metainfo_conf.set('APP_ID', app_id)
metainfo_conf.set('GETTEXT_PACKAGE', meson.project_name())
metainfo_file_in = configure_file(
    input: 'konbucase.metainfo.xml.in.in',
    output: '@0@.metainfo.xml.in'.format(app_id),
    configuration: metainfo_conf
)

i18n.merge_file(
    input: metainfo_file_in,
    output: '@0@.metainfo.xml'.format(app_id),
    po_dir: meson.project_source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)

gschema_conf = configuration_data()
gschema_conf.set('APP_ID', app_id)
gschema_file_in = configure_file(
    input: 'konbucase.gschema.xml.in',
    output: '@0@.gschema.xml'.format(app_id),
    configuration: gschema_conf
)

install_data(
    gschema_file_in,
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
)

subdir('resources')
