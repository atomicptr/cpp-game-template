run: build
    ./build/cpp-game-template

build:
    cmake -B build
    cmake --build build

dev:
    bb scripts/dev.clj

__dev_run: __dev_build
    ./build/cpp-game-template

__dev_build:
    cmake -DHOTRELOAD=ON -B build
    cmake --build build

xbuild-linux:
    cmake -DXBUILD_RELEASE=ON -B build/xbuild/linux
    cmake --build build/xbuild/linux

xbuild-windows:
    cmake -DCMAKE_TOOLCHAIN_FILE=cross/windows.cmake -B build/xbuild/windows
    cmake --build build/xbuild/windows
