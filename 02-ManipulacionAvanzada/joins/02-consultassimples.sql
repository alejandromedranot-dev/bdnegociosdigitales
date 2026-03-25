--Consultas Simples con SQL_MD

SELECT *
FROM Categories;

SELECT *
FROM Products;

SELECT *
FROM Orders;

SELECT *
FROM Order Details;

---proyecciòn (seleccionar algunos campos)

SELECT
    ProductID,
    ProductName,
    UnitPrice,
    UnitsInSTock
FROM Products;

--Alias de COLUMNAS - TABLAS

SELECT
    ProductID AS [NUMERO DE PRODUCTO],
    ProductName 'NOMBRE DE PRODUCTO',
    UnitPrice  AS [PRECIO UNITARIO],
    UnitsInSTock AS STOCK
FROM Products;

SELECT
    CompanyName AS CLIENTE,
    City  AS CIUDAD,
    Country AS PAIS
FROM Customers;

--CAMPOS CALCULADOS
--ES AQUEL CAMPO QUE NO FORMA PARTE DE LA TABLA, SE SACA A PARTIR DE UNA OPERACION

--SELECCIONAR LOS PRODUCTOS  Y CALCULAR EL VALOR DEL INVENTARIO
-- SABER CUANTO CUESTA, LA CANTIDAD DE PRODUCTOS POR SU PRECIO

SELECT*,(UnitPrice * UnitsInStock) AS [COSTO INVENTARIO]
FROM Products;

SELECT*,
ProductID,
ProductName,
UnitPrice,
UnitsInStock,
(UnitPrice * UnitsInStock) AS [COSTO INVENTARIO]
FROM Products;

--CALCULAR EL IMPORTE DE VENTA
SELECT*
FROM [Order Details];

SELECT
    OrderID,
    ProductID,
    UnitPrice,
    Quantity,
    (UnitPrice * Quantity) AS IMPORTE
FROM [Order Details];

--TAREA SELECCIONAR LA VENTA CON EL CALCULO DEL IMPORTE CON DESCUENTO

SELECT
    OrderID,
    UnitPrice,
    Discount
FROM [Order Details];

SELECT
    OrderID,
    UnitPrice,
    Quantity,
    Discount,
    (UnitPrice * Quantity) AS IMPORTE,
    (UnitPrice * Quantity) - ((UnitPrice * Quantity) * Discount)
    AS [Importe con Descunto 1],
    (UnitPrice * Quantity) * (1- Discount)
    AS [Importe con Descunto 2]
FROM [Order Details];

--OPERADORES RELACIONALES (>,<,<=,>=,=,!= ó <>)
/*
 SELECCIONAR LOS PRODUCTOS CON PRECIO MAYOR A 30
 SELECCIONAR LOS PRODUCTOS CON STOCK MENOR O = A 20
 SELECCIONAR LOS PEDIDOS POSTERIORES A 1997
*/
--SELECCIONA LOS PRIMEROS 10
SELECT TOP 10 *
FROM PRODUCTS;

--SELECCIONAR LOS PRODUCTOS CON PRECIO MAYOR A 30
SELECT ProductID AS [NUMERO DE PRODUCTO],
ProductName AS  [NOMBRE PRODUCTO],
UnitPrice AS  [PRECIO UNITARIO],
UnitsINStock AS  [STOCK]
FROM PRODUCTS
WHERE UnitPrice>30
ORDER BY UnitPrice DESC;

--SELECCIONAR LOS PRODUCTOS CON STOCK MENOR O = A 20
SELECT ProductID AS [NUMERO DE PRODUCTO],
ProductName AS  [NOMBRE PRODUCTO],
UnitPrice AS  [PRECIO UNITARIO],
UnitsINStock AS  [STOCK]
FROM PRODUCTS
WHERE UnitSInStock<20;

--SELECCIONAR LOS PEDIDOS POSTERIORES A 1997
SELECT OrderDate AS [FECHA DE LA ORDEN],
OrderID AS  [ID DE LA ORDEN]
FROM Orders
WHERE OrderDate > 1998;

--Extraer datos los rositas
SELECT OrderID, OrderDate,CustomerID,ShipCountry,
    YEAR(OrderDate) AS AÑO,
    MONTH(OrderDate) AS MES,
    DAY (orderDate) AS Dia,
    DATEPART(YEAR, OrderDate) AS AÑO2,
    DATEPART(QUARTER,OrderDate) AS TRIMESTRE,
    DATEPART(WEEKDAY,OrderDate) AS  [DIA SEMANA],
    DATENAME(WEEKDAY,OrderDate) AS  [DIA SEMANA NOMBRE]
FROM Orders
WHERE OrderDate >  '1997-12-31';
--SELECCIONAR LOS PEDIDOS POSTERIORES A 1997

--SELECCIONAR LOS PEDIDOS POSTERIORES A 1997
SELECT OrderID, OrderDate,CustomerID,ShipCountry,
    YEAR(OrderDate) AS AÑO,
    MONTH(OrderDate) AS MES,
    DAY (orderDate) AS Dia,
    DATEPART(YEAR, OrderDate) AS AÑO2,
    DATEPART(QUARTER,OrderDate) AS TRIMESTRE,
    DATEPART(WEEKDAY,OrderDate) AS  [DIA SEMANA],
    DATENAME(WEEKDAY,OrderDate) AS  [DIA SEMANA NOMBRE]
FROM Orders
WHERE YEAR(OrderDate) > 1997;

SET LANGUAGE SPANISH;
SELECT OrderID, OrderDate,CustomerID,ShipCountry,
    YEAR(OrderDate) AS AÑO,
    MONTH(OrderDate) AS MES,
    DAY (orderDate) AS Dia,
    DATEPART(YEAR, OrderDate) AS AÑO2,
    DATEPART(QUARTER,OrderDate) AS TRIMESTRE,
    DATEPART(WEEKDAY,OrderDate) AS  [DIA SEMANA],
    DATENAME(WEEKDAY,OrderDate) AS  [DIA SEMANA NOMBRE]
FROM Orders
WHERE DATEPART(YEAR,OrderDate) > 1997;

--OPERADORES LOGICOS (NOT,AND,OR)
/*
    SELECCIONAR LOS PRODUCTOS QUE TENGAN UN PRECIO MAYOR A 20 Y MENOS DE 100 UNIDADES EN STOCK
    mostrar los clientes que sean de estados unidos o de canada
    obtener los pedidos que no tengan region
*/
SELECT *
FROM PRODUCTS;

SELECT
ProductID AS [ID producto],
ProductName [Nombre producto],
UnitsInStock [Stock],
UnitPrice [PRECIO]
FROM PRODUCTS
WHERE UnitPrice > 20 and UnitsInStock < 100;

SELECT
CustomerID AS [ID CLIENTE],
CompanyName [CONTACTO],
City [CIUDAD],
Country [Pais],
Region [Region]
FROM Customers
WHERE Country = 'USA' or Country = 'Canada';

--In se usa para null el not no funciona
SELECT CustomerID, OrderDate, ShipRegion
FROM Orders
WHERE ShipRegion is null;

SELECT CustomerID, OrderDate, ShipRegion
FROM Orders
WHERE ShipRegion is not null;

---OPERADOR IN
/*
Mostrar los clientes de alemania, francia y uk
OBTENER LOS PRODUCTOS DONDE LA CATEGORIA SEA 1,3 O 5
*/

SELECT*
FROM Customers
WHERE Country in ('Germany','France','UK')
ORDER BY Country DESC;

SELECT*
FROM Customers
WHERE Country = 'Germany'OR
    Country = 'Freance' OR
    Country = 'uk';

--OBTENER LOS PRODUCTOS DONDE LA CATEGORIA SEA 1,3 O 5
SELECT*
FROM Products
    ProductID AS [IDPRODUCTO],
WHERE

--OPERADOR BETWEEN
--MOSTRAR LOS PRODUCTOS CUYO PRECIO ESTA ENTRE 20 Y 40
--EL BETWEEN DEBE COLOCARSE PRIMERO EL LIMITE INFERIOR Y LUEGO EL SUPERIOR
SELECT *
FROM Products
WHERE UnitPrice BETWEEN 20 AND 40
ORDER  BY UnitPrice;

SELECT *
FROM Products
WHERE UnitPrice>= 20 AND UnitPrice<=40
ORDER  BY UnitPrice;

--OPERADOR LIKE
--seleccionar todos los clientes customers que comiencen co la letra a

SELECT*
FROM Customers;

SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName Like 'a%';

--se les conoce como comodines
SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName Like 'an%';

SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE City LIKE 'L_nd__%';

SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName Like '%as';

--seleccionar los clientes donde la ciudad contenga la letra L
SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE City LIKE '%me%';

--seleccionar todo los clientes que en su nombre comiencen con a o con b
SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE NOT CompanyName LIKE 'a%' OR  CompanyName LIKE 'b%';

SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE NOT (CompanyName LIKE 'a%' OR  CompanyName LIKE 'b%');

--SELECCIONAR TODOS LOS CLIENTES QUE COMIENCEN CON B Y TERMINE CON S

SELECT CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE 'b%s';

SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE 'a__%';

SELECT * FROM Customers
WHERE City LIKE '_ondon';

--seleccionar todos los clientes que comiencen con "b", "s", or "p":
SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE '[bsp]%';

--seleccionar todos los clientes que comiencen con "a", "b", "c", "d", "e" or "f":

SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE '[abcdef]%';

--PUEDES PONER EL 2 PORQUE QUEREMOS QUE SE ORDENE DE ACUERDO A COMPANY NAME QUE ES EL SEGUNDO EN LISTA
SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE '[a-f]%'
ORDER BY 2 ASC;

--- EL SIMBOLO ^ ES COMO UNA NEGACIÓN COMO UN NOT
SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE '[^bsp]%';

SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE CompanyName LIKE '[^A-F]%';

---SELECCIONAR TODOS LOS CLIENTES DE ESTADOS UNIDOS O CANADA  QUE INICIEN CON B

SELECT
CustomerID, CompanyName, City, Region, Country
FROM Customers
WHERE (Country = 'USA'OR Country = 'CANADA') AND CompanyName LIKE 'B%';