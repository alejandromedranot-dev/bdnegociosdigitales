# Lenguaje transact-SQL (Microsoft SQL Server)

## Fundamentos programables

1. ¿Qué es la parte programable de T-SQL?

Es todo lo que permite: 

- Usar variables
- Controlar el flujo (while, if, else)
- Crear procedimientos  almecenados (store procidiums)
- Disparadores (Triggers)
- Manejar errores
- Crear funciones
- Usar transacciones

Es convertir SQL en un lenguaje casi como como C/Java pero dentro del motor de base de datos

2. Variables 

Una variable almacena un valor temporable

```sql
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

```

IF/ELSE

Definición

Permite ejecutar codigo segun condición

```SQL
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
```


4. WHILE (CICLOS)

```sql
DECLARE @limite INT = 5;
 DECLARE @i INT =1;

 WHILE (@i <= @limite)
 BEGIN
    PRINT CONCAT('NUMERO ', @i)
    SET @i = @i +1
END
```

