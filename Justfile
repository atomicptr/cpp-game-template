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

xbuild-linux:
    cmake -DCMAKE_BUILD_TYPE=Release -B build/xbuild/linux
    cmake --build build/xbuild/linux -j8

xbuild-windows:
    cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_TOOLCHAIN_FILE=cmake/xbuild-windows.cmake -B build/xbuild/windows
    cmake --build build/xbuild/windows -j8
