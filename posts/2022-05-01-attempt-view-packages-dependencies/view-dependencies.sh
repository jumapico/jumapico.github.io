#!/usr/bin/env bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2021, Juan Picca <juan.picca@jumapico.uy>
#
# Interactive dependency viewer for OpenBSD packages
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

precalculate_files_early() {
    # generate temporary dir and add a trap
    WORKDIR="$(mktemp -d -t view-dependencies.XXXXXXXXXX)"
    trap 'rm -r "$WORKDIR"' EXIT

    ## manual packages first
    pkg_info -q -m > "$WORKDIR/package-manual.txt"
    pkg_info -q -a \
        | grep -v -f "$WORKDIR/package-manual.txt" > "$WORKDIR/package-rest.txt"
}

precalculate_files() {
    # write programs
    cat > "$WORKDIR/generate-graph.awk" <<'EOT'
BEGIN {
    print "digraph dependencies {"
    print "  fontname=\"Helvetica,Arial,sans-serif\""
    print "  node [fontname=\"Helvetica,Arial,sans-serif\"]"
    print "  edge [fontname=\"Helvetica,Arial,sans-serif\"]"
    print "  rankdir=\"LR\""
    hasdeps=1
}

/^@name/ {
    if (!hasdeps)
        printf " \"%s\" ;\n", current
    current=$2
    hasdeps=0
}
/^@depend/ {
    printf " \"%s\" -> \"%s\" ;\n", current, $2
    hasdeps=1
}

END {
    print "}"
}
EOT
    cat > "$WORKDIR/fwd.g" <<'EOT'
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
EOT
    # calculate dependency graph
    pkg_info -A -f \
        | grep -e '^@name' -e '^@depend' \
        | sed 's/^@depend .*:\([^:]*\)$/@depend \1/' \
        | awk -f "$WORKDIR/generate-graph.awk" \
        > "$WORKDIR/package-dependencies.dot"
    # calculate package list
    sed 's/^/FALSE /' "$WORKDIR/package-manual.txt" "$WORKDIR/package-rest.txt" \
        > "$WORKDIR/package-list.txt"
}

select_package() {
    zenity --width=640 --height=800 --title="Dependency viewer" \
        --list --radiolist --text="Select a package" \
        --column="" --column="Package" \
        $(cat "$WORKDIR/package-list.txt")
}

show_package_dependencies() {
    gvpr -a "$1" -f "$WORKDIR/fwd.g" "$WORKDIR/package-dependencies.dot" \
        | xdot -
}

generate_package_dependencies_svg() {
    gvpr -a "$1" -f "$WORKDIR/fwd.g" "$WORKDIR/package-dependencies.dot" \
        | dot -Tsvg > dependencies-for-"$1".svg
}

usage() {
    cat <<'END'

view-dependencies [ -h | --help | <package> ]

View the dependencies of installed packages.

Without arguments use the interactive GUI to select an installed  package to
shown his dependencies.

-h or --help show this help.

<package> check if the given package (with an exact version) is installed and
generate a file named `dependencies-for-<package>.svg` with the dependency
graph.
END
}


main() {
    local pkg

    if [ $# -eq 1 ]; then
        if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
            usage
            exit 0;
        else
            precalculate_files_early
            pkg="$1"
            if ! grep -q "^$pkg$" "$WORKDIR/package-manual.txt" \
                    "$WORKDIR/package-rest.txt"; then
                echo "Package \`$pkg\` was not installed." >&2
                exit 1
            fi
            precalculate_files
            generate_package_dependencies_svg "$pkg"
        fi
    elif [ $# -eq 0 ]; then
        precalculate_files_early
        precalculate_files
        pkg="$(select_package)"
        while [ -n "$pkg" ]; do
            show_package_dependencies "$pkg"
            pkg="$(select_package)"
        done
    else
        usage
        exit 1
    fi
}

main "$@"
