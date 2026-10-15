-- ==============================================================================
-- Script: tsql/01_empleados_constraints_trigger.sql
-- Motor: Microsoft SQL Server (T-SQL)
-- Descripción: Jerarquía de empleados con restricciones CHECK y Trigger
--              para control de cupo máximo por departamento.
-- ==============================================================================

USE master;
GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'EmpresaDB')
BEGIN
    CREATE DATABASE EmpresaDB;
END;
GO

USE EmpresaDB;
GO

-- 1. Tabla Base / Supertipo Empleado
IF OBJECT_ID('dbo.Empleado', 'U') IS NOT NULL DROP TABLE dbo.Empleado;
CREATE TABLE dbo.Empleado (
    Nro_de_CI VARCHAR(20) NOT NULL,
    Nombres VARCHAR(100) NOT NULL,
    Apellido_Paterno VARCHAR(50) NOT NULL,
    Apellido_Materno VARCHAR(50) NULL,
    Nro_de_Item VARCHAR(20) NOT NULL,
    Fecha_contratacion DATE NOT NULL,
    CONSTRAINT PK_Empleado PRIMARY KEY (Nro_de_CI),
    CONSTRAINT UQ_Empleado_Item UNIQUE (Nro_de_Item),
    CONSTRAINT CK_FechaContratacion CHECK (Fecha_contratacion >= '1999-07-12'),
    CONSTRAINT CK_NroItemFormato CHECK (Nro_de_Item LIKE 'ITEM-[0-9]-[1-8]')
);
GO

-- 2. Subtipo Docente
IF OBJECT_ID('dbo.Docente', 'U') IS NOT NULL DROP TABLE dbo.Docente;
CREATE TABLE dbo.Docente (
    Nro_de_CI VARCHAR(20) NOT NULL,
    Especialidad VARCHAR(50) NOT NULL,
    Carga_horaria VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Docente PRIMARY KEY (Nro_de_CI),
    CONSTRAINT FK_Docente_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES dbo.Empleado(Nro_de_CI) ON DELETE CASCADE,
    CONSTRAINT CK_CargaHoraria CHECK (Carga_horaria IN ('Tiempo Completo', 'Tiempo Horario')),
    CONSTRAINT CK_Especialidad CHECK (Especialidad IN ('Informática', 'Electrónica', 'Finanzas', 'Ciencias Sociales'))
);
GO

-- 3. Subtipo Administrativo
IF OBJECT_ID('dbo.Administrativo', 'U') IS NOT NULL DROP TABLE dbo.Administrativo;
CREATE TABLE dbo.Administrativo (
    Nro_de_CI VARCHAR(20) NOT NULL,
    Turno VARCHAR(10) NOT NULL,
    Grado_formacion VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Administrativo PRIMARY KEY (Nro_de_CI),
    CONSTRAINT FK_Administrativo_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES dbo.Empleado(Nro_de_CI) ON DELETE CASCADE,
    CONSTRAINT CK_Turno CHECK (Turno IN ('Mañana', 'Tarde', 'Noche')),
    CONSTRAINT CK_GradoFormacion CHECK (Grado_formacion IN ('Licenciatura', 'Maestría', 'Doctorado'))
);
GO

-- 4. Subtipo Mantenimiento
IF OBJECT_ID('dbo.Mantenimiento', 'U') IS NOT NULL DROP TABLE dbo.Mantenimiento;
CREATE TABLE dbo.Mantenimiento (
    Nro_de_CI VARCHAR(20) NOT NULL,
    Seccion VARCHAR(50) NOT NULL,
    Tipo_de_contrato VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Mantenimiento PRIMARY KEY (Nro_de_CI),
    CONSTRAINT FK_Mantenimiento_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES dbo.Empleado(Nro_de_CI) ON DELETE CASCADE,
    CONSTRAINT CK_TipoContrato CHECK (Tipo_de_contrato IN ('De planta', 'Consultor', 'Jornalero'))
);
GO

-- 5. Trigger para verificar límite de 8 empleados por departamento
CREATE OR ALTER TRIGGER dbo.TR_LimiteEmpleadosPorUnidad
ON dbo.Empleado
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @Nro_de_Item VARCHAR(20);
    DECLARE @Cod_Dep CHAR(1);
    DECLARE @CantidadEmpleados INT;

    SELECT @Nro_de_Item = i.Nro_de_Item FROM inserted i;
    SET @Cod_Dep = SUBSTRING(@Nro_de_Item, 6, 1);

    SELECT @CantidadEmpleados = COUNT(*)
    FROM dbo.Empleado
    WHERE SUBSTRING(Nro_de_Item, 6, 1) = @Cod_Dep;

    IF @CantidadEmpleados > 8
    BEGIN
        RAISERROR('La unidad %s no puede tener más de 8 empleados.', 16, 1, @Cod_Dep);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO
