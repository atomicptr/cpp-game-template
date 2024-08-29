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

  buildInputs = with pkgs; [
    # this has to come first
    llvmPackages_19.clang-tools

    clang
    raylib

    # web
    emscripten
  ];

  shellHook = with pkgs; ''
    export LD_LIBRARY_PATH="${pkgs.lib.makeLibraryPath [
      xorg.libX11
      libglvnd
    ]}:$LD_LIBRARY_PATH"
  '';
}
