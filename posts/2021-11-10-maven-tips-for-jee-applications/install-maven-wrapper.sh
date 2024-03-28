#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileCopyrightText: 2021, Juan Picca <juan.picca@jumapico.uy>
#
# Install maven wrapper in the current directory
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

MAVEN_WRAPPER_VERSION=0.5.6
MAVEN_VERSION=3.8.3

wget -c -P /tmp "https://repo1.maven.org/maven2/io/takari/maven-wrapper/${MAVEN_WRAPPER_VERSION}/maven-wrapper-${MAVEN_WRAPPER_VERSION}.tar.gz"
tar xf /tmp/maven-wrapper-${MAVEN_WRAPPER_VERSION}.tar.gz --strip-components=1
patch -p0 <<'END'
--- .mvn/wrapper/MavenWrapperDownloader.java.orig
+++ .mvn/wrapper/MavenWrapperDownloader.java
@@ -52,7 +52,7 @@

         // If the maven-wrapper.properties exists, read it and check if it contains a custom
         // wrapperUrl parameter.
-        File mavenWrapperPropertyFile = new File(baseDirectory, MAVEN_WRAPPER_PROPERTIES_PATH);
+        File mavenWrapperPropertyFile = new File(baseDirectory.getAbsolutePath(), MAVEN_WRAPPER_PROPERTIES_PATH);
         String url = DEFAULT_DOWNLOAD_URL;
         if(mavenWrapperPropertyFile.exists()) {
             FileInputStream mavenWrapperPropertyFileInputStream = null;
END
rm mvnw.cmd ./.mvn/wrapper/maven-wrapper.jar
sed -i "s/3.6.3/${MAVEN_VERSION}/g" .mvn/wrapper/maven-wrapper.properties
