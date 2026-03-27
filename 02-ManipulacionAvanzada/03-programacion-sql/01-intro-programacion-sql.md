# Lenguaje Transact-SQL (MSServer)

## 😷 Fundamentos Programables

1. ¿Qué es la parte programable de T-SQL?

Es todo lo que permite:

- Usar variables
- Controlar el flujo (if/else, while)
- Crear Procedimientos Almacenados (Stored Procedures)
- Disparadores (Triggers)
- Manejar errores
- Crear Funciones
- Usar Transacciones

Es convertir SQL en un lenguaje casi C/Java pero dentro del motor de base de datos

2. Variables 🪄

📌 Una variable almacena un valor temporal

```sql
/* ======================================= Variables en Transact-SQL ==================================*/
DECLARE @edad INT;
SET @edad = 21;

PRINT @edad;
SELECT @edad AS [EDAD];

DECLARE @nombre AS VARCHAR(30) = 'San Gallardo';
SELECT @nombre AS [Nombre];
SET @nombre = 'San Adonai';
SELECT @nombre AS [Nombre];

/* ======================================= Ejercicios ==================================*/

/*
 Ejercicio 1.

 - Declarar una variable @Precio
 - Asignen el valor 150
 - Calcular el IVA (16)
 - Mostrar el total

*/

DECLARE @Precio MONEY = 150;
DECLARE @Iva DECIMAL(10,2);
DECLARE @Total MONEY;

SET @Iva = @Precio * 0.16;
SET @Total = @Precio + @Iva;

SELECT 
    @Precio AS [PRECIO],
    CONCAT('$',@Iva) AS [IVA(16%)], 
    CONCAT('$',@Total) AS [TOTAL]
```
3️⃣ IF/ELSE

📌 Definición 

Permite ejecutar cógido según condición

```SQL
/* ======================================= IF/ELSE ==================================*/

DECLARE @edad INT;
SET @edad = 18;

IF @edad >= 18
    PRINT 'Eres mayor de edad';
ELSE
    PRINT 'Eres menor de edad';
GO    


DECLARE @calif DECIMAL(10,2) = 9.5; 

IF @calif >= 0.0 AND @calif <= 10.0 
     IF @calif >= 7.0
        PRINT ('APROBADO') 
     ELSE
        PRINT ('REPROBADO') 
ELSE
   SELECT CONCAT(@calif, 'Esta fuera de Rango') AS [RESPUESTA]
```

4️⃣ WHILE (CICLOS)

```sql
/* ======================================= WHILE ==================================*/

DECLARE @limite int = 5;
DECLARE @i int = 1;

WHILE (@i<=@limite)
BEGIN
    PRINT CONCAT('Número: ', @i)
    SET @i = @i + 1
END
``` 