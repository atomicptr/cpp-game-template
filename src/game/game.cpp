#include "game.hpp"

#include <raylib.h>

void game::window_init() {
    InitWindow(800, 600, "Game");
    SetTargetFPS(60);
}

void game::window_destroy() {
    CloseWindow();
}

game::State* game::init() {
    auto state = new game::State;
    state->pos = (Vector2){100.0, 100.0};
    return state;
}

void game::destroy(game::State* game_state) {
    delete game_state;
}

bool game::tick(game::State* game_state) {
    float dt = GetFrameTime();
    game::update(game_state, dt);
    game::draw(game_state);
    return !WindowShouldClose();
}

void game::update(game::State* game_state, float dt) {
    if (IsKeyDown(KEY_W)) {
        game_state->pos.y -= 200.0 * dt;
    }

    if (IsKeyDown(KEY_S)) {
        game_state->pos.y += 200.0 * dt;
    }

    if (IsKeyDown(KEY_A)) {
        game_state->pos.x -= 200.0 * dt;
    }

    if (IsKeyDown(KEY_D)) {
        game_state->pos.x += 200.0 * dt;
    }
}

void game::draw(game::State* game_state) {
    BeginDrawing();
    ClearBackground(RAYWHITE);

    DrawRectangleRec((Rectangle){game_state->pos.x, game_state->pos.y, 100, 100}, BLUE);

    DrawFPS(10, 10);

    EndDrawing();
}

int game::memory_size() {
    return sizeof(game::State);
}

void game::on_hot_reload(game::State* game_state) {}
