project(
  'com.github.ryonakano.konbucase',
  'c',
  version: '4.5.1',
  meson_version: '>= 0.58.0',
  default_options: [
    'warning_level=2',
  ],
)

app_name = 'KonbuCase'
app_id = meson.project_name()
app_version = meson.project_version()
if get_option('development')
  app_name += ' (Development)'
  app_id += '.Devel'

  ret = run_command('git', 'rev-parse', '--short', 'HEAD', check: false)
  if ret.returncode() != 0
    version_suffix = '-devel'
  else
    version_suffix = '-@0@'.format(ret.stdout().strip())
  endif

  app_version += version_suffix
endif

gnome = import('gnome')
i18n = import('i18n')
cc = meson.get_compiler('c')

# TODO: Remove when porting to C completed
add_project_arguments(
  '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
  language: 'c',
)

project_c_args = []
c_args = [
  # TODO: Remove
  '-Wpedantic',
  '-Wcast-align',
  '-Wdeclaration-after-statement',
  '-Werror=address',
  '-Werror=array-bounds',
  '-Werror=empty-body',
  '-Werror=implicit',
  '-Werror=implicit-function-declaration',
  '-Werror=incompatible-pointer-types',
  '-Werror=init-self',
  '-Werror=int-conversion',
  '-Werror=int-to-pointer-cast',
  '-Werror=main',
  '-Werror=misleading-indentation',
  '-Werror=missing-braces',
  '-Werror=missing-include-dirs',
  '-Werror=nonnull',
  '-Werror=overflow',
  '-Werror=parentheses',
  '-Werror=pointer-arith',
  '-Werror=pointer-to-int-cast',
  '-Werror=redundant-decls',
  '-Werror=return-type',
  '-Werror=sequence-point',
  '-Werror=shadow',
  '-Werror=strict-prototypes',
  '-Werror=trigraphs',
  '-Werror=undef',
  '-Werror=write-strings',
  '-Wformat-nonliteral',
  '-Wignored-qualifiers',
  '-Wimplicit-function-declaration',
  '-Wlogical-op',
  '-Wmissing-declarations',
  '-Wmissing-format-attribute',
  '-Wmissing-include-dirs',
  '-Wmissing-noreturn',
  '-Wnested-externs',
  '-Wno-cast-function-type',
  '-Wno-dangling-pointer',
  '-Wno-missing-field-initializers',
  '-Wno-sign-compare',
  '-Wno-unused-parameter',
  '-Wold-style-definition',
  '-Wpointer-arith',
  '-Wredundant-decls',
  '-Wstrict-prototypes',
  '-Wswitch-default',
  '-Wswitch-enum',
  '-Wundef',
  '-Wuninitialized',
  '-Wunused',
  '-fno-strict-aliasing',
  ['-Werror=format-security', '-Werror=format=2'],
]
if get_option('buildtype') != 'plain'
  c_args += '-fstack-protector-strong'
endif
foreach arg: c_args
  if cc.has_multi_arguments(arg)
    project_c_args += arg
  endif
endforeach
add_project_arguments(project_c_args, language: 'c')

granite_dep = dependency('granite-7', version: '>= 7.2.0', required: get_option('granite'))
if granite_dep.found()
  add_project_arguments('-DUSE_GRANITE', language: 'c')
endif

dependencies = [
  dependency('chcase', version: '>= 3.0.0', allow_fallback: get_option('use_submodule')),
  dependency('glib-2.0', version: '>= 2.74'),
  granite_dep,
  dependency('gtk4'),
  dependency('gtksourceview-5'),
  dependency('libadwaita-1', version: '>= 1.5'),
]

subdir('data')
subdir('po')
subdir('src')

if get_option('doc')
  subdir('docs')
endif

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
)
