{ pkgs, ... }:

{
  packages = with pkgs; [
    llvmPackages_19.clang-tools

    libglvnd
    raylib
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr

    babashka
    cmake
    just
    meson

    emscripten
    gcc14
  ];

  enterShell = with pkgs; ''
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        xorg.libX11
      ]
    }:$LD_LIBRARY_PATH"
  '';
}
