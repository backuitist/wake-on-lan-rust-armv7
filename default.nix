let 
    pkgs_source = import (builtins.fetchTarball "channel:nixos-19.03");
    
    moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
    
    pkgs = pkgs_source { overlays = [moz_overlay]; };
    
    pkgs_no_overlay = pkgs_source {};
    
    arm = pkgs_source {
        crossSystem = pkgs.lib.systems.examples.raspberryPi; };
    
    filteredSources = pkgs.lib.sources.sourceFilesBySuffices ./. [".lock" ".rs" ".toml"];
    
    name = "http-wake-on-lan";

    buildPhase = ''
      env
      cargo --version      
      export CARGO_HOME=tmp-cargo-home
      ${pkgs.curl}/bin/curl https://www.github.com
      cargo fetch --locked

      cargo build --target arm-unknown-linux-gnueabihf --release
    '';
in {

  arm = pkgs.stdenv.mkDerivation {

    inherit name buildPhase;

    src = filteredSources;

    buildInputs = [

      # rocket requires rust nightly -- use `stable` otherwise
      (pkgs.rustChannelOfTargets "nightly" null
                            [ "x86_64-unknown-linux-gnu"
                              "arm-unknown-linux-gnueabihf" ])

      arm.stdenv.cc

    ];    
  };

  x86_64 = pkgs_no_overlay.stdenv.mkDerivation {

    inherit name;

    buildPhase = ''
      echo ${pkgs.curl}
      ${pkgs.curl}/bin/curl --version
      ldd ${pkgs.curl}/bin/curl
      ls /etc
      cat /etc/resolv.conf
      ${pkgs.strace}/bin/strace ${pkgs.curl}/bin/curl https://www.github.com 2>&1 | grep resolv
    '';

    src = ./.;

    buildInputs = [
      # rocket requires rust nightly -- use `stable` otherwise
      (pkgs.rustChannelOfTargets "nightly" null [ "x86_64-unknown-linux-gnu"])
    ];
  };

  shell = pkgs.stdenv.mkDerivation {

    inherit name;

    buildInputs = [
      pkgs.curl

      # rocket requires rust nightly -- use `stable` otherwise
      (pkgs.rustChannelOfTargets "nightly" null [ "x86_64-unknown-linux-gnu"])
    ];
  };
}