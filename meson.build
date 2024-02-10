  project('com.github.phase1geo.actioneer', ['vala', 'c'],
    version : '1.0.0',
    license: 'GPL-3.0'
)

add_project_arguments([
        '-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name())
    ],
    language: 'c',
)

gnome = import('gnome')
i18n = import('i18n')

gresource = gnome.compile_resources(
    'actioneer-resources', 'data/' + meson.project_name() + '.gresource.xml',
    source_dir: 'data',
)

add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src/Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

sources = files()

subdir('data')
subdir('po')
subdir('src')
subdir('tests')

# If the valac version is greater than or equal to 0.48, add a define for cross-compile purposes
if meson.get_compiler('vala').version().version_compare('>=0.48.0')
  add_project_arguments(['--define=VALAC048'], language: 'vala')
  message('Using VALAC048')
endif

add_project_arguments([
        '--vapidir', join_paths(meson.current_source_dir(), 'vapi'),
        '--disable-warnings'
    ],
    language: 'vala',
)

dependencies = [
    dependency('gobject-2.0'),
    dependency('glib-2.0'),
    dependency('gee-0.8'),
    dependency('gtk4'),
    dependency('granite-7'),
    dependency('libxml-2.0'),
    dependency('libsecret-1')
]

e = executable('com.github.phase1geo.actioneer',
    sources,
    config_file,
    gresource,
    dependencies: dependencies,
    vala_args: [],
    install : true
)

#test('tests', e, args : ['--run-tests'])

meson.add_install_script('meson/post_install.py')
