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
