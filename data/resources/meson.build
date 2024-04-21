blueprints = custom_target('blueprints',
    input: files(
        'ui/combo-entry.blp',
        'ui/main-window.blp',
    ),
    output: '.',
    command: [
        find_program('blueprint-compiler'),
        'batch-compile',
        '@OUTPUT@',
        '@CURRENT_SOURCE_DIR@',
        '@INPUT@'
    ]
)

asresources = gnome.compile_resources(
    'as-resources',
    'konbucase.gresource.xml',
    dependencies: blueprints,
    c_name: 'as'
)
