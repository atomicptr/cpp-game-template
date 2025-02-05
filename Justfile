run: build
    ./build/cpp-game-template

build:
    cmake -B build
    cmake --build build -j8

dev:
    bb scripts/dev.clj

__dev_run: __dev_build
    ./build/cpp-game-template

__dev_build:
    cmake -DHOTRELOAD=ON -B build
    cmake --build build -j8

web: __web_build
    bb scripts/web.clj

__web_build:
    #!/usr/bin/env bash
    export EMROOT="$(dirname $(dirname $(which emcc)))/share/emscripten"
    cp -r $EMROOT/cache build/web/.emcache
    export EM_CACHE=$(pwd)/build/web/.emcache
    chmod u+rwX -R $EM_CACHE

    cmake -DPLATFORM=Web -DCMAKE_TOOLCHAIN_FILE=$EMROOT/cmake/Modules/Platform/Emscripten.cmake -B build/web
    cmake --build build/web -j8

xbuild-linux:
    cmake -DCMAKE_BUILD_TYPE=Release -B build/xbuild/linux
    cmake --build build/xbuild/linux -j8

xbuild-windows:
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/xbuild-windows.cmake -B build/xbuild/windows
    cmake --build build/xbuild/windows -j8

xbuild-web:
    #!/usr/bin/env bash
    export EMROOT="$(dirname $(dirname $(which emcc)))/share/emscripten"
    cp -r $EMROOT/cache build/web/.emcache
    export EM_CACHE=$(pwd)/build/web/.emcache
    chmod u+rwX -R $EM_CACHE

    cmake -DCMAKE_BUILD_TYPE=Release -DPLATFORM=Web -DCMAKE_TOOLCHAIN_FILE=$EMROOT/cmake/Modules/Platform/Emscripten.cmake -B build/xbuild/web
    cmake --build build/xbuild/web -j8
