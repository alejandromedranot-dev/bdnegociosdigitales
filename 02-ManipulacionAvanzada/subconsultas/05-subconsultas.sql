USE bdsubconsultas;

-- Subconsulta escalar (un valor)

-- Escalar en Select 

SELECT 
	o.OrderID, 
	(od.Quantity * od.UnitPrice) AS [Total], 
	(SELECT AVG(od.Quantity * od.UnitPrice) FROM [Order Details] AS od) as [AVGTOTAL]
FROM Orders AS o 
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID;

-- Mostrar el nombre del producto y el precio promedio de todos los 
-- productos

SELECT 
p.ProductName, 
(
	SELECT AVG(UnitPrice) FROM Products
) AS [Precio Promedio]
FROM Products AS p
 
--Mostrar cada empleado y la cantidad total de pedidos que tiene.
SELECT e.EmployeeID,FirstName, lastname,
(
  SELECT COUNT(*)
  FROM Orders 
) AS [NUMERO DE PEDIDOS]
FROM Employees AS e;

-- Correlacionada
SELECT e.EmployeeID,FirstName, lastname,
(
  SELECT COUNT(*)
  FROM Orders AS o
  WHERE o.EmployeeID =3
) AS [NUMERO DE PEDIDOS]
FROM Employees AS e;



SELECT e.EmployeeID,FirstName, lastname, COUNT(o.OrderID) AS [NUMERO DE ORDENES]
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
GROUP BY e.EmployeeID,FirstName, lastname;

SELECT * 
FROM Employees;


-- Mostra cada cliente y la fecha de su ultimo pedido

-- Mostrar pedidos con nombre del cliente y total del pedido (sum)
SELECT o.OrderID, c.CompanyName, (
	SELECT SUM(od.Quantity * od.UnitPrice ) 
	FROM [Order Details] AS od
	WHERE od.OrderID = o.OrderID
) AS [Total]
FROM Orders AS o
INNER JOIN Customers AS c
ON o.CustomerID = c.CustomerID
ORDER BY c.CompanyName;

-- Datos de Ejemplo

CREATE DATABASE bdsubconsultas;
GO

USE bdsubconsultas;
GO

CREATE TABLE clientes(
 id_cliente int not null identity(1,1) primary key,
 nombre nvarchar(50) not null,
 ciudad nchar(20) not null
);

CREATE TABLE pedidos(
 id_pedido int not null identity(1,1) primary key,
 id_cliente int not null, 
 total money not null,
 fecha date not null, 
 CONSTRAINT fk_pedidos_clientes
 FOREIGN KEY (id_cliente) 
 REFERENCES clientes(id_cliente)
);


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


-- Consulta Escalar: 


-- Seleccionar los pedidos en donde el total sea igual 
-- al total maximo de ellos

SELECT MAX(total)
FROM pedidos;

SELECT *
FROM pedidos
WHERE total = (
	SELECT MAX(total)
	FROM pedidos
);

SELECT TOP 1 p.id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS p
INNER JOIN 
clientes AS c
ON p.id_cliente = c.id_cliente
ORDER BY p.total DESC;

SELECT  p.id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS p
INNER JOIN 
clientes AS c
ON p.id_cliente = c.id_cliente
WHERE p.total = (
	SELECT MAX(total)
	FROM pedidos
);

-- Seleccionar los pedidos mayores al promedio

SELECT  AVG(total)
FROM pedidos;

SELECT * FROM 
pedidos 
WHERE total > (
	SELECT  AVG(total)
	FROM pedidos	
);

-- Seleccionar todos los pedidos del cliente que tenga el menor id

SELECT MIN (id_cliente)
FROM pedidos;

SELECT *
FROM pedidos 
WHERE id_cliente = (
	SELECT MIN (id_cliente)
	FROM pedidos
);

SELECT id_cliente, COUNT(*) AS [N�mero de Pedidos]
FROM pedidos 
WHERE id_cliente = (
	SELECT MIN (id_cliente)
	FROM pedidos
)
GROUP BY id_cliente;

-- Mostrar los datos del pedido del �ltima orden 

SELECT MAX(fecha)
FROM pedidos;

SELECT p.id_pedido, c.nombre, p.fecha, p.total
FROM pedidos AS p
INNER JOIN clientes AS c
ON p.id_cliente = c.id_cliente
WHERE fecha = (
	SELECT MAX(fecha)
	FROM pedidos
);

-- Mostrar todos los pedidos con un total que sea el m�s bajo

SELECT MIN (total)
FROM pedidos;

SELECT * 
FROM pedidos
WHERE total = (
	SELECT MIN (total)
	FROM pedidos
);

-- SELECCIONAR LOS PEDIDOS CON EL NOMBRE DEL CLIENTE CUYO TOTAL (Freight) sea
-- MAYOR AL PROMEDIO GENERAR DE FREIGHT

USE NORTHWND;

SELECT AVG(Freight)
FROM  Orders;

SELECT 
	o.OrderID, c.CompanyName,CONCAT(e.FirstName, ' ', e.LastName) AS [FULLNAME]
	,o.Freight
FROM Orders AS o
INNER JOIN Customers AS c
ON o.CustomerID = c.CustomerID
INNER JOIN Employees AS e
ON e.EmployeeID = o.EmployeeID
WHERE o.Freight > (
	SELECT AVG(Freight)
	FROM  Orders
)
ORDER BY o.Freight DESC;


SELECT o.OrderID, c.CompanyName, o.Freight
FROM Orders AS o
INNER JOIN Customers AS c
ON o.CustomerID = c.CustomerID
WHERE o.Freight > 78.2442;


-- Subqueries con IN, ANY, ALL (llevan una sola columna)
-- La clausula IN

-- Clientes que han hecho pedidos
SELECT id_cliente 
FROM pedidos;
GO

SELECT * 
FROM clientes 
WHERE id_cliente IN (
	SELECT id_cliente 
	FROM pedidos
);

SELECT DISTINCT c.id_cliente, c.nombre, c.ciudad
FROM clientes AS c
INNER JOIN pedidos AS p
ON c.id_cliente = p.id_cliente;

-- Clientes que han hecho pedidios mayores a 800

-- Subconsulta
SELECT id_cliente
FROM pedidos
WHERE total > 800;

-- Principal
SELECT *
FROM pedidos
WHERE id_cliente IN (
	SELECT id_cliente
	FROM pedidos
	WHERE total > 800
);

SELECT *
FROM pedidos
WHERE id_cliente IN (1,3,1);

-- Seleccionar todos los clientes de la ciudad de méxico que han hecho pedidos
SELECT id_cliente
FROM Pedidos;

SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (
	SELECT id_cliente
	FROM Pedidos
);

-- SELECCIONAR CLIENTES QUE NO HAN HECHO PEDIDOS.

SELECT id_cliente
FROM pedidos;

SELECT * 
FROM clientes
WHERE id_cliente NOT IN(
	SELECT id_cliente
	FROM pedidos
)

SELECT * 
FROM pedidos AS p
INNER JOIN 
clientes as c
ON p.id_cliente = c.id_cliente;

SELECT c.id_cliente, c.nombre, c.ciudad 
FROM pedidos AS p
RIGHT JOIN 
clientes as c
ON p.id_cliente = c.id_cliente
WHERE p.id_cliente IS NULL;

-- Seleccionae los Pedidos de clientes de Monterrey

SELECT id_cliente
FROM clientes 
WHERE ciudad = 'Monterrey'


SELECT *
FROM pedidos 
WHERE id_cliente IN (
	SELECT id_cliente
	FROM clientes 
	WHERE ciudad = 'Monterrey'
);

SELECT * 
FROM clientes As c
LEFT JOIN pedidos as p
ON c.id_cliente = p.id_cliente
WHERE c.ciudad = 'Monterrey';

-- Operador ANY

-- Seleccionar Pedidos mayores que algún pedido de luis (id_cliente=2)

-- Primero la subconsulta

SELECT total
FROM pedidos 
WHERE id_cliente = 2;

-- Consulta principal
SELECT * 
FROM pedidos
WHERE total > ANY (
	SELECT total
	FROM pedidos As p
	INNER JOIN 
	clientes AS c
	ON p.id_cliente = c.id_cliente
	WHERE c.nombre = 'Luis'
);

-- Seleccionar los pedidos mayores (total) de algun pedido de Ana
SELECT total
FROM pedidos 
where id_cliente = 1;

SELECT * 
FROM pedidos
WHERE total > ANY (
	SELECT total
	FROM pedidos 
	WHERE id_cliente = 1
);

-- Seleccionar los pedidos mayores que algún pedido superior (total) a 500
SELECT total
FROM pedidos;


SELECT total
FROM pedidos
WHERE total > 500;



SELECT *
FROM Pedidos 
WHERE total > ANY (
	SELECT total
	FROM pedidos
	WHERE total = 500
)


SELECT id_pedido
FROM Pedidos 
WHERE total > ANY (
	SELECT total
	FROM pedidos
	WHERE total > 500
)


-- ALL 

-- Seleccionar los pedidos donde el total sea mayor a todos los totales de los pedidos
-- de Luis

-- Subconsulta
SELECT total 
FROM pedidos
WHERE id_cliente = 2;

SELECT total
FROM pedidos;

SELECT * 
FROM pedidos
WHERE total > ALL (
	SELECT total 
    FROM pedidos
    WHERE id_cliente = 2
);

-- Seleccionar todos los clientes donde su id sea menor que todos los clientes
-- de la ciudad de mexico

SELECT id_cliente
FROM clientes
WHERE ciudad = 'CDMX';


SELECT *
FROM clientes 
WHERE id_cliente < ALL (
	SELECT id_cliente
	FROM clientes
WHERE ciudad = 'CDMX'
);


-- Subconsultas Correlacionadas

SELECT SUM(total) 
FROM pedidos as p;


SELECT *
FROM clientes AS c
WHERE (
   SELECT SUM(total) 
   FROM pedidos as p
   WHERE p.id_cliente = c.id_cliente
) > 1000;


SELECT * 
FROM clientes;

SELECT SUM(total) 
   FROM pedidos as p
   WHERE p.id_cliente = 5


-- Seleccionar todos los clientes que han hecho mas de un pedido

SELECT COUNT(*)
FROM pedidos AS p
WHERE id_cliente = 2

SELECT id_cliente, nombre, ciudad
FROM clientes AS c
WHERE (
	SELECT COUNT(*)
	FROM pedidos AS p
	WHERE id_cliente = c.id_cliente
) > 1

-- Seleccionar todos los pedidos en donde su total debe ser mayor al promedio de los totales hechos por los clientes

SELECT AVG(total)
FROM pedidos AS pe
WHERE pe.id_cliente = 

SELECT *
FROM pedidos AS p
WHERE total > (
	SELECT AVG(total)
	FROM pedidos AS pe
	WHERE pe.id_cliente = p.id_cliente
);

--

SELECT MAX(total)
FROM PEDIDOS AS p
WHERE p.id_cliente = 

SELECT *
FROM clientes AS c
WHERE (
	SELECT MAX(total)
	FROM PEDIDOS AS p
	WHERE p.id_cliente = c.id_cliente
) > 1200;


SELECT MAX(total)
FROM PEDIDOS AS p
WHERE p.id_cliente = 1

SELECT * FROM pedidos;
SELECT * FROM clientes;

