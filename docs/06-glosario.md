# 📖 Glosario Técnico de Bases de Datos & Vector DB

Glosario exhaustivo de términos de bases de datos relacionales, extensiones procedurales (T-SQL, PL/pgSQL) y tecnologías vectoriales modernas para Inteligencia Artificial.

---

## 🔤 Índice Alfabético
[A](#a) • [B](#b) • [C](#c) • [D](#d) • [E](#e) • [F](#f) • [H](#h) • [I](#i) • [J](#j) • [M](#m) • [N](#n) • [O](#o) • [P](#p) • [R](#r) • [S](#s) • [T](#t) • [U](#u) • [V](#v) • [W](#w)

---

## A

### ACID
Acrónimo de **Atomicidad, Consistencia, Aislamiento (*Isolation*) y Durabilidad**. Conjunto de propiedades que garantizan que las transacciones de base de datos se procesen de manera confiable y segura frente a fallos.

### ANSI SQL
Estándar internacional promulgado por el *American National Standards Institute* y la ISO para el lenguaje SQL, que sirve de base para dialectos como T-SQL, PL/pgSQL y MySQL.

### Aria
Motor de almacenamiento desarrollado por MariaDB como sucesor seguro contra caídas (*crash-safe*) de MyISAM.

### Atomicidad
Propiedad transaccional que asegura que un conjunto de operaciones se ejecute completamente ("todo o nada"). Si una sentencia falla, toda la transacción se revierte (`ROLLBACK`).

---

## B

### BCNF (Boyce-Codd Normal Form)
Forma normal estricta que refina la 3FN. Exige que para toda dependencia funcional no trivial $X \rightarrow Y$, el determinante $X$ sea una superclave candidata.

### Búsqueda Híbrida (*Hybrid Search*)
Técnica que combina los resultados de una búsqueda léxica tradicional por palabras clave (ej. BM25 / `tsvector`) con una búsqueda semántica de vectores (`pgvector`), ponderándolos para obtener la máxima relevancia.

### Búsqueda Semántica
Recuperación de información basada en el significado contextual de las palabras y no en su coincidencia literal exacta, empleando distancias matemáticas entre *embeddings*.

---

## C

### Cardinalidad
En modelado relacional, define la relación numérica entre dos entidades: 1:1 (uno a uno), 1:N (uno a muchos) o M:N (muchos a muchos).

### CTE (Common Table Expression)
Conjunto de resultados temporal con nombre definido mediante la cláusula `WITH ... AS (...)`. Facilita consultas jerárquicas y mejora la legibilidad frente a las subconsultas anidadas.

### Chunking (Fragmentación)
Proceso en sistemas RAG donde un documento extenso se divide en bloques pequeños de texto coherente (típicamente entre 256 y 1000 tokens) para generar un *embedding* representativo por cada fragmento.

### Clave Primaria (*Primary Key - PK*)
Columna o combinación de columnas que identifica de forma única y exclusiva cada fila de una tabla. Debe ser no nula (`NOT NULL`) y única (`UNIQUE`).

### Clave Foránea (*Foreign Key - FK*)
Columna o conjunto de columnas en una tabla cuyos valores hacen referencia obligatoria a la Clave Primaria de otra tabla, garantizando la integridad referencial.

---

## D

### DATEDIFF
Función procedural de T-SQL que retorna la cantidad de límites de unidad de tiempo (`YEAR`, `MONTH`, `DAY`) transcurridos entre dos fechas.

### Dependencia Funcional
Relación formal entre atributos de una relación: el atributo $Y$ depende funcionalmente de $X$ ($X \rightarrow Y$) si cada valor de $X$ determina exactamente un único valor de $Y$.

### Desnormalización
Proceso deliberado de introducir redundancia controlada en un esquema relacional con el objetivo de optimizar la velocidad de lectura (OLAP / Data Warehouse), reduciendo el número de operaciones `JOIN`.

### Dimensión (Vectorial)
Número de coordenadas escalares que componen un vector denso. Varía según el modelo generador (ej. 384, 768, 1536 o 3072 dimensiones).

### Distancia Coseno (*Cosine Distance*)
Métrica que mide el ángulo entre dos vectores en un espacio multidimensional: $1 - \cos(\theta)$. Es independiente de la magnitud del vector y es la métrica reina para similitud de textos en NLP. En `pgvector` se representa con `<=>`.

### Distancia Euclidiana ($L_2$)
Distancia geométrica en línea recta entre dos puntos vectoriales: $\sqrt{\sum (u_i - v_i)^2}$. En `pgvector` se representa con `<->`.

---

## E

### Embedding
Representación numérica densa y continua de un concepto, texto, imagen o audio en un espacio vectorial de alta dimensionalidad, donde la cercanía geométrica refleja cercanía semántica.

### EXPLAIN ANALYZE
Comando de diagnóstico que ejecuta una consulta y muestra el árbol del plan de ejecución real con tiempos por nodo, costo de E/S, buffers leídos y número de bucles.

---

## F

### Formas Normales (1FN, 2FN, 3FN)
Conjunto de reglas progresivas para estructurar bases de datos relacionales:
- **1FN:** Valores atómicos y unicidad de tupla.
- **2FN:** 1FN + dependencia funcional completa de la clave primaria.
- **3FN:** 2FN + ausencia de dependencias transitivas entre atributos no clave.

---

## H

### HNSW (Hierarchical Navigable Small World)
Algoritmo de indexación vectorial basado en grafos multicapa. Ofrece la mayor velocidad de búsqueda aproximada (ANN) y alto porcentaje de acierto (*recall*) en memoria RAM.

---

## I

### InnoDB
Motor de almacenamiento transaccional por defecto de MySQL y MariaDB, con soporte completo ACID, claves foráneas, bloqueos a nivel de fila y recuperación automática tras fallos (*crash recovery*).

### IVFFlat (Inverted File Flat)
Índice vectorial que divide el espacio en celdas de Voronoi (clusters con centroides). Consume menos RAM que HNSW pero requiere entrenamiento previo y produce menor recall si los datos se modifican frecuentemente.

---

## J

### JOIN (INNER, LEFT, RIGHT, FULL)
Operación relacional de álgebra que combina registros de dos o más tablas basándose en una condición lógica compartida.

---

## M

### MVCC (Multi-Version Concurrency Control)
Mecanismo de concurrencia en motores como PostgreSQL e InnoDB donde cada transacción observa una instantánea consistente de los datos sin bloquear las operaciones de lectura con las de escritura.

---

## N

### Normalización de Vectores
Operación matemática que divide un vector entre su norma euclidiana ($\frac{v}{\|v\|}$), de modo que su longitud resultante sea 1. Permite calcular similitud coseno usando directamente el producto punto ($u \cdot v$).

---

## O

### OLTP (Online Transaction Processing)
Cargas de trabajo transaccionales con alta tasa de inserciones, actualizaciones y lecturas puntuales concurrentes (ej. sistemas bancarios, e-commerce). Demanda esquemas en 3FN.

### OLAP (Online Analytical Processing)
Cargas de trabajo analíticas complejas con escaneos masivos de datos para reportería y BI. Suele estructurarse en modelos de estrella (*star schema*) desnormalizados.

---

## P

### pgvector
Extensión de PostgreSQL que incorpora tipos vectoriales nativos, operadores de distancia (`<=>`, `<->`, `<#>`) e índices HNSW e IVFFlat.

### Pseudotablas (`inserted` / `deleted`)
Tablas lógicas en memoria creadas por SQL Server durante la ejecución de un trigger que contienen las filas recién insertadas o removidas.

---

## R

### RAG (Retrieval-Augmented Generation)
Arquitectura que suministra contexto recuperado desde una base de datos vectorial a un modelo de lenguaje grande (LLM) antes de generar una respuesta, evitando alucinaciones.

### Reciprocal Rank Fusion (RRF)
Algoritmo matemático de ordenamiento que fusiona múltiples rankings independientes (ej. búsqueda léxica y semántica) asignando un peso ponderado $\frac{1}{k + r_i}$.

### Rollback
Instrucción TCL que revierte de forma atómica todas las modificaciones realizadas dentro de la transacción activa, devolviendo la base de datos a su estado previo.

---

## S

### Storage Engine
Componente modular en MySQL y MariaDB responsable de gestionar la lectura, escritura, bloqueos e indexación de los datos en disco o memoria.

---

## T

### Tabla Intermedia / Unión
Tabla utilizada para resolver cardinalidades Muchos a Muchos (M:N) en modelos relacionales, compuesta por las claves foráneas de ambas entidades.

### Trigger (Disparador)
Procedimiento almacenado que el motor de base de datos ejecuta automáticamente en respuesta a eventos de modificación de datos (`INSERT`, `UPDATE`, `DELETE`) o de definición (`DDL`).

### T-SQL (Transact-SQL)
Dialecto procedural de SQL Server que expande SQL con variables locales, bucles, bloques `TRY...CATCH`, triggers y cursores.

---

## U

### Upsert
Operación híbrida que inserta un registro si la clave no existe, o actualiza sus columnas si se detecta colisión de clave primaria o índice único.

---

## V

### VACUUM
Comando exclusivo de PostgreSQL que reclama espacio físico ocupado por tuplas muertas resultantes de `UPDATE` y `DELETE` en la arquitectura MVCC.

### Vector Denso
Arreglo unidimensional de números en punto flotante donde la mayoría de los componentes tienen valores distintos de cero, propio de los modelos de *deep learning*.

---

## W

### Window Function (Función de Ventana)
Función analítica que realiza cálculos sobre un subconjunto de filas relacionadas con la fila actual (`OVER (PARTITION BY ... ORDER BY ...)`), sin colapsar el resultado como lo hace `GROUP BY`.
