project('com.github.ryonakano.case-converter',
    'vala', 'c',
    version: '0.1.0'
)

executable(
    meson.project_name(),
    'src/Application.vala',
    'src/MainWindow.vala',
    dependencies: [
        dependency('granite', version: '>=5.2.3'),
        dependency('gtk+-3.0'),
    ],
    install: true
)
