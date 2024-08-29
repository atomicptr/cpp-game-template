#include "../../game/game.hpp"
#include <emscripten/emscripten.h>

game::State* state = nullptr;

void tick() {
    game::tick(state);
}

int main(void) {
    game::window_init();
    state = game::init();

    emscripten_set_main_loop(tick, 0, 1);
}
