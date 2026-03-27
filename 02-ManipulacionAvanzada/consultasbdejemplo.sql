use bdejemplo;

SELECT * FROM Clientes;
SELECT * FROM Representantes;
SELECT * FROM Oficinas;
SELECT * FROM Productos;
SELECT * FROM pedidos;

-- Crear una vista que visualice el total de los importes agrupados por productos

CREATE OR ALTER VIEW vw_importes_productos
AS
SELECT pr.Descripcion AS [Nombre Producto], 
	   SUM(p.Importe) AS [Total],
	   SUM(P.Importe * 1.15) AS [ImportrDescuento]
FROM Pedidos AS p
INNER JOIN Productos AS pr
ON p.Fab = pr.Id_fab
AND p.Producto = pr.Id_producto
GROUP BY pr.Descripcion;
GO

SELECT * 
FROM vw_importes_productos
WHERE [Nombre Producto] LIKE '%brazo%'
AND ImportrDescuento > 34000;
GO

-- Seleccionar los nombres de los representantes y las oficinas en donde trabajan
CREATE OR ALTER VIEW vw_oficinas_representantes
AS
SELECT r.Nombre, 
	r.Ventas AS [ventasrepresentantes],
	o.Oficina, 
	o.Ciudad, 
	o.Region, 
	o.Ventas AS [ventasoficinas]
FROM Representantes AS r
INNER JOIN Oficinas as o
ON r.Oficina_Rep = o.Oficina


SELECT *
FROM Representantes
WHERE Nombre = 'Daniel Ruidrobo';

SELECT Nombre, Ciudad 
FROM vw_oficinas_representantes
ORDER BY nombre DESC;

-- SELECCIONAR LOS PEDIDOS CON FECHA EN IMPORTE, EL NOMBRE DEL REPRESENTANTE 
-- QUE LO REALIZO Y AL CLIENTE QUE LO SOLICITO

SELECT 
	p.Num_Pedido, 
	p.Fecha_Pedido, 
	p.Importe, 
	c.Empresa, 
	r.Nombre
FROM Pedidos AS p
INNER JOIN 
Clientes AS c
ON c.Num_Cli = p.Cliente
INNER JOIN Representantes AS r
ON r.Num_Empl = p.Rep;

-- SELECCIONAR LOS PEDIDOS CON FECHA EN IMPORTE, EL NOMBRE DEL REPRESENTANTE 
-- QUE ATENDIO AL CLIENTE Y AL CLIENTE QUE LO SOLICITO

SELECT 
	p.Num_Pedido, 
	p.Fecha_Pedido, 
	p.Importe, 
	c.Empresa, 
	r.Nombre
FROM Pedidos AS p
INNER JOIN 
Clientes AS c
ON c.Num_Cli = p.Cliente
INNER JOIN Representantes AS r
ON r.Num_Empl = c.Rep_Cli;