{ pkgs, ... }:

{
  packages = with pkgs; [
    llvmPackages_19.clang-tools
    babashka
    cmake
    http-server
    just

    xorg.libX11
    xorg.libXrandr
    xorg.libXinerama
    xorg.libXcursor
    xorg.libXi
    libglvnd

    gcc14

    # for cross compiling web
    emscripten

    # for cross compiling windows
    pkgs.pkgsCross.mingwW64.buildPackages.gcc14
  ];
}
