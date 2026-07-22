#!/bin/bash
#-------------------------------------------------------------------------------
# SPDX-License-Identifier: GPL-3.0-or-later
# Copyright 2020, Juan Picca <jumapico@gmail.com>
#
# Patch wildfly adding ojdbc11
#
#-------------------------------------------------------------------------------
[ -n "$DEBUG" ] && { export PS4='+ [${BASH_SOURCE##*/}:${LINENO}] '; set -x; }
set -euo pipefail

cat <<'END' | patch -p1
--- wildfly-23.0.0.Final.orig/standalone/configuration/standalone.xml	2021-03-10 18:50:15.000000000 -0300
+++ wildfly-23.0.0.Final/standalone/configuration/standalone.xml	2021-03-10 18:50:10.000000000 -0300
@@ -159,10 +159,29 @@
                         <password>sa</password>
                     </security>
                 </datasource>
+                <datasource jta="true" jndi-name="java:jboss/datasources/${env.ORACLE_DATASOURCE:OracleDS}" pool-name="OracleDS" enabled="true" use-ccm="false">
+                    <connection-url>${env.ORACLE_URL}</connection-url>
+                    <driver>oracle</driver>
+                    <pool>
+                        <min-pool-size>2</min-pool-size>
+                        <max-pool-size>5</max-pool-size>
+                        <prefill>true</prefill>
+                    </pool>
+                    <security>
+                        <user-name>${env.ORACLE_USER}</user-name>
+                        <password>${env.ORACLE_PASSWORD}</password>
+                    </security>
+                    <statement>
+                        <share-prepared-statements>false</share-prepared-statements>
+                    </statement>
+                </datasource>
                 <drivers>
                     <driver name="h2" module="com.h2database.h2">
                         <xa-datasource-class>org.h2.jdbcx.JdbcDataSource</xa-datasource-class>
                     </driver>
+                    <driver name="oracle" module="com.oracle">
+                        <xa-datasource-class>oracle.jdbc.xa.client.OracleXADataSource</xa-datasource-class>
+                    </driver>
                 </drivers>
             </datasources>
         </subsystem>
END

cat <<'END' | patch -p1
diff -urN wildfly-23.0.0.Final.orig/modules/com/oracle/main/module.xml wildfly-23.0.0.Final/modules/com/oracle/main/module.xml
--- wildfly-23.0.0.Final.orig/modules/com/oracle/main/module.xml	1969-12-31 21:00:00.000000000 -0300
+++ wildfly-23.0.0.Final/modules/com/oracle/main/module.xml	2021-03-10 18:50:10.000000000 -0300
@@ -0,0 +1,13 @@
+<?xml version='1.0' encoding='UTF-8'?>
+
+<module xmlns="urn:jboss:module:1.1" name="com.oracle">
+
+    <resources>
+        <resource-root path="ojdbc11-21.1.0.0.jar"/>
+    </resources>
+
+    <dependencies>
+        <module name="javax.api"/>
+        <module name="javax.transaction.api"/>
+    </dependencies>
+</module>
\ No newline at end of file
Binary files wildfly-23.0.0.Final.orig/modules/com/oracle/main/ojdbc11-21.1.0.0.jar and wildfly-23.0.0.Final/modules/com/oracle/main/ojdbc11-21.1.0.0.jar differ
END

wget -O modules/com/oracle/main/ojdbc11-21.1.0.0.jar \
    'https://download.oracle.com/otn-pub/otn_software/jdbc/211/ojdbc11.jar'
