APP_NAME := Demo

OUT_DIR := bin
LIBS := -lraylib
INCLUDE_DIRS := -Isrc
WARN_FLAGS := -pedantic -Wall -Wextra -Wcast-align -Wcast-qual -Wctor-dtor-privacy -Wdisabled-optimization -Wformat=2 -Winit-self -Wlogical-op -Wmissing-declarations -Wmissing-include-dirs -Wnoexcept -Wold-style-cast -Woverloaded-virtual -Wredundant-decls -Wshadow -Wsign-conversion -Wsign-promo -Wstrict-null-sentinel -Wstrict-overflow=5 -Wswitch-default -Wundef -Werror -Wno-unused
CPP_FLAGS := -xc++ -std=c++20 $(INCLUDE_DIRS) $(LIBS)

build:
	g++ src/platforms/desktop/main.cpp src/game/game.cpp $(CPP_FLAGS) -o $(OUT_DIR)/$(APP_NAME)

run: build
	./$(OUT_DIR)/$(APP_NAME)

__dev_dl: filename = $(OUT_DIR)/$(APP_NAME).$(shell date +%s).so
__dev_dl: filename_tmp = $(filename).tmp
__dev_dl:
	g++ src/game/game.cpp -shared ${CPP_FLAGS} -o $(filename_tmp)
	mv $(filename_tmp) $(filename)

__dev_game:
	g++ src/platforms/dev/main.cpp ${CPP_FLAGS} -o $(OUT_DIR)/$(APP_NAME)
	./$(OUT_DIR)/$(APP_NAME)

dev:
	bb ./scripts/dev.clj
