-- Ejecutar con el usuario SYS con el rol SYSDBA en el contenedor FREEPDB1
@install_headless.sql
-- 1. Otorgar permisos de EJECUCIÓN sobre el paquete principal 'UT'
GRANT EXECUTE ON UT3.UT TO HR;
-- 2. Crear un sinónimo para que HR pueda llamarlo solo como 'UT'
CREATE SYNONYM HR.UT FOR UT3.UT;
