#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2020, Juan Picca <jumapico@gmail.com>
#
# Setup hack to use sane with Panasonic KX-MB1520AG
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

do_install() {
    cat <<'END' > /etc/udev/rules.d/99-libsane-panasonic.rules
ACTION=="add", ENV{DEVTYPE}=="usb_device", ATTRS{idVendor}=="04da", ATTRS{idProduct}=="0f0b", ENV{libsane_matched}="yes", RUN="/usr/local/bin/hack-panasonic $devnode"
END

    cat <<'END' > /usr/local/bin/hack-panasonic
#!/bin/bash
[ $# -ne 1 -o ! -c "$1" ] && exit 1
exec /usr/bin/setfacl -m g:users:rw "$1"
END
    chmod +x /usr/local/bin/hack-panasonic
}

do_uninstall() {
    rm /etc/udev/rules.d/99-libsane-panasonic.rules \
        /usr/local/bin/hack-panasonic
}

main() {
    if [ $EUID -ne 0 ]; then
        echo "Run with sudo"
        exit 1
    fi
    if [ $# -eq 0 ]; then
        do_install
    elif [ $# -eq 1 ] && [ "$1" = '--uninstall' ]; then
        do_uninstall
    else
        echo "Usage: $(basename "$0") [--uninstall]"
        exit 1
    fi
    exit 0
}

main "$@"
