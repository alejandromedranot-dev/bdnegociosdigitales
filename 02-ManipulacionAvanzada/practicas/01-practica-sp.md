# Documentación de Prácticas STORED PROCEDURES

## Objetivo

Crear un Stored Procedure el cual nos permirta realizar compras y actualizar la base de datos, con forme a los procesos establecidos dentro de Stored procedure

## 1. Crear Base de Datos bdpracticas

 1. Crearemos la base de datos en donde trabajaremos: 
 ---

![This is an alt text.](/img/Crear%20base.png "Crear base.")

### 2. Creamos las tablas: catProducto, catCliente, tblVenta, tblDetalleVenta:

---

![This is an alt text.](/img/catcliente.png "Crear base.")

Aqui insertaremos datos de la base de datos de Northwind

![This is an alt text.](/img/insertn.png "Crear base.")
---
![This is an alt text.](/img/catp.png "Crear base.")

Aqui insertaremos datos de la base de datos de Northwind

![This is an alt text.](/img/catpro.png "Crear base.")

---
![This is an alt text.](/img/ventas.png "Crear base.")

---
![This is an alt text.](/img/detalle.png "Crear base.")

### 3. Cremos el diagrama de la base de las tablas creadas


![This is an alt text.](/img/diagrama.png "Crear base.")

Creamos el stored procedure llamado *usp_agregar_venta* y declararemos las siguientes variables: 
    
    @id_cliente NCHAR(5),
    @nombre_producto NVARCHAR(40),
    @cantidad_vendida INT

La cuales recibiran un parametro especifico, como el ID del cliente, el nombre del producto y la cantidad vendida los cuales  nos servirán para insertar valores dentro del stored procedured.

Comenzamos con el try, empezamos con la transacción, el if que se muestra a continuación nos sirve para validar si es que un cliente existe mediante una negación, si el id_cliente no coincide con alguno dentro de la base de detos imprime un mensaje 'EL CLIENTE NO EXISTE' y termina el Stored agregando **ROLLBACK** Y **RETURN**

![This is an alt text.](/img/begin%20try.png "Crear base.")

El siguiente bloque muestra un IF el cual nos ayuda a validar si es que existe el producto ingresado. El campo "SELECT 1 FROM catProducto WHERE nombre_producto = @nombre_producto" verifica si al menos una fila con el nombre de ese producto,  si no lo encuetra imprime el mensaje "EL PRODUCTO NO EXISTE"  termina el stored procedure


![This is an alt text.](/img/segundo%20if.png "Crear base.")

Por último  realizamos una validación más la cual comprueba si hay suficientes unidades en existencia del producto solicitado, en caso de ser mayor el numero de unidades solicitadas (@cantidad_vendida), imprime el mensaje "'NO HAY EXISTENCIA SUFICIENTE DEL PRODUCTO: ' + @nombre_producto" y termina el stored procedure

---
![This is an alt text.](/img/existencia.png "Crear base.")

### 3.1 INSERTS

Si los datos ingresados cumplen con las validaciones, el stored procedure comienza con el proceso de inserción y actualizacion de datos

- Declaramos una variable **@precio** de tipo **MONEY** la cual almacenará el precio del producto que estamos vendiendo, en **SELECT @PRECIO = PRECIO** asignaremos el valor del precio que proviene del producto registrado en la tabla catProducto

---

![This is an alt text.](/img/declare%20precio.png "Crear base.")

- posteriormente agregaremos la fecha y el id del cliente a la tabla **tblVenta**, esto se ejecuta una vez que la validación del primer IF se cumpla,  solo agregaremos los campos de fecha con **GETDATE()** y el id del cliente. El id de venta esta registrado como **IDENTITY** con **SCOPE_IDENTITY()**

![This is an alt text.](/img/insert%20tblventa1.png "Crear base.")


- Después declararemos una variable "@id_producto" la cual nos servirá para almacenar el id del producto proveniente de la tabla "catProducto"

![This is an alt text.](/img/decl%20id%20product.png "Crear base.")


- Insertaremos los datos correspodientes en la tabla **tblDetalleVenta**, que serian las variables: 
    
        @id_venta, @id_producto, @precio, @cantidad_vendida

---

![This is an alt text.](/img/insert%20detalle.png "Crear base.")

- Por úttimo procedemos a actualizar la **tabla catProducto**, la cual debe ser actualizada en el campo de **existencia** cada que se realice una nueva venta mediante la operación: "existencia - @cantidad_vendida" y hacemos **COMMIT**

----

![This is an alt text.](/img/update.png "Crear base.")

### 4. CATCH

Una vez finalizado el proceso del TRY, el CATCH opera **SOLO EN CASO** de que algo no se haya realizado de manera correcta dentro del sistema y podamos tener un mayor control en el manejo de errores, el CATCH imprimirá un mensaje que diga: "OCURRIO UN ERROR EN EL PROCESO" y lanzará un mensaje de error del sistema con **ERROR_MESSAGE()** y finaliza el STORED PROCEDURE


![This is an alt text.](/img/CATCH.png "Crear base.")

- Y por último ejecutamos para comprobar el funcionamiento:

----

![This is an alt text.](/img/EXEC.png "Crear base.")

> TABLA TYPE 

Un User-Defined Table Type es una plantilla de tabla que definimos en SQL Server para luego usarla como un parametro dentro del Stored Procedure

##### Sintaxis

```sql

CREATE TYPE tipo_detalle_venta AS TABLE (
    Nombre_producto NVARCHAR(40),
    Cantidad_vendida INT
)
```

Dentro de un SP:

```sql
    CREATE OR ALTER PROCEDURE usp_agregar_venta

    @id_cliente NCHAR(5), 
    @detalles tipo_detalle_venta READONLY
    AS
    BEGIN
    INSERT INTO Ventas(nombre_producto, cantidad, id_cliente)
    SELECT nombre_producto, cantidad, @id_cliente
    FROM @detalles
END;

```







