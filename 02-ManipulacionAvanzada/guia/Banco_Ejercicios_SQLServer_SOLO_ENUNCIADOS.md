# Banco de ejercicios de SQL Server (dataset de la guía)
Este banco está pensado para practicarse con el mismo dataset de la guía (Clientes, Productos, Ventas, DetalleVenta, Pagos).
Incluye **10 ejercicios por tema**.

> Tip: activa el plan de ejecución con **Ctrl+M** en SSMS para ver impacto de índices.


## Requisito previo
Usa el script de creación e inserción de datos que ya tienes en la guía principal.


## 1) Campos calculados, funciones y valores nulos

### Ejercicio 1
Lista a todos los clientes mostrando: Nombre, Ciudad en MAYÚSCULAS, longitud del nombre y una etiqueta con formato `Nombre (Ciudad)`.

### Ejercicio 2
Muestra los clientes con Email nulo, pero reemplaza el email con el texto `sin-email` en la salida.

### Ejercicio 3
Crea una columna calculada `AntiguedadDias` que indique cuántos días han pasado desde `FechaAlta` hasta hoy.

### Ejercicio 4
De cada venta, muestra: VentaId, SoloFecha (DATE), AñoMes (yyyy-MM) y el nombre del día de la semana.

### Ejercicio 5
Calcula por cada detalle de venta: Subtotal, MontoDescuento y TotalLinea aplicando el porcentaje `Descuento`.

### Ejercicio 6
Muestra productos indicando una columna `PrecioRedondeado` a 0 decimales y otra `PrecioConIVA` (IVA 16%).

### Ejercicio 7
Construye un SKU 'corto' con los primeros 2 caracteres del SKU y los últimos 2 (ej: A100 -> A1 00).

### Ejercicio 8
Genera una columna `EmailODefault`: si Email es NULL usa `Nombre@ejemplo.com` en minúsculas (sin espacios).

### Ejercicio 9
Evita división entre cero: para cada venta calcula `MontoPromedioPago` = TotalPagos / NumPagos (si no hay pagos, que salga NULL).

### Ejercicio 10
Muestra ventas con una columna `EstadoLimpio` que ponga `SIN ESTADO` cuando Estado venga NULL (simúlalo con COALESCE).


## 2) GROUP BY

### Ejercicio 1
Cuenta cuántos clientes hay por Ciudad.

### Ejercicio 2
Calcula el precio promedio, mínimo y máximo por Categoría de productos.

### Ejercicio 3
Obtén el total vendido por VentaId (considerando descuento).

### Ejercicio 4
Total de unidades vendidas por ProductoId.

### Ejercicio 5
Ventas por Estado: cuántas ventas hay de cada estado.

### Ejercicio 6
Pagos por Método: total de monto y número de pagos por método.

### Ejercicio 7
Total vendido por ClienteId (sumando todas sus ventas) usando DetalleVenta + Ventas.

### Ejercicio 8
Total vendido por mes (Año-Mes) usando Ventas.FechaVenta y DetalleVenta.

### Ejercicio 9
Cuenta cuántos productos activos y cuántos inactivos hay.

### Ejercicio 10
Para cada VentaId, calcula: número de renglones (detalles) y unidades totales.


## 3) HAVING

### Ejercicio 1
Muestra solo las ciudades que tengan 2 o más clientes.

### Ejercicio 2
Muestra las categorías cuyo precio promedio sea mayor a 1000.

### Ejercicio 3
Muestra las ventas cuyo total (con descuento) sea mayor a 5000.

### Ejercicio 4
Muestra productos que se hayan vendido en 2 o más ventas distintas.

### Ejercicio 5
Muestra clientes con total vendido mayor a 3000.

### Ejercicio 6
Muestra meses (yyyy-MM) con al menos 2 ventas registradas (cualquier estado).

### Ejercicio 7
Muestra métodos de pago cuyo total de monto pagado sea mayor a 1000.

### Ejercicio 8
Muestra ventas que tengan 2 o más renglones en DetalleVenta.

### Ejercicio 9
Muestra productos con unidades vendidas totales >= 3.

### Ejercicio 10
Muestra clientes que tengan al menos 2 ventas (sin importar estado).


## 4) JOINS

### Ejercicio 1
Lista cada venta con el nombre del cliente (INNER JOIN).

### Ejercicio 2
Lista clientes con sus ventas (LEFT JOIN) y muestra también clientes sin ventas.

### Ejercicio 3
Encuentra clientes sin ventas (LEFT JOIN + IS NULL).

### Ejercicio 4
Muestra el detalle de cada venta: VentaId, Cliente, Producto, Cantidad, PrecioUnit.

### Ejercicio 5
Muestra ventas y pagos (LEFT JOIN) para ver cuáles ventas no tienen pagos.

### Ejercicio 6
Obtén el total de pagos por venta (JOIN + GROUP BY).

### Ejercicio 7
Lista productos y si están o no vendidos al menos una vez (LEFT JOIN + CASE).

### Ejercicio 8
Crea un reporte por venta con TotalVenta y TotalPagos (JOIN + agregados).

### Ejercicio 9
Muestra ventas con cliente y ciudad, solo del cliente activo (JOIN + filtro).

### Ejercicio 10
Simula un FULL OUTER JOIN entre Clientes y Ventas (SQL Server tiene FULL JOIN). Muestra registros huérfanos de ambos lados.


## 5) CASE

### Ejercicio 1
Clasifica a los clientes como 'Activo' o 'Inactivo' según el campo Activo (CASE).

### Ejercicio 2
En ventas, crea una columna `Prioridad`: Pagada=1, Pendiente=2, Cancelada=3, otro=9.

### Ejercicio 3
Etiqueta productos por rango de precio: <500 'Económico', 500-5000 'Medio', >5000 'Premium'.

### Ejercicio 4
Para cada detalle, calcula TotalLinea y etiqueta 'Con descuento' si Descuento>0, si no 'Sin descuento'.

### Ejercicio 5
Crea una columna `TieneEmail` en Clientes (Sí/No).

### Ejercicio 6
En ventas, marca `Cobrable`=Sí si Estado='Pagada' o 'Pendiente', si no 'No'.

### Ejercicio 7
Muestra pagos y clasifica el monto: <=1000 'Bajo', 1001-5000 'Medio', >5000 'Alto'.

### Ejercicio 8
Crea un 'EstadoNormalizado' para ventas: OK/Revisar/Anular.

### Ejercicio 9
Muestra clientes con una columna `CiudadPrioritaria`: Pachuca='Sí', otras='No'.

### Ejercicio 10
Ordena ventas mostrando una columna `OrdenEstado` (CASE) y ordena por esa columna, luego por FechaVenta DESC.


## 6) Subconsultas (IN, EXISTS/NOT EXISTS, ANY, ALL, escalares y tablas derivadas)

### Ejercicio 1
Subconsulta escalar: muestra el número total de ventas en una sola columna.

### Ejercicio 2
Clientes que han tenido al menos una venta Pagada (IN).

### Ejercicio 3
Clientes que NO han tenido ninguna venta Pagada (NOT EXISTS).

### Ejercicio 4
Ventas que NO tienen pagos registrados (NOT EXISTS).

### Ejercicio 5
Productos nunca vendidos (NOT EXISTS).

### Ejercicio 6
Productos con precio mayor al promedio de precios (escalar).

### Ejercicio 7
Productos con precio mayor que ALL los precios de Accesorios (ALL).

### Ejercicio 8
Productos con precio menor que ANY los precios de Computo (ANY).

### Ejercicio 9
Tabla derivada: lista ventas con TotalVenta y filtra las que estén por encima del promedio de TotalVenta.

### Ejercicio 10
Correlacionada: lista clientes y una columna `TotalPagado` usando una subconsulta correlacionada sobre Pagos.


## 7) Vistas (VIEW)

### Ejercicio 1
Crea una vista `vw_VentasTotales` con el total por venta (incluye Estado y FechaVenta).

### Ejercicio 2
Consulta la vista anterior y muestra solo las ventas Pagadas ordenadas por TotalVenta DESC.

### Ejercicio 3
Crea una vista `vw_DetalleEnriquecido` uniendo Ventas, Clientes, DetalleVenta y Productos.

### Ejercicio 4
Desde `vw_DetalleEnriquecido`, calcula el total por venta sin volver a escribir los JOINs.

### Ejercicio 5
Crea una vista `vw_ClientesConTotal` que muestre ClienteId, Nombre y TotalVendido (0 si no tiene ventas).

### Ejercicio 6
Consulta `vw_ClientesConTotal` y muestra solo los que tengan TotalVendido > 3000.

### Ejercicio 7
Crea una vista `vw_PagosPorVenta` con VentaId, TotalPagos y NumPagos.

### Ejercicio 8
Consulta `vw_PagosPorVenta` para identificar ventas sin pagos (TotalPagos NULL).

### Ejercicio 9
Modifica `vw_VentasTotales` para agregar `AnioMes` (yyyy-MM).

### Ejercicio 10
Crea una vista `vw_ProductosVendidos` con ProductoId y UnidadesVendidas.


## 8) Índices (INDEX)

### Ejercicio 1
Crea un índice en Ventas por (ClienteId, FechaVenta) para acelerar búsquedas por cliente y rango de fechas.

### Ejercicio 2
Crea un índice en DetalleVenta(VentaId) para acelerar joins por VentaId.

### Ejercicio 3
Crea un índice en DetalleVenta(ProductoId) para acelerar reportes por producto.

### Ejercicio 4
Crea un índice en Pagos(VentaId) para acelerar búsquedas de pagos por venta.

### Ejercicio 5
Activa estadísticas y ejecuta una consulta por VentaId antes y después de crear el índice correspondiente.

### Ejercicio 6
Identifica el índice único ya existente en Productos (por SKU) y prueba una búsqueda por SKU.

### Ejercicio 7
Crea un índice no cluster en Clientes(Ciudad) para acelerar filtros por ciudad.

### Ejercicio 8
Ejecuta una consulta por ciudad y revisa el plan de ejecución (Ctrl+M) para verificar uso del índice.

### Ejercicio 9
Crea un índice compuesto en DetalleVenta(VentaId, ProductoId) y consulta por ambos campos.

### Ejercicio 10
Elimina (DROP) un índice de prueba que ya no necesites (ejemplo: IX_Clientes_Ciudad).
