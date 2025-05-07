-- Crear la tabla Empleado
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

-- Crear la tabla Docente
CREATE TABLE Docente (
    Nro_de_CI VARCHAR(20) PRIMARY KEY,
    Especialidad VARCHAR(50) NOT NULL,
    Carga_horaria VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Docente_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES Empleado(Nro_de_CI),
    CONSTRAINT CK_CargaHoraria CHECK (Carga_horaria IN ('Tiempo Completo', 'Tiempo Horario')),
    CONSTRAINT CK_Especialidad CHECK (Especialidad IN ('Informática', 'Electrónica', 'Finanzas', 'Ciencias Sociales'))
);
GO

-- Crear la tabla Administrativo
CREATE TABLE Administrativo (
    Nro_de_CI VARCHAR(20) PRIMARY KEY,
    Turno VARCHAR(10) NOT NULL,
    Grado_formacion VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Administrativo_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES Empleado(Nro_de_CI),
    CONSTRAINT CK_Turno CHECK (Turno IN ('Mañana', 'Tarde', 'Noche')),
    CONSTRAINT CK_GradoFormacion CHECK (Grado_formacion IN ('Licenciatura', 'Maestría', 'Doctorado'))
);
GO

-- Crear la tabla Mantenimiento
CREATE TABLE Mantenimiento (
    Nro_de_CI VARCHAR(20) PRIMARY KEY,
    Seccion VARCHAR(50) NOT NULL,
    Tipo_de_contrato VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Mantenimiento_Empleado FOREIGN KEY (Nro_de_CI) REFERENCES Empleado(Nro_de_CI),
    CONSTRAINT CK_TipoContrato CHECK (Tipo_de_contrato IN ('De planta', 'Consultor', 'Jornalero'))
);
GO

-- El Trigger para verificar la cantidad de empleados por unidad SIGUE SIENDO NECESARIO
-- ya que la restricción LIKE solo valida el formato del Nro_de_Item, no la cantidad
-- real de empleados por código de departamento en la base de datos.
CREATE TRIGGER TR_LimiteEmpleadosPorUnidad
ON Empleado
AFTER INSERT
AS
BEGIN
    DECLARE @Nro_de_Item VARCHAR(20);
    DECLARE @Cod_Dep CHAR(1);
    DECLARE @CantidadEmpleados INT;

    SELECT @Nro_de_Item = i.Nro_de_Item FROM inserted i;
    SET @Cod_Dep = SUBSTRING(@Nro_de_Item, 6, 1);

    SELECT @CantidadEmpleados = COUNT(*)
    FROM Empleado
    WHERE SUBSTRING(Nro_de_Item, 6, 1) = @Cod_Dep;

    IF @CantidadEmpleados > 8
    BEGIN
        RAISERROR('La unidad %s no puede tener más de 8 empleados.', 16, 1, @Cod_Dep);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;
GO