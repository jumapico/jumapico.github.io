#!/bin/sh
# From https://serverfault.com/questions/139728/how-to-download-the-ssl-certificate-from-a-website
HOSTNAME=$(hostname)

echo -n \
    | openssl s_client -connect ${HOSTNAME}:8443 \
    | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > /tmp/$HOSTNAME.crt
