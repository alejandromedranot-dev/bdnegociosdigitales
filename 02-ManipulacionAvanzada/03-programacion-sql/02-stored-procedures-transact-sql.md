
# Stored Procedures (Procedimientos Almacenados) en Transact-SQL (SQL SERVER)

1️⃣ Fundamentos 

- ¿Qué es un Stored Procedure?

Un **Stored Procedure (SP)** es un bloque de código SQL guardado dentro de la base de datos que puede ejecutarse cuando se necesite. Es decir es un **OBJETO DE LA BD**

Es similar a una función o método en programación.

Ventajas 

1. Reutilizar el código
2. Mejor Rendimiento 
3. Mayor seguridad
4. Centralización de lógica de negocio 
5. Menos tráfico entre aplicación y servidor

- Sintaxis

![SintaxisSQL](../../img/sp_sintaxis.png)

- Nomenclatura Recomendada

```
spu_<Entidad>_<Acción>
```

| Parte   | Significado                     | Ejemplo |
|--------|---------------------------------|--------|
| spu    | Stored Procedure User           | spu_   |
| Entidad| Tabla o concepto del negocio    | Cliente|
| Acción | Lo que hace                     | Insert |

- Acciones Estándar

Estas son las **acciones mas usadas * en sistemas empresariales

| Acción     | Significado          | Ejemplo                |
| ---------- | -------------------- | ---------------------- |
| Insert     | Insertar registro    | spu_Cliente_Insert     |
| Update     | Actualizar           | spu_Cliente_Update     |
| Delete     | Eliminar             | spu_Cliente_Delete     |
| Get        | Obtener uno          | spu_Cliente_Get        |
| List       | Obtener varios       | spu_Cliente_List       |
| Search     | Búsqueda con filtros | spu_Cliente_Search     |
| Exists     | Validar si existe    | spu_Cliente_Exists     |
| Activate   | Activar registro     | spu_Cliente_Activate   |
| Deactivate | Desactivar           | spu_Cliente_Deactivate |

- Ejemplo completo 

Suponer que tenemos una tabla cliente

🦗 Insertar Cliente

```
spu_Cliente_Insert
```

🦗 Actualizar Cliente

```
spu_Cliente_Update
```
🦗 Obtener Cliente por id

```
spu_Cliente_Get
```
🦗 Listar todos los Cliente

```
spu_Cliente_List
```

🦗 Buscar Cliene

```
spu_Cliente_Search
```

```sql
/*=============================== Stored Procedures ===============================*/

CREATE DATABASE bdstored;
GO

USE bdstored;
GO


-- Ejemplo Simple 

CREATE PROCEDURE usp_Mensaje_Saludar
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo Transact SQL desde SQL SERVER';
END;
GO

-- Ejecutar
EXECUTE usp_Mensaje_Saludar;
GO

CREATE PROC usp_Mensaje_Saludar2
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo Ing en TI';
END;
GO

-- EJECUTAR
EXEC usp_Mensaje_Saludar2; 
GO

CREATE OR ALTER PROC usp_Mensaje_Saludar3
  -- No tendra parametros
AS
BEGIN
    PRINT 'Hola Mundo ENTORNOS VIRTUALES Y NEGOCIOS DIGITALES';
END;
GO

-- ELIMINAR UN SP
DROP PROCEDURE usp_Mensaje_Saludar3;
GO

-- EJECUTAR
EXEC  usp_Mensaje_Saludar3;
GO

-- Crear un SP que muestre la fecha actual del sistema
CREATE OR ALTER PROC usp_Servidor_FechaActual

AS 
BEGIN
    SELECT CAST(GETDATE () AS DATE) AS [ FECHA DEL SISTEMA]
END;
GO

-- EJECUTARLO

EXEC usp_Servidor_FechaActual;
GO
-- CREAR UN SP QUE MUESTRE EL NOMBRE DE LA BASE DE DATOS (DB_NAME())

CREATE OR ALTER PROC spu_Dbname_get 
AS
BEGIN
    SELECT 
        HOST_NAME() AS [MACHINE],
        SUSER_SNAME() AS [SQLUSER],
        SYSTEM_USER AS [SYSTEMUSER],
        DB_NAME() AS [DATABASE NAME],
        APP_NAME() AS [APPLICATION];
END;
GO

-- EJECUTAR
EXEC spu_Dbname_get;
GO 
```


2️⃣ Parámetros en Stored Procedures

Los párametros permiten enviar datos al procedimiento

```SQL
/*=================================== STORED PROCEDURES CON PARAMETROS =========================*/

CREATE OR ALTER PROC usp_persona_saludar
   @nombre VARCHAR(50) -- PARAMETRO DE ENTRADA
AS
BEGIN
    PRINT CONCAT('Hola',' ', @nombre);
END;
GO

EXEC usp_persona_saludar 'Israel';
EXEC usp_persona_saludar 'Artemio';
EXEC usp_persona_saludar 'Irais';
EXEC usp_persona_saludar @Nombre ='Bryan';

DECLARE @name VARCHAR(50);
SET @name = 'Yael';

EXEC usp_persona_saludar @name
```





