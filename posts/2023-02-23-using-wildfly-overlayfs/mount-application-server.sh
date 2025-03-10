#!/bin/sh

PROGNAME="$(basename "$0")"

# extract server type and file
FILE=${PROGNAME##mount-}
FILE=${FILE%%.sh}

case "$FILE" in
    wildfly*.tar.gz)
        AS=wildfly
        VERSION="${FILE%%.tar.gz}"
        ;;
    payara*.zip)
        AS=payara
        VERSION="${FILE%%.zip}"
        ;;
    *)
        echo "abort: invalid script name;" >&2
        echo "abort: can't handle \`$FILE\` application server" >&2
        echo "hint: rename script as \`mount-(wildfly-XXX|payara-XXX).sh\`" >&2
        echo "hint: where XXX is the version and extension of the file." >&2
        exit 1;
esac

DIR="$VERSION"

echo "mounting $VERSION" >&2

if [ ! -d "${DIR}_base" ]; then
    echo "abort: can't found \`${DIR}_base\` (original $VERSION files)" >&2
    if [ "$AS" = wildfly ]; then
        echo "hint: tar xf /path/to/${FILE} --transform 's/^${DIR}/${DIR}_base/'" >&2
    elif [ "$AS" = payara ]; then
        # inside the zip, the directory is payaraX where X is the major version
        DIR2="${DIR##payara-}"
        DIR2="payara${DIR2%%.*}"
        echo "hint: mkdir ${DIR}_base; ln -s ${DIR}_base ${DIR2}; unzip /path/to/${FILE}; rm ${DIR2}" >&2
    fi
    exit 1
fi
if [ ! -d "${DIR}_upper" ]; then
    echo "- creating directory \`${DIR}_upper\`" >&2
    mkdir "${DIR}_upper"
fi
if [ ! -d "${DIR}_work" ]; then
    echo "- creating directory \`${DIR}_work\`" >&2
    mkdir "${DIR}_work"
fi
if [ ! -d "${DIR}" ]; then
    echo "- creating directory \`${DIR}\`" >&2
    mkdir "${DIR}"
elif mountpoint -q "$DIR"; then
    echo "abort: \`$DIR\` is already a mountpoint" >&2
    echo "hint: umount $DIR" >&2
    exit 1
fi

echo "- mounting overlay" >&2
doas mount -t overlay overlay -o lowerdir="${DIR}_base",upperdir="${DIR}_upper",workdir="${DIR}_work" "$DIR"

echo "done" >&2
