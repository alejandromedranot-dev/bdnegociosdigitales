
USE bdejemplo;

SELECT * FROM clientes 




--CREAR UNA VISTA QUE VISUALIZE EL TOTAL DE LOS IMPORTES POR PRODUCTOS

CREATE OR ALTER VIEW vw_importes_productos
AS 
SELECT pr.descripcion AS [NOMBRE DEL PRODUCTO], SUM(p.importe) AS [TOTAL],
SUM(p.importe * 1.15) AS [IMPORTE CON DESCUENTO]
FROM pedidos AS p
INNER JOIN productos AS pr
ON p.fab = pr.id_fab
AND p.producto = pr.id_producto
GROUP BY pr.descripcion

SELECT *
FROM vw_importes_productos
WHERE [NOMBRE DEL PRODUCTO] LIKE '%brazo%'
AND [IMPORTE CON DESCUENTO] > 34000

--SELECCIONAR LOS NOMBRES DE LOS REPRESENTANTES Y LAS OFICINAS EN DONDE TRABAJAN
CREATE OR ALTER VIEW vw_oficinas_representantes 
AS
SELECT r.nombre, r.ventas AS [VENTAS_REPRENSETANTES], o.oficina, o.ciudad, o.region, o.ventas AS [VENTAS_OFICINAS]
FROM Representantes AS r
INNER JOIN oficinas AS o
ON r.oficina_rep = o.oficina


SELECT *
FROM representantes 
WHERE nombre = 'Daniel Ruidrobo'

SELECT *
FROM vw_oficinas_representantes
ORDER BY nombre DESC

--SELECCIONAR LOS PEDIDOS CON FECHA E IMPORTE, EL NOMBRE DEL REPRESENTANTE QUE LO REALIZO
--Y AL CLIENTE QUE LO SOLICITO

SELECT p.num_pedido, p.fecha_pedido, p.importe, c.empresa, r.nombre
FROM pedidos AS p
INNER JOIN clientes AS c
ON c.num_cli = p.cliente
INNER JOIN representantes AS r
ON r.num_empl = p.rep


--SELECCIONAR LOS PEDIDOS CON FECHA E IMPORTE, EL NOMBRE DEL REPRESENTANTE QUE ATENDIO
--AL CLIENTE QUE LO SOLICITO

SELECT p.num_pedido, p.fecha_pedido, p.importe, c.empresa, r.nombre
FROM pedidos AS p
INNER JOIN clientes AS c
ON c.num_cli = p.cliente
INNER JOIN representantes AS r
ON r.num_empl = c.rep_cli

SELECT p.Num_Pedido, p.Fecha_Pedido, p.Importe, c.Empresa,r.Nombre
FROM Pedidos AS p
INNER JOIN Clientes AS c
ON c.Num_Cli = p.Cliente
INNER JOIN Representantes AS r
ON r.Num_Empl = c.Rep_Cli	