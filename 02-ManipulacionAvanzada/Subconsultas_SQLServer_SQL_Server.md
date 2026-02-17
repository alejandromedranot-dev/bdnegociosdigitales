Subconsultas en SQL Server
Guía clara con ejemplos y datos

Fecha: 08/02/2026


Objetivo: entender los tipos de subconsultas, su sintaxis y qué devuelve cada una, usando un mismo conjunto de datos para facilitar la comparación.


# 1. Datos de ejemplo

Usaremos estas dos tablas imaginarias para interpretar los resultados de cada consulta:

Tabla: Customers


Tabla: Orders


# 2. ¿Qué es una subconsulta?

Una subconsulta (subquery) es un SELECT dentro de otro SELECT. Puede devolver:

Un solo valor (escalar).

Una lista de valores (una columna, varias filas).

Una tabla (varias columnas y/o varias filas).

Según lo que devuelva, se elige el operador correcto (=, IN, EXISTS, etc.).

# 3. Tipos de subconsultas con ejemplos

## 3.1 Subconsulta escalar (1 valor)

Devuelve 1 fila y 1 columna. Se usa como si fuera una constante calculada.

### a) Escalar en SELECT (agrega una columna constante)

```sql
SELECT
```

OrderID, Total,

(SELECT AVG(Total) FROM Orders) AS AvgTotal

FROM Orders;

Qué devuelve: Calcula AVG(Total) = 925 y lo repite en cada fila como columna AvgTotal.

### b) Escalar en WHERE (filtra contra un valor global)

```sql
SELECT OrderID, CustomerID, Total
```

FROM Orders

WHERE Total > (SELECT AVG(Total) FROM Orders);

Qué devuelve: Filtra Total > 925. Resultan OrderID 101 (1200) y 104 (1500).

### c) Escalar en WHERE con MAX/MIN

-- Pedido(s) con el máximo total

```sql
SELECT OrderID, CustomerID, Total
```

FROM Orders

WHERE Total = (SELECT MAX(Total) FROM Orders);


-- Pedido(s) con el mínimo total

```sql
SELECT OrderID, CustomerID, Total
```

FROM Orders

WHERE Total = (SELECT MIN(Total) FROM Orders);

Qué devuelve: MAX(Total)=1500 → OrderID 104. MIN(Total)=300 → OrderID 102.

### d) Escalar correlacionada en WHERE (1 valor por cada fila externa)

Sigue siendo escalar, pero se recalcula por cada fila porque usa columnas de la consulta principal.

```sql
SELECT o.OrderID, o.CustomerID, o.Total
```

FROM Orders o

WHERE o.Total > (

```sql
SELECT AVG(o2.Total)
```

FROM Orders o2

WHERE o2.CustomerID = o.CustomerID

);

Qué devuelve: Compara cada pedido contra el promedio de su propio cliente. Solo pasa OrderID 101 (1200), porque para CustomerID=1 el promedio es 750.

## 3.2 Subconsulta de una columna (lista) + IN

```sql
SELECT CustomerID, Name
```

FROM Customers

WHERE CustomerID IN (SELECT CustomerID FROM Orders);

Qué devuelve: La subconsulta devuelve {1,2,3}. Resultan Ana, Luis y María (Jorge no tiene pedidos).

## 3.3 Subconsulta de múltiples filas con ANY (SOME) y ALL

Sirve para comparar un valor contra un conjunto de valores.

### a) > ANY: mayor que al menos uno

```sql
SELECT OrderID, Total
```

FROM Orders

WHERE Total > ANY (

```sql
SELECT Total
```

FROM Orders

WHERE CustomerID = 1

);

Qué devuelve: Pedidos de Ana: {1200,300}. Total > ANY equivale a Total > 300. Resultan 101, 103 y 104.

### b) > ALL: mayor que todos

```sql
SELECT OrderID, Total
```

FROM Orders

WHERE Total > ALL (

```sql
SELECT Total
```

FROM Orders

WHERE CustomerID = 1

);

Qué devuelve: Total > ALL(1200,300) equivale a Total > 1200. Solo resulta 104 (1500).

## 3.4 Subconsulta correlacionada (depende de la fila actual)

Cualquier subconsulta que referencia columnas de la consulta externa es correlacionada (y se ejecuta por fila).

```sql
SELECT c.CustomerID, c.Name,
```

(SELECT COUNT(*)

FROM Orders o

WHERE o.CustomerID = c.CustomerID) AS OrdersCount

FROM Customers c;

Qué devuelve: Devuelve 2 para Ana, 1 para Luis, 1 para María y 0 para Jorge.

## 3.5 EXISTS y NOT EXISTS (sí/no existe)

EXISTS solo verifica existencia de filas; suele ser muy claro para 'tiene / no tiene'.

### a) Clientes que sí tienen pedidos (EXISTS)

```sql
SELECT c.CustomerID, c.Name
```

FROM Customers c

WHERE EXISTS (

```sql
SELECT 1
```

FROM Orders o

WHERE o.CustomerID = c.CustomerID

);

Qué devuelve: Resultan Ana, Luis y María.

### b) Clientes sin pedidos (NOT EXISTS)

```sql
SELECT c.CustomerID, c.Name
```

FROM Customers c

WHERE NOT EXISTS (

```sql
SELECT 1
```

FROM Orders o

WHERE o.CustomerID = c.CustomerID

);

Qué devuelve: Resulta Jorge.

## 3.6 Subconsulta en FROM (tabla derivada)

```sql
SELECT t.CustomerID, t.TotalSpent
```

FROM (

```sql
SELECT CustomerID, SUM(Total) AS TotalSpent
```

FROM Orders

GROUP BY CustomerID

) t

WHERE t.TotalSpent > 1000;

Qué devuelve: Suma por cliente: (1→1500), (2→700), (3→1500). Filtra >1000 → CustomerID 1 y 3.

## 3.7 Escalar con TOP(1) para elegir un valor (último/primero)

```sql
SELECT *
```

FROM Orders

WHERE CustomerID = (

```sql
SELECT TOP (1) CustomerID
```

FROM Orders

ORDER BY OrderDate DESC

);

Qué devuelve: El pedido más reciente es 2025-03-01 (CustomerID=3). Resulta el pedido 104.

# 4. Errores comunes y reglas rápidas

Reglas prácticas:

Si usas '=' en WHERE, la subconsulta debe devolver 1 valor (escalar).

Si la subconsulta devuelve una lista, usa IN, ANY/SOME o ALL (según el caso).

Para 'tiene / no tiene', prefiere EXISTS / NOT EXISTS.

Si necesitas una 'tabla intermedia' con cálculos, usa subconsulta en FROM (tabla derivada) o CTE.

Ejemplo de error típico (subconsulta devuelve varias filas y se usa '=' ):

-- ERROR: Subquery returned more than 1 value

```sql
SELECT *
```

FROM Customers

WHERE CustomerID = (SELECT CustomerID FROM Orders);

Corrección:

```sql
SELECT *
```

FROM Customers

WHERE CustomerID IN (SELECT CustomerID FROM Orders);

# 5. Ejercicios propuestos (sin solución)

1) Lista los pedidos cuyo Total sea mayor que el promedio global de Orders.

2) Lista los pedidos cuyo Total sea igual al máximo Total de Orders.

3) Muestra los clientes que NO tienen pedidos usando NOT EXISTS.

4) Muestra los clientes que SÍ tienen pedidos usando EXISTS.

5) Para cada cliente, muestra CustomerID, Name y la cantidad de pedidos (subconsulta correlacionada en SELECT).

6) Muestra los pedidos cuyo Total sea mayor que el promedio de su propio cliente (subconsulta correlacionada en WHERE).

7) Muestra los clientes cuyo CustomerID esté en la lista de clientes con pedidos (IN).

8) Muestra los pedidos cuyo Total sea mayor que ALL los pedidos del CustomerID=1.

9) Muestra los pedidos cuyo Total sea mayor que ANY los pedidos del CustomerID=1.

10) Construye una tabla derivada (subconsulta en FROM) con TotalSpent por cliente y filtra los que superen 1000.


---
## Tablas del documento

### Tabla 1
| CustomerID | Name | City |
| --- | --- | --- |
| 1 | Ana | Pachuca |
| 2 | Luis | Tula |
| 3 | María | Pachuca |
| 4 | Jorge | Querétaro |

### Tabla 2
| OrderID | CustomerID | OrderDate | Total |
| --- | --- | --- | --- |
| 101 | 1 | 2025-01-10 | 1200 |
| 102 | 1 | 2025-02-05 | 300 |
| 103 | 2 | 2025-02-20 | 700 |
| 104 | 3 | 2025-03-01 | 1500 |
