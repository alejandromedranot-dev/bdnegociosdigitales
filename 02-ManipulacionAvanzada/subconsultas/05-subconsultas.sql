-- SUBCONSULTA ESCALAR (SOLO REGRESAN UN VALOR)


---ESCALAR EN SELECT

SELECT o.OrderID, (od.Quantity * od.UnitPrice) AS TOTAL,
(SELECT AVG((od.Quantity * od.UnitPrice)) FROM [Order Details] AS od) AS AVGTOTAL
FROM Orders AS o
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID


--Mostrar el nombre del producto y el precio promedio de todos los productos

SELECT p.ProductName,
(SELECT AVG(p.UnitPrice) FROM Products AS TOTAL_AVG
FROM Products AS p

--MOSTRAR CADA EMPLEADO Y LA CANTIDAD DE PEDIDOS QUE TIENE

SELECT e.EmployeeID, (
SELECT COUNT(*)
FROM Orders AS o
WHERE e.EmployeeID = o.EmployeeID
) AS NIMERODEORD
FROM Employees AS e

SELECT e.EmployeeID, e.FirstName, LastName, COUNT(o.OrderID) AS [NUMERO DE ORDENES]
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID, e.FirstName, e.LastName

SELECT *
FROM Employees

--MOSTRAR CADA CLIENTE Y LA FECHA DE SU ULIMO PEDIDO

--MOSTRAR PEDIDOS CON CLIENTE Y TOTAL DEL PEDIDO



--datos de ejemplo

CREATE DATABASE bdsubconsultas
GO

CREATE TABLE clientes(id_cliente INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
nombre NVARCHAR(50) NOT NULL, ciudad NCHAR(20) NOT NULL)

USE bdsubconsultas
GO


CREATE TABLE pedidos(id_pedido INT NOT NULL IDENTITY (1,1) PRIMARY KEY,
id_cliente INT NOT NULL, total MONEY NOT NULL, fecha DATE NOT NULL, CONSTRAINT fk_pedidos_clientes FOREIGN KEY(id_cliente) REFERENCES clientes(id_cliente))


--CONSULTA ESCALAR 

--OBTENER EL TOTAL MAXIMO  DE LAS ORDENES



INSERT INTO clientes (nombre, ciudad) VALUES
('Ana', 'CDMX'),
('Luis', 'Guadalajara'),
('Marta', 'CDMX'),
('Pedro', 'Monterrey'),
('Sofia', 'Puebla'),
('Carlos', 'CDMX'), 
('Artemio', 'Pachuca'), 
('Roberto', 'Veracruz');

INSERT INTO pedidos (id_cliente, total, fecha) VALUES
(1, 1000.00, '2024-01-10'),
(1, 500.00,  '2024-02-10'),
(2, 300.00,  '2024-01-05'),
(3, 1500.00, '2024-03-01'),
(3, 700.00,  '2024-03-15'),
(1, 1200.00, '2024-04-01'),
(2, 800.00,  '2024-02-20'),
(3, 400.00,  '2024-04-10');


SELECT MAX(total)
FROM pedidos
---SUBOCONSULTA ESCALAR
SELECT *
FROM pedidos
WHERE total =(SELECT MAX(total)
FROM pedidos)


SELECT id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS P
INNER JOIN clientes AS c
ON p.id_cliente = c.id_cliente
WHERE p.total = (SELECT MAX(total)
FROM pedidos)
ORDER BY p.total DESC;


SELECT p.id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS P
INNER JOIN clientes AS c
ON p.id_cliente = c.id_cliente
WHERE p.total = (SELECT MAX(total)
FROM pedidos)


--SELECCIONAR LOS PEDIDOS MAYORES AL PROMEDIO

SELECT AVG (total)
FROM pedidos

SELECT *
FROM PEDIDOS 
WHERE total > (
SELECT AVG (total)
FROM pedidos
)
-------
SELECT MIN (id_cliente)
FROM pedidos

SELECT *
FROM pedidos
WHERE id_cliente = 
(SELECT MIN (id_cliente)
FROM pedidos)

SELECT id_cliente, COUNT(*) AS [Numero  de pedidos]
FROM pedidos
WHERE id_cliente = 
(SELECT MIN (id_cliente)
FROM pedidos)
GROUP BY id_cliente

----Mostrar los datos del pedido de la ulyima orden

SELECT MAX(fecha)
FROM pedidos

SELECT p.id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS P
INNER JOIN clientes AS c
ON p.id_cliente = c.id_cliente
WHERE fecha = 
(SELECT MAX(fecha)
FROM pedidos)


--MOSTRAR TODOS LOS PEDIDOS CON UN TOTAL QUE SEA EL MAS BAJO
SELECT total
FROM pedidos
ORDER BY total DESC


SELECT MIN(total)
FROM pedidos

SELECT *
FROM pedidos
WHERE total =
(SELECT MIN(total)
FROM pedidos)

--SELECCIONAR LOS PEDIDOS CON EL NOMBRE DEL CLIENTE CUYO TOTAL (FREIGNT) SEA MAYOR AL PROMEDIO
--GENERAL DE FREIGHT

USE Northwind
GO

SELECT *
FROM Orders

SELECT AVG(Freight)
FROM Orders

SELECT o.OrderID, c.CompanyName, o.Freight
FROM Orders AS o
INNER JOIN Customers AS c
ON o.CustomerID = c.CustomerID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
WHERE o.Freight = (
SELECT AVG(Freight)
FROM Orders)
ORDER BY o.Freight DESC;


--SUBQUERIES DE UNA COLUMNA
--CON LA CLAUSULA IN, ANY, ALL Y OR

--CLIENTES QUE HAN HECHO PEDIDOS

SELECT *
FROM pedidos


SELECT *
FROM clientes
WHERE id_cliente IN (SELECT id_cliente
FROM pedidos
)

SELECT DISTINCT c.id_cliente,c.nombre,c.ciudad
FROM clientes AS c
INNER JOIN pedidos AS p
ON c.id_cliente = p.id_cliente


--CLIENTES QUE HAN HECHO PEDIDOS MAYORES A 800

SELECT *
FROM pedidos

SELECT *
FROM pedidos
WHERE total > 800


SELECT *
FROM pedidos
WHERE id_cliente IN (1,3,1)


----mostrar todos los clientes de la CDMX que han hecho pedidos

SELECT  * FROM pedidos

SELECT * FROM clientes


SELECT DISTINCT p.id_cliente, c.ciudad
FROM pedidos AS p
INNER JOIN clientes AS c
ON p.id_cliente = c.id_cliente
WHERE (c.ciudad = 'CDMX')

------- ESTA ES LA BUENA
SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (SELECT id_cliente FROM pedidos)


--SELECCIOANR CLIENTES QUE NO HAN HECHO PEDIDOS

SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (SELECT id_cliente FROM pedidos)

SELECT *
FROM pedidos AS p
RIGHT JOIN  clientes AS c
ON p.id_cliente = c.id_cliente

SELECT c.id_cliente, c.nombre, c.ciudad
FROM pedidos AS p
RIGHT JOIN  clientes AS c
ON p.id_cliente = c.id_cliente
WHERE p.id_cliente IS NULL

SELECT id_cliente
FROM pedidos

SELECT *
FROM clientes
WHERE id_cliente NOT IN (
SELECT id_cliente
FROM pedidos)



--seleccioanr los pedidos de clientes de MTY

SELECT *
FROM clientes
WHERE ciudad = 'Monterrey'

SELECT *
FROM pedidos
WHERE id_cliente = (
SELECT id_cliente
FROM clientes
WHERE ciudad = 'Monterrey')




---------CLAUSULA ANY

--- seleccionar pedidos mayores que algun pedido de Luis(id_cliente=2

---	PRIMERO LA SUBCONSULTA

SELECT total
FROM pedidos
WHERE id_cliente = 2

---CONSULTA PRINCIPAL

SELECT *
FROM pedidos
WHERE total > ANY(
	SELECT total
	FROM pedidos
	WHERE id_cliente = 2
	)


	---SELECCIONAR PEDIDOS QUE SEAN MAYORES(TOTAL) DE ALGUN PEDIDO DE ANA 

	SELECT *
	FROM pedidos
	WHERE id_cliente = 1

SELECT *
FROM pedidos
WHERE total > ANY (
SELECT total
	FROM pedidos
	WHERE id_cliente = 1)

---SELECCIOANR LOS PEDIDOS MAYIRES QUE ALHUN PEDIDO SUPERIOR A 500 (total)

SELECT *
FROM pedidos 
WHERE total > 500

SELECT *
FROM pedidos 
WHERE total > ANY (SELECT total
FROM pedidos 
WHERE total > 500)


---ALL

--SELECCIONAR LOS PEDIDOS DONDE EL TOTAL SEA MAYOR A TODOS LOS TOTALES DE LOS PEDIDOS DE LUIS

SELECT TOTAL
FROM Pedidos
WHERE id_cliente = 2

SELECT TOTAL
FROM Pedidos

SELECT *
FROM pedidos
WHERE total > ALL 
(SELECT TOTAL
FROM Pedidos
WHERE id_cliente = 2
)

---SELECCIONAR TODOS LOS CLIENTES DONDE SU ID SEA MENOR QUE TODOS LOS CLIENTES DE LA CDMX

SELECT id_cliente
FROM clientes
WHERE ciudad = 'CDMX'

SELECT *
FROM clientes
WHERE id_cliente < ALL(SELECT id_cliente
FROM clientes
WHERE ciudad = 'CDMX')


--1. Seleccionar los clientes cuyo total de compras sea mayor a 1000

SELECT SUM(total)
FROM pedidos AS p

SELECT *
FROM clientes AS c
WHERE (
SELECT SUM(total)
FROM pedidos AS p
WHERE p.id_cliente = c.id_cliente ) > 1000

SELECT SUM(total)
FROM pedidos AS p
WHERE p.id_cliente = 3


--SELECCIONAR TODOS LOS CLIENTES QUE HAN ECHO MAS DE UN PEDIDO

SELECT COUNT(*)
FROM pedidos AS p
WHERE id_cliente = 2

SELECT *
FROM clientes AS c
WHERE (
SELECT COUNT(*)
FROM pedidos AS p
WHERE id_cliente = c.id_cliente
) > 1

SELECT * FROM pedidos

--SELECCIONAR EL TOTAL DE PEDIDOS QUE SON MAYORES AL PROMEDIO DE SU CLIENTE

SELECT AVG(total) AS promedio
FROM pedidos AS pe
WHERE pe.id_cliente = 2

SELECT *
FROM pedidos AS p
WHERE total > ( SELECT AVG(total) AS promedio
FROM pedidos AS pe
WHERE pe.id_cliente = p.id_cliente
)


---SELECCIONAR TODOS LOS CLEINTES CUYO PEDIDO MAXIMO SEA MAYOR A 1200

SELECT MAX(total)
FROM pedidos AS pe
WHERE pe.id_cliente = 2


SELECT *
FROM clientes AS c
WHERE  (SELECT MAX(total)
FROM pedidos AS pe
WHERE pe.id_cliente = c.id_cliente) > 1200