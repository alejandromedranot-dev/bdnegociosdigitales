# Guía práctica de SQL Server  
**GROUP BY, HAVING, JOINS, Subconsultas (IN, EXISTS/NOT EXISTS, ANY, ALL), CASE, Vistas e Índices (con ejemplos y ejercicios)**

Esta guía está diseñada para practicar en **SQL Server** paso a paso con un dataset pequeño. Incluye:  
**explicación (qué es y para qué sirve), sintaxis, cómo funciona, ejemplos y ejercicios (con solución)**.

---

## 0) Dataset de práctica (para ejecutar todo)

Copia y ejecuta este script en una base de datos de prueba. Luego podrás hacer todas las consultas de la guía.

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

---

## 1) Campos calculados, funciones y valores nulos

### 1.1 ¿Qué es un campo calculado?
Es una **expresión** dentro del `SELECT` que produce un valor derivado **sin guardarlo** en la tabla.  
Sirve para: **totales**, **etiquetas**, **normalización**, **reglas de negocio en reportes**.

### 1.2 Funciones de texto
**UPPER, LOWER, LEN, LEFT/RIGHT, CONCAT**

**Sintaxis / idea**
- `UPPER(texto)`: mayúsculas  
- `LOWER(texto)`: minúsculas  
- `LEN(texto)`: longitud (en SQL Server **no cuenta espacios finales**)  
- `LEFT(texto, n)` / `RIGHT(texto, n)`  
- `CONCAT(a,b,...)`: concatena; trata `NULL` como cadena vacía

**Ejemplo**
```sql
SELECT
  Nombre,
  UPPER(Ciudad) AS Ciudad_MAYUS,
  LEN(Nombre) AS LongitudNombre,
  LEFT(Nombre, 3) AS Prefijo,
  CONCAT(Nombre, ' - ', Ciudad) AS Etiqueta
FROM dbo.Clientes;
```

### 1.3 Funciones de fecha
**GETDATE, CAST, DATENAME, DATEADD, DATEDIFF, FORMAT**

**Ejemplo**
```sql
SELECT
  VentaId,
  FechaVenta,
  GETDATE() AS Ahora,
  CAST(FechaVenta AS date) AS SoloFecha,
  DATENAME(weekday, FechaVenta) AS DiaSemana,
  DATEADD(day, 7, FechaVenta) AS Mas7Dias,
  DATEDIFF(day, CAST(FechaVenta AS date), CAST(GETDATE() AS date)) AS DiasDesdeVenta,
  FORMAT(FechaVenta,'yyyy-MM') AS AnioMes
FROM dbo.Ventas;
```

### 1.4 Matemáticas y agregados
**ROUND, SUM, COUNT, AVG, MIN, MAX**

**Ejemplo (total por línea con descuento)**
```sql
SELECT
  d.DetalleId,
  d.Cantidad * d.PrecioUnit AS Subtotal,
  d.Cantidad * d.PrecioUnit * (d.Descuento/100.0) AS MontoDescuento,
  d.Cantidad * d.PrecioUnit * (1 - d.Descuento/100.0) AS TotalLinea
FROM dbo.DetalleVenta d;
```

### 1.5 Valores nulos: `IS NULL`, `COALESCE`, `ISNULL`, `NULLIF`

#### A) `IS NULL` / `IS NOT NULL`
**Para qué sirve:** filtrar valores nulos.

```sql
SELECT * FROM dbo.Clientes WHERE Email IS NULL;
SELECT * FROM dbo.Clientes WHERE Email IS NOT NULL;
```

#### B) `COALESCE(a,b,c,...)`
**Para qué sirve:** primer valor **no NULL** (estándar SQL).

```sql
SELECT Nombre, COALESCE(Email,'sin-email') AS EmailSeguro
FROM dbo.Clientes;
```

#### C) `ISNULL(exp, reemplazo)`  ✅ (agregado)
**Para qué sirve:** reemplaza `NULL` por un valor. Es **propio de SQL Server** (más “corto” que COALESCE).  
**Regla importante:** el tipo de salida suele seguir el tipo del primer argumento.

```sql
SELECT Nombre, ISNULL(Email,'sin-email') AS EmailSeguro
FROM dbo.Clientes;
```

**Comparación rápida**
- `ISNULL(x,y)` → solo 2 argumentos, SQL Server  
- `COALESCE(x,y,z,...)` → múltiples argumentos, estándar

#### D) `NULLIF(a,b)`
**Para qué sirve:** regresa `NULL` si `a=b`, si no regresa `a`. Útil para evitar divisiones por cero.

```sql
-- Evitar división por cero (ejemplo general)
SELECT 100.0 / NULLIF(0,0) AS EvitaError; -- devuelve NULL en lugar de error
```

---

## 2) GROUP BY y HAVING

### 2.1 GROUP BY
**Para qué sirve:** agrupar filas y calcular métricas por grupo.

**Sintaxis**
```sql
SELECT columna_grupo, AGREGADO(columna)
FROM tabla
GROUP BY columna_grupo;
```

**Ejemplos**
```sql
SELECT Ciudad, COUNT(*) AS NumClientes
FROM dbo.Clientes
GROUP BY Ciudad;

SELECT d.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta d
GROUP BY d.VentaId;
```

### 2.2 HAVING
**Para qué sirve:** filtrar grupos (después de agrupar).

**Sintaxis**
```sql
SELECT columna_grupo, AGREGADO(columna) AS Metrica
FROM tabla
GROUP BY columna_grupo
HAVING AGREGADO(columna) > valor;
```

**Ejemplo**
```sql
SELECT d.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta d
GROUP BY d.VentaId
HAVING SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) > 5000;
```

---

## 3) JOINS (consultas multitabla)

### 3.1 INNER JOIN
```sql
SELECT v.VentaId, v.FechaVenta, c.Nombre AS Cliente
FROM dbo.Ventas v
JOIN dbo.Clientes c ON c.ClienteId = v.ClienteId;
```

### 3.2 LEFT JOIN
```sql
SELECT c.ClienteId, c.Nombre, v.VentaId
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON v.ClienteId = c.ClienteId
WHERE v.VentaId IS NULL; -- clientes sin ventas
```

---

## 4) CASE (condiciones dentro del SELECT)

### Sintaxis
```sql
CASE
  WHEN condicion THEN resultado
  WHEN condicion THEN resultado
  ELSE resultado
END
```

### Ejemplo (normalizar estado)
```sql
SELECT VentaId, Estado,
       CASE
         WHEN Estado = 'Pagada' THEN 'OK'
         WHEN Estado = 'Pendiente' THEN 'Revisar'
         WHEN Estado = 'Cancelada' THEN 'Anular'
         ELSE 'Otro'
       END AS EstadoNormalizado
FROM dbo.Ventas;
```

---

## 5) Subconsultas (IN, EXISTS/NOT EXISTS, ANY, ALL) ✅ (ampliado)

### 5.1 ¿Qué es una subconsulta?
Es una consulta dentro de otra. Se usa para **filtrar**, **comparar**, **calcular valores**, o construir una **tabla derivada**.

### 5.2 Subconsulta escalar (1 valor)
```sql
SELECT (SELECT COUNT(*) FROM dbo.Ventas) AS TotalVentas;
```

### 5.3 Subconsulta de lista con `IN`
```sql
SELECT *
FROM dbo.Clientes
WHERE ClienteId IN (
  SELECT ClienteId
  FROM dbo.Ventas
  WHERE Estado = 'Pagada'
);
```

### 5.4 `EXISTS` / `NOT EXISTS` ✅ (explicación clara)
**Idea:** `EXISTS` devuelve verdadero si la subconsulta encuentra al menos una fila.  
No te importa “qué” devuelve, solo si **existe**.

**Clientes con al menos una venta pagada (EXISTS):**
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

**Productos nunca vendidos (NOT EXISTS):**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.DetalleVenta d
  WHERE d.ProductoId = p.ProductoId
);
```

> Nota práctica: para “nunca / no tiene relacionados”, `NOT EXISTS` suele ser más seguro que `NOT IN` cuando puede haber `NULL`.

### 5.5 `ANY` y `ALL` ✅ (agregado)

#### A) `ANY` (también se escribe `SOME`)
**Para qué sirve:** comparar un valor contra **alguno** de los valores de una subconsulta.  
- `x > ANY(...)` significa: x es mayor que **al menos uno** de los valores.  
- `x < ANY(...)` significa: x es menor que **al menos uno** de los valores.

**Sintaxis**
```sql
expresion operador ANY (subconsulta)
```

**Ejemplo 1: productos con precio mayor que “algún” precio de la categoría Computo**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ANY (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Computo'
);
```
En este dataset, esto suele equivaler a “precio mayor que el mínimo de Computo”.

#### B) `ALL`
**Para qué sirve:** comparar un valor contra **todos** los valores de una subconsulta.  
- `x > ALL(...)` significa: x es mayor que **todos** (x > máximo).  
- `x < ALL(...)` significa: x es menor que **todos** (x < mínimo).

**Sintaxis**
```sql
expresion operador ALL (subconsulta)
```

**Ejemplo 2: productos con precio mayor que todos los precios de Accesorios**
```sql
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ALL (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Accesorios'
);
```
Esto equivale a “precio mayor que el máximo de Accesorios”.

> Tip mental rápido:  
> - `> ALL` ↔ “mayor que el máximo”  
> - `< ALL` ↔ “menor que el mínimo”  
> - `> ANY` ↔ “mayor que al menos uno” (típicamente mayor que el mínimo)  
> - `< ANY` ↔ “menor que al menos uno” (típicamente menor que el máximo)

### 5.6 Tabla derivada (subconsulta en FROM)
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

### 5.7 Ejercicios (Subconsultas) + soluciones
**Ejercicios**
1) Clientes que NO tienen ventas pagadas (NOT EXISTS).  
2) Ventas sin pagos registrados (NOT EXISTS en Pagos).  
3) Productos con precio > promedio de precios (escalar).  
4) Productos con precio > ALL de Accesorios.  
5) Productos con precio < ANY de Computo.

**Soluciones**
```sql
-- 1
SELECT c.*
FROM dbo.Clientes c
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.Ventas v
  WHERE v.ClienteId = c.ClienteId
    AND v.Estado = 'Pagada'
);

-- 2
SELECT v.*
FROM dbo.Ventas v
WHERE NOT EXISTS (
  SELECT 1
  FROM dbo.Pagos p
  WHERE p.VentaId = v.VentaId
);

-- 3
SELECT *
FROM dbo.Productos
WHERE Precio > (SELECT AVG(Precio*1.0) FROM dbo.Productos);

-- 4
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio > ALL (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Accesorios'
);

-- 5
SELECT p.*
FROM dbo.Productos p
WHERE p.Precio < ANY (
  SELECT Precio
  FROM dbo.Productos
  WHERE Categoria = 'Computo'
);
```

---

## 6) Vistas (VIEW)

### 6.1 ¿Qué es y para qué sirve?
Una vista es una **consulta guardada** para reutilizar lógica, simplificar reportes y controlar acceso a columnas.

### 6.2 Sintaxis
```sql
CREATE OR ALTER VIEW esquema.NombreVista
AS
  SELECT ...
GO
```

### 6.3 Ejemplo (totales por venta)
```sql
CREATE OR ALTER VIEW dbo.vw_VentasTotales
AS
SELECT
  v.VentaId,
  v.ClienteId,
  v.FechaVenta,
  v.Estado,
  SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.Ventas v
JOIN dbo.DetalleVenta d ON d.VentaId = v.VentaId
GROUP BY v.VentaId, v.ClienteId, v.FechaVenta, v.Estado;
GO

SELECT * FROM dbo.vw_VentasTotales;
```

---

## 7) Índices (INDEX)

### 7.1 ¿Qué es y para qué sirve?
Estructura que acelera búsquedas/joins/ordenamientos. Costo: espacio y mantenimiento en escrituras.

### 7.2 Sintaxis
```sql
CREATE INDEX NombreIndice ON esquema.Tabla(Columna1, Columna2);
```

### 7.3 Índices recomendados para el dataset
```sql
CREATE INDEX IX_Ventas_Cliente_Fecha ON dbo.Ventas(ClienteId, FechaVenta);
CREATE INDEX IX_DetalleVenta_VentaId ON dbo.DetalleVenta(VentaId);
CREATE INDEX IX_DetalleVenta_ProductoId ON dbo.DetalleVenta(ProductoId);
CREATE INDEX IX_Pagos_VentaId ON dbo.Pagos(VentaId);
```

### 7.4 Medición básica
```sql
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT d.VentaId,
       SUM(d.Cantidad*d.PrecioUnit*(1-d.Descuento/100.0)) AS TotalVenta
FROM dbo.DetalleVenta d
GROUP BY d.VentaId;
```

---

## 8) Reto integrador (mezcla de todo)

1) Crea una vista `vw_ReporteVentas` con:  
   `VentaId, FechaVenta, AnioMes, Cliente, Ciudad, TotalVenta, SegmentoTotal (CASE: Alta/Media/Baja)`  
2) Consulta esa vista para mostrar solo `Pagadas`, ordenadas por `TotalVenta` DESC.  
3) Lista clientes con `Riesgo` si no tienen ninguna venta pagada (CASE + NOT EXISTS).

---
