# keep this the same as in the CMakeLists.txt file
project_name := "cpp-game-template"

run: build
    ./build/bin/{{project_name}}

build:
    cmake -DCMAKE_BUILD_TYPE=Debug -B build
    cmake --build build -j8 --config Debug

dev:
    bb scripts/dev.clj

__dev_run: __dev_build
    ./build/dev/{{project_name}}

__dev_build:
    cmake -DCMAKE_BUILD_TYPE=Debug -DHOTRELOAD=ON -B build/dev
    cmake --build build/dev -j8 --config Debug

web: __web_build
    bb scripts/web.clj

__web_build:
    #!/usr/bin/env bash
    source ./scripts/setup-emscripten.sh

    cmake -DPLATFORM=Web -DCMAKE_BUILD_TYPE=Debug -DCMAKE_TOOLCHAIN_FILE=$EMROOT/cmake/Modules/Platform/Emscripten.cmake -B build/web
    cmake --build build/web -j8 --config Debug

xbuild-linux:
    cmake -DCMAKE_BUILD_TYPE=Release -B build/xbuild/linux
    cmake --build build/xbuild/linux --config Release -j8

xbuild-windows:
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/xbuild-windows.cmake -B build/xbuild/windows
    cmake --build build/xbuild/windows --config Release -j8

xbuild-web:
    #!/usr/bin/env bash
    source ./scripts/setup-emscripten.sh

    cmake -DCMAKE_BUILD_TYPE=Release -DPLATFORM=Web -DCMAKE_TOOLCHAIN_FILE=$EMROOT/cmake/Modules/Platform/Emscripten.cmake -B build/xbuild/web
    cmake --build build/xbuild/web --config Release -j8

xbuild-github:
    cmake -DCMAKE_BUILD_TYPE=Release -B build/xbuild/github
    cmake --build build/xbuild/github --config Release -j8
