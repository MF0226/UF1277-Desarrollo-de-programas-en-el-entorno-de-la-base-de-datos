CREATE OR REPLACE PROCEDURE award_bonus (
  emp_id NUMBER, sales_amt NUMBER) 
AS
  commission      REAL;
  
  -- Definimos la excepción aquí para poder usarla en el bloque EXCEPTION
  E_COMM_MISSING EXCEPTION; 
  PRAGMA EXCEPTION_INIT(E_COMM_MISSING, -20001); 

BEGIN
  -- 1. Obtener la comisión del empleado. 
  --    Si el ID no existe, lanza NO_DATA_FOUND.
  SELECT commission_pct INTO commission
    FROM employees
    WHERE employee_id = emp_id;

  -- 2. Lanza la excepción -20001 si la comisión es nula
  IF commission IS NULL THEN
    RAISE_APPLICATION_ERROR(-20001, 'El porcentaje de comisión es nulo para el empleado ' || emp_id);
  ELSE
    -- 3. Aplicar el bono
    UPDATE employees
      SET salary = salary + sales_amt * commission
        WHERE employee_id = emp_id;
  END IF;
  
EXCEPTION
    -- Manejador de excepciones:
    -- Si se lanza el error -20001 (que es una excepción declarada), la capturamos.
    WHEN E_COMM_MISSING THEN
        RAISE; -- Relanzamos el error -20001 para que el test lo capture.
    
    -- Los errores NO_DATA_FOUND (-1403) se propagarán automáticamente
    -- porque no están manejados directamente aquí.
END award_bonus;
/
