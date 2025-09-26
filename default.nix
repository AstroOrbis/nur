# Defaulting to <nixpkgs> lets us use nix-build -A pkgname, but we need to take it as argument
{
  pkgs ? import <nixpkgs> {
    overlays = [
      (import (
        builtins.fetchTarball {
          url = "https://github.com/oxalica/rust-overlay/archive/d2bac276ac7e669a1f09c48614538a37e3eb6d0f.zip";
          sha256 = "sha256-kx2uELmVnAbiekj/YFfWR26OXqXedImkhe2ocnbumTA=";
        }
      ))
    ];
  },
}:
rec {
  # The `lib`, `modules`, and `overlays` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  # And now, the packages
  agave-cli = pkgs.callPackage ./pkgs/agave-cli { inherit agave-platform-tools-bin; };
  agave-platform-tools-bin = pkgs.callPackage ./pkgs/agave-platform-tools-bin { };
  mtgatool-desktop = pkgs.callPackage ./pkgs/mtgatool-desktop { };
  hayase = pkgs.callPackage ./pkgs/hayase { };
  kani = pkgs.callPackage ./pkgs/kani { };
  kochmorse = pkgs.libsForQt5.callPackage ./pkgs/kochmorse { };
}
