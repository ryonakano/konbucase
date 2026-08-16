doc_module = 'konbucase'

doc_path = get_option('prefix') / gnome.gtkdoc_html_dir(doc_module)

version_conf = configuration_data()
version_conf.set('VERSION', meson.project_version())

configure_file(
  input: 'version.xml.in',
  output: '@BASENAME@',
  configuration: version_conf
)

doc_assets = [
  'images/View/MainView/example_main_view.png',
  'images/Widget/DropDownButtonContent/example_drop_down_button_content.png',
  'images/Widget/DropDownRow/example_drop_down_row.png',
  'images/Widget/TextArea/example_text_area.png',
  'images/Widget/Toolbar/example_toolbar.png',
]

gnome.gtkdoc(
  doc_module,
  html_assets: doc_assets,
  main_xml: doc_module + '-docs.xml',
  src_dir: meson.project_source_root() / 'src',
  dependencies: dependencies,
  install: true,
  install_dir: doc_path,
)
