{
  lib,
  pkgs,
  stdenv,
  libsForQt5,
  ...
}:
with libsForQt5;
stdenv.mkDerivation rec {
  pname = "kochmorse";
  version = "3.5.1-git";

  src = pkgs.fetchFromGitHub {
    owner = "hmatuschek";
    repo = "kochmorse";
    rev = "f1c5d942cdb0b25e46205e864caeec89822bb28a";
    hash = "sha256-88LHQ3kUQPyog1LPkGcWQ3vt/s0gOynTP6f8YX/3kTM=";
  };

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    qt6.full
    wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qt6.full
    zlib
  ];

}
