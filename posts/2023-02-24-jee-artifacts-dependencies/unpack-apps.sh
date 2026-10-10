#!/bin/bash
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail


PROGNAME="$(basename "$0")"
JARS_TO_SCAN="unpack-apps_jars-to-scan.$$"
JARS_TO_PROCESS="unpack-apps_jars-to-process.$$"
JARS_TO_SKIP="unpack-apps_jars-to-skip.$$"


usage() {
    cat <<END
Usage:\t${PROGNAME} srcdir dstdir

END
}


copy_files() {
    echo "copy_files"
    cp -a "$SRC" "$DST"
}


unpack_ears() {
    echo "unpack_ears"
    for i in $(find "$DST" -name '*.ear' | sort); do
        j="${i%.ear}"
        echo "- unzip -n -d $j $i"
        unzip -n -d "$j" "$i" > /dev/null
        rm "$i"
    done
}


unpack_wars() {
    echo "unpack_wars"
    for i in $(find "$DST" -name '*.war' | sort); do
        j="${i%.war}"
        echo "- unzip -n -d $j $i"
        unzip -n -d "$j" "$i" > /dev/null
        rm "$i"
    done
}


# Desempaca jars recursivamente
# Consiste en varias corridas, ya que puede haber jars dentro de jars
# Se para cuando no haya mas jars para procesar
# Se utiliza el archivo `$JARS_TO_PROCESS` que debe ser llenado por la función
# `calculate_jars_to_process`
unpack_jars() {
    echo "unpack_jars"

    echo "- start_jars_info"
    rm -f "$JARS_TO_PROCESS" "$JARS_TO_SKIP"
    touch "$JARS_TO_PROCESS" "$JARS_TO_SKIP"

    calculate_jars_to_process

    while [ -s "$JARS_TO_PROCESS" ]; do
        for i in $(cat "$JARS_TO_PROCESS"); do
            j="${i%.jar}"
            echo "- unzip -n -d $j $i"
            unzip -n -d "$j" "$i" > /dev/null
            rm "$i"
        done

        echo "- reset_jars_info"
        rm "$JARS_TO_PROCESS"
        touch "$JARS_TO_PROCESS"

        calculate_jars_to_process
    done
    rm -f "$JARS_TO_PROCESS" "$JARS_TO_SKIP"
}


# Generar archivo con jars a procesar (descomprimir)
#
# Por ahora la heurística utilizada es que los jars tengan alguno de los
# directorios `/mycompany/` o ` mycompany/`.
#
calculate_jars_to_process() {
    echo "calculate_jars_to_process"
    find "$DST" -name '*.jar' | sort > "$JARS_TO_SCAN"
    # avoid scan already skipped jars
    if [ -s "$JARS_TO_SKIP" ]; then
        grep -v -f "$JARS_TO_SKIP" "$JARS_TO_SCAN" > "$JARS_TO_SCAN.new" || :
        mv "$JARS_TO_SCAN.new" "$JARS_TO_SCAN"
    fi

    set +e
    for i in $(cat "$JARS_TO_SCAN"); do
        # no se usa `grep -q` para evitar tener un código de error 141
        # ver:
        # * https://stackoverflow.com/questions/19120263/why-exit-code-141-with-grep-q
        # * https://unix.stackexchange.com/questions/274120/pipe-fail-141-when-piping-output-into-tee-why
        unzip -l "$i" | grep -e '/mycompany/' -e ' mycompany/' >/dev/null
        if [ $? -eq 0 ]; then
            echo "- to-process $i"
            echo "$i" >> "$JARS_TO_PROCESS"
        elif [ $? -eq 1 ]; then
            echo "- to-skip $i"
            echo "$i" >> "$JARS_TO_SKIP"
        else
            echo "- error $?: $i"
        fi
    done
    set -e

    rm "$JARS_TO_SCAN"

    sort -u "$JARS_TO_PROCESS" > "$JARS_TO_PROCESS.new"
    mv "$JARS_TO_PROCESS.new" "$JARS_TO_PROCESS"
    sort -u "$JARS_TO_SKIP" > "$JARS_TO_SKIP.new"
    mv "$JARS_TO_SKIP.new" "$JARS_TO_SKIP"
}


# convertir archivos xml a formato unix
convert_unix() {
    echo "convert_unix"
    find "$DST" -name '*.xml' -print0 | xargs -0 dos2unix 2>/dev/null
}


main() {
    if [ $# -ne 2 ]; then
        usage
        exit 1
    fi

    SRC="$1"
    DST="$2"

    if [ ! -d "$SRC" ]; then
        echo "abort - source directory doesn't exists" >&2
        exit 1
    fi
    if [ -d "$DST" ]; then
        echo "abort - destination directory already exists" >&2
        exit 1
    fi

    copy_files
    unpack_ears
    unpack_wars
    unpack_jars
    convert_unix

    echo "Done"
}


main "$@"
