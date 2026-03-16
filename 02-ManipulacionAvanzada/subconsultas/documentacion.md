# ¿Qué es una subconsulta?

Una subconsulta (subquery) es un select dentro de otro SELECT. Puede devolver:

1. Un solo valor (escalar)
1. Una lista de valores (una columna, varias filas)
1. Una tabla (varias columnas y/o varias filas)
1. Según lo que devuelva, se elige el operador correto (=, IN, EXISTS, etc).


Una subconsulta es una consulta anidada dentro de otra consulta
que permite resolver problemas en varios niveles de información

```
Dependiendo de dondé se coloque y que retorne, cambia su comportamiento.

```

5 grandes formas de usarlas:

1. subconsultas escalares.
2. Subconsultas con IN, ANY, ALL.
3. Subconsultas correlacionadas.
4. Subconsultas en Select.
5. Subconsultas en From (Tablas derivadas).

## Escalares:

Devuelven un único valor, por eso se pueden utilizar 
con operadores =,>,<.

Ejemplo:

```sql
SELECT *
FROM pedidos
WHERE total = (
	SELECT MAX(total)
	FROM pedidos
);
```

## Subconsultas con IN, ANY, ALL.

Devuelve varios valores con una sola columna (IN)

> Seleccionar todos los clientes que han hecho pedidos
```sql
SELECT * 
FROM clientes 
WHERE id_cliente IN (
	SELECT id_cliente 
	FROM pedidos
);
```

```sql
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
```

## Clausula ANY

- Compara un valor contra una Lista
- La condición se cumple si se cumple con AL MENOS UNO

```sql
valor > ANY (subconsulta)
```

> Es como decir: Mayor que al menos uno de los valores

- Seleccionar Pedidos mayores que algún pedido de luis (id_cliente=2)

```sql
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
```

## Clausula ALL
Se cumple contra todos los valores

```sql
valor > ALL (subconsulta)
```
Significa:

- Mayor que todos los valores


```sql
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
```

## Subconsultas correlacionadas

> Una subconsulta correlacionada depende de la fila actual de la consulta principal y se ejecuta una vez por cada fila 

--- 

1. Seleccionar los clientes cuyo total de compras sea mayor a 1000
