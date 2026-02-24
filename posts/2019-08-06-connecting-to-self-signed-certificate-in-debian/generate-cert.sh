#!/bin/sh
# From: https://www.jamescoyle.net/how-to/1073-bash-script-to-create-an-ssl-certificate-key-and-request-csr
outfile=/tmp/cert-and-key.pem

country=uy
state=Montevideo
locality=Montevideo
organization="My Home"
organizationalunit="My Room"
commonname="$(hostname)"
email="My Email <my.email@$(hostname)>"

openssl req \
    -new -x509 \
    -keyout "$outfile" -out "$outfile" \
    -subj "/C=${country}/ST=${state}/L=${locality}/O=${organization}/OU=${organizationalunit}/CN=${commonname}/emailAddress=${email}" \
    -days 365 \
    -nodes
