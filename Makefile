APP_NAME := Demo

CC = zig c++
INCLUDE_DIRS := -Isrc

XBUILD_RAYLIB_VERSION := 5.0

OUT_DIR := bin
OBJ_DIR := $(OUT_DIR)/obj
DEPS_DIR := $(OUT_DIR)/deps
BUILD_RAYLIB_BASE := $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64

DESKTOP_DIR := $(OUT_DIR)/debug/desktop
DEV_DIR := $(OUT_DIR)/debug/dev
WEB_DIR := $(OUT_DIR)/debug/web
XBUILD_DIR := $(OUT_DIR)/release

WARN_FLAGS := -pedantic -Wall -Wextra -Wno-unused-parameter -Werror
CPP_FLAGS := -std=c++26 $(INCLUDE_DIRS)
CPP_FLAGS_RELEASE := $(CPP_FLAGS) -O3

WEB_FLAGS := -sUSE_GLFW=3 -sASYNCIFY -sGL_ENABLE_GET_PROC_ADDRESS -sSTACK_SIZE=1048576 -sTOTAL_MEMORY=67108864 -sERROR_ON_UNDEFINED_SYMBOLS=0 --shell-file src/platforms/web/shell.html

DIRS := $(shell find src -type d | sed 's/src/./g')

SRCS := $(shell find src/game -name '*.cpp')
OBJS := $(patsubst src/game/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

all: build

buildrepo:
	mkdir -p $(OUT_DIR)
	for dir in $(DIRS); do mkdir -p $(OBJ_DIR)/$$dir; done

$(OBJ_DIR)/%.o: $(SRCS)
	$(CC) -c $< -o $@ $(CPP_FLAGS)

build: buildrepo $(OBJS) $(BUILD_RAYLIB_BASE)
	mkdir -p $(DESKTOP_DIR)
	$(CC) src/platforms/desktop/main.cpp $(OBJS) $(CPP_FLAGS) -o $(DESKTOP_DIR)/$(APP_NAME) -L$(BUILD_RAYLIB_BASE)/lib -I$(BUILD_RAYLIB_BASE)/include -lraylib

run: build
	./$(DESKTOP_DIR)/$(APP_NAME)

__dev_dl: filename = $(DEV_DIR)/$(APP_NAME).$(shell date +%s).so
__dev_dl: filename_tmp = $(filename).tmp
__dev_dl: buildrepo $(OBJS) $(BUILD_RAYLIB_BASE)
	mkdir -p $(DEV_DIR)
	$(CC) $(OBJS) -shared $(CPP_FLAGS) -o $(filename_tmp) -L$(BUILD_RAYLIB_BASE)/lib -I$(BUILD_RAYLIB_BASE)/include -lraylib
	mv $(filename_tmp) $(filename)

__dev_game:
	mkdir -p $(DEV_DIR)
	$(CC) src/platforms/dev/main.cpp ${CPP_FLAGS} -o $(DEV_DIR)/$(APP_NAME)
	./$(DEV_DIR)/$(APP_NAME)

dev:
	bb ./scripts/dev.clj

build-web: buildrepo $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly
	mkdir -p $(WEB_DIR)
	emcc -o $(WEB_DIR)/index.html src/platforms/web/main.cpp $(SRCS) $(CPP_FLAGS) $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly/lib/libraylib.a -I$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly/include $(WEB_FLAGS)

web: build-web
	bb ./scripts/web.clj

clean:
	rm -rf $(OUT_DIR)/*

### Release Builds / Cross Compilation

###### Linux
xbuild-linux: buildrepo $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64
	rm -rf $(XBUILD_DIR)/x-linux
	mkdir -p $(XBUILD_DIR)/x-linux
	zig c++ src/platforms/desktop/main.cpp $(SRCS) $(CPP_FLAGS_RELEASE) $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64/lib/libraylib.a -o $(XBUILD_DIR)/x-linux/$(APP_NAME) -target x86_64-linux-gnu -I$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64/include

$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64:
	mkdir -p $(DEPS_DIR)
	cd $(DEPS_DIR) && wget https://github.com/raysan5/raylib/releases/download/$(XBUILD_RAYLIB_VERSION)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz
	tar xvf $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz -C $(DEPS_DIR)
	rm $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_linux_amd64.tar.gz

###### Windows
xbuild-windows: buildrepo $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64
	rm -rf $(XBUILD_DIR)/x-windows
	mkdir -p $(XBUILD_DIR)/x-windows
	zig c++ src/platforms/desktop/main.cpp $(SRCS) $(CPP_FLAGS_RELEASE) -o $(XBUILD_DIR)/x-windows/$(APP_NAME).exe -target x86_64-windows -L$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/lib -I$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/include -lraylibdll
	cp $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64/lib/raylib.dll $(XBUILD_DIR)/x-windows

$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64:
	mkdir -p $(DEPS_DIR)
	cd $(DEPS_DIR) && wget https://github.com/raysan5/raylib/releases/download/$(XBUILD_RAYLIB_VERSION)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64.zip
	unzip $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64 -d $(DEPS_DIR)
	rm $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_win64_mingw-w64.zip 

###### Web
xbuild-web: buildrepo $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly
	rm -rf $(XBUILD_DIR)/x-web
	mkdir -p $(XBUILD_DIR)/x-web
	emcc -o $(XBUILD_DIR)/x-web/index.html src/platforms/web/main.cpp $(SRCS) $(CPP_FLAGS) $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly/lib/libraylib.a -I$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly/include $(WEB_FLAGS)

$(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly:
	mkdir -p $(DEPS_DIR)
	cd $(DEPS_DIR) && wget https://github.com/raysan5/raylib/releases/download/$(XBUILD_RAYLIB_VERSION)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly.zip
	unzip $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly -d $(DEPS_DIR)
	rm $(DEPS_DIR)/raylib-$(XBUILD_RAYLIB_VERSION)_webassembly.zip 

