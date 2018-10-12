#!/bin/bash

set -e
set -x

cargo build --target arm-unknown-linux-gnueabihf --release