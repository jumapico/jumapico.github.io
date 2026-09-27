#!/bin/bash
#-------------------------------------------------------------------------------
#
# get-os
#
# Helper to download custom OS'es from raspberry pi website for use with the
# noobs installer.
#
# Copyright 2020 Juan Picca <jumapico@gmail.com>
# SPDX-License-Identifier: GPL-3.0-or-later
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && set -x
set -e

DEFAULT_REPO_SERVER="http://downloads.raspberrypi.org/os_list_v3.json"

if [ $# -ne 1 ]; then
    echo "Usage: get-os os_name"
    exit 1
fi
OS_NAME=$1
FILTER='.os_list[] | select(.os_name == "'"$OS_NAME"'")'

value() {
    jq -r "$FILTER | .$1" os_list.json
}

# get list
wget -O os_list.json "$DEFAULT_REPO_SERVER"

# check if the requested os_name is available
set +e
jq -e "$FILTER" os_list.json > /dev/null
status=$?
set -e
if [ $status -eq 4 ]; then
    echo "Image $OS_NAME is not available; try one of:"
    jq '.os_list[].os_name' os_list.json | LC_ALL=C sort
    exit 1
fi

OS_DIR="$(echo "$OS_NAME" | tr ' ' _)"
if [ -d "$OS_DIR" ]; then
    echo "Directory \"$OS_DIR\" already exist"
    exit 1
fi

echo "Downloading files for $OS_NAME, $(value description)"
mkdir -p "$OS_DIR"

# os.json
wget -P "$OS_DIR" "$(value os_info)"
# icon
wget -P "$OS_DIR" "$(value icon)"

# slides_vga
wget -P "$OS_DIR" "$(value marketing_info)"
tar xf "$OS_DIR/marketing.tar" -C "$OS_DIR" && rm "$OS_DIR/marketing.tar"

# partitions.json
wget -P "$OS_DIR" "$(value partitions_info)"

# partitions_setup.sh
wget -P "$OS_DIR" "$(value partition_setup)"

# root and boot filesystems
for tarball in $(value 'tarballs | .[]'); do
    wget -P "$OS_DIR" "$tarball"
done

# cleanup
rm os_list.json

exit 0
