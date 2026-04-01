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
GO

EXEC usp_nombre_mayusculas 'Monico';
GO
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

SELECT * FROM Customers;


DECLARE @name VARCHAR(40) 
EXEC spu_cliente_obtener 'AROUX', @name OUTPUT
SELECT @name AS [NOMBRE DEL CLIENTE];
GO
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

  /*CREATE DATABASE bd_final_boss;
USE bd_final_boss;*/

CREATE TABLE Productos(
Id_Producto INT PRIMARY KEY,
Nombre NVARCHAR(50),
Precio MONEY,
Stock INT);

CREATE TABLE Clientes(
Id_Cliente NVARCHAR(5) PRIMARY KEY,
Nombre NVARCHAR (30)
);

CREATE TABLE Compras(
Id_Compra INT IDENTITY PRIMARY KEY,
Fecha DATE,
Id_Cliente NVARCHAR(5),
FOREIGN KEY (Id_Cliente) REFERENCES Clientes(Id_Cliente)
);

CREATE TABLE DetalleCompra(
Id_Compra INT,
Id_Producto INT,
Cantidad INT,
Precio_Compra MONEY,
FOREIGN KEY (Id_Compra) REFERENCES Compras(Id_Compra),
FOREIGN KEY (Id_Producto) REFERENCES Productos(Id_Producto)
);

INSERT INTO Productos(Id_Producto, Nombre, Precio, Stock)
SELECT ProductID,ProductName, UnitPrice, UnitsInStock FROM NORTHWND.dbo.Products

INSERT INTO Clientes(Id_Cliente, Nombre)
SELECT CustomerID, ContactName FROM NORTHWND.dbo.Customers
GO

CREATE OR ALTER PROC usp_realizar_compra
@IdCliente NVARCHAR(5),
@IdProducto INT,
@Cantidad INT
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
            DECLARE @PrecioProducto MONEY;
            DECLARE @Existencia INT;
            DECLARE @IdCompra INT;

            --Validar cantidad
            IF @Cantidad <= 0
            BEGIN
            ;THROW 50004, 'Cantidad no válida', 1;
            END;

			--validar cliente
			IF NOT EXISTS (
            SELECT 1 FROM Clientes
            WHERE Id_Cliente = @IdCliente
            )
			BEGIN
            ;THROW 50001, 'El cliente no existe', 1;
			END;

			--Validar Producto
			IF NOT EXISTS (
            SELECT 1 FROM Productos
            WHERE Id_Producto = @IdProducto
            )
			BEGIN
            ;THROW 50002, 'El producto no existe', 1;
			END;

			--Validar existencias
			SELECT 
            @PrecioProducto = Precio,
            @Existencia = Stock
            FROM Productos
            WHERE Id_Producto = @IdProducto;

            IF @Existencia < @Cantidad
            BEGIN
            ;THROW 50003, 'Stock insuficiente', 1;
            END;

            --Insertar datos en el sistema
            INSERT INTO Compras (Fecha, Id_Cliente)
            VALUES (GETDATE(), @IdCliente);

            SET @IdCompra = SCOPE_IDENTITY();

            --Insertar datos en el recibo
            INSERT INTO DetalleCompra(Id_Compra, Id_Producto, Cantidad, Precio_Compra)
            VALUES (@IdCompra, @IdProducto, @Cantidad, @PrecioProducto);

            --Actualizar Stock
            UPDATE Productos
            SET Stock = Stock - @Cantidad
            WHERE Id_Producto = @IdProducto;

        COMMIT;
        PRINT 'Se realizo la venta';
	END TRY
	BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK;
        PRINT 'Error en la venta';
        PRINT ERROR_MESSAGE();
        PRINT 'Linea: ' + CAST(ERROR_LINE() AS VARCHAR);
	END CATCH
END;

EXEC usp_realizar_compra
@IdCliente = 'ALFKI',
@IdProducto = 1,
@Cantidad = 15

SELECT *
FROM Clientes

SELECT *
FROM Productos

SELECT *
FROM DetalleCompra

SELECT *
FROM Compras
GO

CREATE OR ALTER PROC usp_calcular_total_compra
@IdCompra INT,
@Total MONEY OUTPUT
AS
BEGIN
    SELECT 
        @Total = SUM(Cantidad * Precio_Compra)
    FROM DetalleCompra
    WHERE Id_Compra = @IdCompra;
END;

DECLARE @resultado MONEY;
EXEC usp_calcular_total_compra 9, @resultado OUTPUT;
SELECT @resultado AS TotalCompra;
GO

--Proc que indica el valor de la compra de un cliente
CREATE OR ALTER PROC usp_categoria_cliente
@IdCliente NVARCHAR(5)
AS
BEGIN
    DECLARE @Total MONEY;

    SELECT 
        @Total = SUM(dc.Cantidad * dc.Precio_Compra)
    FROM Compras c
    INNER JOIN DetalleCompra dc
        ON c.Id_Compra = dc.Id_Compra
    WHERE c.Id_Cliente = @IdCliente;

    SELECT 
        @Total AS TotalGastado,
        CASE
            WHEN @Total > 5000 THEN 'VIP'
            WHEN @Total BETWEEN 2000 AND 5000 THEN 'Frecuente'
            ELSE 'Normal'
        END AS Categoria;
END;

EXEC usp_categoria_cliente 'ALFKI';
GO


CREATE OR ALTER PROC usp_agregar_venta3
@id_cliente NCHAR(5),
@nombre_producto NVARCHAR(40),
@cantidad_vendida INT

AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM catCliente
        WHERE id_cliente = @id_cliente)
    BEGIN 
        PRINT 'EL CLIENTE NO EXISTE'
        ROLLBACK;
        RETURN;
        END
        

    IF NOT EXISTS (SELECT 1 FROM catProducto WHERE nombre_producto = @nombre_producto)
         BEGIN
             PRINT 'EL PRODUCTO NO EXISTE'
             ROLLBACK;
             RETURN;
             
         END
    IF (SELECT existencia FROM catProducto WHERE nombre_producto = @nombre_producto) < @cantidad_vendida
        BEGIN
            PRINT 'NO HAY EXISTENCIA SUFICIENTE DEL PRODUCTO: ' + @nombre_producto
            ROLLBACK;
            RETURN;
        END
    
    DECLARE @precio MONEY
        SELECT @precio = precio
        FROM catProducto
        WHERE nombre_producto = @nombre_producto

    
    INSERT INTO tblVenta
    VALUES(GETDATE(),@id_cliente)

    DECLARE @id_venta INT = SCOPE_IDENTITY();

    DECLARE @id_producto INT
    SELECT @id_producto = id_producto
    FROM catproducto
    WHERE nombre_producto = @nombre_producto

    INSERT INTO tblDetalleVenta (id_venta,id_producto,precio_venta,cantidad_vendida)
    VALUES(@id_venta, @id_producto, @precio,@cantidad_vendida)

    
    
    UPDATE catProducto
    SET existencia = existencia - @cantidad_vendida
    WHERE id_producto = @id_producto
    COMMIT;
        PRINT 'VENTA REFISTRADA EXITOSAMENTE'

    END TRY
    BEGIN CATCH
          ROLLBACK;
        PRINT 'OCURRIO UN ERROR EN EL PROCESO'
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

EXEC usp_agregar_venta3 
    @id_cliente = 'BERGS',
    @nombre_producto = 'CHANG',
    @cantidad_vendida = 1;


/*=========================================*/

CREATE DATABASE bdpracticas2;
GO

USE bdpracticas2
GO

CREATE TABLE catProducto
(
    id_producto INT IDENTITY,
    nombre_producto NVARCHAR(40) NOT NULL,
    existencia INT,
    precio MONEY
    CONSTRAINT pk_id_producto PRIMARY KEY ( id_producto )
)


INSERT INTO bdpracticas.dbo.catProducto
SELECT ProductName, UnitsInStock, UnitPrice
FROM Northwind.dbo.Products


SELECT *
FROM catProducto

CREATE TABLE catCliente1
(
    id_cliente NCHAR(5) NOT NULL,
    nombre_cliente NVARCHAR (40) NOT NULL,
    pais NVARCHAR (15),
    ciudad NVARCHAR(15)
    CONSTRAINT pk_id_cliente PRIMARY KEY ( id_cliente )
)

INSERT INTO bdpracticas.dbo.catCliente
SELECT CustomerID ,CompanyName, Country, City
FROM Northwind.dbo.Customers

SELECT * 
FROM catCliente1

CREATE TABLE tblVenta1 (
    id_venta INT PRIMARY KEY IDENTITY,
    fecha DATE,
    id_cliente NCHAR(5)

    CONSTRAINT fk_id_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES catCliente (id_cliente)
);

SELECT *
FROM tblVenta

CREATE TABLE tblDetalleVenta1
(
    id_venta INT,
    id_producto INT,
    precio_venta MONEY,
    cantidad_vendida INT

    CONSTRAINT fk_id_venta
    FOREIGN KEY (id_venta)
    REFERENCES tblVenta (id_venta),
    
    CONSTRAINT fk_id_prodiicto
    FOREIGN KEY (id_producto)
    REFERENCES catProducto (id_producto)

)

SELECT *
FROM tblDetalleVenta
GO

----------------------------------------------------

CREATE OR ALTER PROC usp_agregar_venta3
@id_cliente NCHAR(5),
@nombre_producto NVARCHAR(40),
@cantidad_vendida INT

-- 1. Definir el Tipo de Tabla que solo recibe nombres
CREATE TYPE tipo_nombres_productos AS TABLE (
    nombre_producto NVARCHAR(40)
);
GO

-- 2. Stored Procedure para agregar "n" productos con una cantidad fija
CREATE OR ALTER PROC usp_agregar_venta_n_productos
    @id_cliente NCHAR(5),
    @cantidad INT, -- Cantidad que se aplicará a todos los productos de la tabla
    @tabla_productos tipo_nombres_productos READONLY
AS
BEGIN
    BEGIN TRY
    BEGIN TRANSACTION;
        IF NOT EXISTS (SELECT 1 FROM catCliente
        WHERE id_cliente = @id_cliente)
    BEGIN 
        PRINT 'EL CLIENTE NO EXISTE'
        ROLLBACK;
        RETURN;
        BEGIN TRANSACTION;

        -- Validación: El cliente debe existir
        IF NOT EXISTS (SELECT 1 FROM catCliente WHERE id_cliente = @id_cliente)
        BEGIN 
            PRINT 'EL CLIENTE NO EXISTE';
            ROLLBACK; RETURN;
        END
        

    IF NOT EXISTS (SELECT 1 FROM catProducto WHERE nombre_producto = @nombre_producto)
         BEGIN
             PRINT 'EL PRODUCTO NO EXISTE'
             ROLLBACK;
             RETURN;
             
         END
    IF (SELECT existencia FROM catProducto WHERE nombre_producto = @nombre_producto) < @cantidad_vendida
        -- Validación: Todos los productos de la tabla deben existir en el catálogo
        IF EXISTS (SELECT 1 FROM @tabla_productos tp 
                   LEFT JOIN catProducto cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.id_producto IS NULL)
        BEGIN
            PRINT 'NO HAY EXISTENCIA SUFICIENTE DEL PRODUCTO: ' + @nombre_producto
            ROLLBACK;
            RETURN;
            PRINT 'ERROR: Uno o más productos de la lista no existen en el catálogo.';
            ROLLBACK; RETURN;
        END
    
    DECLARE @precio MONEY
        SELECT @precio = precio
        FROM catProducto
        WHERE nombre_producto = @nombre_producto

    
    INSERT INTO tblVenta
    VALUES(GETDATE(),@id_cliente)
        -- Validación: Stock suficiente para TODOS los productos de la lista
        IF EXISTS (SELECT 1 FROM @tabla_productos tp 
                   JOIN catProducto cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.existencia < @cantidad)
        BEGIN
            PRINT 'ERROR: No hay existencia suficiente para completar todo el pedido.';
            ROLLBACK; RETURN;
        END

    DECLARE @id_venta INT = SCOPE_IDENTITY();
        -- Proceso de Inserción: Cabecera de Venta
        INSERT INTO tblVenta (fecha, id_cliente) 
        VALUES (GETDATE(), @id_cliente);

    DECLARE @id_producto INT
    SELECT @id_producto = id_producto
    FROM catproducto
    WHERE nombre_producto = @nombre_producto
        DECLARE @id_venta INT = SCOPE_IDENTITY();

    INSERT INTO tblDetalleVenta (id_venta,id_producto,precio_venta,cantidad_vendida)
    VALUES(@id_venta, @id_producto, @precio,@cantidad_vendida)
        -- Proceso de Inserción: Detalle de Venta (Buscamos el ID y Precio por nombre)
        INSERT INTO tblDetalleVenta (id_venta, id_producto, precio_venta, cantidad_vendida)
        SELECT @id_venta, cp.id_producto, cp.precio, @cantidad
        FROM @tabla_productos tp
        JOIN catProducto cp ON tp.nombre_producto = cp.nombre_producto;

    
    
    UPDATE catProducto
    SET existencia = existencia - @cantidad_vendida
    WHERE id_producto = @id_producto
    COMMIT;
        PRINT 'VENTA REFISTRADA EXITOSAMENTE'
        -- Proceso de Actualización: Restar existencia de forma masiva
        UPDATE cp
        SET cp.existencia = cp.existencia - @cantidad
        FROM catProducto cp
        JOIN @tabla_productos tp ON cp.nombre_producto = tp.nombre_producto;

        COMMIT;
        PRINT 'VENTA MASIVA REGISTRADA EXITOSAMENTE';

    END TRY
    BEGIN CATCH
          ROLLBACK;
        PRINT 'OCURRIO UN ERROR EN EL PROCESO'
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT 'OCURRIÓ UN ERROR EN EL PROCESO MASIVO';
        PRINT ERROR_MESSAGE();
    END CATCH
END
END;
GO

