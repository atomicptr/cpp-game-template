project(
  'demo',
  'cpp',
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

vendor_dir = include_directories('vendor')

game_files_glob = run_command('sh', '-c', 'find src/game -name "**.cpp" | sort', check: true)
game_files = game_files_glob.stdout().strip().split('\n')

# desktop
executable(
  'demo',
  game_files + ['src/platforms/desktop/main.cpp'],
  include_directories: vendor_dir,
  dependencies: [
    dependency('raylib')
  ],
)

# dev
timestamp = run_command('date', '+%s').stdout().strip()
shared_library(
  'demo_dev',
  game_files,
  name_prefix: '',
  name_suffix: timestamp + '.so',
  include_directories: vendor_dir,
  dependencies: [
    dependency('raylib')
  ],
)

executable(
  'demo_dev',
  'src/platforms/dev/main.cpp',
  include_directories: vendor_dir,
  dependencies: [
    dependency('raylib')
  ],
)
