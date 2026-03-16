/*
   Funciones de Agregado:
   
   1. sum()
   2. max()
   3. min()
   4. avg()
   5. count(*)
   6. count(campo)

   Nota: Estas funciones solamente regresan un solo registro
*/

-- Seleccionar los paises de donde son los clientes

SELECT DISTINCT country 
FROM Customers;

-- Agregaci�n count(*) cuenta el n�mero de registros
-- que tiene una tabla 

SELECT COUNT(*) AS [Total de Ordenes]
FROM Orders;

SELECT * 
FROM Customers;

SELECT count(CustomerID) 
FROM Customers;

SELECT count(Region) 
FROM Customers;

-- Seleccione de cuantas ciudades son las ciudades de 
-- los clientes

SELECT city
FROM Customers
ORDER BY city Asc;

SELECT count(city)
FROM Customers;

SELECT DISTINCT city
FROM Customers
ORDER BY city Asc;

SELECT COUNT(DISTINCT city) AS [CIUDADES CLIENTES]
FROM Customers;

-- Selecciona el precio m�ximo de los productos
SELECT *
FROM Products
ORDER BY UnitPrice DESC;

SELECT MAX(UnitPrice) AS [Precio mas Alto]
FROM Products;

-- Seleccionar la fecha de compra mas actual
SELECT MAX(OrderDate) AS [Ultima fecha de compra]
FROM Orders;

-- Seleccionar el a�o de la fecha de compra mas reciente
SELECT MAX(YEAR(OrderDate))
FROM Orders;

SELECT YEAR(MAX(OrderDate))
FROM Orders;

SELECT MAX(DATEPART(YEAR, OrderDate))
FROM orders;

SELECT DATEPART(YEAR, MAX(OrderDate)) AS [A�o]
FROM orders;

-- Cual es minima cantidad de los pedidos 
SELECT MIN(UnitPrice) AS [Precio Minimo de Venta]
FROM [Order Details]

-- Cual es el importe m�s bajo de las compras

SELECT (UnitPrice * Quantity * (1-Discount)) AS [IMPORTE]
FROM [Order Details]
ORDER BY [IMPORTE] ASC

SELECT (UnitPrice * Quantity * (1-Discount)) AS [IMPORTE]
FROM [Order Details]
ORDER BY (UnitPrice * Quantity * (1-Discount)) ASC

SELECT (UnitPrice * Quantity * (1-Discount)) AS [IMPORTE]
FROM [Order Details]
ORDER BY 1 ASC

SELECT 
	MIN ((UnitPrice * Quantity * (1-Discount))) AS [IMPORTE MAS BAJO]
FROM [Order Details]

-- obtener el total de los precios de los productos
SELECT SUM(UnitPrice)
FROM Products


--obtener el total de dinero percibido por las ventas

SELECT 
	SUM ((UnitPrice * Quantity * (1-Discount))) 
	AS [IMPORTE MAS BAJO]
FROM [Order Details]


-- SELECCIONAR LAS VENTAS TOTALES DE LOS PRODUCTOS
-- 4, 10 y 20

select *
from Products


SELECT *
FROM 

-- Seleccionar el numero de ordenes hechas por los 
-- siguientes clientes
Around the Horn, 
B�lido Comidas preparadas, 
Chop-suey Chinese

-- Seleccionar el total de ordenes del segundo trimestre de 
-- 1996

SELECT count(*)
FROM Orders
WHERE datepart(q, OrderDate) = 3 
AND DATEPART(YEAR, OrderDate) = 1996;

-- seleccionar el numero de ordenes entre 1996 a 1997

-- Seleccionar el numero de clientes que comienzan con 
-- a o que comienzan con b

-- seleccionar el n�mero de ordenes realizadas por 
-- el cliente Chop-suey Chinese en 1996






-- Seleccionar el total de ordenes que fueron enviadas
-- Alemania 

SELECT COUNT(*) AS [Total de ordenes] 
FROM Orders 
WHERE ShipCountry = 'Germany';

-- Obtener la cantidad total vendida agrupada por 
-- producto y pedido

SELECT *, (UnitPrice * Quantity) AS [Total] 
FROM [Order Details]

SELECT SUM(UnitPrice * Quantity) AS [Total] 
FROM [Order Details]

SELECT ProductID,SUM(UnitPrice * Quantity) AS [Total] 
FROM [Order Details]
GROUP BY ProductID
ORDER BY ProductID

SELECT ProductID,OrderID,SUM(UnitPrice * Quantity) AS [Total] 
FROM [Order Details]
GROUP BY ProductID, OrderID
ORDER BY ProductID, [Total] DESC

SELECT 
	*, (UnitPrice * Quantity) AS [Total] 
FROM 
[Order Details] 
WHERE OrderID = 10847
AND ProductID = 1

-- SELECCIONAR LA CANTIDAD MAXIMA VENDIDA 
-- POR PRODUCTO EN CADA PEDIDO
SELECT ProductID, OrderID, MAX(Quantity) AS [Cantidad Máxima]
FROM [Order Details]
GROUP BY ProductID, OrderID
ORDER BY ProductID, OrderID;

-- Having (filtro pero de grupos)

-- Seleccionar los clientes que hayan realizado mas de 10 
-- pedidos


SELECT customerid, count(*) AS [Número de Ordenes]
FROM Orders
GROUP BY CustomerID
ORDER BY 2 DESC;

SELECT customerid,count(*) AS [Número de Ordenes]
FROM Orders
WHERE ShipCountry IN ('Germany', 'France', 'Brazil')
GROUP BY CustomerID, ShipCountry
HAVING COUNT(*) > 10
ORDER BY 2 DESC; 

SELECT c.CompanyName ,COUNT(*) AS [Número de Ordenes]
FROM Orders AS o
INNER JOIN
Customers AS c
ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
HAVING COUNT(*) > 10
ORDER BY 2 DESC; 

SELECT customerid, count(*) AS [Número de Ordenes]
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) > 10
ORDER BY 2 DESC; 

-- Seleccionar los empleados que hayan gestionado pedidos por un 
-- total superior a 10000 en ventas (Mostrar el id del empleado y el nombre y total de
-- compras)

SELECT *
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID;

SELECT 
	CONCAT(e.FirstName,' ',e.LastName) AS [Nombre Completo],
	(od.Quantity * od.UnitPrice * (1 - od.Discount)) AS [IMPORTE]
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
ORDER BY e.FirstName;

SELECT 
	CONCAT(e.FirstName,' ',e.LastName) AS [Nombre Completo],
	ROUND(SUM(od.Quantity * od.UnitPrice * (1 - od.Discount)), 2 ) AS [IMPORTE]
FROM Employees AS e
INNER JOIN Orders AS o
ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od
ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName
HAVING SUM(od.Quantity * od.UnitPrice * (1 - od.Discount))>100000
ORDER BY [IMPORTE] DESC;

-- Seleccionar el número de productos vendidos en mas de 20 pedidos distintos
-- Mostrar el id del producto, el nombre del producto el numero de ordenes

SELECT 
	p.ProductID, 
	p.ProductName,
	COUNT(DISTINCT o.OrderID) AS [Numero de Pedidos]
FROM Products AS p
INNER JOIN [Order Details] AS od
ON p.ProductID = od.ProductID
INNER JOIN Orders AS o
ON o.OrderID = od.OrderID
GROUP BY p.ProductID, 
	     p.ProductName
HAVING 	COUNT(DISTINCT o.OrderID)>20;


-- SELECCIONAR LOS PRODUCTOS NO DESCONTINUADOS, 
-- CALCULAR EL PRECIO PROMEDIO VENDIDO, Y 
-- MOSTRAR SOLO AQUELLOS QUE SE HAYAN VENDIDO
-- EN MENOS DE 15 PEDIDOS

SELECT p.ProductName, ROUND(AVG(od.UnitPrice), 2) AS [Precio Promedio]
FROM Products AS p
INNER JOIN [Order Details] AS od
ON p.ProductID = od.ProductID
WHERE p.Discontinued = 0
GROUP BY p.ProductName
HAVING COUNT(OrderID) < 15;

-- Seleccionar el precio máximo de productos por 
-- categoria, pero solo si la suma de unidades es menor a 200
-- y ademas que no esten descontinuados. 

SELECT 
	c.CategoryID,
	c.CategoryName,
	p.ProductName
	,MAX(p.UnitPrice) AS [Precio Maximo]
FROM  Products AS p
INNER JOIN Categories AS c
ON p.CategoryID = c.CategoryID
WHERE p.Discontinued = 0
GROUP BY c.CategoryID,
		 c.CategoryName,
		 p.ProductName
HAVING SUM(p.UnitsInStock) < 200
ORDER BY CategoryName DESC, p.ProductName;



