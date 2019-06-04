let
   pkgs = import <nixpkgs> {};
in
    pkgs.stdenv.mkDerivation {
        name = "blabla";

        src = ./.;

        buildPhase = ''
            ls -al /
            # in sandbox mode this will appear
            # mostly empty (not even resolv.conf!)
            ls -al /etc
        '';
    }