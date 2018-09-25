let 
  moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
  pkgs = import <nixpkgs> { overlays = [moz_overlay]; };
  arm = import <nixpkgs> { 
    crossSystem = pkgs.lib.systems.examples.raspberryPi; };
in

pkgs.stdenv.mkDerivation {

  name = "hi-there";

  buildInputs = [

    (pkgs.rustChannelOfTargets "stable" null

                          [ "x86_64-unknown-linux-gnu"

                            "arm-unknown-linux-gnueabihf" ])

    arm.stdenv.cc

  ];
}
