-- ***************************************
-- ESPECIFICACIÓN DEL PAQUETE (Package Specification)
-- Define la interfaz pública del paquete.
-- ***************************************
CREATE OR REPLACE PACKAGE CALCULADORA_PKG AS
  FUNCTION SUMAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER;
  FUNCTION RESTAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER;
  FUNCTION MULTIPLICAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER;
  FUNCTION DIVIDIR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER;
  -- Excepción para manejo de la división por cero
  E_DIVISION_POR_CERO EXCEPTION;
  PRAGMA EXCEPTION_INIT(E_DIVISION_POR_CERO, -20001);
END CALCULADORA_PKG;
/
-- ***************************************
-- CUERPO DEL PAQUETE (Package Body)
-- Contiene la lógica interna de cada función.
-- ***************************************
CREATE OR REPLACE PACKAGE BODY CALCULADORA_PKG AS
  -- Implementación del Desarrollador A
  FUNCTION SUMAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER
  IS
  BEGIN
    RETURN p_num1 + p_num2;
  END SUMAR;
  -- Implementación del Desarrollador A
  FUNCTION RESTAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER
  IS
  BEGIN
    RETURN p_num1 - p_num2;
  END RESTAR;
  -- Implementación del Desarrollador B
  FUNCTION MULTIPLICAR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER
  IS
  BEGIN
    RETURN p_num1 * p_num2;
  END MULTIPLICAR;
  -- Implementación del Desarrollador B
  FUNCTION DIVIDIR (p_num1 IN NUMBER, p_num2 IN NUMBER)
    RETURN NUMBER
  IS
  BEGIN
    IF p_num2 = 0 THEN
      -- Lanzar la excepción definida en la especificación
      RAISE E_DIVISION_POR_CERO;
    END IF;
    RETURN p_num1 / p_num2;
  END DIVIDIR;
END CALCULADORA_PKG;
/
