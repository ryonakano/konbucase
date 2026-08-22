config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_data.set_quoted('APP_NAME', app_name)
config_data.set_quoted('APP_ID', app_id)
config_data.set_quoted('APP_VERSION', app_version)
config_data.set_quoted('RESOURCE_PREFIX', '/' + meson.project_name().replace('.', '/'))
config_file = configure_file(
  output: 'config.h',
  configuration: config_data,
)

includes = [
  include_directories('.'),
]

sources = files(
  'main.c',
  'kc-application.c',
  'kc-main-window.c',
  'kc-util.c',
)

sources += gnome.mkenums_simple('kc-enums',
  sources: 'kc-types.h',
)

subdir('model')
subdir('util')
subdir('view')
subdir('widget')

blueprints = custom_target('blueprints',
  input: files(
    'help-overlay.blp',
  ),
  output: '.',
  command: [
    find_program('blueprint-compiler'),
    'batch-compile',
    '@OUTPUT@',
    '@CURRENT_SOURCE_DIR@',
    '@INPUT@',
  ],
)

gresource_conf = configuration_data()
gresource_conf.set('APP_ID', app_id)
gresource_file_in = configure_file(
  input: 'konbucase.gresource.xml.in',
  output: '@0@.gresource.xml'.format(app_id),
  configuration: gresource_conf,
)

asresources = gnome.compile_resources(
  'as-resources',
  gresource_file_in,
  dependencies: [
    appstream_file,
    blueprints,
  ],
  source_dir: 'data',
  c_name: 'as',
)

executable(
  app_id,
  asresources,
  config_file,
  sources,
  dependencies: dependencies,
  include_directories: includes,
  install: true,
)
