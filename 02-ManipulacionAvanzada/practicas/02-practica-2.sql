/*==========================SP DE INSERCIÓN MULTIPLE================*/

USE bdpracticas 
GO

-- 1. Definir el Tipo de Tabla que solo recibe nombres
CREATE TYPE tipo_nombres_productos AS TABLE (
    nombre_producto NVARCHAR(40)
);
GO

/*==========================SP DE INSERCIÓN MULTIPLE================*/

CREATE OR ALTER PROC usp_agregar_venta_n_productos
    @id_cliente NCHAR(5),
    @cantidad INT,
    @tabla_productos tipo_nombres_productos READONLY
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validar si el cliente existe
        IF NOT EXISTS (SELECT 1 FROM catCliente WHERE id_cliente = @id_cliente)
        BEGIN 
            PRINT 'EL CLIENTE NO EXISTE';
            ROLLBACK; 
            RETURN;
        END

        -- Validar que todos los productos ingresados existan en la tabla
        IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   LEFT JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.id_producto IS NULL)
        BEGIN
            PRINT 'ERROR: Uno o más productos de la lista no existen en el catálogo.';
            ROLLBACK; RETURN;
        END

        -- Validar que el stock sea suficiente en existencia
        IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   INNER JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.existencia < @cantidad)
        BEGIN
            PRINT 'ERROR: No hay existencia suficiente para completar todo el pedido.';
            ROLLBACK; RETURN;
        END

        INSERT INTO tblVenta (fecha, id_cliente) 
        VALUES (GETDATE(), @id_cliente);

        DECLARE @id_venta INT = SCOPE_IDENTITY();

        -- Insertamos los valores dentro de tblDetalleVenta utilizado INNER JOIN
        INSERT INTO tblDetalleVenta (id_venta, id_producto, precio_venta, cantidad_vendida)
        SELECT @id_venta, cp.id_producto, cp.precio, @cantidad
        FROM @tabla_productos  AS tp
        INNER JOIN catProducto AS cp 
        ON tp.nombre_producto = cp.nombre_producto;

        -- Actulizamos la tabla catProducto
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
VALUES ('CHOCOLADE'), ('FILO MIX'), ('PRIMAVERA');

/*=====================EXEC DEL SP DE MULIPLES VENTAS===========================*/
EXEC usp_agregar_venta_n_productos
@id_cliente = 'LAMAI',
@cantidad = 5,
@tabla_productos = @milista;
/*==========================================================*/