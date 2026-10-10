#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2021, Juan Picca <jumapico@gmail.com>
#
# Demo script used to add a new category and an item to the desktop main menu.
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

# Default icon used for the category and the item
# This is an existing icon in debian systems
ICONNAME=emblem-debian

usage() {
    echo "Usage: $0 --install|--uninstall"
}

uninstall() {
    rm -fr \
        /usr/share/desktop-directories/X-myvendor.directory \
        /etc/xdg/menus/applications-merged/myvendor-applications.menu \
        /usr/share/applications/myvendor
}

install() {
    mkdir -p /usr/share/applications/myvendor
    # Create custom category
    cat > /usr/share/desktop-directories/X-myvendor.directory <<END
[Desktop Entry]
Version=1.0
Type=Directory
Icon=${ICONNAME}
Name=MyVendor1
Comment=MyVendor applications
END
    # Add custom category to desktop menu and item inside it
    cat > /etc/xdg/menus/applications-merged/myvendor-applications.menu <<'END'
<?xml encoding="UTF-8"?>
<!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
    "http://www.freedesktop.org/standards/menu-spec/menu-1.0.dtd">
<Menu>
    <Name>Applications</Name>
    <Menu>
        <Name>MyVendor2</Name>
        <Directory>X-myvendor.directory</Directory>
        <Include>
            <Filename>myvendor-test-filename.desktop</Filename>
        </Include>
    </Menu>
</Menu>
END
    # Add item
    cat > /usr/share/applications/myvendor/test-filename.desktop <<END
[Desktop Entry]
Type=Application
Icon=${ICONNAME}
Name=myvendor test filename
Exec=/usr/bin/zenity --info --text='Hello filename'
END
}

main() {
    if [ $EUID -ne 0 ]; then
        echo "Run as root"
        exit 1
    fi
    if [ $# -ne 1 ]; then
        echo "Invalid arguments"
        usage
        exit 1
    fi
    if [ "$1" = --install ]; then
        install
    elif [ "$1" = --uninstall ]; then
        uninstall
    else
        echo "Invalid arguments"
        usage
        exit 1
    fi
    exit 0
}

main "$@"
