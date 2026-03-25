# Stored procedures (procedimientos almacenados) en Transact-SQL (SQL SERVER)

1. Fundamentos

- ¿Qué es un  stored procedure?

Un **stored procedure (SP)** es un bloque de código SQL guardado dentro de la base de datos que puede ejecutarse cuando se necesite; es decir, es un **OBJETO DE LA BASE DE DATOS**

Es algo similar a un afunción o método en programación

Ventajas 

1. Reutilizar el código 
2. Mejor rendimiento
3. Mayor seguridad
4. Centralización de lógica de negocio
5. menos trafico entre aplicación y servidor

- Sintaxis 

![SintaxisSQL](../../img/sp_sintaxis.png)

-nomenclatura recomendada

```
spu><Entidad>_<Accion>
```
| Parte   | Significado                     | Ejemplo |
|--------|---------------------------------|--------|
| spu    | Stored Procedure User           | spu_   |
| Entidad| Tabla o concepto del negocio    | Cliente|
| Acción | Lo que hace                     | Insert |

- Acciones Estandar
Estas son las **acciones más usadas** en sistemas empresariales

| Acción     | Significado          | Ejemplo                |
| ---------- | -------------------- | ---------------------- |
| Insert     | Insertar registro    | spu_Cliente_Insert     |
| Update     | Actualizar           | spu_Cliente_Update     |
| Delete     | Eliminar             | spu_Cliente_Delete     |
| Get        | Obtener uno          | spu_Cliente_Get        |
| List       | Obtener varios       | spu_Cliente_List       |
| Search     | Búsqueda con filtros | spu_Cliente_Search     |
| Exists     | Validar si existe    | spu_Cliente_Exists     |
| Activate   | Activar registro     | spu_Cliente_Activate   |
| Deactivate | Desactivar           | spu_Cliente_Deactivate |

- EJEMPLO COMPLETO 

Suponer que tenemos una tabla cliente

Inserta cliente

```
spu_cliente_insert
```
Actualizar cliente

```
spu_cliente_update
```
obtener cliente

```
spu_cliente_get
```
Listar todos los clientes

```
spu_cliente_List
```
Listar todos los cleintes

```
spu_cliente_search
```

```sql
CREATE PROCEDURE nombre
[
    @paremetro1 tipodeDato
    @parametro2 TipodeDato
]

AS
BEGIN
 --INSTUCCIONES SQL
 END
 ```
```sql
CREATE DATABASE bdstored;
GO

USE bdstored;
GO
--EJEMPLO SIMPLE

CREATE PROCEDURE ups_Mensaje_Saludar1
    --No tendrá parametros
AS
BEGIN
    PRINT 'Hola mundo Transcact  SQL desde SQL SERVER'
END
GO

--Ejecutar

EXECUTE ups_Mensaje_Saludar
GO

CREATE PROC ups_Mensaje_Saludar2
    --No tendrá parametros
AS
BEGIN
    PRINT 'Hola mundo Ingenieria en tecnologias de la información'
END
GO

EXEC ups_Mensaje_Saludar2
GO

CREATE OR ALTER PROCEDURE ups_Mensaje_Saludar3
    --No tendrá parametros
AS
BEGIN
    PRINT 'Hola hola jeje mundo Entornos viruales y negocios digitales'
END
GO

EXEC ups_Mensaje_Saludar3

DROP PROC ups_Mensaje_Saludar3
GO

--CREAR UN SP QUE MUESTRE LA FECHA ACTUAL DEL SISTEMA

CREATE OR ALTER PROC usp_servidor_fechaActual

AS
BEGIN
    SELECT CAST (GETDATE() AS DATE) AS [FECHA DEL SISTEMA]
END;
GO

EXEC usp_servidor_fechaActual
GO
--CREAR UN SP QUE MUESTRE EL NOMBRE  DEL LA BD UTILIZANDO LA FUNCION (DB_NAME())

CREATE OR ALTER PROC usp_Nombre_bd

AS
BEGIN
    SELECT 
    SUSER_SNAME() AS [SQLUSER],
    SYSTEM_USER AS [SYSTEM USER],
    HOST_NAME() AS [NOMBRE DEL EQUIPO],
    DB_NAME() AS [NOMBRE DE LA BD],
    APP_NAME() AS [APPLICATION]
END;
GO

EXEC usp_Nombre_bd

```
2. Parametros en los stored procedures

Los parametros permiten enviar datos al procedimiento

```sql

CREATE OR ALTER PROC spu_Customer_buscar
@id NCHAR(10)
AS 
BEGIN
SET @id = TRIM(@id)
IF EXISTS (SELECT 1 FROM Customers WHERE CustomerID = 'ANTON')
    BEGIN   
    SELECT CustomerID AS [Numero], CompanyName AS [Cliente]
    FROM Customers
    WHERE CustomerID= @id;
    END
    ELSE
        PRINT 'El cliente no existe en la BD'
END;
GO

 SELECT 1
 FROM Northwind.dbo.Customers
 WHERE  NOT EXISTS (
SELECT 1
 FROM customers
 WHERE CustomerID = 'ANTONI'
 )
 --EJECUTAR

 EXEC spu_customer_buscar 'ANTON'
 GO

 --EJERCICIOS: CREAR UN SP QUE RECIBA UN NUMERO Y QUE VERIFIQUE QUE NO SEA NEGATIVO, SI ES NEGATIVO
 --IMPRIMR VALOR NO VALIDO, Y SI NO MULTIPLICARLO POR 5 Y MOSTRARLO
 --PARA MOSTRARLO USAR UN SELECT

 --EJERCICIO 2: CREAR UN SP QUE REVIBA UN NOMBRE Y LO IMPRIMA EN MAYUSCULAS

 --TODO: PAFRAMETROS DE SALIDA

 CREATE OR ALTER PROC  usp_numero_multiplicar
 @number INT
 AS 
 BEGIN
    IF @number<=0
    BEGIN
    PRINT 'EL NUMERO NO PUEDE SER NEGATIVO NI 0'
    RETURN;
    END
    SELECT (@number * 5) AS [OPERACIÓN]
 END;
GO

EXEC usp_numero_multiplicar -5;
GO

CREATE OR ALTER PROC usp_nombre_mayusculas
@name VARCHAR(15)
AS 
BEGIN
    SELECT UPPER(@name) AS [NOMBRE]
END;

EXEC usp_nombre_mayusculas carlos;
```

3. Paramentros de salida

los paramentros output devuelven valores al usuario

```sql
CREATE OR ALTER PROC spu_numeros_sumar
@a INT,
@b INT,
@resultado INT OUTPUT
AS 
BEGIN
    SET @resultado = @a + @b
END;
GO

DECLARE @res INT 
EXEC spu_numeros_sumar 4, 7, @res OUTPUT;
SELECT @res AS [resultado]
GO

CREATE OR ALTER PROC spu_numeros_sumar2
@a INT,
@b INT,
@resultado INT OUTPUT
AS 
BEGIN
    SELECT @resultado = @a + @b
END;
GO

DECLARE @res INT 
EXEC spu_numeros_sumar2 4, 7, @res OUTPUT;
SELECT @res AS [resultado]
GO
--CREAR UN SP QUE DEVUELVA EL AREA DE UN CIRCULO

CREATE OR ALTER PROC ups_area_circulo
@radio DECIMAL(10,2),
@area DECIMAL(10,2) OUTPUT
AS 
BEGIN
     --SET @area = PI(@radio * @radio)
     SET @area = PI() * POWER(@radio,2)
END;
GO

DECLARE @r DECIMAL(10,2);
EXEC ups_area_circulo 2.4, @r OUTPUT;
SELECT @r AS [AREA DEL  CIRCULO]
GO


CREATE OR ALTER PROC spu_cliente_obtener
@id NCHAR(10),
@name NVARCHAR(40)  OUTPUT
AS
BEGIN
    IF LEN(@id) = 5
    BEGIN
       IF EXISTS(SELECT 1 FROM customers WHERE CustomerID = @id)
       BEGIN
       SELECT @name = CompanyName
       FROM customers
       WHERE CustomerID = @id
       RETURN;
    END
      PRINT 'EL CUSTOMER NO EXISTE'
      RETURN;
    END
    PRINT 'WL ID DEBE DE SER DE TAMAÑO 5'
END;
GO

DECLARE @name NVARCHAR(40)
EXEC spu_cliente_obtener 'ANTON', @name OUTPUT
SELECT @name AS [NOMBRE DEL CLIENTE];

```
4. CASE

SIRVE PARA EVALUAR CONDICIONES COMO UN SWITCH O IF MUTIPLE

