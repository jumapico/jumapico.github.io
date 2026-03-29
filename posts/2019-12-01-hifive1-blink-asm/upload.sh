#!/bin/sh
set -ex

# rnh: This command performs a reset but without halting the device.
echo "loadfile blink.hex\nrnh\nexit" | JLinkExe -device FE310 -if JTAG -speed 4000 -jtagconf -1,-1 -autoconnect 1
