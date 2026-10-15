# 🚀 Matriz de Comandos Más Usados: Comparativa Multi-Motor

Esta guía proporciona una comparativa directa y práctica de los comandos más usados en el día a día para **T-SQL (SQL Server)**, **MySQL / MariaDB** y **PostgreSQL**, junto con su contraparte en **ANSI SQL**.

---

## 💻 1. Conexión y Comandos de Inspección en CLI

| Operación | Microsoft SQL Server (`sqlcmd`) | MySQL / MariaDB (`mysql`) | PostgreSQL (`psql`) |
| :--- | :--- | :--- | :--- |
| **Conectar por terminal** | `sqlcmd -S host,1433 -U sa -P pass` | `mysql -h host -P 3306 -u root -p` | `psql -h host -p 5432 -U postgres -d db` |
| **Listar bases de datos** | `SELECT name FROM sys.databases; GO` | `SHOW DATABASES;` | `\l` o `SELECT datname FROM pg_database;` |
| **Cambiar de base de datos** | `USE MiBaseDatos; GO` | `USE MiBaseDatos;` | `\c mibasedatos` |
| **Listar tablas** | `SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES; GO` | `SHOW TABLES;` | `\dt` |
| **Ver esquema de tabla** | `sp_help 'NombreTabla'; GO` | `DESCRIBE NombreTabla;` | `\d+ NombreTabla` |
| **Listar extensiones / plugins**| `SELECT * FROM sys.assemblies; GO` | `SHOW PLUGINS;` | `\dx` |
| **Ejecutar script externo** | `sqlcmd -S host -U sa -P pass -i script.sql` | `mysql -u user -p db < script.sql` | `psql -U user -d db -f script.sql` |

---

## 🏗️ 2. DDL: Definición de Tablas y Claves

### 2.1 Identificadores Autoincrementales y UUID
```sql
-- T-SQL (SQL Server)
CREATE TABLE T_Ejemplo (
    id INT IDENTITY(1,1) PRIMARY KEY,
    guid_id UNIQUEIDENTIFIER DEFAULT NEWID()
);

-- MySQL 8+ / MariaDB
CREATE TABLE M_Ejemplo (
    id INT AUTO_INCREMENT PRIMARY KEY,
    uuid_val VARCHAR(36) DEFAULT (UUID())
);

-- PostgreSQL
CREATE TABLE P_Ejemplo (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY, -- o 'id SERIAL PRIMARY KEY'
    uuid_id UUID DEFAULT gen_random_uuid()
);
```

### 2.2 Restricciones CHECK con Formato / Regex
```sql
-- T-SQL (Usa operador LIKE con corchetes de rango [0-9])
CONSTRAINT CK_Item_TSQL CHECK (Nro_Item LIKE 'ITEM-[0-9]-[1-8]')

-- MySQL 8.0.16+ / MariaDB
CONSTRAINT CK_Item_MySQL CHECK (REGEXP_LIKE(Nro_Item, '^ITEM-[0-9]-[1-8]$'))

-- PostgreSQL (Operador POSIX '~')
CONSTRAINT CK_Item_PG CHECK (Nro_Item ~ '^ITEM-[0-9]-[1-8]$')
```

---

## 📥 3. DML: Inserción y Upserts (Insert or Update)

### 3.1 Inserción en Bloque (Multi-Row)
Todos los motores modernos soportan la sintaxis multi-fila ANSI:
```sql
INSERT INTO estudiantes (nombre) 
VALUES ('Marco'), ('Pablutus'), ('Valeria');
```

### 3.2 Upsert (Fusión o Conflicto de Clave)

#### T-SQL:
```sql
MERGE INTO Clientes AS Target
USING (SELECT 101 AS ID, 'Juan' AS Nombre, 500 AS Saldo) AS Source
ON (Target.ID = Source.ID)
WHEN MATCHED THEN
    UPDATE SET Target.Saldo = Source.Saldo
WHEN NOT MATCHED THEN
    INSERT (ID, Nombre, Saldo) VALUES (Source.ID, Source.Nombre, Source.Saldo);
```

#### MySQL 8+:
```sql
INSERT INTO Clientes (ID, Nombre, Saldo)
VALUES (101, 'Juan', 500)
AS nuevo
ON DUPLICATE KEY UPDATE Saldo = nuevo.Saldo;
```

#### PostgreSQL:
```sql
INSERT INTO Clientes (ID, Nombre, Saldo)
VALUES (101, 'Juan', 500)
ON CONFLICT (ID) DO UPDATE 
SET Saldo = EXCLUDED.Saldo;
```

---

## 📄 4. Paginación de Consultas

```sql
-- T-SQL (OFFSET ... FETCH NEXT estándar ANSI)
SELECT id, nombre 
FROM estudiantes 
ORDER BY id ASC 
OFFSET 20 ROWS FETCH NEXT 10 ROWS ONLY;

-- MySQL / MariaDB (LIMIT ... OFFSET)
SELECT id, nombre 
FROM estudiantes 
ORDER BY id ASC 
LIMIT 10 OFFSET 20;

-- PostgreSQL (LIMIT ... OFFSET estándar)
SELECT id, nombre 
FROM estudiantes 
ORDER BY id ASC 
LIMIT 10 OFFSET 20;
```

---

## 📅 5. Manejo de Fechas y Tiempos

| Acción | T-SQL | MySQL / MariaDB | PostgreSQL |
| :--- | :--- | :--- | :--- |
| **Fecha y hora actual** | `GETDATE()` o `SYSDATETIME()` | `NOW()` o `CURRENT_TIMESTAMP` | `CURRENT_TIMESTAMP` o `NOW()` |
| **Diferencia entre fechas**| `DATEDIFF(YEAR, FechaNac, '2025-12-31')` | `TIMESTAMPDIFF(YEAR, FechaNac, '2025-12-31')` | `EXTRACT(YEAR FROM AGE('2025-12-31', FechaNac))` |
| **Sumar días/meses** | `DATEADD(DAY, 30, GETDATE())` | `DATE_ADD(NOW(), INTERVAL 30 DAY)` | `NOW() + INTERVAL '30 days'` |
| **Trimming de fecha (solo día)**| `CAST(GETDATE() AS DATE)` | `CURDATE()` | `CURRENT_DATE` |

---

## 🔄 6. Funciones de Ventana (Window Functions)

Idénticas en los tres motores gracias a la adopción completa del estándar SQL:2003 / SQL:2008:

```sql
SELECT 
    departamento_id,
    nombre,
    salario,
    ROW_NUMBER() OVER (PARTITION BY departamento_id ORDER BY salario DESC) AS fila_dep,
    RANK() OVER (PARTITION BY departamento_id ORDER BY salario DESC) AS ranking_salario,
    DENSE_RANK() OVER (PARTITION BY departamento_id ORDER BY salario DESC) AS ranking_denso,
    LAG(salario, 1) OVER (PARTITION BY departamento_id ORDER BY salario DESC) AS salario_anterior
FROM empleados;
```

---

## 🔒 7. Transacciones y Control de Errores

### T-SQL:
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    -- Operaciones
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
```

### PostgreSQL (PL/pgSQL o Bloques Transaccionales):
```sql
BEGIN;
    -- Operaciones
    SAVEPOINT punto_control_1;
    -- Otra operación
    -- Si falla: ROLLBACK TO punto_control_1;
COMMIT;
```

### MySQL / MariaDB:
```sql
START TRANSACTION;
    -- Operaciones
    -- Si falla: ROLLBACK;
COMMIT;
```

---

## 🧠 8. Comandos Vectoriales (`pgvector` en PostgreSQL)

```sql
-- 1. Instalar extensión
CREATE EXTENSION IF NOT EXISTS vector;

-- 2. Crear tabla con columna vectorial (ej. 1536 dimensiones)
CREATE TABLE chunks (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contenido TEXT NOT NULL,
    embedding VECTOR(1536) NOT NULL
);

-- 3. Crear índice HNSW para similitud coseno
CREATE INDEX idx_hnsw_cosine ON chunks USING hnsw (embedding vector_cosine_ops);

-- 4. Búsqueda K-Nearest Neighbors (KNN)
SELECT id, contenido, embedding <=> '[0.12, -0.34, ...]'::vector AS distancia
FROM chunks
ORDER BY embedding <=> '[0.12, -0.34, ...]'::vector ASC
LIMIT 5;
```

---

## 🩺 9. Mantenimiento y Rendimiento

| Motor | Analizar Plan de Ejecución | Mantenimiento / Compactación | Actualizar Estadísticas |
| :--- | :--- | :--- | :--- |
| **T-SQL** | `SET SHOWPLAN_TEXT ON;` o Plan Gráfico en SSMS | `ALTER INDEX ALL ON Tabla REORGANIZE;` / `REBUILD;` | `UPDATE STATISTICS NombreTabla;` |
| **MySQL / MariaDB** | `EXPLAIN FORMAT=JSON SELECT ...;` | `OPTIMIZE TABLE NombreTabla;` | `ANALYZE TABLE NombreTabla;` |
| **PostgreSQL** | `EXPLAIN (ANALYZE, BUFFERS) SELECT ...;` | `VACUUM (FULL, ANALYZE) NombreTabla;` | `ANALYZE NombreTabla;` |
