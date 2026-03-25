# ¿Qué es una subconsulta?

una subconsulta es un SELECT dentro de otro SELECT. Puede devolver:

 1. un solo valor (escalar)
 2. Una lista de valores(una colimna, varias filas)
 3. Una tabla(varias columnas y/o varias filas)
 4. Según lo que devuelta se eligue el operador correcto (*,IN.EXISTS,etc).

Una subconsulta es una consulta anidada dentro de otra consulta
que nos permite resolver problemas en varios niveles de información

```
Dependiendo de donde se coloque y que retorne cambia su comportamiento


```

#### 5 Grandes formas de usarlas

1. subconsultas escalares
2. subconsultas con IN, ANY, ALL (where)
3.  subconsultas correlacioandas
4. subconsultas en SELECT
4. subcosultas en FROM (tablas derivadas)

## 1. Escalares:

Devuelven un único valor por eso se pueden utilizar con operadores =,<,>, etc

Ejemplo

```sql

SELECT *
FROM pedidos
WHERE total =(SELECT MAX(total)
FROM pedidos)
```

## 2. Subconsultas con IN/ON

Devuelve varios valores pero con una sola columna (IN)

>Seleccioanr todos los cleintes que han hecho pedidos

```sql


SELECT *
FROM clientes
WHERE id_cliente IN (SELECT id_cliente
FROM pedidos
)


SELECT *
FROM pedidos
WHERE id_cliente IN (1,3,1)



SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (SELECT id_cliente FROM pedidos)


SELECT *
FROM clientes
WHERE ciudad = 'CDMX'
AND id_cliente IN (SELECT id_cliente FROM pedidos)

```

## Clusula ANY

compara un valor contra una lista, la condición se cumple si se cumple con al menos uno

```sql

valor > ANY (subconsulta)
```

> Es como decir: Mayor que al menos uno de los valores

- seleccionar pedidos mayores que algun pedido de Luis(id_cliente=2)

```sql

SELECT *
FROM pedidos
WHERE total > ANY(
	SELECT total
	FROM pedidos
	WHERE id_cliente = 2
	)


	SELECT *
	FROM pedidos
	WHERE id_cliente = 1

SELECT *
FROM pedidos
WHERE total > ANY (
SELECT total
	FROM pedidos
	WHERE id_cliente = 1)


SELECT *
FROM pedidos 
WHERE total > 500

SELECT *
FROM pedidos 
WHERE total > ANY (SELECT total
FROM pedidos 
WHERE total > 500)


```

## Clusula ALL

se cumple contra todos los valores  

```sql

VALOR > ALL (subconsulta)
```

Significa 

- Mayor que todos los valores

```sql

---SELECCIONAR TODOS LOS CLIENTES DONDE SU ID SEA MENOR QUE TODOS LOS CLIENTES DE LA CDMX

SELECT id_cliente
FROM clientes
WHERE ciudad = 'CDMX'

SELECT *
FROM clientes
WHERE id_cliente < ALL(SELECT id_cliente
FROM clientes
WHERE ciudad = 'CDMX')


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
```

## Subconsultas correlacionadas

> Una subconsulta correlacioanda depende de la fila actual de la consulta pricipal y se ejecuta una vez por cada fila

---

1. Seleccionar los clientes cuyo total de compras sea mayor a 1000

