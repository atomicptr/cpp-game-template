cmake_minimum_required(VERSION 3.30)

project(cpp-game-template)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUILD_TYPE Debug)
endif()

set(CMAKE_CXX_STANDARD 26)
set(CMAKE_CXX_STANDARD_REQUIRED True)
set(CPP_WARN_FLAGS
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

option(HOTRELOAD "Enable hot-reload build" OFF)

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

if (HOTRELOAD)
  set(BUILD_SHARED_LIBS ON INTERNAL)
endif()

FetchContent_MakeAvailable(raylib)

###### vendor dir
include_directories("vendor")

### setup project
include_directories("src/game")

file(GLOB_RECURSE SRC_FILES "src/game/*.cpp")

if (NOT HOTRELOAD)
  if (NOT EMSCRIPTEN)
    add_executable(${PROJECT_NAME} src/platforms/desktop/main.cpp ${SRC_FILES})
    target_link_libraries(${PROJECT_NAME} PRIVATE raylib -static-libgcc -static-libstdc++)
    target_compile_options(${PROJECT_NAME} PRIVATE ${CPP_WARN_FLAGS})
  else()
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    add_executable(${PROJECT_NAME} src/platforms/web/main.cpp ${SRC_FILES})
    set_target_properties(${PROJECT_NAME} PROPERTIES OUTPUT_NAME "index")
    target_link_libraries(${PROJECT_NAME} PRIVATE raylib)
    target_compile_options(${PROJECT_NAME} PRIVATE ${CPP_WARN_FLAGS})
    target_link_options(
      ${PROJECT_NAME} PRIVATE
        -sUSE_GLFW=3
        -sASYNCIFY
        -sGL_ENABLE_GET_PROC_ADDRESS
        -sSTACK_SIZE=1048576
        -sTOTAL_MEMORY=67108864
        -sERROR_ON_UNDEFINED_SYMBOLS=0
        --shell-file ${CMAKE_CURRENT_SOURCE_DIR}/src/platforms/web/shell.html
    )
  endif()
else()
  add_library(${PROJECT_NAME}-lib SHARED ${SRC_FILES})
  set_target_properties(${PROJECT_NAME}-lib PROPERTIES PREFIX "" SUFFIX ".so.tmp")
  target_link_libraries(${PROJECT_NAME}-lib raylib)
  target_compile_options(${PROJECT_NAME}-lib PRIVATE ${CPP_WARN_FLAGS})

  # after build rename file from "project-name-lib.so.tmp" to "project-name.TIMESTAMP.so"
  execute_process(COMMAND date +%s OUTPUT_VARIABLE TIMESTAMP OUTPUT_STRIP_TRAILING_WHITESPACE)
  add_custom_command(TARGET ${PROJECT_NAME}-lib POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E rename
      $<TARGET_FILE:${PROJECT_NAME}-lib>
      $<TARGET_FILE_DIR:${PROJECT_NAME}-lib>/$<TARGET_FILE_BASE_NAME:${PROJECT_NAME}>.${TIMESTAMP}.so
  )

  add_executable(${PROJECT_NAME} src/platforms/dev/main.cpp)
  target_link_libraries(${PROJECT_NAME} raylib)
endif()
