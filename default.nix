{ nixExplodedPath ? fetchTarball channel:nixos-unstable
, crossSystem ? null
, pkgs ? import nixExplodedPath { inherit crossSystem; }
}:

with pkgs;

rustPlatform.buildRustPackage {
  name = "raspberry-hello-world";

  src = fetchGit ./.;

  # cargoBuildFlags = [ "--target armv7-unknown-linux-gnueabihf" ];

  cargoSha256 = "0sjjj9z1dhilhpc8pq4154czrb79z9cm044jvn75kxcjv6v5l2m5";
}
