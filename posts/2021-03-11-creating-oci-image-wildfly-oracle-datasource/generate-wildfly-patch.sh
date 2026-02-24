#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2021, Juan Picca <jumapico@gmail.com>
#
# Generate patch for wildfly that adds oracle datasource
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

# version to download
ORACLE_JDBC_GROUP=com.oracle.database.jdbc
ORACLE_JDBC_NAME=ojdbc11
ORACLE_JDBC_VERSION=21.1.0.0


PROGNAME="$(basename "$0")"

if [ $# -ne 1 ]; then
    echo "Usage: $PROGNAME wildfly-tarball.tar.gz"
    exit 1
fi
if ss -ltn4 | grep -q -e '127.0.0.1:8080' -e '127.0.0.1:8443' -e '127.0.0.1:9990'; then
    echo "Port 8080, 8443 or 9990 in use - abort"
    exit 1
fi

WORKDIR="$(mktemp --tmpdir -d ${PROGNAME}.XXXXXXXXXX)"

WILDFLY="$(basename "$1")"
WILDFLY="${WILDFLY%.tar.gz}"

tar xf "$1" -C "$WORKDIR"
cp -a "$WORKDIR/$WILDFLY" "$WORKDIR/${WILDFLY}.orig"

# download oracle jdbc
mvn dependency:copy \
    -Dartifact=${ORACLE_JDBC_GROUP}:${ORACLE_JDBC_NAME}:${ORACLE_JDBC_VERSION} \
    -DoutputDirectory="$WORKDIR"

# run wildfly in background
export ORACLE_DATASOURCE=OracleDS
export ORACLE_URL=jdbc:oracle:thin:@localhost
export ORACLE_USER=user
export ORACLE_PASSWORD=pass
"$WORKDIR/$WILDFLY/bin/standalone.sh" 1>/dev/null 2>&1 &
PID=$!
sleep 10  # wait for wildfly startup

# connect to wildfly, install oracle jdbc and configure datasource
cat <<END | bash "$WORKDIR/$WILDFLY/bin/jboss-cli.sh" -c
module add \
    --name=com.oracle \
    --resources=${WORKDIR}/${ORACLE_JDBC_NAME}-${ORACLE_JDBC_VERSION}.jar \
    --dependencies=javax.api,javax.transaction.api

/subsystem=datasources/jdbc-driver=oracle:add( \
    driver-name=oracle, \
    driver-module-name=com.oracle, \
    driver-xa-datasource-class-name=oracle.jdbc.xa.client.OracleXADataSource)

data-source add \
    --name=OracleDS \
    --driver-name=oracle \
    --jndi-name=java:jboss/datasources/\${env.ORACLE_DATASOURCE:OracleDS} \
    --connection-url=\${env.ORACLE_URL} \
    --user-name=\${env.ORACLE_USER} \
    --password=\${env.ORACLE_PASSWORD} \
    --enabled=true \
    --jta=true \
    --use-ccm=false \
    --min-pool-size=2 \
    --max-pool-size=5 \
    --pool-prefill=true \
    --share-prepared-statements=false
END

# terminate wildfly
kill $PID

# fix date in files to make a reproducible patch
touch -r "$WORKDIR/$WILDFLY.orig" $(find "$WORKDIR/$WILDFLY"/standalone "$WORKDIR/$WILDFLY"/modules)

# generate patches for configuration
(cd "$WORKDIR"; diff -u "$WILDFLY"{.orig,}/standalone/configuration/standalone.xml || :) > standalone.xml.patch
(cd "$WORKDIR"; diff -urN "$WILDFLY"{.orig,}/modules || :) > modules.patch
cp "$WORKDIR/$ORACLE_JDBC_NAME-$ORACLE_JDBC_VERSION.jar" .

# cleanup
rm -r "$WORKDIR"

exit 0
