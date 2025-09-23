# Mostly a port of gleachkr/nix-tools' kani.nix - thanks!
{
  glibc,
  extend,
  system,
  rsync,
  makeWrapper,
  stdenv,
  autoPatchelfHook,
  makeRustPlatform,
  pkgs,
  lib,
  ...
}:
let
  rustHome = pkgs.rust-bin.nightly."2025-07-02".default.override {
    extensions = [
      "rustc-dev"
      "rust-src"
      "llvm-tools"
      "rustfmt"
    ];
  };

  rustPlatform = makeRustPlatform {
    cargo = rustHome;
    rustc = rustHome;
  };

  kani-home = stdenv.mkDerivation {
    name = "kani-home";

    src = fetchTarball {
      url = "https://github.com/model-checking/kani/releases/download/kani-0.64.0/kani-0.64.0-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-RP38iCbQWoQyAYtq2Nnkm6iFhXtVQ4rbHaKyCFMcIsQ=";
    };

    buildInputs = [
      stdenv.cc.cc.lib # libs needed by patchelf
    ];

    runtimeDependencies = [
      glibc # not detected as missing by patchelf for some reason
    ];

    nativeBuildInputs = [ autoPatchelfHook ];

    installPhase = ''
      runHook preInstall
      ${rsync}/bin/rsync -av $src/ $out --exclude kani-compiler
      runHook postInstall
    '';
  };

in
rustPlatform.buildRustPackage rec {
  pname = "kani";

  version = "kani-0.64.0";

  src = pkgs.fetchFromGitHub {
    owner = "model-checking";
    repo = "kani";
    rev = "96f7e59a8c8058f3edbdcc4d52940e376d54ff09";
    hash = "sha256-8UyAO9eTwcUtOktSJ9QdYpccgDRefWDTIewjAwvkhdA=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [ makeWrapper ];

  patches = [ ./deps.patch ];

  postInstall = ''
    mkdir -p $out/lib/
    ${rsync}/bin/rsync -av ${kani-home}/ $out/lib/${version} --perms --chmod=D+rw,F+rw
    cp $out/bin/* $out/lib/${version}/bin/
    ln -s ${rustHome} $out/lib/${version}/toolchain
  '';

  postFixup = ''
    wrapProgram $out/bin/kani --set KANI_HOME $out/lib/
    wrapProgram $out/bin/cargo-kani --set KANI_HOME $out/lib/
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit
      patches
      pname
      version
      src
      ;
    hash = "sha256-1MfK2O4F0YJZJgDRxwAQ8vRM4Xgx9i1Xl1+InH6r2b4=";
  };

  env = {
    RUSTUP_HOME = "${rustHome}";
    RUSTUP_TOOLCHAIN = "..";
  };
}
