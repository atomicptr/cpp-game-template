{ pkgs, ... }:

{
  packages = with pkgs; [
    llvmPackages_19.clang-tools
    meson
    just
    babashka

    glfw3
    raylib

    emscripten
    gcc14
  ];
}
