# C++ Game Template

A simple C++ game template using Raylib for making games on Linux

## Features

- Code hot reloading
- Web export (emscripten)
- Windows builds

## Requirements

- Devenv

If not using devenv you need to install these on your own:

- [babashka](https://babashka.org/) - Used for some scripts (required for hot reload)
- CMake (3.30+)
- gcc 14+
- Emscripten (used for web export)

## How to use

### Just run

Just do

```bash
$ just run
```

### Hot reloading

This will launch a babashka script that checks for changes in src/game and builds a dynamic library which the executable will load and replace some function pointers

```bash
$ just dev
```

### Web

This will start a web server usually at port 8080 (look into the terminal) and compile the game. This will also auto rebuild on changes although you need to reload the website (disable cache, do Ctrl + F5)

```bash
$ just web
````

## License

BSD 0-Clause
