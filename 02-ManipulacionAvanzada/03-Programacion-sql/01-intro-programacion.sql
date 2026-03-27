/***************************VARIABLES EN T-SQL************/

DECLARE @edad INT;
SET @edad = 21;

PRINT @edad

SELECT @edad AS [EDAD]

DECLARE @nombre AS VARCHAR(30) = 'SAN GALLARDO'
SELECT @nombre AS [NOMBRE];
SET @nombre = 'San Adonai';

SELECT @nombre AS [nombre]

/***************************EJERCICIO************/

/*EJERCICIO 1
-DECLARAR UNA VARIABLE QUE SE LLAME @precio, ASIGNAR EL VALOR: 150
CALCULAR EL IVA AL 16%
MOSTRAR EL TOTAL
*/

DECLARE @precio MONEY;
SET @precio = 150;
SELECT @precio  * 1.16 AS [IVA]
SELECT @precio

DECLARE @precio1 MONEY;
DECLARE @iva DECIMAL(10,2);
DECLARE @total MONEY;

SET @iva = @precio1 * 0.16
SET @total = @precio1 + @iva;

SELECT @precio1 AS [PRECIO], CONCAT(@iva,'%'),@iva AS [IVA(16%)],
@total AS [TOTAL]

DECLARE @edad1 INT = 18;

IF NOT @edad >= 18
PRINT 'ERES MAYOR DE EDAD';
    ELSE
    PRINT 'ERES MENOR DE EDAD';


/*
SI ES MAYOR A 70 ES APROBADO
*/

DECLARE @calificacion DECIMAL(10,2);
SET @calificacion = 9.5;

IF (@calificacion >= 0 AND @calificacion >=10)
BEGIN
    IF @calificacion >= 7.0
    BEGIN
        PRINT ('APROBADO')
    END
    ELSE
    BEGIN
        PRINT ('REPROBADO')
    END
END
ELSE
BEGIN
    SELECT CONCAT(@calificacion, 'ESTR fuera del rango') AS [RESPUESTA]
 END

 /* =======================WHILE======================*/

 DECLARE @limite INT = 5;
 DECLARE @i INT =1;

 WHILE (@i <= @limite)
 BEGIN
    PRINT CONCAT('NUMERO ', @i)
    SET @i = @i +1
END

--EJEMPLO DE USO DE FUNCIOES PARA OBTENER INFORMACIÓN DEL ERROR

BEGIN TRY
    SELECT 10/0;
END TRY
BEGIN CATCH
    PRINT 'MENSAJE DEL ERROR: ' + ERROR_MESSAGE();
    PRINT 'NUMERO DE ERROR: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'LINEA DEL ERROR: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'ESTADO DEL ERROR' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH