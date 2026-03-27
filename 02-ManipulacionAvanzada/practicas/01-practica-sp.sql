-- crear una base de datos llamada BDPTRACTICAS

--Crear el diagrama utilizando como base los datos de northwind en las tablas de catalogo

--catproducto: id_producto INT IDENTITY PK, nombre_producto,existencia,precio. En base a la tabla Northwind.dbo.product

--catCliente: id_cliente NCHAR(5), nombre_cliente_pais,ciudad. En base a la tabla Northwind.dbo.customers

--TBL VENTA: id_venta, fecha, id_cliente, id_cliente FK

--TBLdetalleVenta: id_venta, id_producto, precio_venta,, cantidad_vendida

--3 CREAR UN SP LLAMADO USP_AGREGAR_VENTA 
    --VA A INSEERTAR EN LA TABLA tblVenta, DEBE MANEJAR TRY CATCH Y TRANSACTION
    --LA FECHA DEBE SER LA FECHA ACTUAL(GETDATE())
    --VERIFICAR SI EL CLIENTE EXISTE, SI NO EXISTE EL STORED ACABA

    --DETALLE DE VENTA
    --INSERTAR EN LA TABLA tblDetalleVenta   MESSAGE_ERROR
    --VERIFICAR SI EL CLIENTE EXISTE, SI NO EXISTE TERMINA
    --OBTENER DE LA TABLA catProducto EL PRECIO DEL PRODUCTO  MESSAGE_ERROR
    --CANTIDAD VENDIDA SEA SUFICIENTE EN LA EXISTENCIA DE LA TABLA catProducto MESSAGE_ERROR


    --ACTUALIUZAR EL STOCK O LA EXISTENCIA EN LA TABLA catProducto MEDIANTE LA OPERACIÓN existencia-cantidadVendida

    --DOCUMENTAR TODO EL PROCEDIMIENTO EN MD

    --CREAR UN COMMIT LLAMADO: PRACTICA VENTA CON STORE PROCEDURE

    --HACER MERGE A MAIN


USE Northwind
GO

SELECT *
FROM Products

CREATE DATABASE bdpracticas;
GO

USE bdpracticas 
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

CREATE TABLE catCliente
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
FROM catCliente

CREATE TABLE tblVenta (
    id_venta INT PRIMARY KEY IDENTITY,
    fecha DATE,
    id_cliente NCHAR(5)

    CONSTRAINT fk_id_cliente
    FOREIGN KEY (id_cliente)
    REFERENCES catCliente (id_cliente)
);

SELECT *
FROM tblVenta

CREATE TABLE tblDetalleVenta
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

CREATE OR ALTER PROC usp_agregar_venta
@id_cliente NCHAR(5),
@nombre_producto NVARCHAR(40),
@cantidad_vendida INT
AS
BEGIN 
    BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 
        FROM catCliente
         WHERE id_cliente = @id_cliente)
    BEGIN 
        PRINT 'EL CLIENTE NO EXISTE'
        RETURN;
    END
    ELSE
        BEGIN
        INSERT INTO tblVenta (id_cliente, fecha)
        VALUES (@id_cliente,GETDATE());
        END
        PRINT 'VENTA REGISTRADA EXITOSAMENTE'
        INSERT INTO tblDetalleVenta
        VALUES (@id_cliente,GETDATE());

        IF NOT EXISTS (SELECT 1
        FROM catProducto
        WHERE nombre_producto = @nombre_producto)
        BEGIN
        PRINT 'EL PRODUCTO NO EXISTE'
        RETURN;
        END
    ELSE 
    SELECT precio
    FROM catProducto
    WHERE nombre_producto = @nombre_producto

    
        IF EXISTS (SELECT 1 FROM catProducto WHERE existencia < @cantidad_vendida)
        BEGIN
            PRINT 'NO HAY EXISTENCIA SUFICIENTE'
            ROLLBACK;
            RETURN;
            END
         ELSE
         BEGIN
         SELECT (existencia - @cantidad_vendida) AS [EXISTENCIA ACTUALIZADA]
         FROM catProducto
         END

    END TRY
    BEGIN CATCH
        ROLLBACK;
        PRINT 'OCURRIO UN ERROR EN EL PROCESO'
        PRINT ERROR_MESSAGE();
    END CATCH



    



END
GO

CREATE OR ALTER PROC usp_agregar_venta2
@id_cliente NCHAR(5),
@nombre_producto NVARCHAR(40),
@cantidad_vendida INT

AS
BEGIN
      BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 
        FROM catCliente
         WHERE id_cliente = @id_cliente)
    BEGIN 
        PRINT 'EL CLIENTE NO EXISTE'
        ROLLBACK;
        RETURN;
    END
    ELSE
        BEGIN
        INSERT INTO tblVenta (id_cliente, fecha)
        VALUES (@id_cliente,GETDATE());
        PRINT 'VENTA REGISTRADA EXITOSAMENTE'
        DECLARE @id_venta INT
        INSERT INTO tblDetalleVenta
        VALUES (@id_venta, @id_producto, @precio_venta)
        END
        COMMIT;
           
    IF NOT EXISTS (SELECT 1 FROM catProducto WHERE nombre_producto = @nombre_producto)
         BEGIN
             PRINT 'EL PRODUCTO NO EXISTE'
             ROLLBACK;
             RETURN;
         END
    ELSE
        BEGIN
        DECLARE @precio MONEY
        SELECT @precio = precio
        FROM catProducto
        WHERE nombre_producto = @nombre_producto
        END
        COMMIT;

    IF(SELECT existencia FROM catProducto WHERE nombre_producto = @nombre_producto) < @cantidad_vendida
        BEGIN
            PRINT 'NO HAY EXISTENCIA SUFICIENTE DEL PRODUCTO: ' + @nombre_producto
            ROLLBACK;
            RETURN;
        END
    ELSE
        BEGIN 
            SELECT (existencia - @cantidad_vendida) AS [EXISTENCIA ACTUALIZADA]
            FROM catProducto
        END
        COMMIT;

    END TRY
     BEGIN CATCH
        ROLLBACK;
        PRINT 'OCURRIO UN ERROR EN EL PROCESO'
        PRINT ERROR_MESSAGE();
    END CATCH
END
GO

----------------------------------------------------

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

    DECLARE @id_venta INT = SCOPE_IDENTITY()

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
    @nombre_producto = 'weeer',
    @cantidad_vendida = 1;

SELECT *
FROM tblDetalleVenta

SELECT *
FROM tblVenta

SELECT *
FROM catCliente

SELECT *
FROM catProducto