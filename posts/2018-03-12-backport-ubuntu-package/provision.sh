#!/bin/bash -x
set -e


# install packages needed for create the backports
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -qVy packaging-dev devscripts equivs

# add source repository for get the gutenprint package from artful
cat > /etc/apt/sources.list.d/sources-artful.list <<'END'
deb-src http://archive.ubuntu.com/ubuntu artful main
END
apt-get update
