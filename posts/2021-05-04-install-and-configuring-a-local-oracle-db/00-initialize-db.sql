-- Pasos para descarga y configuración de base de datos oracle 12c local.
--
-- 1. Loguearse en [dockerhub](https://hub.docker.com/).
-- 2. Ir a la página de la imagen
--     [Oracle Database Enterprise Edition](https://hub.docker.com/_/oracle-database-enterprise-edition)
--     y presionar el botón *Proceed to Checkout* para llenar el formulario y
--     poder obtener acceso a la imagen luego de presionar el botón
--     *Get Content*.
-- 3. Loguearse a dockerhub con [podman](https://podman.io/) y descargar la
--     imagen:
--     ```
--     $ podman login docker.io
--     $ podman pull docker.io/store/oracle/database-enterprise:12.2.0.1-slim
--     ```
-- 4. Ejecutar la imagen
--     ```
--     $ podman run --detach --interactive --tty \
--         --publish 1521:1521/tcp --publish 5500:5500/tcp \
--         --env DB_MEMORY=1GB \
--         --name oracledb \
--         docker.io/store/oracle/database-enterprise:12.2.0.1-slim
--     ```
-- 5. Utilizando el cliente [sqlcl](https://www.oracle.com/database/technologies/appdev/sqlcl.html)
--     conectarse a la *multitenant container database (CDB)*
--     ```
--     $ sql sys/Oradoc_db1@localhost:1521:ORCLCDB as sysdba
--     ```
-- 6. Ejecutar las sentencias sql de este archivo para crear usuario
--     administrador para conectarse a la *pluggable database (PDB)* PDB1:
--     ```
--     SQL> @00-initialize-db.sql;
--     ```

-- *Nota*: La base de datos oracle está funcionando como una multitenant
-- container database (CDB).
-- Ver: https://docs.oracle.com/database/121/CNCPT/cdbovrvw.htm

-- TODO: para acceder a la PDB debe utilizarse `/ORCLPDB1.localdomain`; queda
--       pendiente la configuración para utilizar `:ORCLPDB1`

alter session set container=ORCLPDB1;

-- Crear usuario local utilizado para definir el esquema.
--
-- NOTE: Al crear las tablas deben darse permiso de acceso al usuario de la
--       aplicación.
create user myschema identified by "password";
grant all privileges to myschema;

-- Crear usuario local utilizado por la aplicación para conectarse
create user myapp identified by "password";
grant connect to myapp;
