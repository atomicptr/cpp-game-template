#pragma once

#include <raylib.h>

namespace game {
    struct State {
        Vector2 pos;
    };

    extern "C" void window_init();
    extern "C" void window_destroy();
    extern "C" State* init();
    extern "C" void destroy(State* game_state);
    extern "C" bool tick(State* game_state);
    extern "C" int memory_size();
    extern "C" void on_hot_reload(State* game_state);

    void update(State* game_state, float dt);
    void draw(State* game_state);
};
