cmake_minimum_required(VERSION 3.30)

project(cpp-game-template)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED True)

### setup dependencies
include(FetchContent)

###### raylib
set(RAYLIB_VERSION 5.5)
FetchContent_Declare(
  raylib
  URL "https://github.com/raysan5/raylib/archive/refs/tags/${RAYLIB_VERSION}.tar.gz"
  FIND_PACKAGE_ARGS ${RAYLIB_VERSION} EXACT
)
set(BUILD_EXAMPLES OFF CACHE INTERNAL "")
FetchContent_MakeAvailable(raylib)

###### vendor dir
include_directories("vendor")

### setup project
include_directories("src/game")

file(GLOB_RECURSE SRC_FILES "src/game/*.cpp")

add_executable(${PROJECT_NAME} src/platforms/desktop/main.cpp ${SRC_FILES})
target_link_libraries(${PROJECT_NAME} raylib)

target_compile_options(
  ${PROJECT_NAME} PRIVATE
  -Wall
  -Wextra
  -pedantic
  -Wno-unused-parameter
  -Werror
  -Weffc++
  -Wshadow
  -Wunused-local-typedefs
  -Wmisleading-indentation
  -Wdouble-promotion
  -Wnull-dereference
  -Wzero-as-null-pointer-constant
  -Wnon-virtual-dtor
  -Woverloaded-virtual
  -Werror
)
