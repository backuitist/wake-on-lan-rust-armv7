# Running a Rust web-server on Raspberry pi

We're using Rocket which uses the plugin experimental feature (requiring nightly).

    $ nix-shell
    $ ./build.sh

Copy the binary to your Raspberry pi, e.g:
    
    $ scp hello-world remote-rpi:

Run it (overriding the bind address in development env.):
    
    $ ssh remote-rpi
    $ ROCKET_ADDRESS=0.0.0.0 ./hello-world

See https://api.rocket.rs/rocket/config/ for rocket configuration options

## RLS

    $ nix-shell # should bring RLS to the path
    $ code -n . # make sure rustup is disabled: "rust-client.disableRustup": true