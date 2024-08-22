APP_NAME := Demo

CC = g++
LIBS := -lraylib
INCLUDE_DIRS := -Isrc

OUT_DIR := bin
OBJ_DIR := $(OUT_DIR)/obj

WARN_FLAGS := -pedantic -Wall -Wextra -Wcast-align -Wcast-qual -Wctor-dtor-privacy -Wdisabled-optimization -Wformat=2 -Winit-self -Wlogical-op -Wmissing-declarations -Wmissing-include-dirs -Wnoexcept -Wold-style-cast -Woverloaded-virtual -Wredundant-decls -Wshadow -Wsign-conversion -Wsign-promo -Wstrict-null-sentinel -Wstrict-overflow=5 -Wswitch-default -Wundef -Werror -Wno-unused
CPP_FLAGS := -xc++ -std=c++20 $(INCLUDE_DIRS) $(LIBS)

DIRS := $(shell find src -type d | sed 's/src/./g')

SRCS := $(shell find src/game -name '*.cpp')
OBJS := $(patsubst src/game/%.cpp,$(OBJ_DIR)/%.o,$(SRCS))

$(shell mkdir -p $(OBJ_DIR))

all: build

buildrepo:
	mkdir -p $(OUT_DIR)
	for dir in $(DIRS); do mkdir -p $(OBJ_DIR)/$$dir; done

$(OBJ_DIR)/%.o: $(SRCS)
	$(CC) -c $< -o $@

build: buildrepo $(OBJS)
	$(CC) src/platforms/desktop/main.cpp $(OBJS) $(CPP_FLAGS) -o $(OUT_DIR)/$(APP_NAME)

run: build
	./$(OUT_DIR)/$(APP_NAME)

__dev_dl: filename = $(OUT_DIR)/$(APP_NAME).$(shell date +%s).so
__dev_dl: filename_tmp = $(filename).tmp
__dev_dl: buildrepo $(OBJS)
	$(CC) $(OBJS) -shared ${CPP_FLAGS} -o $(filename_tmp)
	mv $(filename_tmp) $(filename)

__dev_game:
	$(CC) src/platforms/dev/main.cpp ${CPP_FLAGS} -o $(OUT_DIR)/$(APP_NAME)
	./$(OUT_DIR)/$(APP_NAME)

dev:
	bb ./scripts/dev.clj
