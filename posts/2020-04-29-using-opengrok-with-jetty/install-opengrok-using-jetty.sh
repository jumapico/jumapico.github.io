#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2020, Juan Picca <jumapico@gmail.com>
#
# install-opengrok-using-jetty
#
# Install opengrok and run it using jetty web server.
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

OPENGROK_VERSION=1.3.13
JETTY_VERSION=9.4.28.v20200408

if [ $EUID -eq 0 ]; then
    echo "Don't run as root!" >&2
    exit 1
fi

usage() {
    echo "usage: $0 install-dir source-dir"
}

if [ $# -eq 1 ] && { [ "$1" = '-h' ] || [ "$1" = '--help' ]; }; then
    usage
    exit 0
fi

if [ $# -ne 2 ]; then
    usage
    exit 1
fi

if ! command -v java > /dev/null \
        || ! command -v ctags-universal > /dev/null; then
    echo "Missing system dependencies; install java and universal-ctags"
    echo "(In debian: apt-get install -Vy default-jre-headless universal-ctags)"
    exit 1
fi

WORKDIR="$1"
SOURCEDIR="$2"
CACHEDIR="$HOME"/.cache/install-opengrok-using-jetty

if [ ! -d "$SOURCEDIR" ]; then
    echo "Directory for sources, \`$SOURCEDIR\` doesn't exist"
    exit 1
fi

mkdir -p "$WORKDIR"/{bin,data,etc,log,dist,jetty} "$CACHEDIR"

if [ ! -f "$CACHEDIR"/jetty-distribution-${JETTY_VERSION}.tar.gz ]; then
    wget -P "$CACHEDIR" "https://repo1.maven.org/maven2/org/eclipse/jetty/jetty-distribution/${JETTY_VERSION}/jetty-distribution-${JETTY_VERSION}.tar.gz"
fi
tar --strip-components=1 -xzf "$CACHEDIR"/jetty-distribution-${JETTY_VERSION}.tar.gz -C "$WORKDIR"/jetty

if [ ! -f "$CACHEDIR"/opengrok-${OPENGROK_VERSION}.tar.gz ]; then
    wget -P "$CACHEDIR" "https://github.com/oracle/opengrok/releases/download/${OPENGROK_VERSION}/opengrok-${OPENGROK_VERSION}.tar.gz"
fi
tar --strip-components=1 -xzf "$CACHEDIR"/opengrok-${OPENGROK_VERSION}.tar.gz -C "$WORKDIR"/dist

cp "$WORKDIR"/dist/doc/logging.properties "$WORKDIR"/etc
sed -i 's#^\(java.util.logging.FileHandler.pattern =\).*$#\1 '"$WORKDIR"'/log/opengrok%g.%u.log#' "$WORKDIR"/etc/logging.properties

ln -s "$WORKDIR"/dist/lib/source.war "$WORKDIR"/jetty/webapps

cat <<END > "$WORKDIR"/jetty/webapps/source.xml
<?xml version="1.0" encoding="UTF-8"?>
<Configure class="org.eclipse.jetty.webapp.WebAppContext">
    <Set name="war">${WORKDIR}/jetty/webapps/source.war</Set>
    <Set name="overrideDescriptor">${WORKDIR}/override-web.xml</Set>
</Configure>
END

cat <<END > "$WORKDIR"/override-web.xml
<?xml version="1.0" encoding="UTF-8"?>
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
         http://xmlns.jcp.org/xml/ns/javaee/web-app_3_1.xsd"
         version="3.1">
    <!--
        This web.xml format file is an override file that is applied to the
        opengrok webapp (source.war) AFTER it has been configured by the default
        descriptor and the WEB-INF/web.xml descriptor
    -->

    <!-- Override context init parameter CONFIGURATION -->
    <context-param>
        <param-name>CONFIGURATION</param-name>
        <param-value>${WORKDIR}/etc/configuration.xml</param-value>
    </context-param>
</web-app>
END

cat > "$WORKDIR"/bin/up <<END
#!/bin/bash
cd "${WORKDIR}"/jetty
exec java -jar start.jar
END
chmod +x "$WORKDIR"/bin/up

cat > "$WORKDIR"/bin/reindex <<END
#!/bin/bash
exec java \
    -Djava.util.logging.config.file="${WORKDIR}"/etc/logging.properties \
    -jar "${WORKDIR}"/dist/lib/opengrok.jar \
    -c /usr/bin/ctags-universal \
    -s "${SOURCEDIR}" \
    -d "${WORKDIR}"/data -H -P -S -G \
    -W "${WORKDIR}"/etc/configuration.xml \
    -U http://localhost:8080/source
END
chmod +x "$WORKDIR"/bin/reindex

"$WORKDIR"/bin/up > /tmp/jetty.out.$$ 2>&1 &
# give some seconds to jetty to start
sleep 5
JETTYPID=$!

"$WORKDIR"/bin/reindex || :

kill $JETTYPID || echo "Can't kill jetty process; try \`kill $JETTYPID\`"

echo "Successful installation."
echo "Run \`$WORKDIR/bin/up\` and open \`http://127.0.0.1:8080\`"

exit 0
