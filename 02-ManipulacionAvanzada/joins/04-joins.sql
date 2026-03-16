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

SELECT TOP 0
	ProductID AS [numero_producto],
	ProductName AS [nombre_producto],
	CategoryID AS [catego_id]
INTO producto
FROM Products;

ALTER TABLE producto
ADD CONSTRAINT pk_producto
PRIMARY KEY (numero_producto); 

ALTER TABLE producto
ADD CONSTRAINT fk_producto_categoria
FOREIGN KEY (catego_id)
REFERENCES categoria (CategoryID)
ON DELETE CASCADE;

INSERT INTO producto
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
producto AS p
ON c.CategoryID = p.catego_id
WHERE numero_producto is null;

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




