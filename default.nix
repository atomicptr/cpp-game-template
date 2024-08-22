let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = with pkgs; [
    babashka
    http-server
    unzip
    wget
  ];

  nativeBuildInputs = with pkgs; [
    # this has to come first
    clang-tools

    bear
    emscripten
    gcc
    gdb
    gnumake
    zig
  ];

  buildInputs = with pkgs; [ raylib ];
}
