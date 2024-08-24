# C++ Game Template

A simple C++ game template using Raylib for making games on Linux

## Features

- Code hot reloading
- Web export (emscripten)
- Windows builds

## Requirements

- Nix package manager (optional, but provides everything below)
- [babashka](https://babashka.org/) - Used for some scripts (required for hot reload)
- Make
- Zig compiler (used for cross compiling)
- Emscripten (used for web export)

## How to use

### Just run

Just

```bash
$ make run
```

### Hot reloading

This will launch a babashka script that checks for changes in src/game and builds a dynamic library which the executable will load and replace some function pointers

```bash
$ make dev
```

### Web

This will start a web server usually at port 8080 (look into the terminal) and compile the game. This will also auto rebuild on changes although you need to reload the website (disable cache, do Ctrl + F5)

```bash
$ make web
````

### Building releases

All release commands start with **xbuild-...** and the builds can be found in **bin/release/x-...**

#### Linux

```bash
$ make xbuild-linux
```

#### Windows

```bash
$ make xbuild-windows
```

#### Web

```bash
$ make xbuild-web
```

## License

BSD 0-Clause
