# ⚡ T-SQL (Transact-SQL) - Microsoft SQL Server

Transact-SQL (T-SQL) es la extensión propietaria de Microsoft y Sybase para el estándar SQL, orientada a la programabilidad procedural, manejo robusto de excepciones, transacciones atómicas y lógica de servidor en Microsoft SQL Server y Azure SQL.

---

## 🔍 1. Análisis Exhaustivo de los Comandos Previos del Amo

En esta sección se documentan formalmente los scripts desarrollados previamente en este repositorio, desglosando su funcionamiento y arquitectura.

### 📌 1.1 Script `b.sql`: Integridad y Triggers de Capacidad

Archivo de origen: [b.sql](file:///e:/repositorios/t-sql-sql-examples/b.sql)

#### Arquitectura del Modelo
El script modela una jerarquía de personal mediante herencia de tabla única/subtipos (`Empleado` como supertipo, y `Docente`, `Administrativo`, `Mantenimiento` como subtipos), vinculados por Claves Foráneas que coinciden con la Clave Primaria (`Nro_de_CI`).

```sql
-- Supertipo Empleado
CREATE TABLE Empleado (
    Nro_de_CI VARCHAR(20) PRIMARY KEY,
    Nombres VARCHAR(100) NOT NULL,
    Apellido_Paterno VARCHAR(50) NOT NULL,
    Apellido_Materno VARCHAR(50),
    Nro_de_Item VARCHAR(20) UNIQUE NOT NULL,
    Fecha_contratacion DATE NOT NULL,
    CONSTRAINT CK_FechaContratacion CHECK (Fecha_contratacion >= '1999-07-12'),
    CONSTRAINT CK_NroItemFormato CHECK (Nro_de_Item LIKE 'ITEM-[0-9]-[1-8]')
);
GO
```

#### Restricciones Clave:
1. **`CK_FechaContratacion`**: Regla de negocio que impide registrar personal con fecha previa a la fundación o corte institucional (`1999-07-12`).
2. **`CK_NroItemFormato`**: Valida mediante pattern matching de T-SQL (`LIKE 'ITEM-[0-9]-[1-8]'`) que el número de ítem cumpla el formato exacto:
   - Prefijo fijo: `ITEM-`
   - Primer dígito: Código de departamento/unidad `[0-9]`
   - Segundo dígito: Sub-ítem acotado entre `1` y `8` `[1-8]`

#### Subtipos con Claves Foráneas 1:1:
```sql
CREATE TABLE Docente (
    Nro_de_CI VARCHAR(20) PRIMARY KEY,
    Especialidad VARCHAR(50) NOT NULL,
    Carga_horaria VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Docente_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES Empleado(Nro_de_CI),
    CONSTRAINT CK_CargaHoraria CHECK (Carga_horaria IN ('Tiempo Completo', 'Tiempo Horario')),
    CONSTRAINT CK_Especialidad CHECK (Especialidad IN ('Informática', 'Electrónica', 'Finanzas', 'Ciencias Sociales'))
);
GO
```

#### Trigger de Validación de Límite (`TR_LimiteEmpleadosPorUnidad`):
Dado que un `CHECK constraint` solo evalúa la fila entrante de forma estática y no puede consultar agregaciones de otras filas de la tabla de forma declarativa, se implementó un `TRIGGER AFTER INSERT`:

```sql
CREATE TRIGGER TR_LimiteEmpleadosPorUnidad
ON Empleado
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON; -- Buena práctica T-SQL para suprimir mensajes de filas afectadas
    DECLARE @Nro_de_Item VARCHAR(20);
    DECLARE @Cod_Dep CHAR(1);
    DECLARE @CantidadEmpleados INT;

    -- Lectura de la pseudotabla 'inserted' proporcionada por SQL Server
    SELECT @Nro_de_Item = i.Nro_de_Item FROM inserted i;
    SET @Cod_Dep = SUBSTRING(@Nro_de_Item, 6, 1);

    -- Conteo de empleados actuales para dicho departamento
    SELECT @CantidadEmpleados = COUNT(*)
    FROM Empleado
    WHERE SUBSTRING(Nro_de_Item, 6, 1) = @Cod_Dep;

    -- Si excede el cupo permitido (máximo 8), aborta la transacción
    IF @CantidadEmpleados > 8
    BEGIN
        RAISERROR('La unidad %s no puede tener más de 8 empleados.', 16, 1, @Cod_Dep);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
```

> [!NOTE]
> **Pseudotablas en Triggers:** En T-SQL, `inserted` contiene las filas añadidas en `INSERT` y los nuevos valores en `UPDATE`. `deleted` contiene las filas removidas en `DELETE` y los valores viejos en `UPDATE`.

---

### 📌 1.2 Script `pendiente.sql`: CTEs y Clasificación por Rangos

Archivo de origen: [pendiente.sql](file:///e:/repositorios/t-sql-sql-examples/pendiente.sql)

El script resuelve una consulta analítica sobre las tablas de `AdventureWorks` (`Person.Person` y `HumanResources.Employee`), calculando la edad al 31 de diciembre de 2025 y categorizando en rangos etarios mediante una **Expresión de Tabla Común (CTE)**:

```sql
WITH EmpleadosConCategoria AS (
    SELECT
        P.BusinessEntityID,
        DATEDIFF(YEAR, P.BirthDate, '2025-12-31') AS Edad,
        CASE
            WHEN DATEDIFF(YEAR, P.BirthDate, '2025-12-31') BETWEEN 25 AND 40 THEN 'Junior'
            WHEN DATEDIFF(YEAR, P.BirthDate, '2025-12-31') BETWEEN 41 AND 55 THEN 'Senior'
            WHEN DATEDIFF(YEAR, P.BirthDate, '2025-12-31') BETWEEN 56 AND 75 THEN 'Mérito'
            ELSE 'Otra Categoría'
        END AS Categoria
    FROM
        Person.Person P
        INNER JOIN HumanResources.Employee E ON P.BusinessEntityID = E.BusinessEntityID
    WHERE
        P.BirthDate IS NOT NULL
        AND DATEDIFF(YEAR, P.BirthDate, '2025-12-31') BETWEEN 25 AND 75
)
SELECT
    Categoria,
    COUNT(BusinessEntityID) AS Cantidad
FROM
    EmpleadosConCategoria
GROUP BY
    Categoria
ORDER BY
    CASE
        WHEN Categoria = 'Junior' THEN 1
        WHEN Categoria = 'Senior' THEN 2
        WHEN Categoria = 'Mérito' THEN 3
        ELSE 4
    END;
```

#### Funcionalidades T-SQL destacadas:
- **`DATEDIFF(datepart, startdate, enddate)`**: Calcula la diferencia entre límites de fechas basándose en unidades de calendario (`YEAR`, `MONTH`, `DAY`).
- **`WITH ... AS (...)`**: Las CTEs mejoran la legibilidad frente a las subconsultas derivadas y permiten reutilizar nombres de columnas calculadas en el `GROUP BY` exterior.
- **`ORDER BY CASE ... END`**: Ordenamiento semántico arbitrario que prevalece sobre el orden alfabético natural.

---

## 🛠️ 2. Estructuras Procedurales Avanzadas en T-SQL

### 2.1 Manejo Estructurado de Excepciones (`TRY...CATCH`)
A diferencia de `RAISERROR`, en versiones modernas de SQL Server se utiliza el bloque estándar `BEGIN TRY ... BEGIN CATCH` junto con `THROW`:

```sql
BEGIN TRY
    BEGIN TRANSACTION;
    
    INSERT INTO Empleado (Nro_de_CI, Nombres, Apellido_Paterno, Nro_de_Item, Fecha_contratacion)
    VALUES ('1001', 'David', 'Loayza', 'ITEM-1-9', '2025-01-01'); -- Fallará por CK_NroItemFormato
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
        ROLLBACK TRANSACTION;
        
    SELECT 
        ERROR_NUMBER() AS NumeroError,
        ERROR_SEVERITY() AS Severidad,
        ERROR_STATE() AS Estado,
        ERROR_PROCEDURE() AS Procedimiento,
        ERROR_LINE() AS Linea,
        ERROR_MESSAGE() AS Mensaje;
END CATCH;
```

### 2.2 Tablas Temporales vs Variables Tabla

| Característica | Tablas Temporales Locales (`#temp`) | Variables de Tabla (`@tabla`) |
| :--- | :--- | :--- |
| **Ámbito** | Sesión o procedimiento actual | Bloque de lote (`BATCH`) actual |
| **Almacenamiento** | Base de datos `tempdb` | Memoria y desborde a `tempdb` |
| **Estadísticas de Consulta** | Sí (optimizador de consultas genera planes óptimos) | No (el estimador asume 1 fila, salvo SQL 2019+) |
| **Soporte de Índices** | Índices primarios, compuestos y Non-Clustered | Solo restricciones `PRIMARY KEY` y `UNIQUE` |
| **Impacto Transaccional** | Participa en transacciones y `ROLLBACK` | No se revierte con `ROLLBACK` |

### 2.3 Procedimiento Almacenado Seguro
```sql
CREATE OR ALTER PROCEDURE dbo.usp_RegistrarEmpleado
    @Nro_CI VARCHAR(20),
    @Nombres VARCHAR(100),
    @Paterno VARCHAR(50),
    @Materno VARCHAR(50) = NULL,
    @Item VARCHAR(20),
    @FechaContrato DATE
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON; -- Cancela y revierte la transacción automáticamente ante errores en tiempo de ejecución

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO dbo.Empleado (Nro_de_CI, Nombres, Apellido_Paterno, Apellido_Materno, Nro_de_Item, Fecha_contratacion)
        VALUES (@Nro_CI, @Nombres, @Paterno, @Materno, @Item, @FechaContrato);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO
```

---

## 💻 3. Comandos de Terminal (`sqlcmd`)

Para automatizar o ejecutar scripts en SQL Server mediante CLI o contenedores Docker:

```bash
# Conexión interactiva a SQL Server
sqlcmd -S localhost,1433 -U sa -P "TuPasswordSegura123!"

# Ejecución directa de un archivo .sql
sqlcmd -S localhost,1433 -U sa -P "TuPasswordSegura123!" -d BaseDatosDemo -i ./tsql/01_empleados_constraints_trigger.sql

# Ejecución de una consulta inline con salida formateada
sqlcmd -S localhost,1433 -U sa -P "TuPasswordSegura123!" -Q "SELECT @@VERSION;" -W
```
