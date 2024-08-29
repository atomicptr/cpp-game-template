#include <cassert>
#include <chrono>
#include <dlfcn.h>
#include <filesystem>
#include <iostream>
#include <optional>
#include <string>
#include <vector>

namespace fs = std::filesystem;

namespace game {
    using State = void;

    using WindowInitProc = void (*)();
    using WindowDestroyProc = void (*)();
    using InitProc = State* (*)();
    using DestroyProc = void (*)(State*);
    using TickProc = bool (*)(State*);
    using MemorySizeProc = int (*)();
    using OnHotReloadProc = void (*)(State*);

    struct API {
        void* handle;
        std::string lib_path;
        std::time_t modtime;
        WindowInitProc window_init;
        WindowDestroyProc window_destroy;
        InitProc init;
        DestroyProc destroy;
        TickProc tick;
        MemorySizeProc memory_size;
        OnHotReloadProc on_hot_reload;
    };
}

std::string exec_path = "";

std::optional<std::string> find_newest_api_filename() {
    assert(exec_path != "");

    auto exec = fs::path(exec_path);
    auto exec_name = exec.stem().string();
    auto dir = exec.parent_path();

    std::string newest = "";
    fs::file_time_type newest_time = fs::file_time_type::min();

    for (auto const& entry : fs::directory_iterator {dir}) {
        auto p = entry.path();

        if (!p.stem().string().starts_with(exec_name)) {
            continue;
        }

        if (p.extension() != ".so") {
            continue;
        }

        if (entry.last_write_time() < newest_time) {
            continue;
        }

        newest_time = entry.last_write_time();
        newest = p.string();
    }

    if (newest == "") {
        return {};
    }

    return newest;
}

std::optional<game::API> load_game_api() {
    auto path_opt = find_newest_api_filename();
    if (!path_opt.has_value()) {
        std::cerr << "ERR: Could not find game api file" << std::endl;
        return {};
    }

    auto path = path_opt.value();

    game::API api;

    api.handle = dlopen(path.c_str(), RTLD_LAZY);
    if (!api.handle) {
        std::cerr << "ERR: Cannot load library: " << dlerror() << std::endl;
        return {};
    }

    dlerror();

#define LOAD_SYM(name)                                                                \
    *(void**)(&api.name) = dlsym(api.handle, #name);                                  \
    if (auto err = dlerror(); err != nullptr) {                                       \
        dlclose(api.handle);                                                          \
        std::cerr << "ERR: Cannot load symbol " << #name << ": " << err << std::endl; \
        return {};                                                                    \
    }

    LOAD_SYM(window_init);
    LOAD_SYM(window_destroy);
    LOAD_SYM(init);
    LOAD_SYM(destroy);
    LOAD_SYM(tick);
    LOAD_SYM(memory_size);
    LOAD_SYM(on_hot_reload);

#undef LOAD_SYM

    api.lib_path = path;
    api.modtime = fs::last_write_time(fs::path(path)).time_since_epoch().count();

    return api;
}

bool has_api_been_modified(game::API& api) {
    auto filename_opt = find_newest_api_filename();
    if (!filename_opt.has_value()) {
        std::cerr << "ERR: Could not determine new API file" << std::endl;
        return false;
    }

    auto filename = filename_opt.value();
    auto last_mod = fs::last_write_time(fs::path(filename)).time_since_epoch().count();

    return last_mod > api.modtime;
}

void unload_api(game::API& api) {
    if (api.handle) {
        if (dlclose(api.handle) != 0) {
            std::cerr << "ERR: Failed to unload library: " << dlerror() << std::endl;
            return;
        }
        api.handle = nullptr;
    }

    auto res = std::remove(api.lib_path.c_str());
    if (res != 0) {
        std::cerr << "ERR: Could not delete file: " << api.lib_path << std::endl;
        return;
    }
}

int main(int argc, char** argv) {
    exec_path = argv[0];

    auto api_opt = load_game_api();
    assert(api_opt.has_value());

    auto api = api_opt.value();

    api.window_init();
    auto state = api.init();

    std::vector<game::API> old_apis;

    bool running = true;

    while (running) {
        if (has_api_been_modified(api)) {
            auto newapi_opt = load_game_api();
            if (!newapi_opt.has_value()) {
                continue;
            }

            auto newapi = newapi_opt.value();

            // save old api
            old_apis.push_back(api);

            if (api.memory_size() != newapi.memory_size()) {
                // something has changed hard reload
                std::cout << "WARN: Game data has changed, doing a hard reload" << std::endl;

                api.destroy(state);

                for (auto& old_api : old_apis) {
                    unload_api(old_api);
                }

                old_apis.clear();

                api = newapi;
                state = api.init();

                continue;
            }

            api = newapi;
            api.on_hot_reload(state);
        }

        running = api.tick(state);
    }

    for (auto& old_api : old_apis) {
        unload_api(old_api);
    }

    api.destroy(state);
    api.window_destroy();

    unload_api(api);

    return 0;
}
