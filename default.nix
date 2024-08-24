let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  packages = with pkgs; [
    babashka
    bear
    gnumake
    http-server
    unzip
    wget
    zig
  ];

  nativeBuildInputs = with pkgs; [
    # this has to come first
    clang-tools

    # web
    emscripten
  ];

  buildInputs = with pkgs; [ raylib ];
}
