# Guía práctica de SQL Server (AMPLIADA)
**Campos calculados, funciones, valores nulos, GROUP BY, HAVING, JOINS, CASE, Subconsultas, Vistas e Índices**

Esta versión amplía la guía original con explicaciones más claras y **mínimo 10 ejercicios por tema (con solución)**.


---

## 0) Dataset de práctica (ejecuta primero)

Usaremos el mismo dataset de la guía original (Clientes, Productos, Ventas, DetalleVenta y Pagos). Ejecuta el script tal cual en una base de datos de prueba.

```sql

-- Limpieza (opcional)
IF OBJECT_ID('dbo.Pagos','U') IS NOT NULL DROP TABLE dbo.Pagos;
IF OBJECT_ID('dbo.DetalleVenta','U') IS NOT NULL DROP TABLE dbo.DetalleVenta;
IF OBJECT_ID('dbo.Ventas','U') IS NOT NULL DROP TABLE dbo.Ventas;
IF OBJECT_ID('dbo.Productos','U') IS NOT NULL DROP TABLE dbo.Productos;
IF OBJECT_ID('dbo.Clientes','U') IS NOT NULL DROP TABLE dbo.Clientes;

CREATE TABLE dbo.Clientes(
  ClienteId INT IDENTITY(1,1) PRIMARY KEY,
  Nombre     VARCHAR(80) NOT NULL,
  Email      VARCHAR(120) NULL,
  Ciudad     VARCHAR(60) NOT NULL,
  FechaAlta  DATE NOT NULL,
  Activo     BIT NOT NULL
);

CREATE TABLE dbo.Productos(
  ProductoId INT IDENTITY(1,1) PRIMARY KEY,
  SKU        VARCHAR(20) NOT NULL UNIQUE,
  Nombre     VARCHAR(80) NOT NULL,
  Categoria  VARCHAR(40) NOT NULL,
  Precio     DECIMAL(10,2) NOT NULL,
  Activo     BIT NOT NULL
);

CREATE TABLE dbo.Ventas(
  VentaId    INT IDENTITY(1,1) PRIMARY KEY,
  ClienteId  INT NOT NULL,
  FechaVenta DATETIME2(0) NOT NULL,
  Estado     VARCHAR(20) NOT NULL, -- Pagada, Pendiente, Cancelada
  CONSTRAINT FK_Ventas_Clientes FOREIGN KEY (ClienteId) REFERENCES dbo.Clientes(ClienteId)
);

CREATE TABLE dbo.DetalleVenta(
  DetalleId  INT IDENTITY(1,1) PRIMARY KEY,
  VentaId    INT NOT NULL,
  ProductoId INT NOT NULL,
  Cantidad   INT NOT NULL,
  PrecioUnit DECIMAL(10,2) NOT NULL, -- precio al momento de la venta
  Descuento  DECIMAL(5,2) NOT NULL DEFAULT 0, -- % 0-100
  CONSTRAINT FK_Detalle_Ventas FOREIGN KEY (VentaId) REFERENCES dbo.Ventas(VentaId),
  CONSTRAINT FK_Detalle_Productos FOREIGN KEY (ProductoId) REFERENCES dbo.Productos(ProductoId)
);

CREATE TABLE dbo.Pagos(
  PagoId     INT IDENTITY(1,1) PRIMARY KEY,
  VentaId    INT NOT NULL,
  FechaPago  DATETIME2(0) NOT NULL,
  Monto      DECIMAL(10,2) NOT NULL,
  Metodo     VARCHAR(20) NOT NULL, -- Tarjeta, Transferencia, Efectivo
  CONSTRAINT FK_Pagos_Ventas FOREIGN KEY (VentaId) REFERENCES dbo.Ventas(VentaId)
);

-- Datos
INSERT INTO dbo.Clientes(Nombre, Email, Ciudad, FechaAlta, Activo) VALUES
('Ana Ruiz','ana@correo.com','Pachuca','2025-10-10',1),
('Luis Soto','luis@correo.com','Tula','2025-11-01',1),
('María Peña',NULL,'Tula','2025-09-15',1),
('Jorge Cano','jorge@correo.com','Tepeji','2025-07-20',0),
('Carla Díaz','carla@correo.com','Pachuca','2025-12-05',1);

INSERT INTO dbo.Productos(SKU,Nombre,Categoria,Precio,Activo) VALUES
('A100','Laptop 14','Computo',16500,1),
('A200','Mouse','Accesorios',250,1),
('A300','Teclado','Accesorios',450,1),
('B100','Monitor 24','Computo',3200,1),
('C100','Silla','Oficina',2100,0);

INSERT INTO dbo.Ventas(ClienteId,FechaVenta,Estado) VALUES
(1,'2026-01-05 10:10','Pagada'),
(2,'2026-01-06 12:20','Pagada'),
(2,'2026-01-10 09:00','Pendiente'),
(3,'2026-01-12 18:05','Cancelada'),
(5,'2026-02-01 14:40','Pagada');

INSERT INTO dbo.DetalleVenta(VentaId,ProductoId,Cantidad,PrecioUnit,Descuento) VALUES
(1,1,1,16500,5),
(1,2,2,250,0),
(2,4,1,3200,10),
(2,2,1,250,0),
(3,3,1,450,0),
(3,2,1,250,0),
(4,1,1,16500,0),
(5,2,3,250,0),
(5,3,1,450,0);

INSERT INTO dbo.Pagos(VentaId,FechaPago,Monto,Metodo) VALUES
(1,'2026-01-05 10:30',16000,'Tarjeta'),
(1,'2026-01-05 10:31',575,'Tarjeta'),
(2,'2026-01-06 12:40',3100,'Transferencia'),
(5,'2026-02-01 15:00',1200,'Efectivo');
```



## 1) Campos calculados, funciones y valores nulos

### ¿Qué es un campo calculado?
Es una **expresión en el SELECT** que se calcula “al vuelo” (no se guarda en la tabla). Se usa para totales, etiquetas, normalización de texto, reglas de negocio y reportes.

### Reglas clave que te evitan errores
- Si haces operaciones con enteros, usa `1.0` o `CAST(... AS decimal)` para evitar división entera.
- Cuando hay `NULL`, muchas expresiones devuelven `NULL`. Usa `ISNULL`/`COALESCE` para “asegurar” valores.
- `LEN()` en SQL Server **no cuenta espacios al final**.

### Sintaxis típica
```sql
SELECT
  Columna,
  Columna * 1.16 AS ConIVA,
  CONCAT(ColumnaTexto, ' - ', OtraColumna) AS Etiqueta,
  ISNULL(ColumnaNullable, 'valor') AS SinNulos
FROM dbo.Tabla;
```

### Mini-ejemplos guiados
**A) Total por línea con descuento**
```sql
SELECT
  d.DetalleId,
  d.Cantidad,
  d.PrecioUnit,
  d.Descuento,
  d.Cantidad*d.PrecioUnit AS Subtotal,
  d.Cantidad*d.PrecioUnit*(d.Descuento/100.0) AS MontoDescuento,
  d.Cantidad*d.PrecioUnit*(1 - d.Descuento/100.0) AS TotalLinea
FROM dbo.DetalleVenta d;
```

**B) Fecha de venta como Año-Mes**
```sql
SELECT VentaId, FechaVenta,
       FORMAT(FechaVenta, 'yyyy-MM') AS AnioMes
FROM dbo.Ventas;
```

**C) Email seguro (si viene NULL, pon 'sin-email')**
```sql
SELECT Nombre, ISNULL(Email,'sin-email') AS EmailSeguro
FROM dbo.Clientes;
```

### Ejercicios (10) + soluciones

**1) Lista clientes con una columna `Etiqueta` tipo: `NOMBRE (CIUDAD)` en mayúsculas.**

```sql
SELECT Nombre, Ciudad,
       CONCAT(UPPER(Nombre), ' (', UPPER(Ciudad), ')') AS Etiqueta
FROM dbo.Clientes;
```

**2) Muestra `Nombre`, `LongitudNombre` (LEN) y `Iniciales` (primeras 2 letras).**

```sql
SELECT Nombre,
       LEN(Nombre) AS LongitudNombre,
       LEFT(Nombre, 2) AS Iniciales
FROM dbo.Clientes;
```

**3) En Ventas, agrega `SoloFecha` (DATE) y `DiaSemana` (nombre del día).**

```sql
SELECT VentaId, FechaVenta,
       CAST(FechaVenta AS date) AS SoloFecha,
       DATENAME(weekday, FechaVenta) AS DiaSemana
FROM dbo.Ventas;
```

**4) En Ventas, calcula `DiasDesdeVenta` con respecto a hoy (GETDATE).**

```sql
SELECT VentaId, FechaVenta,
       DATEDIFF(day, CAST(FechaVenta AS date), CAST(GETDATE() AS date)) AS DiasDesdeVenta
FROM dbo.Ventas;
```

**5) En DetalleVenta, calcula `TotalLinea` con descuento y redondea a 2 decimales.**

```sql
SELECT DetalleId,
       ROUND(Cantidad*PrecioUnit*(1-Descuento/100.0), 2) AS TotalLinea
FROM dbo.DetalleVenta;
```

**6) En Productos, crea una columna `PrecioConIVA` (16%) y otra `PrecioRedondeado` a enteros.**

```sql
SELECT ProductoId, Nombre, Precio,
       ROUND(Precio*1.16, 2) AS PrecioConIVA,
       ROUND(Precio, 0) AS PrecioRedondeado
FROM dbo.Productos;
```

**7) Lista clientes con `EmailSeguro` usando COALESCE y otra columna `TieneEmail` (SI/NO) con CASE.**

```sql
SELECT Nombre,
       COALESCE(Email, 'sin-email') AS EmailSeguro,
       CASE WHEN Email IS NULL THEN 'NO' ELSE 'SI' END AS TieneEmail
FROM dbo.Clientes;
```

**8) Calcula el total pagado por cada venta en Pagos y un campo `FaltaPagar` suponiendo que el total de la venta es la suma de DetalleVenta (con descuento).**

```sql
SELECT
  tv.VentaId,
  tv.TotalVenta,
  pg.TotalPagado,
  tv.TotalVenta - ISNULL(pg.TotalPagado,0) AS FaltaPagar
FROM (
  SELECT d.VentaId,
         SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
  FROM dbo.DetalleVenta d
  GROUP BY d.VentaId
) tv
LEFT JOIN (
  SELECT p.VentaId, SUM(p.Monto) AS TotalPagado
  FROM dbo.Pagos p
  GROUP BY p.VentaId
) pg ON pg.VentaId = tv.VentaId;
```

**9) Usa NULLIF para evitar división por cero: calcula `MontoPromedioPago` = TotalPagado / NumPagos por VentaId.**

```sql
AS TotalPagado, COUNT(*) AS NumPagos
  FROM dbo.Pagos
  GROUP BY VentaId
)
SELECT VentaId, TotalPagado, NumPagos,
       TotalPagado*1.0 / NULLIF(NumPagos, 0) AS MontoPromedioPago
FROM (
SELECT VentaId, SUM(Monto
) PagosAgg;
```

**10) Crea una columna `EstadoCliente` que diga ACTIVO/INACTIVO a partir del BIT `Activo`.**

```sql
SELECT ClienteId, Nombre,
       CASE WHEN Activo = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END AS EstadoCliente
FROM dbo.Clientes;
```




## 2) GROUP BY

### ¿Qué hace GROUP BY?
Agrupa filas por una o varias columnas para calcular agregados como `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`.

### Regla de oro
En el `SELECT` solo puedes poner:
- columnas que estén en el `GROUP BY`, y/o
- expresiones agregadas (`SUM(...)`, `COUNT(...)`, etc.).

### Orden mental de ejecución (simplificado)
`FROM` → `WHERE` → `GROUP BY` → (agregados) → `SELECT` → `ORDER BY`

### Ejemplo base
```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad;
```
### Ejercicios (10) + soluciones

**1) Cuenta cuántos productos hay por `Categoria`.**

```sql
SELECT Categoria, COUNT(*) AS NumProductos
FROM dbo.Productos
GROUP BY Categoria;
```

**2) Obtén el precio promedio, mínimo y máximo por `Categoria`.**

```sql
SELECT Categoria,
       AVG(Precio*1.0) AS PrecioPromedio,
       MIN(Precio) AS PrecioMin,
       MAX(Precio) AS PrecioMax
FROM dbo.Productos
GROUP BY Categoria;
```

**3) Calcula el total (con descuento) por `VentaId` en DetalleVenta.**

```sql
SELECT VentaId,
       SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta
GROUP BY VentaId
ORDER BY VentaId;
```

**4) Calcula cuántas ventas hay por `Estado` en Ventas.**

```sql
SELECT Estado, COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY Estado;
```

**5) Total vendido (con descuento) por `Estado` de la venta (Pagada/Pendiente/Cancelada).**

```sql
SELECT v.Estado,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalPorEstado
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY v.Estado;
```

**6) Cantidad total vendida por `ProductoId` (y muestra también el nombre del producto).**

```sql
SELECT p.ProductoId, p.Nombre,
       SUM(d.Cantidad) AS CantidadVendida
FROM dbo.Productos p
JOIN dbo.DetalleVenta d ON d.ProductoId = p.ProductoId
GROUP BY p.ProductoId, p.Nombre
ORDER BY CantidadVendida DESC;
```

**7) Total vendido por `Categoria` (usa JOIN Productos + DetalleVenta).**

```sql
SELECT p.Categoria,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalCategoria
FROM dbo.Productos p
JOIN dbo.DetalleVenta d ON d.ProductoId = p.ProductoId
GROUP BY p.Categoria
ORDER BY TotalCategoria DESC;
```

**8) Ventas por Año-Mes (yyyy-MM) usando FORMAT en FechaVenta.**

```sql
SELECT FORMAT(FechaVenta,'yyyy-MM') AS AnioMes,
       COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY FORMAT(FechaVenta,'yyyy-MM')
ORDER BY AnioMes;
```

**9) Total vendido por Ciudad del cliente (Clientes + Ventas + DetalleVenta).**

```sql
SELECT c.Ciudad,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalCiudad
FROM dbo.Clientes c
JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY c.Ciudad
ORDER BY TotalCiudad DESC;
```

**10) Cuenta ventas distintas (COUNT DISTINCT) por cliente (muestra Cliente y NumVentas).**

```sql
SELECT c.ClienteId, c.Nombre,
       COUNT(DISTINCT v.VentaId) AS NumVentas
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
GROUP BY c.ClienteId, c.Nombre
ORDER BY NumVentas DESC;
```




## 3) HAVING

### ¿Qué hace HAVING?
`HAVING` filtra **grupos** (resultado del `GROUP BY`).
Si el filtro es por filas individuales, va en `WHERE`. Si el filtro depende de agregados (`SUM`, `COUNT`, `AVG`), va en `HAVING`.

### Ejemplo base
```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad
HAVING COUNT(*) >= 2;
```
### Ejercicios (10) + soluciones

**1) Muestra ciudades con **2 o más** clientes.**

```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad
HAVING COUNT(*) >= 2;
```

**2) Lista ventas cuyo total (con descuento) sea mayor a 5000.**

```sql
SELECT VentaId,
       SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta
GROUP BY VentaId
HAVING SUM(Cantidad*PrecioUnit*(1-Descuento/100.0)) > 5000
ORDER BY TotalVenta DESC;
```

**3) Muestra categorías donde el precio promedio sea mayor a 1000.**

```sql
SELECT Categoria, AVG(Precio*1.0) AS PrecioPromedio
FROM dbo.Productos
GROUP BY Categoria
HAVING AVG(Precio*1.0) > 1000;
```

**4) Clientes con **más de 1 venta** (cualquier estado).**

```sql
SELECT c.ClienteId, c.Nombre, COUNT(v.VentaId) AS NumVentas
FROM dbo.Clientes c
JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
GROUP BY c.ClienteId, c.Nombre
HAVING COUNT(v.VentaId) > 1;
```

**5) Productos con cantidad vendida total >= 2.**

```sql
SELECT p.ProductoId, p.Nombre, SUM(d.Cantidad) AS CantidadVendida
FROM dbo.Productos p
JOIN dbo.DetalleVenta d ON d.ProductoId = p.ProductoId
GROUP BY p.ProductoId, p.Nombre
HAVING SUM(d.Cantidad) >= 2
ORDER BY CantidadVendida DESC;
```

**6) Ventas pagadas cuyo total sea >= 3000 (usa JOIN con Ventas).**

```sql
SELECT v.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
WHERE v.Estado = 'Pagada'
GROUP BY v.VentaId
HAVING SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) >= 3000;
```

**7) Ciudades cuyo total vendido (con descuento) sea mayor a 3000.**

```sql
SELECT c.Ciudad,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalCiudad
FROM dbo.Clientes c
JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY c.Ciudad
HAVING SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) > 3000;
```

**8) Año-Mes con al menos 2 ventas.**

```sql
SELECT FORMAT(FechaVenta,'yyyy-MM') AS AnioMes, COUNT(*) AS NumVentas
FROM dbo.Ventas
GROUP BY FORMAT(FechaVenta,'yyyy-MM')
HAVING COUNT(*) >= 2
ORDER BY AnioMes;
```

**9) Métodos de pago con total cobrado > 1000.**

```sql
SELECT Metodo, SUM(Monto) AS TotalCobrado
FROM dbo.Pagos
GROUP BY Metodo
HAVING SUM(Monto) > 1000
ORDER BY TotalCobrado DESC;
```

**10) Ventas que tienen **2 o más** líneas en DetalleVenta.**

```sql
SELECT VentaId, COUNT(*) AS NumLineas
FROM dbo.DetalleVenta
GROUP BY VentaId
HAVING COUNT(*) >= 2
ORDER BY NumLineas DESC;
```




## 4) JOINS (consultas multitabla)

### ¿Qué es un JOIN?
Une filas de dos (o más) tablas usando una condición (`ON`).

### Tipos más usados
- `INNER JOIN`: solo filas con match en ambas tablas.
- `LEFT JOIN`: trae todo de la izquierda y NULLs cuando no hay match.
- `FULL OUTER JOIN`: todo de ambos lados (cuando existe).
- `CROSS JOIN`: producto cartesiano (casi nunca en producción sin cuidado).

### Regla práctica
En reportes: suele ser `Ventas → Clientes` (1 a N) y `Ventas → DetalleVenta` (1 a N), y `DetalleVenta → Productos` (N a 1).

### Ejemplo base
```sql
SELECT v.VentaId, v.FechaVenta, c.Nombre AS Cliente
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId;
```

### Error común
Filtrar una tabla del `LEFT JOIN` en `WHERE` puede convertirlo en `INNER` sin querer.
- Correcto: filtrar del lado derecho en el `ON` o usar `WHERE ... IS NULL` según el caso.
### Ejercicios (10) + soluciones

**1) Lista todas las ventas con el nombre del cliente y su ciudad.**

```sql
SELECT v.VentaId, v.FechaVenta, v.Estado,
       c.Nombre AS Cliente, c.Ciudad
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
ORDER BY v.VentaId;
```

**2) Muestra el detalle de cada venta: VentaId, FechaVenta, Cliente, Producto, Cantidad, PrecioUnit.**

```sql
SELECT v.VentaId, v.FechaVenta,
       c.Nombre AS Cliente,
       p.Nombre AS Producto,
       d.Cantidad, d.PrecioUnit
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
JOIN dbo.Productos p ON p.ProductoId = d.ProductoId
ORDER BY v.VentaId, d.DetalleId;
```

**3) Encuentra clientes **sin ventas** (LEFT JOIN).**

```sql
SELECT c.ClienteId, c.Nombre
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
WHERE v.VentaId IS NULL;
```

**4) Encuentra ventas **sin pagos** usando LEFT JOIN (no subconsulta).**

```sql
SELECT v.VentaId, v.Estado, v.FechaVenta
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
WHERE p.PagoId IS NULL
ORDER BY v.VentaId;
```

**5) Suma el total pagado por venta (Ventas + Pagos) mostrando ventas aunque no tengan pagos.**

```sql
SELECT v.VentaId, v.Estado,
       SUM(ISNULL(p.Monto,0)) AS TotalPagado
FROM dbo.Ventas v
LEFT JOIN dbo.Pagos p ON p.VentaId = v.VentaId
GROUP BY v.VentaId, v.Estado
ORDER BY v.VentaId;
```

**6) Saca un reporte de ventas pagadas con: VentaId, Cliente, TotalVenta (con descuento).**

```sql
SELECT v.VentaId, c.Nombre AS Cliente,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
WHERE v.Estado = 'Pagada'
GROUP BY v.VentaId, c.Nombre
ORDER BY TotalVenta DESC;
```

**7) Lista productos y cuántas veces aparecen en detalle (incluye productos nunca vendidos).**

```sql
SELECT p.ProductoId, p.Nombre,
       COUNT(d.DetalleId) AS VecesEnDetalle
FROM dbo.Productos p
LEFT JOIN dbo.DetalleVenta d ON d.ProductoId = p.ProductoId
GROUP BY p.ProductoId, p.Nombre
ORDER BY VecesEnDetalle DESC;
```

**8) FULL OUTER JOIN: lista todos los clientes y todas las ventas, incluso si hay clientes sin ventas. (Tip: ver columnas NULL).**

```sql
SELECT c.ClienteId, c.Nombre,
       v.VentaId, v.Estado
FROM dbo.Clientes c
FULL OUTER JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
ORDER BY ISNULL(c.ClienteId, 9999), ISNULL(v.VentaId, 9999);
```

**9) CROSS JOIN: genera todas las combinaciones Cliente x Producto (solo para practicar).**

```sql
SELECT c.ClienteId, c.Nombre AS Cliente,
       p.ProductoId, p.Nombre AS Producto
FROM dbo.Clientes c
CROSS JOIN dbo.Productos p
ORDER BY c.ClienteId, p.ProductoId;
```

**10) Join + condición en ON: trae clientes con ventas pagadas (y deja NULL si no tiene pagadas).**

```sql
SELECT c.ClienteId, c.Nombre,
       v.VentaId, v.Estado
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v
  ON v.ClienteId = c.ClienteId
 AND v.Estado = 'Pagada'
ORDER BY c.ClienteId, v.VentaId;
```




## 5) CASE (condiciones dentro del SELECT)

### ¿Qué es CASE?
Es el equivalente a un **if/else** dentro de SQL. Se usa para clasificar, crear etiquetas, normalizar valores y aplicar reglas de negocio en reportes.

### Dos formas
**A) CASE buscado (el más flexible)**
```sql
CASE
  WHEN condicion THEN resultado
  WHEN condicion THEN resultado
  ELSE resultado
END
```
**B) CASE simple (compara contra un valor)**
```sql
CASE Columna
  WHEN 'A' THEN '...'
  WHEN 'B' THEN '...'
  ELSE '...'
END
```

### Tip práctico
Si tu CASE depende de un total agregado, primero calcula el total (tabla derivada/tabla derivada) y luego aplica CASE.
### Ejercicios (10) + soluciones

**1) Normaliza el estado de la venta: Pagada→OK, Pendiente→REVISAR, Cancelada→ANULAR, otro→OTRO.**

```sql
SELECT VentaId, Estado,
       CASE Estado
         WHEN 'Pagada' THEN 'OK'
         WHEN 'Pendiente' THEN 'REVISAR'
         WHEN 'Cancelada' THEN 'ANULAR'
         ELSE 'OTRO'
       END AS EstadoNormalizado
FROM dbo.Ventas;
```

**2) Etiqueta clientes como 'CON EMAIL' / 'SIN EMAIL' usando CASE.**

```sql
SELECT ClienteId, Nombre,
       CASE WHEN Email IS NULL THEN 'SIN EMAIL' ELSE 'CON EMAIL' END AS EtiquetaEmail
FROM dbo.Clientes;
```

**3) Clasifica productos por precio: <=500 'BARATO', <=3000 'MEDIO', >3000 'CARO'.**

```sql
SELECT ProductoId, Nombre, Precio,
       CASE
         WHEN Precio <= 500 THEN 'BARATO'
         WHEN Precio <= 3000 THEN 'MEDIO'
         ELSE 'CARO'
       END AS RangoPrecio
FROM dbo.Productos
ORDER BY Precio;
```

**4) En DetalleVenta, crea una columna `TieneDescuento` (SI/NO).**

```sql
SELECT DetalleId, Descuento,
       CASE WHEN Descuento > 0 THEN 'SI' ELSE 'NO' END AS TieneDescuento
FROM dbo.DetalleVenta;
```

**5) Calcula total por venta y segmenta: >=10000 'ALTA', >=3000 'MEDIA', <3000 'BAJA'.**

```sql
) AS TotalVenta
  FROM dbo.DetalleVenta
  GROUP BY VentaId
)
SELECT VentaId, TotalVenta,
       CASE
         WHEN TotalVenta >= 10000 THEN 'ALTA'
         WHEN TotalVenta >= 3000 THEN 'MEDIA'
         ELSE 'BAJA'
       END AS Segmento
FROM (
SELECT VentaId,
         SUM(Cantidad*PrecioUnit*(1-Descuento/100.0
) Totales
ORDER BY TotalVenta DESC;
```

**6) Marca ventas como 'LIQUIDADA' si TotalPagado >= TotalVenta, si no 'PENDIENTE DE PAGO'.**

```sql
) AS TotalVenta
  FROM dbo.DetalleVenta d
  GROUP BY d.VentaId
), TotalesPago AS (
  SELECT VentaId, SUM(Monto) AS TotalPagado
  FROM dbo.Pagos
  GROUP BY VentaId
)
SELECT v.VentaId,
       tv.TotalVenta,
       ISNULL(tp.TotalPagado,0) AS TotalPagado,
       CASE WHEN ISNULL(tp.TotalPagado,0) >= tv.TotalVenta THEN 'LIQUIDADA'
            ELSE 'PENDIENTE DE PAGO' END AS EstadoPago
FROM dbo.Ventas v
JOIN (
SELECT d.VentaId,
         SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0
) TotalesVenta tv ON tv.VentaId = v.VentaId
LEFT JOIN TotalesPago tp ON tp.VentaId = v.VentaId
ORDER BY v.VentaId;
```

**7) Clasifica clientes por antigüedad: FechaAlta <= 2025-09-30 'ANTERIOR', si no 'NUEVO'.**

```sql
SELECT ClienteId, Nombre, FechaAlta,
       CASE WHEN FechaAlta <= '2025-09-30' THEN 'ANTERIOR' ELSE 'NUEVO' END AS Antiguedad
FROM dbo.Clientes;
```

**8) En Pagos, crea una etiqueta de método: Tarjeta/Transferencia/Efectivo y si otro 'OTRO'.**

```sql
SELECT PagoId, Metodo,
       CASE Metodo
         WHEN 'Tarjeta' THEN 'Tarjeta'
         WHEN 'Transferencia' THEN 'Transferencia'
         WHEN 'Efectivo' THEN 'Efectivo'
         ELSE 'OTRO'
       END AS MetodoEtiqueta
FROM dbo.Pagos;
```

**9) Crea un campo `EstadoProducto` = ACTIVO/INACTIVO a partir del BIT Activo.**

```sql
SELECT ProductoId, Nombre,
       CASE WHEN Activo = 1 THEN 'ACTIVO' ELSE 'INACTIVO' END AS EstadoProducto
FROM dbo.Productos;
```

**10) Genera una columna `Observacion` en Ventas: si Estado='Cancelada' → 'NO CONTABILIZAR', si no 'OK'.**

```sql
SELECT VentaId, Estado,
       CASE WHEN Estado = 'Cancelada' THEN 'NO CONTABILIZAR' ELSE 'OK' END AS Observacion
FROM dbo.Ventas;
```




## 6) Subconsultas (IN, EXISTS/NOT EXISTS, ANY, ALL, correlacionadas)

### ¿Qué es una subconsulta?
Es una consulta dentro de otra. Puede devolver:
- **1 valor** (escalar)
- **1 columna con varios valores** (lista)
- **una tabla** (tabla derivada)

### Tipos útiles en SQL Server
1) **Escalar**: se usa como un valor.
2) **IN**: filtra por una lista.
3) **EXISTS / NOT EXISTS**: verifica existencia (muy usado para 'tiene' / 'no tiene').
4) **Correlacionada**: la subconsulta usa columnas de la consulta externa.
5) **ANY / ALL**: compara contra alguno o todos.

### Nota práctica
Para 'no tiene relacionados', `NOT EXISTS` suele ser más robusto que `NOT IN` si puede haber `NULL`.
### Ejercicios (10) + soluciones

**1) Subconsulta escalar: muestra en una sola fila el total de ventas y el total de clientes.**

```sql
SELECT
  (SELECT COUNT(*) FROM dbo.Ventas) AS TotalVentas,
  (SELECT COUNT(*) FROM dbo.Clientes) AS TotalClientes;
```

**2) Clientes que tienen al menos una venta pagada (EXISTS).**

```sql
SELECT c.*
FROM dbo.Clientes c
WHERE EXISTS (
  SELECT 1
  FROM dbo.Ventas v
  WHERE v.ClienteId = c.ClienteId
    AND v.Estado = 'Pagada'
);
```

**3) Clientes que NO tienen ninguna venta (NOT EXISTS).**

```sql
SELECT c.*
FROM dbo.Clientes c
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.Ventas v
  WHERE v.ClienteId = c.ClienteId
);
```

**4) Ventas sin pagos registrados (NOT EXISTS en Pagos).**

```sql
SELECT v.*
FROM dbo.Ventas v
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.Pagos p
  WHERE p.VentaId = v.VentaId
);
```

**5) Productos nunca vendidos (NOT EXISTS en DetalleVenta).**

```sql
SELECT p.*
FROM dbo.Productos p
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.DetalleVenta d
  WHERE d.ProductoId = p.ProductoId
);
```

**6) Clientes que están en la lista de quienes tienen ventas canceladas (IN).**

```sql
SELECT *
FROM dbo.Clientes
WHERE ClienteId IN (
  SELECT ClienteId
  FROM dbo.Ventas
  WHERE Estado = 'Cancelada'
);
```

**7) Productos con precio mayor que el promedio (subconsulta escalar en WHERE).**

```sql
SELECT *
FROM dbo.Productos
WHERE Precio > (
  SELECT AVG(Precio*1.0) FROM dbo.Productos
);

```

**8) ANY: productos con precio mayor que **algún** precio de Accesorios.**

```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ANY (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Accesorios'
);
```

**9) ALL: productos con precio mayor que **todos** los precios de Accesorios.**

```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ALL (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Accesorios'
);
```

**10) Correlacionada en SELECT: para cada venta, muestra TotalVenta (con descuento) calculado por subconsulta.**

```sql
SELECT v.VentaId, v.Estado,
       (
         SELECT SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0))
         FROM dbo.DetalleVenta d
         WHERE d.VentaId = v.VentaId
       ) AS TotalVenta
FROM dbo.Ventas v
ORDER BY v.VentaId;
```




## 7) Vistas (VIEW)

### ¿Qué es una VIEW?
Una vista es una **consulta guardada**. No almacena datos (salvo vistas indexadas, tema avanzado), pero ayuda a:
- reutilizar lógica,
- simplificar reportes,
- dar acceso controlado (solo ciertas columnas).

### Buenas prácticas rápidas
- Nombra vistas con prefijo `vw_`.
- Evita `SELECT *` dentro de la vista.
- Si necesitas ordenar, hazlo al consultar la vista (no dentro).

### Sintaxis
```sql
CREATE OR ALTER VIEW dbo.vw_Nombre
AS
  SELECT ...
GO
```
### Ejercicios (10) + soluciones

**1) Crea una vista `vw_VentasConCliente` con VentaId, FechaVenta, Estado, Cliente, Ciudad.**

```sql
CREATE OR ALTER VIEW dbo.vw_VentasConCliente
AS
SELECT v.VentaId, v.FechaVenta, v.Estado,
       c.Nombre AS Cliente, c.Ciudad
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId;
GO
SELECT * FROM dbo.vw_VentasConCliente ORDER BY VentaId;
```

**2) Crea una vista `vw_DetalleExtendido` con VentaId, Cliente, Producto, Categoria, Cantidad, PrecioUnit, Descuento, TotalLinea.**

```sql
CREATE OR ALTER VIEW dbo.vw_DetalleExtendido
AS
SELECT v.VentaId,
       c.Nombre AS Cliente,
       p.Nombre AS Producto,
       p.Categoria,
       d.Cantidad, d.PrecioUnit, d.Descuento,
       d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0) AS TotalLinea
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
JOIN dbo.Productos p ON p.ProductoId = d.ProductoId;
GO
SELECT TOP (50) * FROM dbo.vw_DetalleExtendido ORDER BY VentaId;
```

**3) Crea una vista `vw_VentasTotales` (como en la guía) y úsala para mostrar solo pagadas.**

```sql
CREATE OR ALTER VIEW dbo.vw_VentasTotales
AS
SELECT v.VentaId, v.ClienteId, v.FechaVenta, v.Estado,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY v.VentaId, v.ClienteId, v.FechaVenta, v.Estado;
GO
SELECT *
FROM dbo.vw_VentasTotales
WHERE Estado = 'Pagada'
ORDER BY TotalVenta DESC;
```

**4) Crea una vista `vw_PagosPorVenta` con VentaId, TotalPagado y NumPagos.**

```sql
CREATE OR ALTER VIEW dbo.vw_PagosPorVenta
AS
SELECT VentaId,
       SUM(Monto) AS TotalPagado,
       COUNT(*) AS NumPagos
FROM dbo.Pagos
GROUP BY VentaId;
GO
SELECT * FROM dbo.vw_PagosPorVenta ORDER BY VentaId;
```

**5) Usa `vw_VentasTotales` y `vw_PagosPorVenta` para mostrar por venta: TotalVenta, TotalPagado y FaltaPagar.**

```sql
SELECT vt.VentaId, vt.Estado, vt.TotalVenta,
       ISNULL(pv.TotalPagado,0) AS TotalPagado,
       vt.TotalVenta - ISNULL(pv.TotalPagado,0) AS FaltaPagar
FROM dbo.vw_VentasTotales vt
LEFT JOIN dbo.vw_PagosPorVenta pv ON pv.VentaId = vt.VentaId
ORDER BY vt.VentaId;
```

**6) Crea una vista `vw_ProductosActivos` que muestre solo productos Activo=1.**

```sql
CREATE OR ALTER VIEW dbo.vw_ProductosActivos
AS
SELECT ProductoId, SKU, Nombre, Categoria, Precio
FROM dbo.Productos
WHERE Activo = 1;
GO
SELECT * FROM dbo.vw_ProductosActivos ORDER BY Categoria, Precio;
```

**7) Crea una vista de reporte mensual `vw_VentasPorMes` (AnioMes, NumVentas, TotalVendido).**

```sql
CREATE OR ALTER VIEW dbo.vw_VentasPorMes
AS
SELECT FORMAT(v.FechaVenta,'yyyy-MM') AS AnioMes,
       COUNT(DISTINCT v.VentaId) AS NumVentas,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVendido
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY FORMAT(v.FechaVenta,'yyyy-MM');
GO
SELECT * FROM dbo.vw_VentasPorMes ORDER BY AnioMes;
```

**8) Actualiza (ALTER) `vw_ProductosActivos` para incluir la columna `EstadoProducto` (ACTIVO/INACTIVO) usando CASE.**

```sql
CREATE OR ALTER VIEW dbo.vw_ProductosActivos
AS
SELECT ProductoId, SKU, Nombre, Categoria, Precio,
       CASE WHEN Activo=1 THEN 'ACTIVO' ELSE 'INACTIVO' END AS EstadoProducto
FROM dbo.Productos
WHERE Activo = 1;
GO
SELECT * FROM dbo.vw_ProductosActivos;
```

**9) Crea una vista `vw_ClientesResumen` con ClienteId, Cliente, Ciudad, NumVentas, TotalComprado (solo ventas pagadas).**

```sql
CREATE OR ALTER VIEW dbo.vw_ClientesResumen
AS
SELECT c.ClienteId, c.Nombre AS Cliente, c.Ciudad,
       COUNT(DISTINCT v.VentaId) AS NumVentas,
       ISNULL(SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)),0) AS TotalComprado
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v
  ON v.ClienteId = c.ClienteId
 AND v.Estado = 'Pagada'
LEFT JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY c.ClienteId, c.Nombre, c.Ciudad;
GO
SELECT * FROM dbo.vw_ClientesResumen ORDER BY TotalComprado DESC;
```

**10) Usa una vista (elige cualquiera) y filtra/ordena desde afuera (demuestra que el ORDER BY va en la consulta, no en la vista).**

```sql
SELECT *
FROM dbo.vw_ClientesResumen
WHERE Ciudad = 'Tula'
ORDER BY NumVentas DESC, TotalComprado DESC;
```




## 8) Índices (INDEX)

### ¿Qué es un índice?
Es una estructura (como un “índice de libro”) que acelera búsquedas, joins y ordenamientos.

### Trade-off (costo/beneficio)
- **Beneficio:** lecturas más rápidas (SEEK en lugar de SCAN).
- **Costo:** más espacio y más trabajo al insertar/actualizar/eliminar.

### Tipos básicos (lo más práctico)
- **Clustered**: define el orden físico (solo 1 por tabla).
- **Nonclustered**: índices adicionales (puede haber varios).
- **Índice compuesto**: varias columnas.
- **INCLUDE**: columnas “extra” para cubrir una consulta.
- **Filtered index**: índice para un subconjunto (ej. solo Estado='Pagada').

### Cómo medir rápido
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
-- ejecuta tu consulta
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

### Índices sugeridos para este dataset (base)
```sql
CREATE INDEX IX_Ventas_Cliente_Fecha ON dbo.Ventas(ClienteId, FechaVenta);
CREATE INDEX IX_DetalleVenta_VentaId ON dbo.DetalleVenta(VentaId);
CREATE INDEX IX_DetalleVenta_ProductoId ON dbo.DetalleVenta(ProductoId);
CREATE INDEX IX_Pagos_VentaId ON dbo.Pagos(VentaId);
```
### Ejercicios (10) + soluciones

**1) Crea los 4 índices sugeridos (si no existen).**

```sql
CREATE INDEX IX_Ventas_Cliente_Fecha ON dbo.Ventas(ClienteId, FechaVenta);
CREATE INDEX IX_DetalleVenta_VentaId ON dbo.DetalleVenta(VentaId);
CREATE INDEX IX_DetalleVenta_ProductoId ON dbo.DetalleVenta(ProductoId);
CREATE INDEX IX_Pagos_VentaId ON dbo.Pagos(VentaId);
```

**2) Mide IO/TIME antes y después: consulta total por VentaId en DetalleVenta.**

```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT d.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta d
GROUP BY d.VentaId;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```

**3) Crea un índice para acelerar consultas por `Estado` y `FechaVenta` en Ventas.**

```sql
CREATE INDEX IX_Ventas_Estado_Fecha
ON dbo.Ventas(Estado, FechaVenta);
```

**4) Crea un índice filtrado solo para ventas pagadas (cuando la mayoría NO son pagadas).**

```sql
CREATE INDEX IX_Ventas_Pagadas_Fecha
ON dbo.Ventas(FechaVenta)
WHERE Estado = 'Pagada';
```

**5) Crea un índice con INCLUDE para cubrir una consulta: buscar ventas por ClienteId y devolver FechaVenta y Estado.**

```sql
CREATE INDEX IX_Ventas_ClienteId_Includes
ON dbo.Ventas(ClienteId)
INCLUDE(FechaVenta, Estado);
```

**6) Identifica un query típico: pagos por VentaId (sum/método). Propón índice compuesto en Pagos (VentaId, Metodo).**

```sql
CREATE INDEX IX_Pagos_VentaId_Metodo
ON dbo.Pagos(VentaId, Metodo)
INCLUDE(Monto, FechaPago);
```

**7) Crea un índice en Productos por Categoria y Precio para acelerar reportes por categoría ordenados por precio.**

```sql
CREATE INDEX IX_Productos_Categoria_Precio
ON dbo.Productos(Categoria, Precio)
INCLUDE(Nombre, SKU);
```

**8) Ejecuta una consulta que use ese índice: productos activos por categoría y rango de precio.**

```sql
SELECT ProductoId, SKU, Nombre, Categoria, Precio
FROM dbo.Productos
WHERE Activo = 1
  AND Categoria = 'Accesorios'
  AND Precio BETWEEN 200 AND 600
ORDER BY Precio;
```

**9) Muestra los índices existentes en tus tablas (consulta a sys.indexes).**

```sql
SELECT t.name AS Tabla,
       i.name AS Indice,
       i.type_desc,
       i.is_unique,
       i.has_filter,
       i.filter_definition
FROM sys.indexes i
JOIN sys.tables t ON t.object_id = i.object_id
WHERE t.name IN ('Clientes','Productos','Ventas','DetalleVenta','Pagos')
ORDER BY t.name, i.name;
```

**10) Elimina (DROP) un índice de prueba (si lo creaste) y vuelve a medir IO/TIME para ver el cambio.**

```sql
DROP INDEX IF EXISTS dbo.Ventas.IX_Ventas_ClienteId_Includes;

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
SELECT VentaId, FechaVenta, Estado
FROM dbo.Ventas
WHERE ClienteId = 2
ORDER BY FechaVenta;
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
```




## 9) Reto integrador

Usa lo aprendido para construir un reporte completo.

### Reto (con solución)
**A) Crea una vista `vw_ReporteVentas` con:**
`VentaId, FechaVenta, AnioMes, Cliente, Ciudad, TotalVenta, SegmentoTotal (CASE: Alta/Media/Baja), TotalPagado, FaltaPagar`

**B) Consulta esa vista para mostrar solo Pagadas, ordenadas por TotalVenta DESC.**

**C) Lista clientes con `Riesgo` si no tienen ninguna venta pagada (CASE + NOT EXISTS).**

```sql
CREATE OR ALTER VIEW dbo.vw_ReporteVentas
AS
SELECT
  v.VentaId,
  v.FechaVenta,
  FORMAT(v.FechaVenta,'yyyy-MM') AS AnioMes,
  v.Estado,
  c.Nombre AS Cliente,
  tv.TotalVenta,
  pg.TotalPagado,
  tv.TotalVenta - ISNULL(pg.TotalPagado,0) AS FaltaPagar
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId
JOIN (
  SELECT d.VentaId,
         SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
  FROM dbo.DetalleVenta d
  GROUP BY d.VentaId
) tv ON tv.VentaId = v.VentaId
LEFT JOIN (
  SELECT VentaId, SUM(Monto) AS TotalPagado
  FROM dbo.Pagos
  GROUP BY VentaId
) pg ON pg.VentaId = v.VentaId;
GO
```

