#!/bin/bash
#
# Genera un nuevo grafo que contiene todas las dependencias transitivas del
# nodo dado.
#
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail


PROGNAME="$(basename "$0")"


if [ $# -ne 2 ]; then
    echo "Usage: $PROGNAME node graph-file"
    exit 1
fi

FWD_G='
# From: https://marc.info/?l=graphviz-interest&m=115396062000535

BEG_G {
   graph_t sg = subg ($, "reachable");
   $tvtype = TV_fwd;
   $tvroot = node($,ARGV[0]);
}

N {$tvroot = NULL; subnode (sg, $); }

END_G {
   induce (sg);
   write (sg);
}
'

gvpr -f <(echo "$FWD_G") -a "$1" "$2"
