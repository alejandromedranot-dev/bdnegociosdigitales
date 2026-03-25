
# Documentación de Prácticas SQL: Creación de BD, Tablas y Restricciones

###### Alumno: Alejandro Medrano Tovar

El siguiente documente describe paso a paso la ejecución y funcionamiento de distintas consultas en SQL Server para llevar a la práctica la Definición de Datos(DDL) yla Manipulación de Datos(MDL).

---

## 1. Creación de Bases de Datos
Creamos la base de datos principal y se selecciona para su uso. El comando que nos permite crear una Base de datos es:

* `CREATE DATABASE `

El comando `USE` nos ayuda a referenciar la base de datos que ocuparemos.


```sql
-- Crea una base de datos
CREATE DATABASE tienda;
GO

--Usar la DB creada
USE tienda;
GO

```

## 2. Creación de Tablas Básicas

Creareos una tabla `cliente` inicial con tipos de datos básicos y valores por defecto.

* `CREATE TABLE`: Crea una nueva tabla

### tipos de datos

* `INT`: Tipo de dato entero.
* `NOT NULL`: No acepta valores nulos.
* `NVARCHAR`: Almacena cadenas de caracteres


```sql
CREATE TABLE cliente(
    id INT not null,
    nombre NVARCHAR(30) not null,
    apaterno NVARCHAR(10) not null,
    amaterno NVARCHAR(10) null,
    sexo NCHAR(1) not null,
    edad INT not null,
    direccion NVARCHAR(80) not null,
    rfc NVARCHAR(20) not null,
    limitecredito MONEY not null default 500.0
);
GO

```

## 3. Definición de Restricciones (Primary Keys)

Posteriormente crearemos una versión mejorada de la tabla, `clientes`, definiendo explícitamente la **Llave Primaria** y tipos de datos para fechas.

* `DATE`: Solo acepta fechas dentro del campo

```sql

CREATE TABLE clientes(
    cliente_id INT NOT NULL PRIMARY KEY,
    nombre NVARCHAR(30) NOT NULL,
    apellido_paterno NVARCHAR(20) NOT NULL,
    apellido_materno NVARCHAR(20),
    edad INT NOT NULL,
    fecha_nacimiento DATE NOT NULL,
    limite_credito MONEY NOT NULL
);
GO

```

## 4. Inserción de Datos (DML)

La inserción de datos en SQL se refire al proceso de añadir nuevos registros(filas) a una tabla existente, en este caso aremos una inserción de datos a la tabla `clientes`.

### Inserción posicional y específica

Se insertan valores respetando el orden de las columnas o definiendo el orden explícitamente.

* `INSERT INTO`: Define a que tabla se realizará la inserción
* `VALUES`: Define los valores que se agregaran a los campos

```sql
INSERT INTO clientes 
VALUES(1, 'Goku', 'Linterna', 'Superman', 450, '1578-01-17', 100);

INSERT INTO clientes 
VALUES(2, 'Pancracio', 'Rivero', 'Patroclo', 20, '2005-01-17', 10000);

INSERT INTO clientes 
(nombre, cliente_id, limite_credito, fecha_nacimiento, apellido_paterno, edad)
VALUES('Arcadia', 3, 45800, '2000-01-22', 'Ramirez', 26);

INSERT INTO clientes 
VALUES(4, 'Vanesa', 'Buena Vista', NULL, 26, '2000-04-25', 3000);

```

### Inserción múltiple

Podemos hacer inserciones a varias filas en una sola sentencia de la siguiente manera:

```sql
INSERT INTO clientes 
VALUES
(5, 'Soyla', 'Vaca', 'del Corral', 42, '1983-04-06', 78955),
(6, 'Bad Bunny', 'Perez', 'sin Sentido', 22, '1999-05-06', 85858),
(7, 'Jose Luis', 'Herrera', 'Gallardo', 42, '1983-04-06', 14000);

```

## 5. Consultas y Funciones del Sistema

Ejemplos de cómo obtener la fecha del servidor y consultar datos.

```sql
SELECT GETDATE(); -- obtiene la fecha del sistema

SELECT * FROM clientes;

SELECT cliente_id, nombre, edad, limite_credito
FROM clientes;

```

## 6. Propiedad IDENTITY y DEFAULT

**IDENTITY** Crea valores numericos autoincrementales para identificadores únicos usados generalmente en la `PRIMARY KEY`.

**DEFAULT** inserta un valor predeterminado especifico cuando no se proporciona uno en una sentencia `INSERT`.

Se crea la tabla `clientes_2` para demostrar el autoincremento (`IDENTITY`) y valores por defecto (`DEFAULT`).

```sql
CREATE TABLE clientes_2(
    cliente_id INT not null IDENTITY(1,1),
    nombre NVARCHAR(50) not null,
    edad INT not null,
    fecha_registro DATE DEFAULT GETDATE(),
    limite_credito MONEY not null,
    CONSTRAINT pk_clientes_2
    PRIMARY KEY (cliente_id)
);

SELECT * FROM clientes_2;

```

Se insertan datos sin especificar el ID (se genera solo) y usando `DEFAULT` para la fecha.

```sql
INSERT INTO clientes_2
VALUES ('Chespirito', 89, DEFAULT, 45500);

INSERT INTO clientes_2 (nombre, edad, limite_credito)
VALUES ('Batman', 45, 8900);

INSERT INTO clientes_2
VALUES ('Robin', 35, '2026-01-19', 89.32);

INSERT INTO clientes_2 (limite_credito, edad, nombre, fecha_registro)
VALUES (12.33, 24, 'Flash reverso', '2026-01-21');

```

## 7. Restricciones Avanzadas (CHECK y UNIQUE)

**CHECK** nos ayuda a validar que los datos cumplan una condición en especifico antes de que realicemos una inserción.

**UNIQUE** se asegura de que todos los valores en una columna sean distintos, prohibiendo asi duplicados.

Se crea la tabla `suppliers` validando que el nombre sea único, el crédito esté en un rango y el tipo sea un valor permitido.

```sql
CREATE TABLE suppliers (
    supplier_id INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(30) NOT NULL,
    date_register DATE NOT NULL DEFAULT GETDATE(),
    tipo CHAR(1) NOT NULL,
    credit_limit MONEY NOT NULL,
    CONSTRAINT pk_suppliers
    PRIMARY KEY ( supplier_id ),
    CONSTRAINT unique_name
    UNIQUE ([name]),
    CONSTRAINT chk_credit_limit
    CHECK (credit_limit > 0.0 and credit_limit <= 50000),
    CONSTRAINT chk_tipo
    CHECK (tipo in ('A', 'B', 'C'))
);

SELECT * FROM suppliers;

INSERT INTO suppliers
VALUES (UPPER('bimbo'), DEFAULT, UPPER('c'), 45000);

INSERT INTO suppliers
VALUES (UPPER('tia rosa'), '2026-01-21', UPPER('a'), 49999.9999);

INSERT INTO suppliers ([name], tipo, credit_limit)
VALUES (UPPER('tia mensa'), UPPER('a'), 49999.9999);

```

---

## 8. Nueva Base de Datos: Relaciones y FK

`CONSTRAINT`: Es una regla la cual se define en una tabla que limita el tipo de datos que pueden insertarse, actualizarse o eliminarse. El objetivo principal es asegurar la integridad, precisión y fiabilidad de los datos rechazando cualquier acción que viole dichas reglas.

##### Principales tipos de Constraints

* `PRIMARY KEY`: Identifica de forma única cada fila y garantiza que no haya valores nulos ni duplicados.

*`FOREIGN KEY`: Mantiene la integridad referencial, asegurando que un valor en una tabla coincida con uno en otra tabla relacionada.

*`CHECK`:  Limita el rango de valores permitidos en una columna basándose en una expresión lógica (ej. Edad >= 18).

Se crea una segunda base de datos `dborders` para trabajar relaciones entre tablas.

```sql

CREATE DATABASE dborders;
GO

USE dborders;
GO


CREATE TABLE customers (
    customer_id INT NOT NULL IDENTITY(1,1),
    first_name NVARCHAR(20) NOT NULL,
    last_name NVARCHAR(30),
    [address] NVARCHAR(80) NOT NULL,
    number INT,
    CONSTRAINT pk_customers
    PRIMARY KEY (customer_id)
);
GO

```

### Gestión de Estructura (DDL)

Se muestra cómo crear una tabla, eliminar una restricción y luego eliminar la tabla completa.

```sql
CREATE TABLE suppliers (
    
    supplier_id INT NOT NULL,
    
    CONSTRAINT pk_suppliers PRIMARY KEY ( supplier_id ),
    
);
GO

ALTER TABLE suppliers
DROP CONSTRAINT pk_suppliers;

DROP TABLE suppliers;

```

## 9. Integridad Referencial: ON DELETE NO ACTION

La integridad referencial es una regla que impide borrar un registro principal(padre) si existenregistros relacionados en una tabla dependiente (hija)

* `ON DELETE NO ACTION`:  Cuando se elimina una fila en una tabla referenciada (la principal), NO ACTION verifica si hay claves foráneas relacionadas en otra tabla.

* `ON UPDATE NO ACTION`: Si no se especifica ninguna acción al crear una clave foránea (FOREIGN KEY), SQL Server aplica NO ACTION automáticamente.

Se crea la tabla `products` relacionada con `suppliers`. La configuración `NO ACTION` impide eliminar un proveedor si tiene productos asociados.

```sql
CREATE TABLE products (
    product_id INT NOT NULL IDENTITY(1,1),
    [name] NVARCHAR(40) NOT NULL,
    quantity INT NOT NULL,
    unit_price MONEY NOT NULL,
    supplier_id INT
    CONSTRAINT pk_products
    PRIMARY KEY (product_id),
    /* ... constraints ... */
    CONSTRAINT fk_products_suppliers
    FOREIGN KEY (supplier_id)
    REFERENCES suppliers (supplier_id)
    ON DELETE NO ACTION 
    ON UPDATE NO ACTION
);
GO

```

*(El script realiza operaciones de limpieza `DROP` y `ALTER` para ajustar la columna `supplier_id` a NULLABLE antes de las pruebas).*

```sql

ALTER TABLE products
ALTER COLUMN supplier_id INT NULL;

UPDATE products
SET supplier_id = NULL;

```

### Inserción de datos relacionales

Se llenan ambas tablas para probar las llaves foráneas.

```sql
INSERT INTO suppliers VALUES (1, UPPER('CHINO S.A.'), DEFAULT, UPPER('c'), 45000);

INSERT INTO products VALUES ('Papas', 10, 5.3, 1);

```

### Pruebas de Integridad

Se valida qué sucede al intentar borrar registros vinculados.

```sql

DELETE FROM products WHERE supplier_id = 1;


DELETE FROM suppliers WHERE supplier_id = 1;


UPDATE products SET supplier_id = NULL WHERE supplier_id = 2; 
UPDATE suppliers SET supplier_id = 10 WHERE supplier_id = 2;

```

## 10. Integridad Referencial: ON DELETE SET NULL

Se modifica la estructura (borrando y creando de nuevo la tabla `products`) para cambiar el comportamiento de la llave foránea a `SET NULL`.

```sql
DROP TABLE products;

CREATE TABLE products (
    CONSTRAINT fk_products_suppliers
    FOREIGN KEY (supplier_id)
    REFERENCES suppliers (supplier_id)
    ON DELETE SET NULL 
    ON UPDATE SET NULL
);
GO

```

### Comprobación del comportamiento

Al eliminar un proveedor, sus productos no se eliminan, sino que su referencia se vuelve `NULL`.

```sql

DELETE suppliers
WHERE supplier_id = 10;

UPDATE suppliers
SET supplier_id = 20
WHERE supplier_id = 1;


SELECT * FROM suppliers;
SELECT * FROM products;

```


# Guía de Consultas SQL: Operadores y Funciones

#### En este apartado abordaremos una serie de consultas de manipulación de datos (DML) utilizando la base de datos de ejemplo de *Northwind* donde se abordaran temas desde selecciones básicas hasta funciones más avanzadas como fechas y coincidencia de patrones
---

## 1. Consultas Básicas (Selección Total)
El comando `SELECT *` se utiliza para recuperar todas las columnas y todas las filas de una tabla. Es útil para exploraciones rápidas.

```sql
SELECT *
FROM Categories;

SELECT *
FROM Products;

SELECT *
FROM Orders;

SELECT *
FROM [Order Details];

```

## 2. Proyección (Selección de Columnas Específicas)

Cuando no necesitemos seleccionar todos los datos de la tabla, se especifican las columnas exactas que se necesitan. Esto mejora el rendimiento y la legibilidad.

```sql
SELECT *
FROM Products;

SELECT 
    ProductID, 
    ProductName, 
    UnitPrice, 
    UnitsInStock
FROM Products;

```

## 3. Uso de Alias de Columnas

Los alias (`AS`) permiten renombrar temporalmente las columnas en el conjunto de resultados para que sean más comprensibles para el usuario final. Se pueden usar corchetes `[]` o comillas simples `''` si el nombre contiene espacios.

```sql
SELECT 
    ProductID AS [NUMERO DE PRODUCTO], 
    ProductName 'NOMBRE DE PRODUCTO', 
    UnitPrice AS [PRECIO UNITARIO], 
    UnitsInStock AS STOCK
FROM Products;

SELECT 
    CompanyName AS CLIENTE,
    City AS CIUDAD,
    Country AS PAIS
FROM Customers;

```

## 4. Campos Calculados

SQL permite realizar operaciones aritméticas directamente en la consulta. Estos campos no existen físicamente en la tabla, se calculan al ejecutar la consulta.

### Calculando el valor del inventario

Se multiplica el precio unitario por las unidades en stock.

```sql

SELECT *, (UnitPrice * UnitsInStock) AS [COSTO INVENTARIO]
FROM Products;


SELECT 
    ProductID, 
    ProductName, 
    UnitPrice, 
    UnitsInStock, 
    (UnitPrice * UnitsInStock) AS [COSTO INVENTARIO]
FROM Products;

```

### Calculando importes de venta y descuentos

A continuación, se realizan cálculos sobre la tabla de detalles de órdenes, incluyendo lógica para aplicar descuentos porcentuales.

```sql
SELECT *
FROM [Order Details];

-- Cálculo simple de subtotal
SELECT 
    OrderID,
    ProductID,
    UnitPrice, 
    Quantity, 
    (UnitPrice * Quantity) AS Subtotal
FROM [Order Details];

-- Cálculo mostrando el importe base y aplicando descuentos
SELECT
    OrderID,
    UnitPrice, 
    Quantity, 
    Discount,
    (UnitPrice * Quantity) AS Importe,
    (UnitPrice * Quantity) - ((UnitPrice * Quantity) * Discount) AS [Importe con Descuento 1],
    (UnitPrice * Quantity) * (1 - Discount) AS [Importe con descuento 2]
FROM [Order Details];


SELECT 
    OrderID, 
    ProductID, 
    UnitPrice, 
    Quantity, 
    Discount,
    (UnitPrice * Quantity * (1 - Discount)) AS [Total Con Descuento]
FROM [Order Details];

```

## 5. Operadores Relacionales

Se utilizan para filtrar registros comparando valores (`<`, `>`, `<=`, `>=`, `=`, `!=` o `<>`).

```sql
/*
    Seleccionar los productos con precio mayor a 30
    Seleccionar los productos con stock menor o igual a 20
*/

SELECT 
    ProductID AS [Número de Producto],
    ProductName AS [Nombre Producto],
    UnitPrice AS [Precio Unitario],
    UnitsInStock AS Stock
FROM Products
WHERE UnitPrice > 30
ORDER BY UnitPrice DESC;

SELECT 
    ProductID AS [Número de Producto],
    ProductName AS [Nombre Producto],
    UnitPrice AS [Precio Unitario],
    UnitsInStock AS [Stock]
FROM Products
WHERE UnitsInStock <= 20;

```

## 6. Funciones de Fecha

SQL Server ofrece funciones muy eficientes para manipular y extraer partes de una fecha (`YEAR`, `MONTH`, `DAY`, `DATEPART`, `DATENAME`).

```sql
-- Filtrar pedidos posteriores al año 1997
SELECT * FROM Orders;

SELECT 
    OrderID,
    OrderDate,
    CustomerID,
    ShipCountry,
    YEAR(OrderDate) AS Año,
    MONTH(OrderDate) AS Mes,
    DAY(OrderDate) AS Dia
FROM Orders
WHERE YEAR(OrderDate) > '1997';

```

### Exploración detallada de partes de la fecha

Uso de `DATEPART` y configuración del idioma para obtener nombres de días en español.

```sql
SELECT 
    OrderID,
    OrderDate,
    CustomerID,
    ShipCountry,
    YEAR(OrderDate) AS Año,
    MONTH(OrderDate) AS Mes,
    DAY(OrderDate) AS Dia,
    DATEPART(YEAR, OrderDate) AS AÑO2,
    DATEPART(QUARTER, OrderDate) AS Trimestre,
    DATEPART(WEEKDAY, OrderDate),
    DATEPART(WEEKDAY, OrderDate) AS [Dia Semana],
    DATENAME(WEEKDAY, OrderDate) AS [Dia Semana Nombre]
FROM Orders
WHERE YEAR(OrderDate) > 1997;

-- Configuración de idioma para que DATENAME devuelva español
SET LANGUAGE SPANISH;

SELECT 
    OrderID,
    OrderDate,
    CustomerID,
    ShipCountry,
    -- (Columnas de fecha repetidas para confirmar el cambio de idioma)
    DATENAME(WEEKDAY, OrderDate) AS [Dia Semana Nombre]
FROM Orders
WHERE YEAR(OrderDate) > 1997;

```

### Filtrado por fecha específica

Nota: Las fechas suelen manejarse en formato `YYYY-MM-DD` o `YYYYMMDD` para evitar ambigüedades.

```sql
SELECT 
    OrderID,
    OrderDate,
    ShipName
FROM Orders
WHERE OrderDate >= '1998-01-01';

```

## 7. Operadores Lógicos (AND, OR, NOT, IS NULL)

Permiten combinar múltiples condiciones.

```sql
/* Seleccionar productos con precio > 20 Y stock < 100 */
SELECT 
    ProductName AS [Nombre del producto], 
    UnitPrice AS [Precio unitario], 
    UnitsInStock AS Stock
FROM Products
WHERE (UnitPrice > 20) AND (UnitsInStock < 100);

-- Operador OR: Clientes de USA o Canada
SELECT 
    CustomerID,
    CompanyName,
    City,
    Region,
    Country
FROM Customers
WHERE Country IN ('USA', 'Canada');

-- Filtrar nulos (IS NOT NULL)
-- Obtener pedidos que sí tengan registrada una región de envío
SELECT 
    CustomerID,
    OrderDate,
    ShipRegion
FROM Orders
WHERE ShipRegion IS NOT NULL;

```

## 8. Operadores de Lista y Rango (IN, BETWEEN)

Simplifican la sintaxis cuando se busca dentro de un conjunto de valores o un rango numérico/fecha.

```sql
-- Operador IN: Reemplaza múltiples OR
SELECT * FROM Customers
WHERE Country IN ('Germany', 'France', 'UK')
ORDER BY Country DESC;

SELECT 
    ProductName,
    CategoryID,
    QuantityPerUnit
FROM Products
WHERE CategoryID IN (1, 3, 5)
ORDER BY CategoryID;

-- Operador BETWEEN
SELECT *
FROM Products
WHERE UnitPrice BETWEEN 20 AND 40
ORDER BY UnitPrice;

-- Equivalente usando AND
SELECT *
FROM Products
WHERE UnitPrice >= 20 AND UnitPrice <= 40
ORDER BY UnitPrice;

```

## 9. Búsqueda por Patrones (Operador LIKE)

El operador `LIKE` permite realizar búsquedas flexibles dentro de cadenas de texto utilizando comodines.

### Comodines básicos (% y _)

* `%`: Representa cero o más caracteres.
* `_`: Representa exactamente un caracter.

```sql
-- Comienza con 'a'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CompanyName LIKE 'a%';

-- Comienza con 'an'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CompanyName LIKE 'an%';

-- Patrón específico: L + un caracter + nd + dos caracteres
SELECT * FROM Customers
WHERE city LIKE 'L_nd__';

-- Termina con 'as'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CompanyName LIKE '%as';

-- Contiene 'mé' en cualquier parte
SELECT CustomerID, CompanyName, City FROM Customers
WHERE City LIKE '%mé%';

```

### Combinación con lógica booleana

```sql
-- No comienza con 'a' O comienza con 'b'
SELECT * FROM Customers
WHERE NOT CompanyName LIKE 'a%' OR CompanyName LIKE 'b%';

-- Comienza con 'b' Y termina con 's'
SELECT * FROM Customers
WHERE CompanyName LIKE 'b%s';

```

### Búsqueda con Conjuntos de Caracteres ([ ])

Permite especificar una lista o rango de caracteres posibles para una posición específica.

```sql
-- Comienza con 'b', 's', o 'p'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CustomerID LIKE '[bsp]%';

-- Rango: Comienza con cualquier letra de la 'a' a la 'f'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CustomerID LIKE '[a-f]%'
ORDER BY 2 ASC;

```

### Exclusión de Conjuntos ([^ ])

El símbolo `^` dentro de los corchetes indica negación (que NO contenga esos caracteres).

```sql
-- NO comienza con 'b', 's', o 'p'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CompanyName LIKE '[^bsp]%';

-- NO comienza con letras de la 'a' a la 'f'
SELECT CustomerID, CompanyName, Country FROM Customers
WHERE CompanyName LIKE '[^a-f]%'
ORDER BY 2 ASC;

```

## 10. Ejemplo Combinado Final

Consulta que mezcla operadores lógicos, listas y patrones de texto.

```sql
/*
    Seleccionar clientes de USA o Canadá 
    QUE ADEMÁS su nombre inicie con 'B'
*/

-- Usando AND
SELECT
    CustomerID,
    CompanyName,
    City,
    Region,
    Country
FROM Customers
WHERE Country IN ('USA','Canada') AND CompanyName LIKE 'B%'
ORDER BY 5;

-- Usando OR
SELECT
    CustomerID,
    CompanyName,
    City,
    Region,
    Country
FROM Customers
WHERE Country IN ('USA','Canada') OR CompanyName LIKE 'B%'
ORDER BY 5;

```

# Funciones de Agregado, GROUP BY y HAVING

En este apartado abordaremos el uso de funciones para realizar calculos sobre conjuntos de datos como agrupar resultados y fitrar grupos.

## 1. Introducción a Funciones de Agregado
Las funciones de agregado realizan un cálculo sobre un conjunto de valores y devuelven un solo valor. Las principales son:

1.  `SUM()`: Suma valores.
2.  `MAX()`: Encuentra el valor máximo.
3.  `MIN()`: Encuentra el valor mínimo.
4.  `AVG()`: Calcula el promedio.
5.  `COUNT()`: Cuenta filas.

---

## 2. Conteos Básicos (COUNT)

El conteo puede realizarse sobre todas las filas, sobre filas filtradas o sobre valores distintos.

```sql
-- Seleccionar los países distintos de los clientes
SELECT DISTINCT country
FROM Customers;

-- COUNT(*) cuenta el total de filas en la tabla (incluye nulos)
SELECT COUNT(*) AS [Total de ordenes]
FROM Orders;

-- Contar órdenes enviadas a Alemania
SELECT COUNT(*) AS [Total de ordenes Alemania]
FROM Orders
WHERE ShipCountry = 'Germany';

-- Diferencia entre contar "*" y contar un campo específico
-- COUNT(Campo) ignora los valores NULL
SELECT COUNT(CustomerID) FROM Customers; -- Cuenta todos
SELECT COUNT(Region) FROM Customers;     -- Cuenta solo quienes tienen región

```

### Contar valores únicos (DISTINCT)

Combinación de `COUNT` y `DISTINCT` para saber cuántas ciudades únicas existen.

```sql
SELECT COUNT(DISTINCT City) AS [Ciudades clientes]
FROM Customers;

```

---

## 3. Máximos y Mínimos (MAX / MIN)

Estas funciones sirven para números, fechas y cadenas de texto.

```sql
-- Precio más alto
SELECT MAX(UnitPrice) AS [Precio mas alto]
FROM Products;

-- Fecha más reciente de compra
SELECT MAX(OrderDate) AS [Fecha mas reciente]
FROM Orders;

-- Manejo de fechas: Obtener solo el año de la fecha más reciente
-- Forma 1: YEAR fuera del MAX
SELECT YEAR(MAX(OrderDate)) AS [Año mas reciente]
FROM Orders;

-- Forma 2: DATEPART fuera del MAX
SELECT DATEPART(YEAR, MAX(OrderDate)) AS [Año mas reciente]
FROM Orders;

```

### Cálculos con Mínimos

Podemos usar expresiones matemáticas dentro de la función de agregado.

```sql
-- Mínima cantidad en un detalle de pedido
SELECT MIN(Quantity) FROM [Order Details];

-- Importe más bajo calculado (Precio * Cantidad * Descuento)
SELECT MIN((UnitPrice * Quantity) * (1 - Discount)) AS [Importe mas bajo]
FROM [Order Details];

```

---

## 4. Sumas (SUM)

Se utiliza para totalizar columnas numéricas.

```sql
-- Suma total de precios unitarios
SELECT SUM(UnitPrice) FROM Products;

-- Total de dinero percibido
SELECT SUM((UnitPrice * Quantity) * (1 - Discount)) AS [Total de ventas]
FROM [Order Details];

```

---

## 5. Agrupamiento (GROUP BY)

La cláusula `GROUP BY` permite aplicar funciones de agregado a subconjuntos de datos.
**Regla de oro:** Todo campo en el `SELECT` que **no** sea una función de agregado, debe estar en el `GROUP BY`.

```sql
-- Total de órdenes agrupadas por país
SELECT ShipCountry, COUNT(*) AS [Total de ordenes]
FROM Orders
GROUP BY ShipCountry;

-- Ventas totales (cantidad) de los productos 4, 10 y 20
SELECT ProductID, SUM(Quantity) AS [Ventas de productos]
FROM [Order Details]
WHERE ProductID IN (4, 10, 20)
GROUP BY ProductID;

-- Suma de IDs de orden
SELECT ShipName, SUM(OrderID) AS [Ordenes por cliente]
FROM Orders
WHERE ShipName IN ('Around the Horn', 'Bólido Comidas preparadas', 'Chop-suey Chinese')
GROUP BY ShipName;

```

### Agrupamiento con fechas

Podemos agrupar o filtrar usando partes de una fecha.

```sql
-- Total de órdenes del segundo trimestre de 1996
SELECT COUNT(*) AS [Total Ordenes]
FROM Orders
WHERE DATEPART(YEAR, OrderDate) = 1996 
  AND DATEPART(QUARTER, OrderDate) = 2;

-- Total de órdenes entre 1996 y 1997
SELECT COUNT(*) AS [Total de ordenes]
FROM Orders
WHERE DATEPART(YEAR, OrderDate) BETWEEN 1996 AND 1997;

```

---

## 6. Consultas con Patrones y Agregados

Combinando `LIKE` con `COUNT`.

```sql
-- Clientes que empiezan con A o B
SELECT COUNT(*) AS [Total de clientes con A o B]
FROM Customers
WHERE CompanyName LIKE '[a-B]%';

-- Clientes que empiezan con B y terminan con S
SELECT COUNT(*) AS [Número de clientes]
FROM Customers
WHERE CompanyName LIKE 'B%S';

```

---

## 7. GROUP BY con JOINS

Es común agrupar datos provenientes de múltiples tablas relacionadas.

Los `Joins` son cláusulas que se utilizan para combinar filas de dos o mas tablas basadas en una  columna relacionda(que coincida o tengan en común) entre las tablas 

###### Tipos de JOINS

* `INNER JOIN`: Devuelve los registros que tienen correspondencia en **ambas tablas**. Es el tipo de unión más común, donde la intersección de datos es necesaria.

* `LEFT JOIN`: Retorna **todos los registros de la tabla izquierda**, junto con los registros coincidentes de la tabla derecha. Si no hay coincidencia, **devuelve NULL** para la tabla derecha.

* `RIGHT JOIN`:  Retorna todos los registros de la tabla derecha y las coincidencias de la izquierda.

* `FULL JOIN`:  Devuelve todos los registros cuando hay una coincidencia en cualquiera de las tablas. Muestra datos, incluso si no coinciden en la otra tabla.

```sql
-- Contar órdenes por nombre de compañía (JOIN entre Orders y Customers)
SELECT c.CompanyName, COUNT(*) AS [Ordenes por cliente]
FROM Orders AS o
INNER JOIN Customers AS c ON o.CustomerID = c.CustomerID
GROUP BY c.CompanyName
ORDER BY 2 DESC; -- Ordenar por la segunda columna

-- Total de productos por categoría
SELECT CategoryID, COUNT(*) AS [Total de productos]
FROM Products
GROUP BY CategoryID
ORDER BY [Total de productos] DESC;

-- Precio promedio por proveedor, redondeado a 2 decimales
SELECT SupplierID, ROUND(AVG(UnitPrice), 2) AS [Precio promedio]
FROM Products
GROUP BY SupplierID
ORDER BY 2 DESC;

```

---

## 8. Filtrado de Grupos (HAVING)

La diferencia fundamental:

* `WHERE`: Filtra filas **antes** de agrupar.
* `HAVING`: Filtra grupos **después** de agrupar (se usa con funciones de agregado).

```sql
-- Clientes con más de 10 pedidos
SELECT CustomerID, COUNT(*) AS [Numero de ordenes]
FROM Orders
GROUP BY CustomerID
HAVING COUNT(*) > 10
ORDER BY 2 DESC;

-- Empleados que han vendido más de 100,000 en total
SELECT 
    CONCAT(e.FirstName, ' ', e.LastName) AS [Nombre completo], 
    ROUND(SUM(od.Quantity * od.UnitPrice * ( 1 - od.Discount)), 2) AS [Importe]
FROM Employees AS e
INNER JOIN Orders AS o ON e.EmployeeID = o.EmployeeID
INNER JOIN [Order Details] AS od ON o.OrderID = od.OrderID
GROUP BY e.FirstName, e.LastName
HAVING SUM(od.Quantity * od.UnitPrice * ( 1 - od.Discount)) > 100000
ORDER BY Importe DESC;

-- Productos vendidos en más de 20 pedidos distintos
SELECT p.ProductID, p.ProductName, COUNT(DISTINCT o.OrderID) AS [Numero de pedidos]
FROM Products AS p
INNER JOIN [Order Details] AS od ON p.ProductID = od.ProductID
INNER JOIN Orders AS o ON od.OrderID = o.OrderID
GROUP BY p.ProductID, p.ProductName
HAVING COUNT(DISTINCT o.OrderID) > 20 
ORDER BY 3;

```

---

## 9. Flujo Lógico de Ejecución en SQL

Es importante entender que SQL no ejecuta el código en el orden en que se escribe (comenzando por SELECT), sino en el siguiente orden lógico:

1. **FROM**: Identifica las tablas base.
2. **JOIN**: Combina las tablas.
3. **WHERE**: Filtra las filas base (no agregados).
4. **GROUP BY**: Agrupa las filas restantes.
5. **HAVING**: Filtra los grupos creados (permite agregados).
6. **SELECT**: Escoge las columnas a mostrar.
7. **DISTINCT**: Elimina duplicados de la visualización.
8. **ORDER BY**: Ordena el resultado final.

