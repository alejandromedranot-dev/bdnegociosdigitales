
# Stored Procedures (Procedimientos Almacenados) en Transact-SQL (SQL SERVER)

1️⃣ Fundamentos 

- ¿Qué es un Stored Procedure?

Un **Stored Procedure (SP)** es un bloque de código SQL guardado dentro de la base de datos que puede ejecutarse cuando se necesite. Es decir es un **OBJETO DE LA BD**

Es similar a una función o método en programación.

Ventajas 

1. Reutilizar el código
2. Mejor Rendimiento 
3. Mayor seguridad
4. Centralización de lógica de negocio 
5. Menos tráfico entre aplicación y servidor

- Sintaxis

![SintaxisSQL](../../img/sp_sintaxis.png)

- Nomenclatura Recomendada

```
spu_<Entidad>_<Acción>
```

| Parte   | Significado                     | Ejemplo |
|--------|---------------------------------|--------|
| spu    | Stored Procedure User           | spu_   |
| Entidad| Tabla o concepto del negocio    | Cliente|
| Acción | Lo que hace                     | Insert |

- Acciones Estándar

Estas son las **acciones mas usadas * en sistemas empresariales

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

- Ejemplo completo 

Suponer que tenemos una tabla cliente

🦗 Insertar Cliente

```
spu_Cliente_Insert
```

🦗 Actualizar Cliente

```
spu_Cliente_Update
```
🦗 Obtener Cliente por id

```
spu_Cliente_Get
```
🦗 Listar todos los Cliente

```
spu_Cliente_List
```

🦗 Buscar Cliene

```
spu_Cliente_Search
```

```sql
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
```


2️⃣ Parámetros en Stored Procedures

Los párametros permiten enviar datos al procedimiento

```SQL
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
```
```SQL

/* Ejemplo con consultas, vamos a crear una tabla de clientes basada en la tabla de customers
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
GO
-- Ejercicios: crear un SP que reciba un número y que verifique que no sea negativo, 
-- si es negativo imprimir valor no valido, y sino multiplicarlo por cinco y mostrarlo 
-- para mostrar usar un select

CREATE OR ALTER PROCEDURE usp_numero_multiplicar 
@number INT 
AS
BEGIN
   IF @number<=0
   BEGIN
     PRINT 'El número no puede ser negativo ni cero'
     RETURN;
   END

   SELECT (@number * 5) AS [OPERACIÓN]
END;
GO

EXEC usp_numero_multiplicar -34;
EXEC usp_numero_multiplicar 0;
EXEC usp_numero_multiplicar 5;
GO

-- Ejercicio 2: Crear un sp que reciba un nombre y lo imprima en mayusculas
CREATE OR ALTER PROC usp_nombre_mayusculas 
@name VARCHAR(15)
AS
BEGIN
   SELECT UPPER(@name) AS [NAME]
END;

EXEC usp_nombre_mayusculas 'Monico';
```

3️⃣ Parámetros de Salida

Los Parametros OUTPUT devuelven valores al Usuario

```SQL
/* ======================PARAMETROS DE SALIDA==========================*/

CREATE OR ALTER PROC spu_numeros_sumar
  @a INT, 
  @b INT, 
  @resultado INT OUTPUT
  AS
  BEGIN
     SET @resultado = @a + @b
  END;
GO

DECLARE @res INT;
EXEC spu_numeros_sumar 5,7,@res OUTPUT;
SELECT @res AS [Resultado];
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

DECLARE @res INT;
EXEC spu_numeros_sumar2 5,7,@res OUTPUT;
SELECT @res AS [Resultado];
GO
-- CREAR UN SP QUE DEVUELVA EL AREA DE UN CIRCULO
CREATE OR ALTER PROC usp_area_circulo 
@radio DECIMAL(10,2),
@area DECIMAL(10,2) OUTPUT
AS
BEGIN
    --SET @area = PI() * @radio * @radio;
    SET @area = PI() * POWER(@radio,2);
END;
GO


DECLARE @r DECIMAL(10,2);
EXEC usp_area_circulo 2.4, @r OUTPUT;
SELECT @r AS [area del circulo];
GO

-- crear un sp que reciba un idcliente y devuelva el nombre

CREATE OR ALTER PROC spu_cliente_obtener
  @id NCHAR(10),
  @name NVARCHAR(40) OUTPUT
AS 
BEGIN
  IF LEN(@id) = 5
  BEGIN
    IF EXISTS (SELECT 1 FROM CUSTOMERS WHERE CustomerID = @id)
    BEGIN
        SELECT @name = CompanyName
        FROM Customers
        WHERE CustomerID = @id;

        RETURN;
    END

    PRINT 'EL CUSTOMER NO EXISTE';
    RETURN;
  END

  PRINT 'EL ID DEBE SER DE TAMAÑO 5';
END;
GO
```

4️⃣ CASE 

Sirve para evaluar condiciones como un switch o if múltiple

```sql
/*===========================CASE==============================*/

CREATE OR ALTER PROC spu_Evaluar_Calificacion
@calif INT
AS 
BEGIN
    SELECT 
      CASE 
          WHEN @calif >= 90 THEN 'EXCELENTE'
          WHEN @calif >= 70 THEN 'APROBADO'
          WHEN @calif >= 60 THEN 'REGULAR'
          ELSE 'NO ACREDITO'
      END AS [RESULTADO];
END;


EXEC spu_Evaluar_Calificacion 100;
EXEC spu_Evaluar_Calificacion 75;
EXEC spu_Evaluar_Calificacion 55;
EXEC spu_Evaluar_Calificacion 65;
GO
-- Case dentro de un select caso real
use NORTHWND;

CREATE TABLE bdstored.dbo.Productos
(
  nombre VARCHAR(50), 
  precio money

);

-- Inserta los datos basados en la consulta (Select)
INSERT INTO bdstored.dbo.Productos
SELECT 
  ProductName, UnitPrice 
  FROM NORTHWND.dbo.Products;

-- EJERCICIO CON CASE

SELECT 
  nombre, 
  precio, 
  CASE 
      WHEN precio >= 200 THEN 'Caro' 
      WHEN precio >= 100 THEN 'Medio'
      ELSE 'Barato'
  END AS [Categoria]
FROM bdstored.dbo.Productos;
GO

-- SELECCIONA LOS CLIENTES, CON SU NOMBRE, PAIS, CIUDAD Y REGION (LOS VALORES NULOS, VISUALIZALOS CON LA LEYENDA SIN REGION), ADEMAS QUIERO QUE TODO EL RESULTADO ESTE MAYUSCULA

use NORTHWND;
GO

CREATE OR ALTER view vw_buena
AS
SELECT 
  UPPER(CompanyName) AS [CompanyName], 
  UPPER(c.Country) AS [Country], 
  UPPER(c.City) AS [City], 
  UPPER(ISNULL(c.Region, 'Sin Region')) AS [RegionLimpia], 
  LTRIM(UPPER(CONCAT(e.FirstName, ' ', e.LastName))) AS [FullName],
  ROUND(SUM(od.Quantity * od.UnitPrice), 2) AS [Total],
    CASE 
       WHEN SUM(od.Quantity * od.UnitPrice) >=30000 AND SUM(od.Quantity * od.UnitPrice) <= 60000 THEN 'GOLD'
       WHEN SUM(od.Quantity * od.UnitPrice) >=10000 AND SUM(od.Quantity * od.UnitPrice) < 30000 THEN 'SILVER'
       ELSE 'BRONCE'
    END AS [MEDALLON]   
FROM NORTHWND.dbo.Customers as c
INNER JOIN 
NORTHWND.dbo.Orders AS o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Employees as e
ON e.EmployeeID = o.EmployeeID
GROUP BY c.CompanyName, c.Country, c.City, c.Region,CONCAT(e.FirstName, ' ', e.LastName);
GO

CREATE OR ALTER PROC spu_informe_clientes_empleados
@nombre VARCHAR(50), 
@region VARCHAR(50)
AS
BEGIN
     SELECT * 
        FROM vw_buena
        WHERE FullName = @nombre 
        AND RegionLimpia = @region;  
END;


EXEC spu_informe_clientes_empleados 'andrew Fuller', 'sin region';



SELECT 
  UPPER(CompanyName) AS [CompanyName], 
  UPPER(c.Country) AS [Country], 
  UPPER(c.City) AS [City], 
  UPPER(ISNULL(c.Region, 'Sin Region')) AS [RegionLimpia], 
  LTRIM(UPPER(CONCAT(e.FirstName, ' ', e.LastName))) AS [FullName],
  ROUND(SUM(od.Quantity * od.UnitPrice), 2) AS [Total],
    CASE 
       WHEN SUM(od.Quantity * od.UnitPrice) >=30000 AND SUM(od.Quantity * od.UnitPrice) <= 60000 THEN 'GOLD'
       WHEN SUM(od.Quantity * od.UnitPrice) >=10000 AND SUM(od.Quantity * od.UnitPrice) < 30000 THEN 'SILVER'
       ELSE 'BRONCE'
    END AS [MEDALLON]   
FROM NORTHWND.dbo.Customers as c
INNER JOIN 
NORTHWND.dbo.Orders AS o
ON c.CustomerID = o.CustomerID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
INNER JOIN Employees as e
ON e.EmployeeID = o.EmployeeID
WHERE UPPER(CONCAT(e.FirstName, ' ', e.LastName)) = UPPER('ANDREW FULLER')
AND UPPER(ISNULL(c.Region, 'Sin Region')) = UPPER('Sin Region')
GROUP BY c.CompanyName, c.Country, c.City, c.Region,CONCAT(e.FirstName, ' ', e.LastName)
ORDER BY FULLNAME ASC, [Total] DESC;
```

5️⃣ Try ... Catch 

Manejo de Errores o excepciones en tiempo de ejecución y manejar lo que sucede cuando ocurren.

SINTAXIS

```SQL
  BEGIN TRY
    -- CÓDIGO QUE PUEDE GENERAR UN ERROR
  END TRY
  BEGIN CATCH
    -- CÓDIGO QUE SE EJECUTA SI OCURRE UN ERROR
  END CATCH
```

- ¿ CÓMO FUNCIONA ?

1. SQL ejecuta todo lo que esta dentro del TRY
2. Si ocurre un error:
  - Se detiene la ejecución del TRY
  - Salta automaticamente al CATCH
3. En el CATCH se puede:
  - Mostrar mensajes
  - Registrar Errores 
  - Revertir transacciones

  **OBTENER INFORMACIÓN DEL ERROR**

  Dentro del CATCH, SQL SERVER tiene funciones especiales:

  
  | Función | Descripción |
| :--- | :--- |
| ERROR_MESSAGE() | Mensaje de Error |
| ERROR_NUMBER() | Número de Error |
| ERROR_LINE() | Línea donde ocurrio |
| ERROR_PROCEDURE() | Procedimiento |
| ERROR_SEVERITY() | Nivel de Gravedad |
| ERROR_STATE() | Estado del Error |

```SQL
/*======================================= Manejo de Errores con Try ... Catch ========================================================*/


-- SIN TRY - CATCH
SELECT 10/0;

-- CON TRY .. CATCH

BEGIN TRY
   SELECT 10/0;
END TRY
BEGIN CATCH
  PRINT 'OCURRIÓ UN ERROR';
END CATCH;
GO
-- EJEMPLO DE USO DE FUNCIONES PARA OBTENER INFORMACIÓN DEL ERROR
BEGIN TRY
  SELECT 10/0;
END TRY  
BEGIN CATCH
    PRINT 'Mensaje: ' + ERROR_MESSAGE();
    PRINT 'Número de Error: ' + CAST(ERROR_NUMBER() AS VARCHAR);
    PRINT 'Línea de Error: ' + CAST(ERROR_LINE() AS VARCHAR);
    PRINT 'Estado del Error: ' + CAST(ERROR_STATE() AS VARCHAR);
END CATCH;

CREATE TABLE clientes(
   id INT PRIMARY KEY, 
   nombre VARCHAR(35)
);
GO

INSERT INTO clientes 
VALUES(1,'PANFILO');
GO

BEGIN TRY

  INSERT INTO clientes 
  VALUES(1,'EUSTACIO');

END TRY
BEGIN CATCH
  PRINT 'ERROR AL INSERTAR: ' + ERROR_MESSAGE();
  PRINT 'ERROR EN LA LINEA: ' + CAST(ERROR_LINE() AS VARCHAR);
END CATCH
GO

BEGIN TRANSACTION;

INSERT INTO clientes 
VALUES(2,'AMERICO ANGEL');

SELECT * FROM clientes;

COMMIT;
ROLLBACK;

-- Ejemplo de uso de transacciones junto con el try catch

SELECT * FROM clientes;

BEGIN TRY
  BEGIN TRANSACTION;

  INSERT INTO clientes 
  Values(3, 'VALDERABANO');
  INSERT INTO clientes 
  VALUES (4, 'ROLES ALINA');
  
  COMMIT;

END TRY
BEGIN CATCH
  IF @@TRANCOUNT > 1
  BEGIN
    ROLLBACK;
  END
    PRINT 'Se hizo rollback por error';
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH
GO

-- CREAR UN STORE PROCEDURE QUE INSERTE UN CLIENTE, CON LAS VALIDACIONES 
-- NECESARIAS.

CREATE OR ALTER PROCEDURE usp_insertar_cliente
    @id INT, 
    @nombre VARCHAR(35)
AS
BEGIN
     
      BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO clientes 
        VALUES (@id, @nombre);
        COMMIT;
        PRINT 'CLIENTE INSERTADO';
      END TRY
      BEGIN CATCH
          IF @@TRANCOUNT > 1
            BEGIN
              ROLLBACK;
            END
            PRINT 'ERROR: ' + ERROR_MESSAGE();
      END CATCH 
END;

SELECT * FROM clientes;

UPDATE clientes 
SET nombre = 'AMERICO AZUL'
WHERE id = 10;

IF @@ROWCOUNT < 1
BEGIN
  PRINT @@ROWCOUNT;
  PRINT 'NO EXISTE EL CLIENTE';
END
ELSE
  PRINT 'CLIENTE ACTUALIZADO';



  CREATE TABLE teams 
  (
    id INT NOT NULL IDENTITY PRIMARY KEY, 
    nombre NVARCHAR(15)

  );

  SELECT * FROM teams;

  INSERT INTO teams (nombre)
  VALUES ('CHAFA AZUL');

  -- FORMA DE OBTENER UN IDENTITY INSERTADO FORMA 1
  DECLARE @id_insertado INT
  SET @id_insertado = @@IDENTITY
  PRINT 'ID INSERTADO: ' + CAST(@id_insertado AS VARCHAR);
  SELECT @id_insertado = @@IDENTITY 
  PRINT 'ID INSERTADO FORMA 2: ' + CAST(@id_insertado AS VARCHAR);


 INSERT INTO teams (nombre)
  VALUES ('AGUILAS 🦅');

 -- FORMA DE OBTENER UN IDENTITY INSERTADO FORMA 2
  DECLARE @id_insertado2 INT
  SET @id_insertado2 = SCOPE_IDENTITY();
  PRINT 'ID INSERTADO: ' + CAST(@id_insertado2 AS VARCHAR);
  SELECT @id_insertado2 = SCOPE_IDENTITY(); 
  PRINT 'ID INSERTADO FORMA 2: ' + CAST(@id_insertado2 AS VARCHAR);
```
