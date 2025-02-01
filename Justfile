run: build
    ./build/demo

build:
    meson setup build  --reconfigure
    cd build && meson compile

dev: build
    bb ./scripts/dev.clj
