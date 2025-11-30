CREATE OR REPLACE PACKAGE TEST_AWARD_BONUS IS
  
  --%suite(Pruebas para el Procedimiento award_bonus)
  --%suitepath(todos_los_tests)
  
  -- Procedimiento de preparación que se llama antes de cada prueba
  PROCEDURE setup_data;
  
  --%test(Verifica que el salario se actualiza correctamente cuando hay comision)
  PROCEDURE test_successful_bonus;

  --%test(Verifica que se lanza la excepcion COMM_MISSING para comision NULL)
  PROCEDURE test_null_commission_raises_exception;

  --%test(Verifica la excepcion NO_DATA_FOUND para un ID inexistente)
  PROCEDURE test_employee_not_found;

END TEST_AWARD_BONUS;
/
CREATE OR REPLACE PACKAGE BODY TEST_AWARD_BONUS IS
  
  -- Constantes (usaremos los mismos IDs de HR.employees)
  C_COMMISSION_EMP_ID CONSTANT NUMBER := 158;    -- Empleado con una comisión de 0.1
  C_NULL_COMM_EMP_ID  CONSTANT NUMBER := 178;    -- Empleado sin comisión asignada
  C_NON_EXISTENT_ID   CONSTANT NUMBER := 999999; -- No existe este empleado
  C_SALES_AMOUNT      CONSTANT NUMBER := 5000;
  
  -- Códigos de error de Oracle
  C_COMM_MISSING_CODE CONSTANT NUMBER := -20001; 
  C_NO_DATA_FOUND_CODE CONSTANT NUMBER := -1403; 
  
  ----------------------------------------------------------------------
  -- CONFIGURACIÓN: setup_data
  ----------------------------------------------------------------------
  PROCEDURE setup_data IS
  BEGIN
    UPDATE employees 
    SET salary = 10500, commission_pct = 0.10 
    WHERE employee_id = C_COMMISSION_EMP_ID;
    
    UPDATE employees 
    SET salary = 7000, commission_pct = NULL 
    WHERE employee_id = C_NULL_COMM_EMP_ID;
    
    COMMIT;
  END setup_data;

  ----------------------------------------------------------------------
  -- 1. PRUEBA: Caso de éxito
  ----------------------------------------------------------------------
  PROCEDURE test_successful_bonus IS
    l_initial_salary employees.salary%TYPE;
    l_commission employees.commission_pct%TYPE;
    l_expected_salary employees.salary%TYPE;
    l_actual_salary employees.salary%TYPE;
  BEGIN
    setup_data; 
    SELECT salary, commission_pct INTO l_initial_salary, l_commission 
    FROM employees WHERE employee_id = C_COMMISSION_EMP_ID;

    l_expected_salary := l_initial_salary + (C_SALES_AMOUNT * l_commission);

    award_bonus(emp_id => C_COMMISSION_EMP_ID, sales_amt => C_SALES_AMOUNT);

    SELECT salary INTO l_actual_salary FROM employees WHERE employee_id = C_COMMISSION_EMP_ID;
    ut.expect(l_actual_salary, 'El salario no se actualizo correctamente.').to_equal(l_expected_salary);
    ROLLBACK;
  END test_successful_bonus;
  
  ----------------------------------------------------------------------

  -- 2. PRUEBA: Caso de excepción (-20001)
  ----------------------------------------------------------------------
  PROCEDURE test_null_commission_raises_exception IS
    l_exception_caught BOOLEAN := FALSE;
  BEGIN
    setup_data; 
    
    BEGIN
        award_bonus(emp_id => C_NULL_COMM_EMP_ID, sales_amt => C_SALES_AMOUNT);
        l_exception_caught := FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = C_COMM_MISSING_CODE THEN 
                l_exception_caught := TRUE;
            ELSE
                l_exception_caught := FALSE;
            END IF;
    END;
    
    ut.expect(l_exception_caught, 'Se esperaba el error -20001. SQLCODE actual: ' || SQLCODE).to_be_true();
    ROLLBACK;
  END test_null_commission_raises_exception;
  
  ----------------------------------------------------------------------
  
  -- 3. PRUEBA: Caso de Borde (NO_DATA_FOUND, Error -1403)
  ----------------------------------------------------------------------
-- 3. PRUEBA: Caso de Borde (NO_DATA_FOUND, Error -1403)
  ----------------------------------------------------------------------
  PROCEDURE test_employee_not_found IS
    l_exception_caught BOOLEAN := FALSE;
    C_SQLCODE_NOT_FOUND CONSTANT NUMBER := 100; -- Valor retornado internamente a veces por Oracle
BEGIN
    
    BEGIN
        award_bonus(emp_id => C_NON_EXISTENT_ID, sales_amt => C_SALES_AMOUNT);
        l_exception_caught := FALSE;
    EXCEPTION
        WHEN OTHERS THEN
            -- Capturamos el error si es -1403 (NO_DATA_FOUND ORA) O +100 (NO_DATA_FOUND SQLCODE)
            IF SQLCODE = C_NO_DATA_FOUND_CODE OR SQLCODE = C_SQLCODE_NOT_FOUND THEN 
                l_exception_caught := TRUE;
            ELSE
                l_exception_caught := FALSE;
            END IF;
    END;
    
    ut.expect(l_exception_caught, 'Se esperaba NO_DATA_FOUND (-1403 o +100). SQLCODE actual: ' || SQLCODE).to_be_true();
END test_employee_not_found;

END TEST_AWARD_BONUS;
/
