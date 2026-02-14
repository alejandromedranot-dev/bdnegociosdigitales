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


