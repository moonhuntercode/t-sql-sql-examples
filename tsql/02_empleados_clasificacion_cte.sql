-- ==============================================================================
-- Script: tsql/02_empleados_clasificacion_cte.sql
-- Motor: Microsoft SQL Server (T-SQL)
-- Base de Datos: AdventureWorks / Esquema Compatible
-- Descripción: Consulta analítica con CTE, funciones de fecha (DATEDIFF),
--              clasificación por rangos CASE y ordenamiento personalizado.
-- ==============================================================================

USE AdventureWorks;
GO

-- CTE para calcular edad de los empleados y clasificarlos en rangos
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
    COUNT(BusinessEntityID) AS CantidadEmpleados
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
GO
