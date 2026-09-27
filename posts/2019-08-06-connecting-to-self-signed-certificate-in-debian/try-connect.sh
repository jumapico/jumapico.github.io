#!/bin/sh
URL="https://$(hostname):8443"
set -x
wget "$URL"
curl "$URL"
{ set +x; } 2>/dev/null

if [ -e HttpsClient.java ]; then
    if [ ! -e HttpsClient.class ] \
            || [ HttpsClient.java -nt HttpsClient.class ]; then
        javac HttpsClient.java
    fi
    set -x
    java HttpsClient "$URL"
    { set +x; } 2>/dev/null
fi
