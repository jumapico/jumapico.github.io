-- Creación de tablas para aplicación `myapp` en esquema `myschema`
--
-- 1. Conectarse a la base de datos con usuario `myschema`
--     ```
--     $ sql myschema/password@localhost:1521/ORCLPDB1.localdomain
--     ```
-- 2. Ejecutar sentencias sql de este archivo
--     ```
--     SQL> @01-create-tables.sql;
--     ```

-- NOTE: Realizar la creación de objetos en una misma transacción
-- NOTE: Dar permisos de acceso y modificación al usuario `myapp`
