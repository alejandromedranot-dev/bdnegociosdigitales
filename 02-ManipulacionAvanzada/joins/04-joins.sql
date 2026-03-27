<<<<<<< HEAD
/** 
JOINS
1.INNER JOIN 
2.LEFF JOIN
3.RIGHT JOIN
4.FULL JOIN

**/

USE NORTHWND;

SELECT C.CategoryID, 
C.CategoryName,
P.ProductID,
P.ProductName,
P.UnitPrice,
P.UnitsInStock,
(P.UnitPrice * P.UnitsInStock)
AS [PRECIO INVENTARIO]
FROM Categories AS C
INNER JOIN Products AS P
ON C.CategoryID = P.CategoryID
WHERE C.CategoryID=9;

/*
FLUJO LOGICO DE EJECUCUION DE SQL
1.FROM 
2.JOIN 
3.WHERE
4.GROUP BY
5.HAVING
6.SELECT
7.DISTING
8.ORDER BY 
*/

--SELECCIONAR LOS CLIENTES QUE HAYAN REALIZADO 
--MAS DE 10 PEDIDOS 


SELECT Customerid, COUNT(*) AS [NUMERO DE ORDENES]
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) >10
ORDER BY 2 DESC;

SELECT Customerid, COUNT(*) AS [NUMERO DE ORDENES]
FROM Orders
WHERE ShipCountry IN ('GERMANY', 'FRANCE', 'BRAZIL')
GROUP BY CustomerID, ShipCountry
HAVING COUNT(*) >10
ORDER BY 2 DESC;

SELECT C.CompanyName, COUNT(*) AS [NUMERO DE ORDENES]
FROM Orders AS O
INNER JOIN
Customers AS C
ON O.CustomerID = C.CustomerID
GROUP BY C.CompanyName
HAVING COUNT(*) > 10
ORDER BY 2 DESC;

--SELECCIONAR LOS EMPLEADOS QUE HAYAN GESTIONADO PEDIDOS POR UN TOTAL
--SUPERIOR A 100000 EN VENTAS
--MOSTRAR EL ID DEL EMPLEADO Y EL NOMBRE Y EL TOTAL DE COMPRAS

SELECT
	CONCAT (E.FirstName,' ',E.LastName) AS [NOMBRE COMPLETO], 
	ROUND (SUM(OD.Quantity * OD.UnitPrice * (1-OD.Discount)), 2) AS [IMPORTE]
FROM Employees AS E
INNER JOIN Orders AS O
ON E.EmployeeID = O.EmployeeID
INNER JOIN [Order Details] AS OD
ON O.OrderID = OD.OrderID
GROUP BY E.FirstName, E.LastName
HAVING SUM(OD.Quantity * OD.UnitPrice * (1-OD.Discount)) > 100000
ORDER BY [IMPORTE] DESC;

--SELECCIONAR EL PRECIO M�XIMO DE PRODUCTOS POR CATEGORIA
--PERO SOLO SI LA SUNA DE UNIDADES ES MENOR A 200 Y ADEMAS
--QUE NO ESTEN DESCONTINUADOS


SELECT 
	C.CategoryID,
	C.CategoryName,
	P.ProductName,
	MAX(P.UnitPrice) AS [PRECIO MAXIMO]
FROM Products AS P
INNER JOIN Categories AS C
ON P.CategoryID = C.CategoryID
WHERE P.Discontinued = 0
GROUP BY C.CategoryID,
		C.CategoryName,
		P.ProductName
HAVING SUM(P.UnitsInStock) < 200
ORDER BY CategoryName, P.ProductName DESC;

----JOINS------------------------------------------------------------------------
--Estructura:
--SELECT [TABLA]
--FROM
--Tablaizquierda
--Joins
--Tabla derecha
--On=campo1=campo2;

--El AS _ ES PARA crear un alias

---Inner Join = Join: son todas las coincidencias en ambas tablas, con lo que esta en el ON
--Left Join: son todos los datos de la tabla left y todos los que coinciden de la otra tabla, 
   --aqui si importa el orden: los que no coinciden se ponen en NULL
--Righ Join: son todos los datos de la tabla righ y todos los que coinciden de la otra tabla
--Full Join: todos los valores de las dos tablas los que coinciden y los que no los pone en NULL

/**



**/

--Seleccionar las categorias y sus productos
SELECT 
      categories.CategoryID, 
      categories.CategoryName,
      Products.ProductID,
      products.ProductName,
      products.UnitPrice,
      products.UnitsInStock,
      products.UnitsInStock,
      (products.UnitPrice * Products.UnitsInStock)
      AS [Precio Inventario]
FROM Categories
INNER JOIN Products
on Categories.CategoryID =products.CategoryID
WHERE categories.CategoryID = 9;

-------------------------------------------------------------------------

-- Crear una tabla a partir de una consuta 

SELECT TOP 0
	CategoryID,
	CategoryName
	INTO  categoria
	FROM categories;

ALTER TABLE categoria
ADD CONSTRAINT pk_categoria
PRIMARY KEY (CategoryID);

INSERT INTO categoria
VALUES ('C1'),('C2'),('C3'),('C4'),('C5');

SELECT TOP 0
	ProductID AS [numero producto],
	ProductName AS [nombre_producto],
	CategoryID AS [catego_id]
FROM Products;
=======
/**
  JOINS
  1. INNER JOIN
  2. LEFT JOIN 
  3. RIGHT JOIN 
  4. FULL JOIN
**/

-- SELECCIONAR LAS CATEGORIAS Y SUS PRODUCTOS

SELECT 
	categories.CategoryID, 
	categories.CategoryName,
	Products.ProductID, 
	products.ProductName, 
	Products.UnitPrice, 
	Products.UnitsInStock,
	(products.UnitPrice * Products.UnitsInStock) 
	AS [Precio Inventario]
FROM Categories 
INNER JOIN Products
ON Categories.CategoryID = products.CategoryID
WHERE categories.CategoryID = 9;


-- Crear una tabla a partir de una consulta

SELECT TOP 0 CategoryID, CategoryName 
INTO categoria
FROM Categories;

ALTER TABLE categoria
ADD CONSTRAINT pk_categoria
PRIMARY KEY (CategoryId);

INSERT INTO categoria
VALUES ('C1'), ('C2'),('C3'),('C4'),('C5');
>>>>>>> c8a744de13c2cbd33d810bdf0255bd7b88161059

SELECT TOP 0
	ProductID AS [numero_producto],
	ProductName AS [nombre_producto],
	CategoryID AS [catego_id]
INTO producto
FROM Products;

ALTER TABLE producto
ADD CONSTRAINT pk_producto
<<<<<<< HEAD
PRIMARY KEY (numero_producto);
=======
PRIMARY KEY (numero_producto); 
>>>>>>> c8a744de13c2cbd33d810bdf0255bd7b88161059

ALTER TABLE producto
ADD CONSTRAINT fk_producto_categoria
FOREIGN KEY (catego_id)
REFERENCES categoria (CategoryID)
ON DELETE CASCADE;

INSERT INTO producto
<<<<<<< HEAD
VALUES ('P1',1),
		('P2',1),
		('P3',2),
		('P4',2),
		('P5',3),
		('P6',NULL);

--INNER JOIN


SELECT *
FROM categoria AS c
INNER JOIN 
producto AS P
ON c.CategoryID = p.catego_id;

--LEFT JOIN
SELECT *
FROM categoria AS c
LEFT JOIN 
producto AS P
ON c.CategoryID = p.catego_id;

-- RIGHT JOIN
SELECT *
FROM categoria AS c
RIGHT JOIN 
producto AS P
ON c.CategoryID = p.catego_id;

-- FULL JOIN
SELECT *
FROM categoria AS c
FULL JOIN 
producto AS P
ON c.CategoryID = p.catego_id;

-- SIMULAR EL RIGHT JOIN DEL QUERY ANTERIOR 
-- CON UN LEFT JOIN

SELECT c.CategoryID, c.CategoryName,
	p.numero_producto, p.nombre_producto,
	p.catego_id
FROM categoria AS c
RIGHT JOIN 
producto AS P
ON c.CategoryID = p.catego_id;


SELECT c.CategoryID, c.CategoryName,
	p.numero_producto, p.nombre_producto,
	p.catego_id
FROM producto AS p
LEFT JOIN  
categoria AS c
ON c.CategoryID = p.catego_id;

-- VISUALIZAR TODAS LAS CATEGORIAS QUE NO TIENEN PRODUCTOS 

SELECT *
FROM categoria AS c
LEFT JOIN
=======
VALUES ('P1', 1),
       ('P2', 1),
       ('P3', 2),
       ('P4',2 ),
       ('P5', 3),
       ('P6', NULL);

-- INNER JOIN 

SELECT * 
FROM categoria AS c
INNER JOIN 
producto AS p
ON c.CategoryID = p.catego_id;

-- LEFT JOIN 
SELECT * 
FROM categoria AS c
LEFT JOIN 
producto AS p
ON c.CategoryID = p.catego_id;

-- RIGHT JOIN

SELECT * 
FROM categoria AS c
RIGHT JOIN 
producto AS p
ON c.CategoryID = p.catego_id;

-- FULL JOIN 
SELECT * 
FROM categoria AS c
FULL JOIN 
producto AS p
ON c.CategoryID = p.catego_id;

-- Simular el right join del query anterior
-- con un LEFT JOIN

SELECT 
	c.CategoryID, c.CategoryName, 
	p.numero_producto, p.nombre_producto, 
	p.catego_id
FROM categoria AS c
RIGHT JOIN 
producto AS p
ON c.CategoryID = p.catego_id;

SELECT 
	c.CategoryID, c.CategoryName, 
	p.numero_producto, p.nombre_producto, 
	p.catego_id 
FROM producto AS p
LEFT JOIN
categoria AS c
ON c.CategoryID = p.catego_id;

-- Visualizar todos las categorias que no tienen 
-- productos

SELECT * 
FROM categoria AS c
LEFT JOIN 
>>>>>>> c8a744de13c2cbd33d810bdf0255bd7b88161059
producto AS p
ON c.CategoryID = p.catego_id
WHERE numero_producto is null;

<<<<<<< HEAD
-- SELECCIONAR TODOS LOS PRODUCTOS QUE 
-- NO TIENE CATEGORIA

SELECT *
FROM producto AS p
LEFT JOIN
categoria AS c
ON c.CategoryID = p.catego_id
WHERE catego_id is null;

--GUARDADR EN UNA TABLA DE PRODUCTOS NUEVOS TODOS AQUELLOS PRODUCTOS QUE FUERON AGREGADOS 
--RECIEMTEMENTE Y NO ESTAN EN ESTA TABLA DE APOYO

--CREAR LA TABLA PRODUCTS NEW A PARTIR DE PRODUCTS MEDIANTE UNA CONSULTA

SELECT 
	TOP 0
	ProductID AS[PRODUCT_NUMBER], 
	ProductName AS PRODUCT_NAME,
	UnitPrice AS UNIT_PRICE, 
	UnitsInStock AS STOCK, 
	(UnitPrice * UnitsInStock ) AS TOTAL
INTO PRODUCTS_NEW
FROM Products

ALTER TABLE PRODUCTS_NEW
ADD CONSTRAINT pk_products_new
PRIMARY KEY (PRODUCT_NUMBER);



SELECT p.ProductID, p.ProductName, p.UnitPrice, p.UnitsInStock,
(p.UnitPrice * p.UnitsInStock) AS TOTAL, pw.*
FROM Products AS p
LEFT JOIN PRODUCTS_NEW AS pw
ON p.ProductID = pw.PRODUCT_NUMBER

SELECT p.ProductID, p.ProductName, p.UnitPrice, p.UnitsInStock,
(p.UnitPrice * p.UnitsInStock) AS TOTAL
FROM Products AS p
LEFT JOIN PRODUCTS_NEW AS pw
ON p.ProductID = pw.PRODUCT_NUMBER
WHERE PRODUCT_NUMBER IS NULL
=======
-- Seleccionar todos los productos que no tienen
-- Categoria

SELECT * 
FROM categoria AS c
RIGHT JOIN 
producto AS p
ON c.CategoryID = p.catego_id
WHERE c.CategoryID IS NULL;


SELECT * 
FROM producto AS p
LEFT JOIN 
categoria AS c
ON c.CategoryID = p.catego_id
WHERE c.CategoryID IS NULL;

SELECT * 
FROM categoria;

SELECT * 
FROM producto; 



-- Guardar en una tabla de productos nuevos, todos aquellos
-- aquellos productos que fueron agregados recientemente y no 
-- estan en esta tabla de apoyo

-- Crear la tabla products_new a partir de products, mediante
-- una consulta
SELECT 
	   TOP 0
       ProductID AS [product_number],
	   ProductName AS [product_name], 
	   UnitPrice AS unit_price, 
	   UnitsInStock AS [stock], 
	   (UnitPrice * UnitsInStock) AS [total]
INTO products_new
from Products

ALTER TABLE products_new
ADD CONSTRAINT pk_products_new
PRIMARY KEY ([product_number]);

SELECT 
	p.ProductID,
	p.ProductName, 
	p.UnitPrice, 
	p.UnitsInStock, 
	(p.UnitPrice * p.UnitsInStock) AS [Total],
	pw.*
FROM Products AS p
INNER JOIN products_new as pw
ON p.ProductID = pw.product_number;

SELECT 
	p.ProductID,
	p.ProductName, 
	p.UnitPrice, 
	p.UnitsInStock, 
	(p.UnitPrice * p.UnitsInStock) AS [Total],
	pw.*
FROM Products AS p
LEFT JOIN products_new as pw
ON p.ProductID = pw.product_number;


INSERT INTO products_new
SELECT 
	p.ProductName, 
	p.UnitPrice, 
	p.UnitsInStock, 
	(p.UnitPrice * p.UnitsInStock) AS [Total]
FROM Products AS p
LEFT JOIN products_new as pw
ON p.ProductID = pw.product_number
WHERE pw.product_number IS NULL;



SELECT * 
FROM products_new;




>>>>>>> c8a744de13c2cbd33d810bdf0255bd7b88161059
