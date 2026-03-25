/*DECLARE @RC int

-- TODO: Set parameter values here.

EXECUTE @RC = [dbo].[usp_servidor_fechaActual] 
GO
*/
CREATE OR ALTER PROC usp_persona_saludar
    @nombre VARCHAR(50) --PARAMETRO DE ENTRADA
AS
BEGIN
    PRINT 'HOLA ' + @nombre;
END
GO

EXEC usp_persona_saludar 'ISRAEL'
EXEC usp_persona_saludar 'ARTEMIO'
EXEC usp_persona_saludar 'IRAIS'
EXEC usp_persona_saludar @nombre ='ISRAEL'

DECLARE @name VARCHAR(50);
SET @name = 'Yael';

EXEC usp_persona_saludar @name

--TODO: EJEMPLO CON CONSULTAS, CREAR UNA TABLA DE CLIENTES BASADA EN LA TABLA DE 
--CUSTOMERS DE NORTHWIND
