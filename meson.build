project(
  'demo',
  'cpp',
  'c',
  default_options: [
    'warning_level=everything',
    'default_library=static',
    'prefer_static=true',
    'optimization=0',
    'buildtype=debug',
    'debug=true',
    'cpp_std=c++26',
  ],
)

cc = meson.get_compiler('c')
cxx = meson.get_compiler('cpp')

link_args = []
name_suffix = []
dependencies = []

###### raylib configuration
cmake = import('cmake')
raylib_opts = cmake.subproject_options()
raylib_opts.set_install(false)
raylib_opts.add_cmake_defines({'BUILD_EXAMPLES': 'Off'})

if cc.get_id() == 'emscripten'
  raylib_opts.add_cmake_defines({'PLATFORM': 'Web'})
else
  raylib_opts.add_cmake_defines({'PLATFORM': 'Desktop'})
endif

if get_option('hotreload')
  raylib_opts.add_cmake_defines({'RAYLIB_LIBTYPE': 'SHARED', 'CMAKE_POSITION_INDEPENDENT_CODE': true})
endif

raylib = cmake.subproject('raylib', options: raylib_opts)
dependencies += raylib.dependency('raylib')

if host_machine.system() == 'linux'
  dependencies += [
    cc.find_library('m'),
    cc.find_library('dl'),
    raylib.dependency('glfw'),
  ]
elif host_machine.system() == 'emscripten'
  link_args += [
    '-s', 'ENVIRONMENT=web',
    '-s', 'USE_GLFW=3',
    '-s', 'ASYNCIFY',
    '-s', 'GL_ENABLE_GET_PROC_ADDRESS',
    '-s', 'STACK_SIZE=1048576',
    '-s', 'TOTAL_MEMORY=67108864',
    '-s', 'ERROR_ON_UNDEFINED_SYMBOLS=0',
    '--shell-file', 'src/platforms/web/shell.html',
  ]
  name_suffix = 'html'
endif

vendor_dir = include_directories('vendor')

game_files_glob = run_command('sh', '-c', 'find src/game -name "**.cpp" | sort', check: true)
game_files = game_files_glob.stdout().strip().split('\n')

# desktop

if not get_option('hotreload')
  executable(
    'demo',
    game_files + ['src/platforms/desktop/main.cpp'],
    include_directories: vendor_dir,
    dependencies: dependencies,
    link_args: link_args,
    name_suffix: name_suffix,
  )
else
  timestamp = run_command('date', '+%s').stdout().strip()
  shared_library(
    'demo_dev',
    game_files,
    name_prefix: '',
    name_suffix: timestamp + '.so',
    include_directories: vendor_dir,
    dependencies: dependencies,
    link_args: link_args,
  )
  executable(
    'demo_dev',
    'src/platforms/dev/main.cpp',
    include_directories: vendor_dir,
    dependencies: dependencies,
    link_args: link_args,
  )
endif
