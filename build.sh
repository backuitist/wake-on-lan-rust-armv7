#!/bin/sh

set -e
set -x

cargo build --target arm-unknown-linux-gnueabihf --release
