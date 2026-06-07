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

vala_sources = files(
  'Model/CaseListItemModel.vala',
  'Util/Convert.vala',
  'Util/SettingsMigration.vala',
  'View/MainView.vala',
  'Widget/DropDownButtonContent.vala',
  'Widget/DropDownRow.vala',
  'Widget/TextArea.vala',
  'Widget/Toolbar.vala',
  'Application.vala',
  'Define.vala',
  'MainWindow.vala',
  'Util.vala',
)

includes = [
  include_directories('.'),
]

sources = files(
  'main.c',
  'kc-application.c',
  'kc-convert.c',
  'kc-util.c',
)

sources += gnome.mkenums_simple('kc-enums',
  sources: 'kc-types.h',
)

subdir('model')

executable(
  app_id,
  asresources,
  config_file,
  #vala_sources,
  sources,
  dependencies: dependencies,
  include_directories: includes,
  install: true,
)
