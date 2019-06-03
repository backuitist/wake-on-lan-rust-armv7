let 
    pkgs_source = import (builtins.fetchTarball "channel:nixos-19.03");
    
    moz_overlay = import (builtins.fetchTarball https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz);
    
    pkgs = pkgs_source { overlays = [moz_overlay]; };
    
    armPkgs = pkgs_source {
        crossSystem = pkgs.lib.systems.examples.raspberryPi; };
    
    filteredSources = pkgs.lib.sources.sourceFilesBySuffices ./. [".lock" ".rs" ".toml"];
    
    name = "http-wake-on-lan";
in {
  
  ## TODO try to use the rust platform using cargo options.
  arm = pkgs.stdenv.mkDerivation {

    inherit name;

    src = filteredSources;

    buildInputs = [

      # rocket requires rust nightly -- use `stable` otherwise
      (pkgs.rustChannelOfTargets "nightly" null
                            [ "x86_64-unknown-linux-gnu"
                              "arm-unknown-linux-gnueabihf" ])

      armPkgs.stdenv.cc
    ];    

    # This won't work as nix doesn't expect builds to pull
    # things from the outside. It would mess up the hash calculation.
    buildPhase = ''
      export CARGO_HOME=tmp-cargo-home
      
      cargo fetch --locked

      cargo build --target arm-unknown-linux-gnueabihf --release
    '';
  };

  shell = pkgs.stdenv.mkDerivation {

    inherit name;

    buildInputs = [
      pkgs.curl
      # pkgs.rls
      
      # rocket requires rust nightly -- use `stable` otherwise
      # https://github.com/SergioBenitez/Rocket/issues/19
      ((pkgs.rustChannelOf {
        channel = "nightly";
        date = "2019-03-20";
      }).rust.override {
        targets = [ 
          "x86_64-unknown-linux-gnu"
          "arm-unknown-linux-gnueabihf"
        ];
        extensions = [
          "rust-src"
          "rls-preview" # rls isn't always available on nightly ...
          # ... and nightly is needed by rocket!
          "rustfmt-preview"
        ];
      })

      armPkgs.stdenv.cc
    ];
  };
}