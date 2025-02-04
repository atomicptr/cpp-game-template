run: build
    ./build/cpp-game-template

build:
    cmake -B build
    cmake --build build
