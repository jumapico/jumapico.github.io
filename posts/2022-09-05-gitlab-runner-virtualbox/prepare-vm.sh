#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2022, Juan Picca <juan.picca@jumapico.uy>
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail


## BEGIN - variables to edit
OVA=/tmp/fedora-coreos-36.20220806.3.0-virtualbox.x86_64.ova
SECOND_DISK_SIZE_MB=10000
## END   - variables to edit


if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") vmname" >&2
    exit 1
fi

VBOXFOLDER="$(vboxmanage list systemproperties | grep -oP '^Default machine folder:\s*\K.*$')"
VMNAME="$1"
VMDIR="$VBOXFOLDER/$VMNAME"
IGNITION_FILE="$VMDIR/$VMNAME.ign"
VMLOG="$VMDIR/$VMNAME.log"


import_vm() {
    # https://www.virtualbox.org/manual/UserManual.html#vboxmanage-showvminfo
    # https://www.virtualbox.org/manual/UserManual.html#vboxmanage-import

    if vboxmanage showvminfo "$VMNAME" > /dev/null 2>&1; then
        echo "A vm with the name \`$VMNAME\` already exists -- abort" >&2
        exit 1
    fi
    vboxmanage import --vsys 0 --vmname "$VMNAME" "$OVA"
}

add_secondary_disk() {
    # https://www.virtualbox.org/manual/UserManual.html#vboxmanage-createmedium
    # https://www.virtualbox.org/manual/UserManual.html#vboxmanage-storageattach

    local disk_uuid

    disk_uuid="$(vboxmanage createmedium disk --filename "$VMDIR/disk2.vmdk" --size "$SECOND_DISK_SIZE_MB" --format vmdk --variant standard 2>/dev/null | grep -oP '^Medium created. UUID: \K.*$')"
    if [ -z "$disk_uuid" ]; then
        echo "Error during the creation of the second disk -- abort" >&2
        exit 1
    fi
    vboxmanage storageattach "$VMNAME" --storagectl 'AHCI' --port 1 --device 0 --type hdd --medium $disk_uuid
}

configure_ignition() {
    vboxmanage guestproperty set "$VMNAME" /Ignition/Config "$(cat "$IGNITION_FILE")"
}

configure_ssh_nat_forwarding() {
    vboxmanage modifyvm "$VMNAME" --natpf1 "guestssh,tcp,,2222,,22"
}

attach_serial_for_logs() {
    vboxmanage modifyvm "$VMNAME" --uart1 0x3F8 4
    vboxmanage modifyvm "$VMNAME" --uartmode1 file "$VMLOG"
}

main() {
    import_vm
    add_secondary_disk
    configure_ignition
    configure_ssh_nat_forwarding
    attach_serial_for_logs

    echo "Done"
}

main "$@"
