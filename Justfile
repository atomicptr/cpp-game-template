run: build
    ./build/desktop/demo

build *FLAGS:
    #!/usr/bin/env bash
    if [[ ! -d build/desktop || '{{FLAGS}}' == *'--setup'* ]]; then
        meson setup build/desktop --reconfigure 
    fi
    meson compile -C build/desktop

dev *FLAGS:
    meson setup build/dev -Dhotreload=true --reconfigure
    meson compile -C build/dev
    bb ./scripts/dev.clj

__dev_rebuild:
    meson setup build/dev -Dhotreload=true --reconfigure
    meson compile -C build/dev

web *FLAGS:
    #!/usr/bin/env bash
    if [[ ! -d build/web  || '{{FLAGS}}' == *'--setup'* ]]; then
        meson setup --cross-file cross/web.ini build/web --reconfigure
    fi
    meson compile -C build/web
