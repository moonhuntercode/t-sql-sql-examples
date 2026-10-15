# 📚 Estándar SQL (ANSI SQL) y Teoría de Normalización

Este documento compila los fundamentos del estándar SQL, las categorías de sentencias, el modelo relacional y la teoría formal de normalización (1FN a BCNF).

---

## 📑 1. Categorías de Comandos SQL

El lenguaje SQL se clasifica formalmente en 5 sub-lenguajes según el propósito de cada sentencia:

| Categoría | Nombre Completo | Propósito | Comandos Principales |
| :--- | :--- | :--- | :--- |
| **DDL** | *Data Definition Language* | Define y modifica la estructura de la base de datos | `CREATE`, `ALTER`, `DROP`, `TRUNCATE`, `RENAME` |
| **DML** | *Data Manipulation Language* | Gestiona los datos almacenados en las tablas | `INSERT`, `UPDATE`, `DELETE`, `MERGE` |
| **DQL** | *Data Query Language* | Recupera datos y realiza consultas analíticas | `SELECT` (con `WHERE`, `GROUP BY`, `HAVING`, `WINDOW`) |
| **DCL** | *Data Control Language* | Gestiona permisos, roles y seguridad | `GRANT`, `REVOKE` |
| **TCL** | *Transaction Control Language* | Controla transacciones y atomicidad | `COMMIT`, `ROLLBACK`, `SAVEPOINT` |

---

## 🏛️ 2. Fundamentos del Modelo Relacional

El modelo relacional, propuesto originalmente por Edgar F. Codd, estructura la información en **relaciones** (tablas) compuestas por **tuplas** (filas) y **atributos** (columnas).

### 2.1 Restricciones de Integridad
- **Integridad de Entidad:** Toda tabla debe poseer una Clave Primaria (`PRIMARY KEY`) única y no nula (`NOT NULL`).
- **Integridad Referencial:** Una Clave Foránea (`FOREIGN KEY`) debe coincidir con un valor existente en la clave primaria de la tabla referenciada o ser nula.
- **Integridad de Dominio:** Los valores de una columna deben respetar el tipo de dato, formato y restricciones (`CHECK`, `DEFAULT`, `UNIQUE`).

### 2.2 Cardinalidades y Mapeo
1. **Uno a Uno (1:1):** La clave primaria de una entidad pasa como clave foránea única (`UNIQUE`) a la otra.
2. **Uno a Muchos (1:N):** La clave primaria de la entidad del lado "1" se propaga como clave foránea al lado "N".
3. **Muchos a Muchos (M:N):** Requiere una **tabla intermedia o de unión** que contiene las claves foráneas de ambas entidades, formando una clave primaria compuesta.
   - *Ejemplo práctico:* [a.html](file:///e:/repositorios/t-sql-sql-examples/a.html) implementa `PartidoEquipo`, `Ocurre`, `EstadioHincha` y `EquipoJugador`.

```sql
-- Ejemplo de tabla intermedia M:N
CREATE TABLE PartidoEquipo (
    Partido_ID INT NOT NULL,
    Equipo_Nombre VARCHAR(100) NOT NULL,
    PRIMARY KEY (Partido_ID, Equipo_Nombre),
    CONSTRAINT FK_PartidoEquipo_Partido FOREIGN KEY (Partido_ID) REFERENCES Partido(ID_Partido) ON DELETE CASCADE,
    CONSTRAINT FK_PartidoEquipo_Equipo FOREIGN KEY (Equipo_Nombre) REFERENCES Equipo(NombreSeleccion) ON DELETE CASCADE
);
```

---

## 📐 3. Teoría de Normalización (1FN a BCNF)

La normalización busca eliminar la redundancia de datos y prevenir anomalías de inserción, actualización y borrado.

### 🧩 3.1 Primera Forma Normal (1FN)
Una tabla está en 1FN si y solo si:
1. Todos los atributos contienen valores atómicos e indivisibles (sin listas, arrays o campos multivalor dentro de una misma celda).
2. Cada fila es identificable de forma única mediante una clave primaria.
3. No existen grupos repetitivos de columnas (ej. `Telefono1`, `Telefono2`, `Telefono3`).

```sql
-- ❌ Violación de 1FN (Campo no atómico)
-- Estudiante(ID, Nombre, Telefonos) -> (1, 'Carlos', '71234567, 79876543')

-- ✅ Cumple 1FN (Valores atómicos con tabla relacionada 1:N)
CREATE TABLE Estudiante (
    ID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL
);

CREATE TABLE EstudianteTelefono (
    Estudiante_ID INT NOT NULL,
    Telefono VARCHAR(20) NOT NULL,
    PRIMARY KEY (Estudiante_ID, Telefono),
    FOREIGN KEY (Estudiante_ID) REFERENCES Estudiante(ID)
);
```

---

### 🧩 3.2 Segunda Forma Normal (2FN)
Una tabla está en 2FN si:
1. Ya cumple con la **1FN**.
2. **Dependencia Funcional Completa:** Todo atributo que no forma parte de la clave primaria depende funcionalmente de la totalidad de la clave primaria, y no de una parte de ella (aplica cuando la PK es compuesta).

```sql
-- ❌ Violación de 2FN (CursoNombre depende solo de Curso_ID, no de toda la PK compuesta)
-- Matricula(Estudiante_ID, Curso_ID, CursoNombre, Calificacion)

-- ✅ Cumple 2FN (Separación en tablas dedicadas)
CREATE TABLE Curso (
    Curso_ID INT PRIMARY KEY,
    CursoNombre VARCHAR(100) NOT NULL
);

CREATE TABLE Matricula (
    Estudiante_ID INT NOT NULL,
    Curso_ID INT NOT NULL,
    Calificacion DECIMAL(5,2) NOT NULL,
    PRIMARY KEY (Estudiante_ID, Curso_ID),
    FOREIGN KEY (Curso_ID) REFERENCES Curso(Curso_ID)
);
```

---

### 🧩 3.3 Tercera Forma Normal (3FN)
Una tabla está en 3FN si:
1. Ya cumple con la **2FN**.
2. **Sin Dependencias Transitivas:** Ningún atributo no clave depende de otro atributo no clave ($A \rightarrow B$ y $B \rightarrow C$).

```sql
-- ❌ Violación de 3FN (Ciudad depende de CodigoPostal, no directamente de Empleado_ID)
-- Empleado(Empleado_ID, Nombre, CodigoPostal, Ciudad)

-- ✅ Cumple 3FN (Se aísla la dependencia transitiva en su propia entidad)
CREATE TABLE CodigoPostalZona (
    CodigoPostal VARCHAR(10) PRIMARY KEY,
    Ciudad VARCHAR(100) NOT NULL
);

CREATE TABLE Empleado (
    Empleado_ID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    CodigoPostal VARCHAR(10) NOT NULL,
    FOREIGN KEY (CodigoPostal) REFERENCES CodigoPostalZona(CodigoPostal)
);
```

---

### 🧩 3.4 Forma Normal de Boyce-Codd (BCNF / FNBC)
Una tabla está en BCNF si:
1. Ya cumple con la **3FN**.
2. Para cada dependencia funcional $X \rightarrow Y$, $X$ es una superclave (clave candidata).
- Resuelve anomalías cuando existen múltiples claves candidatas compuestas superpuestas.

---

## ⚖️ 4. Normalización vs Desnormalización Estratégica

| Criterio | Esquema Normalizado (3FN / BCNF) | Esquema Desnormalizado |
| :--- | :--- | :--- |
| **Caso de uso** | Sistemas transaccionales OLTP | Sistemas analíticos OLAP, Data Warehouses, RAG |
| **Rendimiento Escritura** | Muy alto (actualizaciones atómicas en un solo punto) | Más lento (requiere actualizar múltiples réplicas) |
| **Rendimiento Lectura** | Requiere múltiples `JOIN` | Rápido (lectura plana y directa) |
| **Integridad de Datos** | Garantizada a nivel de motor | Requiere validación por aplicación o triggers |
| **Espacio en Disco** | Óptimo y reducido | Mayor consumo por datos redundantes |
