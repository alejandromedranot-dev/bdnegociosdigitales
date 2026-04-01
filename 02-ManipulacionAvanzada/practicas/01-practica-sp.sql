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

CREATE TABLE catProducto1
(
    id_producto INT IDENTITY,
    nombre_producto NVARCHAR(40) NOT NULL,
    existencia INT,
    precio MONEY
    CONSTRAINT pk_id_producto PRIMARY KEY ( id_producto )
)
--SELECT *
--FROM catProducto
--ORDER BY 2 ASC

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
FROM catCliente

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

/*=======================SP DE INSERCIÓN DE UNA SOLA VENTA================================*/
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
/*======================================================================*/


/*==========================SP DE INSERCIÓN MULTIPLE================*/


-- 1. Definir el Tipo de Tabla que solo recibe nombres
CREATE TYPE tipo_nombres_productos1 AS TABLE (
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

        -- Validación: El cliente debe existir
        IF NOT EXISTS (SELECT 1 FROM catCliente WHERE id_cliente = @id_cliente)
        BEGIN 
            PRINT 'EL CLIENTE NO EXISTE';
            ROLLBACK; 
            RETURN;
        END

        -- Validación: Todos los productos de la tabla deben existir en el catálogo
        IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   LEFT JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.id_producto IS NULL)
        BEGIN
            PRINT 'ERROR: Uno o más productos de la lista no existen en el catálogo.';
            ROLLBACK; RETURN;
        END

        -- Validación: Stock suficiente para TODOS los productos de la lista
        IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   INNER JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.existencia < @cantidad)
        BEGIN
            PRINT 'ERROR: No hay existencia suficiente para completar todo el pedido.';
            ROLLBACK; RETURN;
        END

        -- Proceso de Inserción: Cabecera de Venta
        INSERT INTO tblVenta (fecha, id_cliente) 
        VALUES (GETDATE(), @id_cliente);

        DECLARE @id_venta INT = SCOPE_IDENTITY();

        -- Proceso de Inserción: Detalle de Venta (Buscamos el ID y Precio por nombre)
        INSERT INTO tblDetalleVenta (id_venta, id_producto, precio_venta, cantidad_vendida)
        SELECT @id_venta, cp.id_producto, cp.precio, @cantidad
        FROM @tabla_productos  AS tp
        INNER JOIN catProducto AS cp 
        ON tp.nombre_producto = cp.nombre_producto;

        -- Proceso de Actualización: Restar existencia de forma masiva
        UPDATE cp
        SET cp.existencia = cp.existencia - @cantidad
        FROM catProducto AS cp
        INNER JOIN @tabla_productos AS tp 
        ON cp.nombre_producto = tp.nombre_producto;

        COMMIT;
        PRINT 'VENTAS REGISTRADAS EXITOSAMENTE';

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT 'OCURRIÓ UN ERROR EN EL PROCESO';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO

--Para ejecutarlo debemos declarar una variable del tipo Type que definimos arriba
DECLARE @milista tipo_nombres_productos;
--Insertamos los prodcutos los cuales vamos a regitrar en la compra
INSERT INTO @milista
VALUES ('CHANG'), ('CHAI');

/*=====================EXEC DEL SP DE MULIPLES VENTAS===========================*/
EXEC usp_agregar_venta_n_productos
@id_cliente = 'ANTON',
@cantidad = 1,
@tabla_productos = @milista;
/*==========================================================*/

/*=====================EXEC DEL SP ORIGINAL===========================*/
EXEC usp_agregar_venta3 
    @id_cliente = 'CACTU',
    @nombre_producto = 'TOFU',
    @cantidad_vendida = 2;
/*============================================================*/



SELECT *
FROM tblDetalleVenta

SELECT *
FROM tblVenta

SELECT *
FROM catCliente

SELECT *
FROM catProducto

SELECT *
FROM catProducto
ORDER BY 2 DESC


SELECT *
FROM Northwind.dbo.Products
ORDER BY 2 DESC
