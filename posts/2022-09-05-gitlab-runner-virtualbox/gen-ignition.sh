#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2022, Juan Picca <juan.picca@jumapico.uy>
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail


if [ $# -ne 1 ]; then
    echo "Usage: $(basename "$0") vmname" >&2
    exit 1
fi

VBOXFOLDER="$(vboxmanage list systemproperties | grep -oP '^Default machine folder:\s*\K.*$')"
VMNAME="$1"
VMDIR="$VBOXFOLDER/$VMNAME"
if [ -d "$VMDIR" ]; then
    echo "The directory \`$VMDIR\` already exists - abort" >&2
    exit 1
fi
mkdir -p "$VMDIR"

DATE="$(date -u +%Y%m%dT%H%M%SZ)"
PASS_GHRUNNER_RAW="$(pwgen -y 64 1)"
PASS_GHRUNNER_HASH="$(mkpasswd --method=yescrypt "$PASS_GHRUNNER_RAW")"
PASS_GHRUNNER_FILE="$VMDIR/user_gitlabrunner.pass"
CERTCOMMENT="Certificate for core user - fcos - $VMNAME - $DATE"
CERT_CORE_FILE="$VMDIR/user_core.cert"
IGNITION_FILE="$VMDIR/$VMNAME.ign"

echo "$PASS_GHRUNNER_RAW" > "$PASS_GHRUNNER_FILE"

ssh-keygen -t rsa -b 4096 -C "$CERTCOMMENT" -f "$CERT_CORE_FILE" -N '' > /dev/null 2>&1
CERT_CORE_PUBCONTENT="$(cat "$CERT_CORE_FILE.pub")"

cat <<END | butane --pretty --strict > "$IGNITION_FILE"
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: gitlab-runner
      # gitlab wants to connect using a password
      home_dir: /var/lib/gitlab-runner
      password_hash: ${PASS_GHRUNNER_HASH}
    - name: core
      # for monitoring purposes
      ssh_authorized_keys:
        - ${CERT_CORE_PUBCONTENT}
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: gitlab-runner-vm
    - path: /etc/ssh/sshd_config.d/20-enable-passwords.conf
      mode: 0644
      contents:
        inline: |
          # Fedora CoreOS disables SSH password login by default.
          # Enable it.
          # This file must sort before 40-disable-passwords.conf.
          PasswordAuthentication yes
  disks:
    - device: /dev/sdb
      wipe_table: true
      partitions:
        - number: 1
          label: "gitlab-runner"
  filesystems:
    - path: /var/lib/gitlab-runner
      device: /dev/disk/by-partlabel/gitlab-runner
      format: ext4
      wipe_filesystem: true
      label: gitlab-runner
      with_mount_unit: true
END


printf 'ignition config file: %s\n' "$IGNITION_FILE"
printf 'file with pass for user github-runner: %s\n' "$PASS_GHRUNNER_FILE"
printf 'file to connect with core user: %s\n' "$CERT_CORE_FILE"

printf '\nDone\n'
