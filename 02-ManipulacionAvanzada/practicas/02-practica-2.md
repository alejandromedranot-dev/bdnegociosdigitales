# STORED PROCEDURE con tablas Type (User-Defined Table Type)

### ¿Qué es una tabla UDTT?

Unas User-Defined Tabla Type, es considerada principalmente como una plantilla o estructuta de tabla definida por el usuario la cual se almacena en la base de datos. Dentro de un SP se utiliza para poder pasar multiples filas de datos como un único parametro. Es decir, si queremos inseertar 50 nuevos productos al mismo tiempo, tendriamos que llamar al SP **50 veces** a la vez, en cambio con una UDTT solo definimos la forma de la tabla una sola vez para luego pasar esa tabla como "variable de tabla" al procedimiento almacenado.

##### Sintaxis

```sql
CREATE TYPE dbo.ProductoType AS TABLE (
    ID INT,
    Nombre VARCHAR(100),
    Precio DECIMAL(10, 2)
);
```

#### Práctica

> Utilizar el SP realizado previamente(usp_agregar_venta) y crear un nuevo SP que permita agregar "n" cantidad de productos. El id del producto no se ingresa, solo el parametro a insertar:    - crear una UDTT y enviar como parametro del SP, ademas del id_cliente y la cantidad de productos.

##### PASO 1: Crear la tbla UDTT

Definiremos el tipo de tabla la cual solo recibirá como prametro el nombre del producto.

```sql
CREATE TYPE tipo_nombres_productos AS TABLE (
    nombre_producto NVARCHAR(40)
);
GO
```

##### PASO 2: Crear el SP

Procedemos a crear el SP llamado "usp_agregar_venta_n_productos", el cual recibirá los siguientes parametros:

- @id_cliente
- @cantidad
- @tabla_productos

```sql
CREATE OR ALTER PROC usp_agregar_venta_n_productos
    @id_cliente NCHAR(5),
    @cantidad INT,
    @tabla_productos tipo_nombres_productos READONLY -- Sirve para proteger la integridad de los 
    --datos de entrada y no puedan ser modificados por el SP
    AS
    BEGIN
        BEGIN TRY
            BEGIN TRANSACTION;
```

##### PASO 3: Validaciones dentro del SP

1. Validar si el cliente existe en la tabla catCliente
 El siguiente bloque de código nos ayuda validar si el cliente existe en la tabla catCliente.
 **IF NOT EXISTS** nos indica que si NO existe al menos ALGUN registro en catCliente en donde el id_cliente sea igual al @id_cliente que estamos ingresando, imprimirá el mensaje **"EL CLIENTE NO EXISTE"** y entrará y el **ROLLBACK** y **RETURN** para terminar con la transacción.


    ```sql
     IF NOT EXISTS (SELECT 1 FROM catCliente WHERE id_cliente = @id_cliente)
        BEGIN 
            PRINT 'EL CLIENTE NO EXISTE';
            ROLLBACK; 
            RETURN;
        END
    ```

2. Validar si los productos ingresados existen en la tabla catProducto.

 En el siguiente código validamos si los productos ingresados existen en la tabla catProducto.
Con el LEFT JOIN utilizado, tomaremos todos los elementos de la tabla izquierda(@tabla_prodcutos) y buscaremos alguna coincidencia de la tabla derecha(catProducto). **SI EL PRODUCTO EXISTE** los datos se emparejan y la columna cp.id_producto tendra un valor, pero si el prducto **NO EXISTE** SQL no encuentra ninguna coincidencia en la tabla, por lo que llena los campos con NULL.
El WHERE nos ayuda a detectar el error en @tabla_productos, si ingresamos un id_producto que no existe en la tabla catProducto, la condicion se cumple  por que ese id_producto no  esta registrado dentro de la BD y es ahi donde entra el **ROLLBACK** y **RETURN** para terminar con la transacción.

```sql
    IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   LEFT JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.id_producto IS NULL)
        BEGIN
            PRINT 'ERROR: Uno o más productos de la lista no existen en el catálogo.';
            ROLLBACK; RETURN;
        END
```
3. validar que el stock sea suficiente para la venta.

En esta validación verificaremos si la existencia en la tabla catProducto es suficiente para completar la venta.
Utilizaremos un INNER JOIN que enlace la tabla @tabla_productos con la tabla catProdcto en donde coincida el nombre del producto, en donde cp.existencia sea menor a @cantidad. Si la condició se cumple imprime el mensaje **"ERROR: No hay existencia suficiente para completar todo el pedido."** y entra el **ROLLBACK** y **RETURN** para terminar con la transacción.

```sql
IF EXISTS (SELECT 1 FROM @tabla_productos AS tp 
                   INNER JOIN catProducto AS cp ON tp.nombre_producto = cp.nombre_producto 
                   WHERE cp.existencia < @cantidad)
        BEGIN
            PRINT 'ERROR: No hay existencia suficiente para completar todo el pedido.';
            ROLLBACK; RETURN;
        END
```

##### PASO 4: AInsercion de datos en la tabla tblVenta

1. Si los datos ingresados en el SP son validos para generar la transacción, el SP procederá a insertar dentro de la tabla tblVenta, la fecha de la venta y el ID del cliente. Es importante declarar aqui una variable llamada @id_venta(INT) que sea *SCOPE_IDENTITY();* para que genere su propio ID de venta de manera automatica.


```sql
INSERT INTO tblVenta (fecha, id_cliente) 
 VALUES (GETDATE(), @id_cliente);

DECLARE @id_venta INT = SCOPE_IDENTITY();
```

2. Insrtados los datos correspondientes en tblVenta, procedemos a insertar dentro de la tabla tblDetalleVenta.
los valores: (id_venta, id_producto, precio_venta, cantidad_vendida), para esto es importante hacer INNER JOIN de la tabla *@tabla_productos* con la *tabla catProducto*, esto nos ayuda a poder imprimir dentro de la tabla el precio y el ID del product provenientes de la tabla *catProducto*.


```sql
 INSERT INTO tblDetalleVenta (id_venta, id_producto, precio_venta, cantidad_vendida)
  SELECT @id_venta, cp.id_producto, cp.precio, @cantidad
        FROM @tabla_productos  AS tp
        INNER JOIN catProducto AS cp 
        ON tp.nombre_producto = cp.nombre_producto;
```

3. Por último actualizaremos la tabla *catProducto* en la existencia de productos en tabla mediante la operación: **cp.existencia = cp.existencia - @cantidad** la cual nos ayudará a actualizar la existencia en la tabla catProducto al restar la cantidad ingresada en la venta, posteriormente haremos *COMMIT* para terminar la transacción.

```sql
 UPDATE cp
  SET cp.existencia = cp.existencia - @cantidad
        FROM catProducto AS cp
        INNER JOIN @tabla_productos AS tp 
        ON cp.nombre_producto = tp.nombre_producto;

         COMMIT;
        PRINT 'VENTAS REGISTRADAS EXITOSAMENTE';
    END TRY
```

##### PASO 5: Manejo de Errores

Si algo sale mal dentro del SP, el procedimiento entra al *CATCH*. **@@@TRANCOUNT** es una función del sistema la cual nos dice cuantas transacciones abaiertas existen en la sesión actual, Sí **@@TRANCOUNT** es mayor a 0 hace **ROLLBACK** para finalizar la transacción e imprime un mensaje de error definido en el catch, ademas de imprimir el error exacto que ocurrio con *ERROR_MESSAGE()*.


```sql
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        PRINT 'OCURRIÓ UN ERROR EN EL PROCESO';
        PRINT ERROR_MESSAGE();
    END CATCH
END;
GO
```

##### EJECUCIÓN DEL SP

Ejecutamos el SP declarando una variable del tipo de tabla type, en este caso llamada @milista.
Hacemos una inserción con el nombre de los productos(solo recibe el nombre del producto la tabla type)
con *EXEC usp_agregar_venta_n_productos* ejecutamos y agregamos los valores de las variables a insertar en el SP.

```sql
 DECLARE @milista tipo_nombres_productos;

INSERT INTO @milista
VALUES ('CHOCOLADE'), ('FILO MIX'), ('PRIMAVERA');

/*=====================EXEC DEL SP DE MULIPLES VENTAS===========================*/
EXEC usp_agregar_venta_n_productos
@id_cliente = 'LAMAI',
@cantidad = 5,
@tabla_productos = @milista;
```