# 🗄️ Repositorio Maestro: SQL, T-SQL, MySQL/MariaDB & PostgreSQL + pgvector

Repositorio integral de arquitectura de bases de datos, que documenta desde los fundamentos relacionales y la teoría formal de normalización hasta implementaciones avanzadas en **T-SQL**, **MySQL/MariaDB** y **PostgreSQL con pgvector** para inteligencia artificial y búsqueda semántica.

---

## 📂 Estructura del Repositorio

```text
├── docs/                                # 📚 Documentación teórica y guías maestras
│   ├── 01-sql-estandar.md               # ANSI SQL, DDL/DML, modelo relacional y normalización (1FN a BCNF)
│   ├── 02-t-sql.md                      # T-SQL: scripts analizados, CTEs, triggers, AdventureWorks y sqlcmd
│   ├── 03-mysql-mariadb.md              # MySQL 8 y MariaDB 11: InnoDB vs Aria, upserts, LIMIT y CLI
│   ├── 04-postgresql-pgvector.md        # PostgreSQL + pgvector: RAG, normalización de embeddings, HNSW e híbrida
│   ├── 05-comandos-mas-usados.md        # Matriz comparativa de comandos CLI, DDL, DML, fechas y vectores
│   └── 06-glosario.md                   # Glosario técnico A-Z de bases de datos y Vector DB
├── sql/                                 # 🏛️ Scripts y esquemas en Estándar ANSI SQL
│   └── 01_modelo_relacional_futbol.sql  # DDL del modelo relacional M:N documentado en a.html
├── tsql/                                # ⚡ Scripts en Transact-SQL (Microsoft SQL Server)
│   ├── 01_empleados_constraints_trigger.sql # Esquema jerárquico con CHECK regex y control de cupos
│   └── 02_empleados_clasificacion_cte.sql   # CTE analítico con DATEDIFF y ordenamiento CASE
├── mysql/                               # 🐬 Scripts para MySQL y MariaDB
│   └── 01_estudiantes.sql               # Tabla con motor InnoDB, multi-row insert y ON DUPLICATE KEY
├── postgresql/                          # 🐘 Scripts para PostgreSQL con pgvector
│   └── 01_pgvector_rag_schema.sql       # Esquema 3FN para RAG, chunks, índices HNSW y funciones KNN
├── docker-compose.yml                   # 🐳 Orquestación de contenedores para desarrollo local y Swarm
├── a.html                               # 📄 Documento relacional original (HTML de práctica de fútbol)
├── b.sql                                # 📄 Script original T-SQL de empleados
├── new.sql                              # 📄 Script original de inserciones
└── pendiente.sql                        # 📄 Script original de CTE AdventureWorks
```

---

## 🧭 Módulos de Documentación y Aprendizaje

### 1. [📚 Estándar SQL & Normalización](file:///e:/repositorios/t-sql-sql-examples/docs/01-sql-estandar.md)
- Clasificación de comandos: DDL, DML, DQL, DCL, TCL.
- Mapeo de cardinalidades relacionales (1:1, 1:N y tablas intermedias M:N).
- Desglose riguroso de las Formas Normales: **1FN**, **2FN**, **3FN** y **BCNF**.
- Criterios de normalización transaccional (OLTP) vs desnormalización analítica (OLAP).
- Implementación práctica en código: [sql/01_modelo_relacional_futbol.sql](file:///e:/repositorios/t-sql-sql-examples/sql/01_modelo_relacional_futbol.sql).

### 2. [⚡ T-SQL (Microsoft SQL Server)](file:///e:/repositorios/t-sql-sql-examples/docs/02-t-sql.md)
- Análisis de scripts de origen: [b.sql](file:///e:/repositorios/t-sql-sql-examples/b.sql) y [pendiente.sql](file:///e:/repositorios/t-sql-sql-examples/pendiente.sql).
- Triggers `AFTER INSERT`, pseudotablas `inserted` / `deleted` y validación de cupos por subcadena (`SUBSTRING`).
- Expresiones de Tabla Comunes (**CTEs**), cálculos de edad con `DATEDIFF` y clasificación condicional `CASE`.
- Estructuras procedurales modernas: `BEGIN TRY ... BEGIN CATCH`, `THROW` y transacciones atómicas.
- Scripts organizados: [tsql/01_empleados_constraints_trigger.sql](file:///e:/repositorios/t-sql-sql-examples/tsql/01_empleados_constraints_trigger.sql) y [tsql/02_empleados_clasificacion_cte.sql](file:///e:/repositorios/t-sql-sql-examples/tsql/02_empleados_clasificacion_cte.sql).

### 3. [🐬 MySQL & MariaDB](file:///e:/repositorios/t-sql-sql-examples/docs/03-mysql-mariadb.md)
- Análisis del script [new.sql](file:///e:/repositorios/t-sql-sql-examples/new.sql) y optimización multi-row insert.
- Comparativa de motores: `InnoDB` (ACID) vs `Aria` / `MyISAM`.
- Manejo de duplicados: `INSERT ... ON DUPLICATE KEY UPDATE` vs `REPLACE INTO`.
- Divergencias clave entre MySQL 8.x y MariaDB 10/11 (secuencias, JSON y query cache).
- Script estructurado: [mysql/01_estudiantes.sql](file:///e:/repositorios/t-sql-sql-examples/mysql/01_estudiantes.sql).

### 4. [🐘 PostgreSQL & pgvector](file:///e:/repositorios/t-sql-sql-examples/docs/04-postgresql-pgvector.md)
- Introducción a bases de datos vectoriales y embeddings para LLMs (OpenAI, Gemini, Ollama).
- **Normalización de esquemas vectoriales:**
  - Por qué no almacenar vectores de alta dimensión en tablas relacionales monolíticas (saturación de `shared_buffers`).
  - Patrón de Chunks 1:N normalizado en 3FN para arquitecturas RAG.
  - Normalización relacional vs normalización vectorial matemática ($\|v\| = 1$).
- Métricas de distancia: Distancia Coseno (`<=>`), Distancia Euclidiana $L_2$ (`<->`) y Producto Punto (`<#>`).
- Índices vectoriales: **HNSW** (Hierarchical Navigable Small World) e **IVFFlat**.
- Búsqueda Híbrida (*Hybrid Search*) combinando `tsvector` léxico con `vector` semántico vía RRF.
- Script de producción: [postgresql/01_pgvector_rag_schema.sql](file:///e:/repositorios/t-sql-sql-examples/postgresql/01_pgvector_rag_schema.sql).

### 5. [🚀 Matriz de Comandos Más Usados](file:///e:/repositorios/t-sql-sql-examples/docs/05-comandos-mas-usados.md)
- Tablas comparativas lado a lado: CLI (`sqlcmd`, `mysql`, `psql`), creación de esquemas, identidad autoincremental, regex CHECK, paginación, fechas, funciones de ventana y mantenimiento.

### 6. [📖 Glosario Técnico Exhaustivo](file:///e:/repositorios/t-sql-sql-examples/docs/06-glosario.md)
- Diccionario A-Z con más de 35 términos clave sobre modelado relacional, motores, heurísticas vectoriales y sistemas de IA.

---

## 🐳 Despliegue con Docker (Win11 Local & Debian Swarm)

El archivo [docker-compose.yml](file:///e:/repositorios/t-sql-sql-examples/docker-compose.yml) permite levantar los tres motores de bases de datos de forma aislada y reproducible:

```bash
# Iniciar todos los contenedores en segundo plano
docker compose up -d

# Verificar el estado y healthchecks
docker compose ps
```

| Servicio | Imagen | Puerto Host | Credenciales Predeterminadas |
| :--- | :--- | :--- | :--- |
| **PostgreSQL + pgvector** | `pgvector/pgvector:pg16` | `5432` | User: `postgres` / Pass: `postgres123` / DB: `vector_db` |
| **SQL Server 2022** | `mcr.microsoft.com/mssql/server:2022-latest` | `1433` | User: `sa` / Pass: `PasswordSegura123!` |
| **MariaDB 11** | `mariadb:11` | `3306` | User: `root` / Pass: `mariadb123` / DB: `academia_db` |
