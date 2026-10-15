# 🐬 MySQL & MariaDB - Guía de Operaciones y Diferencias

MySQL y MariaDB comparten raíces históricas pero han divergido significativamente en motores de almacenamiento, optimizadores de consultas y características modernas de SQL.

---

## 📌 1. Script del Repositorio `new.sql`

Archivo de origen: [new.sql](file:///e:/repositorios/t-sql-sql-examples/new.sql)

```sql
insert into estudiantes values ('marco'),('pablutus');
```

### Análisis Técnico:
1. **Multi-Row Insert:** MySQL y MariaDB optimizan la inserción en bloque (`multi-row insert`) reduciendo la latencia de red y el costo de transacciones frente a ejecutar sentencias `INSERT` individuales.
2. **Buenas Prácticas:** Siempre es mandatorio especificar las columnas explícitamente para evitar fallos si el esquema añade nuevas columnas o altera su orden:

```sql
-- Versión robusta para producción
INSERT INTO estudiantes (nombre) 
VALUES 
    ('marco'),
    ('pablutus');
```

---

## ⚙️ 2. Motores de Almacenamiento (Storage Engines)

A diferencia de SQL Server o PostgreSQL donde existe un único motor de almacenamiento unificado, MySQL y MariaDB permiten seleccionar el motor por tabla:

| Motor | Soporte Transaccional (ACID) | Claves Foráneas (FK) | Bloqueo | Uso Recomendado |
| :--- | :--- | :--- | :--- | :--- |
| **InnoDB** | ✅ Completo | ✅ Sí | Nivel de Fila (*Row-level*) | Motor predeterminado para producción y OLTP. |
| **MyISAM** | ❌ No | ❌ No | Nivel de Tabla (*Table-level*) | Obsoleto; reemplazado en la mayoría de escenarios. |
| **Aria** (MariaDB) | ⚠️ Crash-Safe (no full ACID) | ❌ No | Nivel de Página / Tabla | Motor interno de MariaDB para tablas temporales y lectura intensiva. |
| **Memory / Heap** | ❌ No | ❌ No | Nivel de Tabla | Tablas volátiles ultra rápidas en memoria RAM. |

---

## 🆚 3. Diferencias Críticas: MySQL 8 vs MariaDB

| Característica | MySQL 8.0 / 8.4 LTS | MariaDB 10.11 / 11.x |
| :--- | :--- | :--- |
| **Secuencias ANSI** | No (usa solo `AUTO_INCREMENT`) | ✅ Sí (`CREATE SEQUENCE seq_nombre START WITH 1;`) |
| **JSON Support** | Tipo nativo binario JSON con índices funcionales | Alias a `LONGTEXT` con validaciones `JSON_VALID()` |
| **Motor por Defecto** | InnoDB | InnoDB (soporta motores adicionales como Spider, ColumnStore, Aria) |
| **Query Cache** | Eliminado por completo (desde MySQL 8.0) | Mantenido y optimizado en ciertas versiones |
| **Cláusula RETURNING** | ❌ No soportada en `INSERT`/`UPDATE` | ✅ Soportada (`INSERT ... RETURNING id;`) |
| **Autenticación Predeterminada** | `caching_sha2_password` | `mysql_native_password` / `unix_socket` |

---

## 💡 4. Patrones y Comandos Esenciales

### 4.1 Upsert Seguro (`INSERT ... ON DUPLICATE KEY UPDATE`)
En MySQL 8.0+ se utiliza el alias de fila `AS new_row`:

```sql
INSERT INTO estudiantes (id, nombre, nota)
VALUES (1, 'Marco', 85)
AS new_data
ON DUPLICATE KEY UPDATE
    nota = new_data.nota,
    fecha_actualizacion = CURRENT_TIMESTAMP;
```

### 4.2 Paginación Eficiente
```sql
-- Paginación estándar (página 2 con tamaño 10)
SELECT id, nombre, fecha_registro
FROM estudiantes
ORDER BY id ASC
LIMIT 10 OFFSET 10;

-- Paginación por Cursor (Keyset Pagination) - Recomendada para millones de registros
SELECT id, nombre, fecha_registro
FROM estudiantes
WHERE id > 10
ORDER BY id ASC
LIMIT 10;
```

---

## 💻 5. Comandos de Consola (`mysql` / `mariadb`)

```bash
# Conectar a servidor local o contenedor Docker
mysql -u root -p -h 127.0.0.1 -P 3306

# Importar script SQL a una base de datos específica
mysql -u root -p mi_base_datos < ./mysql/01_estudiantes.sql

# Generar backup lógico (mysqldump / mariadb-dump)
mysqldump -u root -p --single-transaction --routines --triggers mi_base_datos > backup.sql
```
