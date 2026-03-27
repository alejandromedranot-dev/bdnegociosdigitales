# Banco de ejercicios de SQL Server (dataset de la guía)
Este banco está pensado para practicarse con el mismo dataset de la guía (Clientes, Productos, Ventas, DetalleVenta, Pagos).
Incluye **10 ejercicios por tema**.

> Tip: activa el plan de ejecución con **Ctrl+M** en SSMS para ver impacto de índices.


## Requisito previo
Usa el script de creación e inserción de datos que ya tienes en la guía principal.


## 1) Campos calculados, funciones y valores nulos

### Ejercicio 1
Lista a todos los clientes mostrando: Nombre, Ciudad en MAYÚSCULAS, longitud del nombre y una etiqueta con formato `Nombre (Ciudad)`.


**Solución**
```sql
SELECT
  Nombre,
  UPPER(Ciudad) AS Ciudad_MAYUS,
  LEN(Nombre) AS LongitudNombre,
  CONCAT(Nombre,' (',Ciudad,')') AS Etiqueta
FROM dbo.Clientes;
```

### Ejercicio 2
Muestra los clientes con Email nulo, pero reemplaza el email con el texto `sin-email` en la salida.


**Solución**
```sql
SELECT
  Nombre,
  ISNULL(Email,'sin-email') AS EmailSeguro
FROM dbo.Clientes
WHERE Email IS NULL;
```

### Ejercicio 3
Crea una columna calculada `AntiguedadDias` que indique cuántos días han pasado desde `FechaAlta` hasta hoy.


**Solución**
```sql
SELECT
  ClienteId, Nombre, FechaAlta,
  DATEDIFF(day, FechaAlta, CAST(GETDATE() AS date)) AS AntiguedadDias
FROM dbo.Clientes;
```

### Ejercicio 4
De cada venta, muestra: VentaId, SoloFecha (DATE), AñoMes (yyyy-MM) y el nombre del día de la semana.


**Solución**
```sql
SELECT
  VentaId,
  CAST(FechaVenta AS date) AS SoloFecha,
  FORMAT(FechaVenta,'yyyy-MM') AS AnioMes,
  DATENAME(weekday, FechaVenta) AS DiaSemana
FROM dbo.Ventas;
```

### Ejercicio 5
Calcula por cada detalle de venta: Subtotal, MontoDescuento y TotalLinea aplicando el porcentaje `Descuento`.


**Solución**
```sql
SELECT
  DetalleId,
  Cantidad, PrecioUnit, Descuento,
  Cantidad*PrecioUnit AS Subtotal,
  Cantidad*PrecioUnit*(Descuento/100.0) AS MontoDescuento,
  Cantidad*PrecioUnit*(1-Descuento/100.0) AS TotalLinea
FROM dbo.DetalleVenta;
```

### Ejercicio 6
Muestra productos indicando una columna `PrecioRedondeado` a 0 decimales y otra `PrecioConIVA` (IVA 16%).


**Solución**
```sql
SELECT
  ProductoId, Nombre, Precio,
  ROUND(Precio,0) AS PrecioRedondeado,
  ROUND(Precio*1.16,2) AS PrecioConIVA
FROM dbo.Productos;
```

### Ejercicio 7
Construye un SKU 'corto' con los primeros 2 caracteres del SKU y los últimos 2 (ej: A100 -> A1 00).


**Solución**
```sql
SELECT
  SKU,
  CONCAT(LEFT(SKU,2), RIGHT(SKU,2)) AS SKU_Corto
FROM dbo.Productos;
```

### Ejercicio 8
Genera una columna `EmailODefault`: si Email es NULL usa `Nombre@ejemplo.com` en minúsculas (sin espacios).


**Solución**
```sql
SELECT
  Nombre,
  COALESCE(
    Email,
    CONCAT(LOWER(REPLACE(Nombre,' ','')),'@ejemplo.com')
  ) AS EmailODefault
FROM dbo.Clientes;
```

### Ejercicio 9
Evita división entre cero: para cada venta calcula `MontoPromedioPago` = TotalPagos / NumPagos (si no hay pagos, que salga NULL).


**Solución**
```sql
SELECT
  v.VentaId,
  SUM(p.Monto) AS TotalPagos,
  COUNT(p.PagoId) AS NumPagos,
  SUM(p.Monto)*1.0 / NULLIF(COUNT(p.PagoId),0) AS MontoPromedioPago
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
GROUP BY v.VentaId;
```

### Ejercicio 10
Muestra ventas con una columna `EstadoLimpio` que ponga `SIN ESTADO` cuando Estado venga NULL (simúlalo con COALESCE).


**Solución**
```sql
SELECT
  VentaId,
  COALESCE(Estado,'SIN ESTADO') AS EstadoLimpio
FROM dbo.Ventas;
```


## 2) GROUP BY

### Ejercicio 1
Cuenta cuántos clientes hay por Ciudad.


**Solución**
```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad;
```

### Ejercicio 2
Calcula el precio promedio, mínimo y máximo por Categoría de productos.


**Solución**
```sql
SELECT Categoria,
       AVG(Precio*1.0) AS PrecioPromedio,
       MIN(Precio) AS PrecioMin,
       MAX(Precio) AS PrecioMax
FROM dbo.Productos
GROUP BY Categoria;
```

### Ejercicio 3
Obtén el total vendido por VentaId (considerando descuento).


**Solución**
```sql
SELECT VentaId,
       SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta
GROUP BY VentaId;
```

### Ejercicio 4
Total de unidades vendidas por ProductoId.


**Solución**
```sql
SELECT ProductoId,
       SUM(Cantidad) AS UnidadesVendidas
FROM dbo.DetalleVenta
GROUP BY ProductoId;
```

### Ejercicio 5
Ventas por Estado: cuántas ventas hay de cada estado.


**Solución**
```sql
SELECT Estado, COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY Estado;
```

### Ejercicio 6
Pagos por Método: total de monto y número de pagos por método.


**Solución**
```sql
SELECT Metodo,
       COUNT(*) AS NumPagos,
       SUM(Monto) AS TotalMonto
FROM dbo.Pagos
GROUP BY Metodo;
```

### Ejercicio 7
Total vendido por ClienteId (sumando todas sus ventas) usando DetalleVenta + Ventas.


**Solución**
```sql
SELECT v.ClienteId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalCliente
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY v.ClienteId;
```

### Ejercicio 8
Total vendido por mes (Año-Mes) usando Ventas.FechaVenta y DetalleVenta.


**Solución**
```sql
SELECT FORMAT(v.FechaVenta,'yyyy-MM') AS AnioMes,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalMes
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY FORMAT(v.FechaVenta,'yyyy-MM');
```

### Ejercicio 9
Cuenta cuántos productos activos y cuántos inactivos hay.


**Solución**
```sql
SELECT Activo, COUNT(*) AS NumProductos
FROM dbo.Productos
GROUP BY Activo;
```

### Ejercicio 10
Para cada VentaId, calcula: número de renglones (detalles) y unidades totales.


**Solución**
```sql
SELECT VentaId,
       COUNT(*) AS NumRenglones,
       SUM(Cantidad) AS UnidadesTotales
FROM dbo.DetalleVenta
GROUP BY VentaId;
```


## 3) HAVING

### Ejercicio 1
Muestra solo las ciudades que tengan 2 o más clientes.


**Solución**
```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad
HAVING COUNT(*) >= 2;
```

### Ejercicio 2
Muestra las categorías cuyo precio promedio sea mayor a 1000.


**Solución**
```sql
SELECT Categoria, AVG(Precio*1.0) AS PrecioPromedio
FROM dbo.Productos
GROUP BY Categoria
HAVING AVG(Precio*1.0) > 1000;
```

### Ejercicio 3
Muestra las ventas cuyo total (con descuento) sea mayor a 5000.


**Solución**
```sql
SELECT VentaId,
       SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta
GROUP BY VentaId
HAVING SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) > 5000;
```

### Ejercicio 4
Muestra productos que se hayan vendido en 2 o más ventas distintas.


**Solución**
```sql
SELECT ProductoId,
       COUNT(DISTINCT VentaId) AS VentasDistintas
FROM dbo.DetalleVenta
GROUP BY ProductoId
HAVING COUNT(DISTINCT VentaId) >= 2;
```

### Ejercicio 5
Muestra clientes con total vendido mayor a 3000.


**Solución**
```sql
SELECT v.ClienteId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalCliente
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY v.ClienteId
HAVING SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) > 3000;
```

### Ejercicio 6
Muestra meses (yyyy-MM) con al menos 2 ventas registradas (cualquier estado).


**Solución**
```sql
SELECT FORMAT(FechaVenta,'yyyy-MM') AS AnioMes,
       COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY FORMAT(FechaVenta,'yyyy-MM')
HAVING COUNT(*) >= 2;
```

### Ejercicio 7
Muestra métodos de pago cuyo total de monto pagado sea mayor a 1000.


**Solución**
```sql
SELECT Metodo, SUM(Monto) AS TotalMonto
FROM dbo.Pagos
GROUP BY Metodo
HAVING SUM(Monto) > 1000;
```

### Ejercicio 8
Muestra ventas que tengan 2 o más renglones en DetalleVenta.


**Solución**
```sql
SELECT VentaId, COUNT(*) AS NumRenglones
FROM dbo.DetalleVenta
GROUP BY VentaId
HAVING COUNT(*) >= 2;
```

### Ejercicio 9
Muestra productos con unidades vendidas totales >= 3.


**Solución**
```sql
SELECT ProductoId, SUM(Cantidad) AS Unidades
FROM dbo.DetalleVenta
GROUP BY ProductoId
HAVING SUM(Cantidad) >= 3;
```

### Ejercicio 10
Muestra clientes que tengan al menos 2 ventas (sin importar estado).


**Solución**
```sql
SELECT ClienteId, COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY ClienteId
HAVING COUNT(*) >= 2;
```


## 4) JOINS

### Ejercicio 1
Lista cada venta con el nombre del cliente (INNER JOIN).


**Solución**
```sql
SELECT v.VentaId, v.FechaVenta, v.Estado, c.Nombre AS Cliente
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId;
```

### Ejercicio 2
Lista clientes con sus ventas (LEFT JOIN) y muestra también clientes sin ventas.


**Solución**
```sql
SELECT c.ClienteId, c.Nombre, v.VentaId, v.Estado
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
ORDER BY c.ClienteId, v.VentaId;
```

### Ejercicio 3
Encuentra clientes sin ventas (LEFT JOIN + IS NULL).


**Solución**
```sql
SELECT c.*
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
WHERE v.VentaId IS NULL;
```

### Ejercicio 4
Muestra el detalle de cada venta: VentaId, Cliente, Producto, Cantidad, PrecioUnit.


**Solución**
```sql
SELECT v.VentaId, c.Nombre AS Cliente, p.Nombre AS Producto, d.Cantidad, d.PrecioUnit
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
JOIN dbo.Productos p ON p.ProductoId = d.ProductoId
ORDER BY v.VentaId;
```

### Ejercicio 5
Muestra ventas y pagos (LEFT JOIN) para ver cuáles ventas no tienen pagos.


**Solución**
```sql
SELECT v.VentaId, v.Estado, p.PagoId, p.Monto
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
ORDER BY v.VentaId, p.PagoId;
```

### Ejercicio 6
Obtén el total de pagos por venta (JOIN + GROUP BY).


**Solución**
```sql
SELECT v.VentaId, SUM(p.Monto) AS TotalPagos
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
GROUP BY v.VentaId;
```

### Ejercicio 7
Lista productos y si están o no vendidos al menos una vez (LEFT JOIN + CASE).


**Solución**
```sql
SELECT p.ProductoId, p.Nombre,
       CASE WHEN d.ProductoId IS NULL THEN 'No vendido' ELSE 'Vendido' END AS EstadoVenta
FROM dbo.Productos p
LEFT JOIN dbo.DetalleVenta d ON d.ProductoId = p.ProductoId
GROUP BY p.ProductoId, p.Nombre, CASE WHEN d.ProductoId IS NULL THEN 'No vendido' ELSE 'Vendido' END;
```

### Ejercicio 8
Crea un reporte por venta con TotalVenta y TotalPagos (JOIN + agregados).


**Solución**
```sql
SELECT v.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta,
       SUM(p.Monto) AS TotalPagos
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
GROUP BY v.VentaId;
```

### Ejercicio 9
Muestra ventas con cliente y ciudad, solo del cliente activo (JOIN + filtro).


**Solución**
```sql
SELECT v.VentaId, c.Nombre, c.Ciudad, v.Estado
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
WHERE c.Activo = 1;
```

### Ejercicio 10
Simula un FULL OUTER JOIN entre Clientes y Ventas (SQL Server tiene FULL JOIN). Muestra registros huérfanos de ambos lados.


**Solución**
```sql
SELECT c.ClienteId, c.Nombre, v.VentaId
FROM dbo.Clientes c
FULL OUTER JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
WHERE c.ClienteId IS NULL OR v.VentaId IS NULL;
```


## 5) CASE

### Ejercicio 1
Clasifica a los clientes como 'Activo' o 'Inactivo' según el campo Activo (CASE).


**Solución**
```sql
SELECT ClienteId, Nombre,
       CASE WHEN Activo = 1 THEN 'Activo' ELSE 'Inactivo' END AS Estatus
FROM dbo.Clientes;
```

### Ejercicio 2
En ventas, crea una columna `Prioridad`: Pagada=1, Pendiente=2, Cancelada=3, otro=9.


**Solución**
```sql
SELECT VentaId, Estado,
       CASE
         WHEN Estado='Pagada' THEN 1
         WHEN Estado='Pendiente' THEN 2
         WHEN Estado='Cancelada' THEN 3
         ELSE 9
       END AS Prioridad
FROM dbo.Ventas;
```

### Ejercicio 3
Etiqueta productos por rango de precio: <500 'Económico', 500-5000 'Medio', >5000 'Premium'.


**Solución**
```sql
SELECT ProductoId, Nombre, Precio,
       CASE
         WHEN Precio < 500 THEN 'Económico'
         WHEN Precio <= 5000 THEN 'Medio'
         ELSE 'Premium'
       END AS Segmento
FROM dbo.Productos;
```

### Ejercicio 4
Para cada detalle, calcula TotalLinea y etiqueta 'Con descuento' si Descuento>0, si no 'Sin descuento'.


**Solución**
```sql
SELECT DetalleId,
       Cantidad*PrecioUnit*(1-Descuento/100.0) AS TotalLinea,
       CASE WHEN Descuento>0 THEN 'Con descuento' ELSE 'Sin descuento' END AS TipoDescuento
FROM dbo.DetalleVenta;
```

### Ejercicio 5
Crea una columna `TieneEmail` en Clientes (Sí/No).


**Solución**
```sql
SELECT ClienteId, Nombre,
       CASE WHEN Email IS NULL THEN 'No' ELSE 'Sí' END AS TieneEmail
FROM dbo.Clientes;
```

### Ejercicio 6
En ventas, marca `Cobrable`=Sí si Estado='Pagada' o 'Pendiente', si no 'No'.


**Solución**
```sql
SELECT VentaId, Estado,
       CASE WHEN Estado IN ('Pagada','Pendiente') THEN 'Sí' ELSE 'No' END AS Cobrable
FROM dbo.Ventas;
```

### Ejercicio 7
Muestra pagos y clasifica el monto: <=1000 'Bajo', 1001-5000 'Medio', >5000 'Alto'.


**Solución**
```sql
SELECT PagoId, VentaId, Monto,
       CASE
         WHEN Monto <= 1000 THEN 'Bajo'
         WHEN Monto <= 5000 THEN 'Medio'
         ELSE 'Alto'
       END AS NivelMonto
FROM dbo.Pagos;
```

### Ejercicio 8
Crea un 'EstadoNormalizado' para ventas: OK/Revisar/Anular.


**Solución**
```sql
SELECT VentaId, Estado,
       CASE
         WHEN Estado='Pagada' THEN 'OK'
         WHEN Estado='Pendiente' THEN 'Revisar'
         WHEN Estado='Cancelada' THEN 'Anular'
         ELSE 'Otro'
       END AS EstadoNormalizado
FROM dbo.Ventas;
```

### Ejercicio 9
Muestra clientes con una columna `CiudadPrioritaria`: Pachuca='Sí', otras='No'.


**Solución**
```sql
SELECT ClienteId, Nombre, Ciudad,
       CASE WHEN Ciudad='Pachuca' THEN 'Sí' ELSE 'No' END AS CiudadPrioritaria
FROM dbo.Clientes;
```

### Ejercicio 10
Ordena ventas mostrando una columna `OrdenEstado` (CASE) y ordena por esa columna, luego por FechaVenta DESC.


**Solución**
```sql
SELECT VentaId, FechaVenta, Estado,
       CASE
         WHEN Estado='Pagada' THEN 1
         WHEN Estado='Pendiente' THEN 2
         WHEN Estado='Cancelada' THEN 3
         ELSE 9
       END AS OrdenEstado
FROM dbo.Ventas
ORDER BY OrdenEstado, FechaVenta DESC;
```


## 6) Subconsultas (IN, EXISTS/NOT EXISTS, ANY, ALL, escalares y tablas derivadas)

### Ejercicio 1
Subconsulta escalar: muestra el número total de ventas en una sola columna.


**Solución**
```sql
SELECT (SELECT COUNT(*) FROM dbo.Ventas) AS TotalVentas;
```

### Ejercicio 2
Clientes que han tenido al menos una venta Pagada (IN).


**Solución**
```sql
SELECT *
FROM dbo.Clientes
WHERE ClienteId IN (
  SELECT ClienteId
  FROM dbo.Ventas
  WHERE Estado='Pagada'
);
```

### Ejercicio 3
Clientes que NO han tenido ninguna venta Pagada (NOT EXISTS).


**Solución**
```sql
SELECT c.*
FROM dbo.Clientes c
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Ventas v
  WHERE v.ClienteId=c.ClienteId AND v.Estado='Pagada'
);
```

### Ejercicio 4
Ventas que NO tienen pagos registrados (NOT EXISTS).


**Solución**
```sql
SELECT v.*
FROM dbo.Ventas v
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.Pagos p
  WHERE p.VentaId=v.VentaId
);
```

### Ejercicio 5
Productos nunca vendidos (NOT EXISTS).


**Solución**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE NOT EXISTS (
  SELECT 1 FROM dbo.DetalleVenta d
  WHERE d.ProductoId=p.ProductoId
);
```

### Ejercicio 6
Productos con precio mayor al promedio de precios (escalar).


**Solución**
```sql
SELECT *
FROM dbo.Productos
WHERE Precio > (SELECT AVG(Precio*1.0) FROM dbo.Productos);
```

### Ejercicio 7
Productos con precio mayor que ALL los precios de Accesorios (ALL).


**Solución**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ALL (
  SELECT Precio FROM dbo.Productos WHERE Categoria='Accesorios'
);
```

### Ejercicio 8
Productos con precio menor que ANY los precios de Computo (ANY).


**Solución**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio < ANY (
  SELECT Precio FROM dbo.Productos WHERE Categoria='Computo'
);
```

### Ejercicio 9
Tabla derivada: lista ventas con TotalVenta y filtra las que estén por encima del promedio de TotalVenta.


**Solución**
```sql
SELECT t.VentaId, t.TotalVenta
FROM (
  SELECT VentaId,
         SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
  FROM dbo.DetalleVenta
  GROUP BY VentaId
) t
WHERE t.TotalVenta > (
  SELECT AVG(t2.TotalVenta*1.0)
  FROM (
    SELECT VentaId,
           SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
    FROM dbo.DetalleVenta
    GROUP BY VentaId
  ) t2
);
```

### Ejercicio 10
Correlacionada: lista clientes y una columna `TotalPagado` usando una subconsulta correlacionada sobre Pagos.


**Solución**
```sql
SELECT c.ClienteId, c.Nombre,
       (SELECT SUM(p.Monto)
        FROM dbo.Ventas v
        JOIN dbo.Pagos p ON p.VentaId=v.VentaId
        WHERE v.ClienteId=c.ClienteId) AS TotalPagado
FROM dbo.Clientes c;
```


## 7) Vistas (VIEW)

### Ejercicio 1
Crea una vista `vw_VentasTotales` con el total por venta (incluye Estado y FechaVenta).


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_VentasTotales
AS
SELECT v.VentaId, v.ClienteId, v.FechaVenta, v.Estado,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId=v.VentaId
GROUP BY v.VentaId, v.ClienteId, v.FechaVenta, v.Estado;
GO
```

### Ejercicio 2
Consulta la vista anterior y muestra solo las ventas Pagadas ordenadas por TotalVenta DESC.


**Solución**
```sql
SELECT *
FROM dbo.vw_VentasTotales
WHERE Estado='Pagada'
ORDER BY TotalVenta DESC;
```

### Ejercicio 3
Crea una vista `vw_DetalleEnriquecido` uniendo Ventas, Clientes, DetalleVenta y Productos.


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_DetalleEnriquecido
AS
SELECT v.VentaId, v.FechaVenta, v.Estado,
       c.ClienteId, c.Nombre AS Cliente, c.Ciudad,
       d.DetalleId, d.Cantidad, d.PrecioUnit, d.Descuento,
       p.ProductoId, p.Nombre AS Producto, p.Categoria
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId=v.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId=v.VentaId
JOIN dbo.Productos p ON p.ProductoId=d.ProductoId;
GO
```

### Ejercicio 4
Desde `vw_DetalleEnriquecido`, calcula el total por venta sin volver a escribir los JOINs.


**Solución**
```sql
SELECT VentaId,
       SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
FROM dbo.vw_DetalleEnriquecido
GROUP BY VentaId;
```

### Ejercicio 5
Crea una vista `vw_ClientesConTotal` que muestre ClienteId, Nombre y TotalVendido (0 si no tiene ventas).


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_ClientesConTotal
AS
SELECT c.ClienteId, c.Nombre,
       ISNULL(SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)),0) AS TotalVendido
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId=c.ClienteId
LEFT JOIN dbo.DetalleVenta d ON d.VentaId=v.VentaId
GROUP BY c.ClienteId, c.Nombre;
GO
```

### Ejercicio 6
Consulta `vw_ClientesConTotal` y muestra solo los que tengan TotalVendido > 3000.


**Solución**
```sql
SELECT *
FROM dbo.vw_ClientesConTotal
WHERE TotalVendido > 3000
ORDER BY TotalVendido DESC;
```

### Ejercicio 7
Crea una vista `vw_PagosPorVenta` con VentaId, TotalPagos y NumPagos.


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_PagosPorVenta
AS
SELECT v.VentaId,
       SUM(p.Monto) AS TotalPagos,
       COUNT(p.PagoId) AS NumPagos
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId=v.VentaId
GROUP BY v.VentaId;
GO
```

### Ejercicio 8
Consulta `vw_PagosPorVenta` para identificar ventas sin pagos (TotalPagos NULL).


**Solución**
```sql
SELECT *
FROM dbo.vw_PagosPorVenta
WHERE TotalPagos IS NULL;
```

### Ejercicio 9
Modifica `vw_VentasTotales` para agregar `AnioMes` (yyyy-MM).


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_VentasTotales
AS
SELECT v.VentaId, v.ClienteId, v.FechaVenta, v.Estado,
       FORMAT(v.FechaVenta,'yyyy-MM') AS AnioMes,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId=v.VentaId
GROUP BY v.VentaId, v.ClienteId, v.FechaVenta, v.Estado, FORMAT(v.FechaVenta,'yyyy-MM');
GO
```

### Ejercicio 10
Crea una vista `vw_ProductosVendidos` con ProductoId y UnidadesVendidas.


**Solución**
```sql
CREATE OR ALTER VIEW dbo.vw_ProductosVendidos
AS
SELECT ProductoId, SUM(Cantidad) AS UnidadesVendidas
FROM dbo.DetalleVenta
GROUP BY ProductoId;
GO
```


## 8) Índices (INDEX)

### Ejercicio 1
Crea un índice en Ventas por (ClienteId, FechaVenta) para acelerar búsquedas por cliente y rango de fechas.


**Solución**
```sql
CREATE INDEX IX_Ventas_Cliente_Fecha ON dbo.Ventas(ClienteId, FechaVenta);
```

### Ejercicio 2
Crea un índice en DetalleVenta(VentaId) para acelerar joins por VentaId.


**Solución**
```sql
CREATE INDEX IX_DetalleVenta_VentaId ON dbo.DetalleVenta(VentaId);
```

### Ejercicio 3
Crea un índice en DetalleVenta(ProductoId) para acelerar reportes por producto.


**Solución**
```sql
CREATE INDEX IX_DetalleVenta_ProductoId ON dbo.DetalleVenta(ProductoId);
```

### Ejercicio 4
Crea un índice en Pagos(VentaId) para acelerar búsquedas de pagos por venta.


**Solución**
```sql
CREATE INDEX IX_Pagos_VentaId ON dbo.Pagos(VentaId);
```

### Ejercicio 5
Activa estadísticas y ejecuta una consulta por VentaId antes y después de crear el índice correspondiente.


**Solución**
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Consulta (ejecuta antes y después de crear IX_DetalleVenta_VentaId)
SELECT *
FROM dbo.DetalleVenta
WHERE VentaId = 5;
```

### Ejercicio 6
Identifica el índice único ya existente en Productos (por SKU) y prueba una búsqueda por SKU.


**Solución**
```sql
SELECT *
FROM dbo.Productos
WHERE SKU = 'A200';
```

### Ejercicio 7
Crea un índice no cluster en Clientes(Ciudad) para acelerar filtros por ciudad.


**Solución**
```sql
CREATE INDEX IX_Clientes_Ciudad ON dbo.Clientes(Ciudad);
```

### Ejercicio 8
Ejecuta una consulta por ciudad y revisa el plan de ejecución (Ctrl+M) para verificar uso del índice.


**Solución**
```sql
SELECT *
FROM dbo.Clientes
WHERE Ciudad = 'Tula';
```

### Ejercicio 9
Crea un índice compuesto en DetalleVenta(VentaId, ProductoId) y consulta por ambos campos.


**Solución**
```sql
CREATE INDEX IX_DetalleVenta_Venta_Producto ON dbo.DetalleVenta(VentaId, ProductoId);

SELECT *
FROM dbo.DetalleVenta
WHERE VentaId = 1 AND ProductoId = 2;
```

### Ejercicio 10
Elimina (DROP) un índice de prueba que ya no necesites (ejemplo: IX_Clientes_Ciudad).


**Solución**
```sql
DROP INDEX IF EXISTS IX_Clientes_Ciudad ON dbo.Clientes;
```
