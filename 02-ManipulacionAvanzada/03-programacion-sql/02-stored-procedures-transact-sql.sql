/*=============================== Stored Procedures ===============================*/

CREATE DATABASE bdstored;
GO

USE bdstored;
GO


-- Ejemplo Simple 

CREATE PROCEDURE usp_Mensaje_Saludar
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo Transact SQL desde SQL SERVER';
END;
GO

-- Ejecutar
EXECUTE usp_Mensaje_Saludar;
GO

CREATE PROC usp_Mensaje_Saludar2
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo Ing en TI';
END;
GO

-- EJECUTAR
EXEC usp_Mensaje_Saludar2; 
GO

CREATE OR ALTER PROC usp_Mensaje_Saludar3
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo ENTORNOS VIRTUALES Y NEGOCIOS DIGITALES';
END;
GO

-- ELIMINAR UN SP
DROP PROCEDURE usp_Mensaje_Saludar3;
GO

-- EJECUTAR
EXEC  usp_Mensaje_Saludar3;
GO

-- Crear un SP que muestre la fecha actual del sistema
CREATE OR ALTER PROC usp_Servidor_FechaActual

AS 
BEGIN
    SELECT CAST(GETDATE () AS DATE) AS [ FECHA DEL SISTEMA]
END;
GO

-- EJECUTARLO

EXEC usp_Servidor_FechaActual;
GO
-- CREAR UN SP QUE MUESTRE EL NOMBRE DE LA BASE DE DATOS (DB_NAME())

CREATE OR ALTER PROC spu_Dbname_get 
AS
BEGIN
    SELECT 
        HOST_NAME() AS [MACHINE],
        SUSER_SNAME() AS [SQLUSER],
        SYSTEM_USER AS [SYSTEMUSER],
        DB_NAME() AS [DATABASE NAME],
        APP_NAME() AS [APPLICATION];
END;
GO

-- EJECUTAR
EXEC spu_Dbname_get;
GO 

/*=================================== STORED PROCEDURES CON PARAMETROS =========================*/

CREATE OR ALTER PROC usp_persona_saludar
   @nombre VARCHAR(50) -- PARAMETRO DE ENTRADA
AS
BEGIN
    PRINT CONCAT('Hola',' ', @nombre);
END;
GO

EXEC usp_persona_saludar 'Israel';
EXEC usp_persona_saludar 'Artemio';
EXEC usp_persona_saludar 'Irais';
EXEC usp_persona_saludar @Nombre ='Bryan';

DECLARE @name VARCHAR(50);
SET @name = 'Yael';

EXEC usp_persona_saludar @name

/*TODO: Ejemplo con consultas, vamos a crear una tabla de clientes basada en la tabla de customers
de Northwind*/

SELECT CustomerID, CompanyName
INTO Customers
FROM NORTHWND.dbo.Customers;
GO
-- Crear un SP que busque un cliente en especifico
CREATE OR ALTER PROC spu_Customer_buscar
@id NCHAR(10)
AS 
BEGIN 

    SET @id = TRIM(@id);

    IF LEN(@id)<=0 OR LEN(@id)>5
    BEGIN
        PRINT('El ID DEBE ESTAR EN EL RANGO DE 1 A 5 DE TAMAÑO');
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM Customers WHERE CustomerID = @id)
    BEGIN
      SELECT CustomerID AS [NÚMERO], CompanyName AS [Cliente]
      FROM Customers
      WHERE CustomerID = @id;
    END
    ELSE
       PRINT 'EL CLIENTE NO EXISTE EN LA BD'

END;
GO

SELECT * 
FROM Customers
WHERE CustomerID = '';

-- ejecutar
EXEC spu_Customer_buscar 'YUTTT ';



SELECT 1
WHERE EXISTS(
SELECT 1
FROM Customers 
WHERE CustomerID = 'ANTONi');

-- Ejercicios: crear un SP que reciba un número y que verifique que no sea negativo, 
-- si es negativo imprimir valor no valido, y sino multiplicarlo por cinco y mostrarlo 
-- para mostrar usar un select

-- Ejercicio 2: Crear un sp que reciba un nombre y lo imprima en mayusculas


-- TODO: PARAMETROS DE SALIDA