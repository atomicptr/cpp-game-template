APP_NAME := Demo

CC = g++
INCLUDE_DIRS := -Isrc

OUT_DIR := bin
OBJ_DIR := $(OUT_DIR)/obj

WARN_FLAGS := -pedantic -Wall -Wextra -Wno-unused-parameter -Werror
CPP_FLAGS := -std=c++20 $(INCLUDE_DIRS) $(WARN_FLAGS)
CPP_FLAGS_DESKTOP = $(CPP_FLAGS) -lraylib
CPP_FLAGS_WEB := $(CPP_FLAGS)

DIRS := $(shell find src -type d | sed 's/src/./g')

SRCS := $(shell find src/game -name '*.cpp')
OBJS := $(patsubst src/game/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

all: build

buildrepo:
	mkdir -p $(OUT_DIR)
	for dir in $(DIRS); do mkdir -p $(OBJ_DIR)/$$dir; done

$(OBJ_DIR)/%.o: $(SRCS)
	$(CC) -c $< -o $@ $(CPP_FLAGS_DESKTOP)

build: buildrepo $(OBJS)
	mkdir -p $(OUT_DIR)/target/desktop
	$(CC) src/platforms/desktop/main.cpp $(OBJS) $(CPP_FLAGS_DESKTOP) -o $(OUT_DIR)/target/desktop/$(APP_NAME)

run: build
	./$(OUT_DIR)/target/desktop/$(APP_NAME)

__dev_dl: filename = $(OUT_DIR)/target/dev/$(APP_NAME).$(shell date +%s).so
__dev_dl: filename_tmp = $(filename).tmp
__dev_dl: buildrepo $(OBJS)
	mkdir -p $(OUT_DIR)/target/dev
	$(CC) $(OBJS) -shared ${CPP_FLAGS_DESKTOP} -o $(filename_tmp)
	mv $(filename_tmp) $(filename)

__dev_game:
	mkdir -p $(OUT_DIR)/target/dev
	$(CC) src/platforms/dev/main.cpp ${CPP_FLAGS_DESKTOP} -o $(OUT_DIR)/target/dev/$(APP_NAME)
	./$(OUT_DIR)/target/dev/$(APP_NAME)

dev:
	bb ./scripts/dev.clj

build-web: $(OUT_DIR)/deps/raylib/src/libraylib.a buildrepo
	mkdir -p $(OUT_DIR)/target/web
	emcc -o $(OUT_DIR)/target/web/index.html src/platforms/web/main.cpp $(SRCS) $(CPP_FLAGS) $(OUT_DIR)/deps/raylib/src/libraylib.a $(CPP_FLAGS) -I$(OUT_DIR)/deps/raylib/src -sUSE_GLFW=3 -sASYNCIFY -sGL_ENABLE_GET_PROC_ADDRESS -DWEB_BUILD -sSTACK_SIZE=1048576 -sTOTAL_MEMORY=67108864 -sERROR_ON_UNDEFINED_SYMBOLS=0 --shell-file src/platforms/web/shell.html

web: build-web
	bb ./scripts/web.clj

$(OUT_DIR)/deps/raylib/src/libraylib.a:
	mkdir -p $(OUT_DIR)/deps

	if [ ! -d "$(OUT_DIR)/deps/raylib" ]; then git clone --depth 1 --branch 5.0 git@github.com:raysan5/raylib.git $(OUT_DIR)/deps/raylib; fi

	cd ./$(OUT_DIR)/deps/raylib/src

	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rcore.c -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rshapes.c -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rtextures.c -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rtext.c -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rmodels.c -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c utils.c -Os -Wall -DPLATFORM_WEB
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c raudio.c -Os -Wall -DPLATFORM_WEB

	cd ./$(OUT_DIR)/deps/raylib/src && emar rcs libraylib.a rcore.o rshapes.o rtextures.o rtext.o rmodels.o utils.o raudio.o

clean:
	rm -rf $(OUT_DIR)/*
