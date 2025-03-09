#!/bin/bash
#
# Crear grafo de dependencias de artefactos que se encuentran en un jboss
#
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -eu


PROGNAME="$(basename "$0")"
GRAPH="dependency-graph.dot"
DEBUG_NODES=0


node_application_xml() {
    local f="$1"
    local filename displayname name dep ejbmodules webmodules clustername

    filename="$(echo "$f" | sed 's#.*/\([^/]*\)/META-INF/application.xml$#\1#')"

    displayname="$(xmllint --xpath "/*[local-name()='application']/*[local-name()='display-name']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d')"

    if [ -n "$displayname" ]; then
        name="$displayname"
    else
        name="$filename"
    fi

    # se busca "limpiar" el nombre del artefacto quitando los números de versión que tuviera
    clustername="$(echo "$name" | sed 's/^\(.*\)-[0-9.-RCrc]*/\1/' | sed 's/^\(.*\)-[0-9.-RCrc]*/\1/' | sed 's/-/_/g; s/\./_/g')"

    ejbmodules="$(xmllint --xpath "/*[local-name()='application']/*[local-name()='module']/*[local-name()='ejb']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d; s/.jar$//' | sort -u)"

    webmodules="$(xmllint --xpath "/*[local-name()='application']/*[local-name()='module']/*[local-name()='web']/*[local-name()='web-uri']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d; s/.war$//' | sort -u)"

    if [ "$DEBUG_NODES" -eq 1 ]; then
        echo "FILE: '$f'"
        echo "FILENAME: '$filename'"
        echo "DISPLAYNAME: '$displayname'"
        echo "NAME: '$name'"
        echo "CLUSTERNAME: '$clustername'"
        echo "EJBMODULES: '$ejbmodules'"
        echo "WEBMODULES: '$webmodules'"
        echo
        echo "GRAPH:"
    fi

    echo "  subgraph cluster_$clustername {"
    echo "    label=\"$clustername\";"
    echo "    graph[style=dotted];"

    # node info
    echo "    \"$name\" ;"

    # deps ejb
    for dep in $ejbmodules; do
        echo "    \"$name\" -> \"$dep\" ;"
    done

    # deps web
    for dep in $webmodules; do
        echo "    \"$name\" -> \"$dep\" ;"
    done

    echo "  }"
}


node_ejb_jar_xml() {
    local f="$1"

    filename="$(echo "$f" | sed 's#.*/\([^/]*\)/META-INF/ejb-jar.xml$#\1#')"

    displayname="$(xmllint --xpath "/*[local-name()='ejb-jar']/*[local-name()='display-name']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d')"

    if [ -n "$displayname" ]; then
        name="$displayname"
    else
        name="$filename"
    fi

    interceptors="$(xmllint --xpath "//*[local-name()='interceptor-class']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d' | sort -u)"


    if [ "$DEBUG_NODES" -eq 1 ]; then
        echo "FILE: '$f'"
        echo "FILENAME: '$filename'"
        echo "DISPLAYNAME: '$displayname'"
        echo "NAME: '$name'"
        echo "INTERCEPTORS: '$interceptors'"
        echo
        echo "GRAPH:"
    fi

    for dep in $interceptors; do
        echo "    \"$name\" -> \"$dep\" ;"
    done

}


node_jboss_xml() {
    local f="$1"
    local filename displayname name dep ejblocalref

    filename="$(echo "$f" | sed 's#.*/\([^/]*\)/META-INF/jboss.xml$#\1#')"

    name="$filename"

    ejblocalref="$(xmllint --xpath "//*[local-name()='ejb-local-ref']/*[local-name()='local-jndi-name']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d; s#^\([^/]*\)/.*$#\1#' | sort -u)"

    # debug
    if [ "$DEBUG_NODES" -eq 1 ]; then
        echo "FILE: '$f'"
        echo "FILENAME: '$filename'"
        echo "NAME: '$name'"
        echo "EJBLOCALREF: '$ejblocalref'"
        echo
        echo "GRAPH:"
    fi

    # node info
    echo "    \"$name\" ;"

    # deps ejb-local-ref
    for dep in $ejblocalref; do
        echo "    \"$name\" -> \"$dep\" ;"
    done
}


node_jboss_web_xml() {
    local f="$1"
    local filename displayname name dep ejblocalref

    filename="$(echo "$f" | sed 's#.*/\([^/]*\)/WEB-INF/jboss-web.xml$#\1#')"

    name="$filename"

    ejblocalref="$(xmllint --xpath "//*[local-name()='ejb-local-ref']/*[local-name()='local-jndi-name']/text()" "$f" 2>/dev/null \
        | sed 's/[[:space:]]*//g; /^$/d; s#^\([^/]*\)/.*$#\1#' | sort -u)"

    # debug
    if [ "$DEBUG_NODES" -eq 1 ]; then
        echo "FILE: '$f'"
        echo "FILENAME: '$filename'"
        echo "NAME: '$name'"
        echo "EJBLOCALREF: '$ejblocalref'"
        echo
        echo "GRAPH:"
    fi

    # node info
    echo "    \"$name\" ;"

    # deps ejb-local-ref
    for dep in $ejblocalref; do
        echo "    \"$name\" -> \"$dep\" ;"
    done
}


allnodes() {
    local file="$1" func="$2"

    for f in $(find "$DIR" -name "$file" | sort); do
        node_$func "$f"
    done
}


create_graph() {
    {
        echo "digraph deps_jboss {"
        allnodes application.xml application_xml
        allnodes ejb-jar.xml ejb_jar_xml
        allnodes jboss.xml jboss_xml
        allnodes jboss-web.xml jboss_web_xml
        echo "}"
    } > "$GRAPH"
}


usage() {
    cat <<END
Usage:
    $PROGNAME directory
    $PROGNAME --application_xml|--jboss_xml|--ejb_jar_xml file

END
}


main() {
    local badparams=1
    local option

    if [ $# -eq 1 ]; then
        DIR="$1"
        if [ ! -d "$DIR" ]; then
            echo "abort - no existe el directorio $DIR" >&2
            exit 1
        fi
        create_graph
        echo "Done"
        exit 0
    elif [ $# -eq 2 ]; then
        case $1 in
            --application_xml|--jboss_web_xml|--jboss_xml|--ejb_jar_xml)
                if [ "$#" -ne 2 ]; then
                    exit 1
                fi
                OPTION="${1#--}"
                FILE="$2"
                if [ ! -f "$FILE" ]; then
                    echo "abort - no existe el archivo $FILE" >&2
                    exit 1
                fi

                DEBUG_NODES=1
                node_$OPTION "$FILE"
                exit 0
        esac
    fi

    usage
    exit 1
}


main "$@"
