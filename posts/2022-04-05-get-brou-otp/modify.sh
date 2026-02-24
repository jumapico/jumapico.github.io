#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2022, Juan Picca <juan.picca@jumapico.uy>
#
# Modify app *BROU-Llave-Digital*
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

printf '1. Extract files with apktool\n'
printf '* remove modified app if exists\n'
rm -fr uy.com.brou.token uy.jumapico.brou.token

printf '* extract app\n'
java -jar apktool_2.6.1.jar d aurorastore/uy.com.brou.token.apk

printf '2. Change app name\n'
printf '* rename\n'
mv uy.com.brou.token uy.jumapico.brou.token

printf '* change app name used in build command\n'
sed -i 's/apkFileName: uy.com.brou.token.apk/apkFileName: uy.jumapico.brou.token.apk/' uy.jumapico.brou.token/apktool.yml

printf '3. Change app name\n'
patch -d uy.jumapico.brou.token -p1 < 01-change-app-name.patch

printf '4. Modify application\n'
patch -d uy.jumapico.brou.token -p1 < 02-show-log-message.patch

printf '5. Build modified app\n'
java -jar apktool_2.6.1.jar b uy.jumapico.brou.token

printf '6. Sign app\n'
if [ ! -e debug.keystore ]; then
    printf '* generate debug keystore\n'
    keytool -genkey -v -keystore debug.keystore -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
fi

printf '* sign\n'
apksigner sign --ks debug.keystore --ks-pass pass:android --debuggable-apk-permitted --out uy.jumapico.brou.token/dist/uy.jumapico.brou.token-signed.apk uy.jumapico.brou.token/dist/uy.jumapico.brou.token.apk
