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

executable(
  app_id,
  asresources,
  config_file,
  sources,
  dependencies: dependencies,
  include_directories: includes,
  install: true,
)
