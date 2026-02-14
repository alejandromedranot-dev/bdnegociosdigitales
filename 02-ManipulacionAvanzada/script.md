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