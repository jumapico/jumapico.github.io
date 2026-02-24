#!/bin/sh
echo "Hello world, from a sandbox"
printenv | LC_ALL=C sort
