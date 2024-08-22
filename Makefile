APP_NAME := Demo

CC = g++
INCLUDE_DIRS := -Isrc

XBUILD_RAYLIB_VERSION := 5.0

OUT_DIR := bin
OBJ_DIR := $(OUT_DIR)/obj

WARN_FLAGS := -pedantic -Wall -Wextra -Wno-unused-parameter -Werror
CPP_FLAGS := -std=c++20 $(INCLUDE_DIRS)
CPP_FLAGS_RELEASE := $(CPP_FLAGS) -O3

DIRS := $(shell find src -type d | sed 's/src/./g')

SRCS := $(shell find src/game -name '*.cpp')
OBJS := $(patsubst src/game/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

all: build

buildrepo:
	mkdir -p $(OUT_DIR)
	for dir in $(DIRS); do mkdir -p $(OBJ_DIR)/$$dir; done

$(OBJ_DIR)/%.o: $(SRCS)
	$(CC) -c $< -o $@ $(CPP_FLAGS)

build: buildrepo $(OBJS)
	mkdir -p $(OUT_DIR)/target/desktop
	$(CC) src/platforms/desktop/main.cpp $(OBJS) -lraylib $(CPP_FLAGS) -o $(OUT_DIR)/target/desktop/$(APP_NAME)

run: build
	./$(OUT_DIR)/target/desktop/$(APP_NAME)

__dev_dl: filename = $(OUT_DIR)/target/dev/$(APP_NAME).$(shell date +%s).so
__dev_dl: filename_tmp = $(filename).tmp
__dev_dl: buildrepo $(OBJS)
	mkdir -p $(OUT_DIR)/target/dev
	$(CC) $(OBJS) -shared $(CPP_FLAGS) -lraylib -o $(filename_tmp)
	mv $(filename_tmp) $(filename)

__dev_game:
	mkdir -p $(OUT_DIR)/target/dev
	$(CC) src/platforms/dev/main.cpp ${CPP_FLAGS} -o $(OUT_DIR)/target/dev/$(APP_NAME)
	./$(OUT_DIR)/target/dev/$(APP_NAME)

dev:
	bb ./scripts/dev.clj

build-web: $(OUT_DIR)/deps/raylib/build-web/libraylib.a buildrepo
	mkdir -p $(OUT_DIR)/target/web
	emcc -o $(OUT_DIR)/target/web/index.html src/platforms/web/main.cpp $(SRCS) $(CPP_FLAGS) $(OUT_DIR)/deps/raylib/build-web/libraylib.a $(CPP_FLAGS) -I$(OUT_DIR)/deps/raylib/src -sUSE_GLFW=3 -sASYNCIFY -sGL_ENABLE_GET_PROC_ADDRESS -DWEB_BUILD -sSTACK_SIZE=1048576 -sTOTAL_MEMORY=67108864 -sERROR_ON_UNDEFINED_SYMBOLS=0 --shell-file src/platforms/web/shell.html

web: build-web
	bb ./scripts/web.clj

$(OUT_DIR)/deps/raylib:
	mkdir -p $(OUT_DIR)/deps
	cd $(OUT_DIR)/deps && git clone --depth 1 --branch 5.0 git@github.com:raysan5/raylib.git

$(OUT_DIR)/deps/raylib/build-web/libraylib.a: $(OUT_DIR)/deps/raylib
	mkdir -p $(OUT_DIR)/deps/raylib/build-web

	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rcore.c -o ../build-web/rcore.o -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rshapes.c -o ../build-web/rshapes.o -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rtextures.c -o ../build-web/rtextures.o -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rtext.c -o ../build-web/rtext.o -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c rmodels.c -o ../build-web/rmodels.o -Os -Wall -DPLATFORM_WEB -DGRAPHICS_API_OPENGL_ES2
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c utils.c -o ../build-web/utils.o -Os -Wall -DPLATFORM_WEB
	cd ./$(OUT_DIR)/deps/raylib/src && emcc -c raudio.c -o ../build-web/raudio.o -Os -Wall -DPLATFORM_WEB

	cd ./$(OUT_DIR)/deps/raylib/build-web && emar rcs libraylib.a rcore.o rshapes.o rtextures.o rtext.o rmodels.o utils.o raudio.o

clean:
	rm -rf $(OUT_DIR)/*

### Release Builds / Cross Compilation

###### Linux
xbuild-linux: buildrepo $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64
	rm -rf $(OUT_DIR)/target/x-linux
	mkdir -p $(OUT_DIR)/target/x-linux
	zig c++ src/platforms/desktop/main.cpp $(SRCS) $(CPP_FLAGS_RELEASE) $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64/lib/libraylib.a -o $(OUT_DIR)/target/x-linux/$(APP_NAME) -target x86_64-linux-gnu -I$(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64/include

$(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64:
	cd $(OUT_DIR)/deps && wget https://github.com/raysan5/raylib/releases/download/$(XBUILD_RAYLIB_VERSION)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz
	tar xvf $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz -C $(OUT_DIR)/deps
	rm $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz

###### Windows
xbuild-windows: buildrepo $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64
	rm -rf $(OUT_DIR)/target/x-windows
	mkdir -p $(OUT_DIR)/target/x-windows
	zig c++ src/platforms/desktop/main.cpp $(SRCS) $(CPP_FLAGS_RELEASE) -o $(OUT_DIR)/target/x-windows/$(APP_NAME).exe -target x86_64-windows -L$(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/lib -I$(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/include -lraylibdll
	cp $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/lib/raylib.dll $(OUT_DIR)/target/x-windows

$(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64:
	cd $(OUT_DIR)/deps && wget https://github.com/raysan5/raylib/releases/download/$(XBUILD_RAYLIB_VERSION)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64.zip
	unzip $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64 -d $(OUT_DIR)/deps
	rm $(OUT_DIR)/deps/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64.zip 
