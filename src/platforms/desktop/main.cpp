#include "../../game/game.hpp"

int main(void) {
    game::window_init();
    auto state = game::init();

    bool running = true;

    while (running) {
        running = game::tick(state);
    }

    game::destroy(state);
    game::window_destroy();
}
