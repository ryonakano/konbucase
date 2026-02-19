valadoc = find_program('valadoc')

valadoc_output_dir = 'valadoc'
valadoc_target = custom_target(
  'valadoc',
  command: [
    valadoc,
    '--pkg=chcase',
    '--pkg=glib-2.0',
    '--pkg=gtk4',
    '--pkg=gtksourceview-5',
    '--pkg=libadwaita-1',
    sources,
    config_file,
    '--package-name=' + meson.project_name(),
    '--package-version=' + meson.project_version(),
    '--verbose',
    '--force',
    '--use-svg-images',
    '-o', valadoc_output_dir,
  ],

  build_by_default: true,
  output: valadoc_output_dir,
)
