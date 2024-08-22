let 
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs; [
    wget
    unzip
    babashka
    http-server
  ];

  nativeBuildInputs = with pkgs; [
    # this has to come first
    clang-tools

    bear
    gcc
    gdb
    gnumake
    zig
    emscripten
  ];

  buildInputs = with pkgs; [
    raylib
  ];
}
