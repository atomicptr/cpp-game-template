let 
  pkgs = import <nixpkgs> {};
in
pkgs.mkShell {
  packages = with pkgs; [
    babashka
  ];

  nativeBuildInputs = with pkgs; [
    # this has to come first
    clang-tools

    bear
    gcc
    gdb
    gnumake
  ];

  buildInputs = with pkgs; [
    raylib
  ];
}
