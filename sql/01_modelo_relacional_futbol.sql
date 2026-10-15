-- ==============================================================================
-- Script: sql/01_modelo_relacional_futbol.sql
-- Motor: Estándar ANSI SQL (Compatible con PostgreSQL, MySQL, SQL Server)
-- Descripción: Implementación DDL del modelo relacional documentado en a.html
--              (Árbitros, Equipos, Jugadores, Partidos, Estadios, Hinchas
--              y sus relaciones Muchos a Muchos M:N).
-- ==============================================================================

-- 1. Entidad Árbitro (con relación reflexiva/autotopológica ReemplazadoPor)
CREATE TABLE Arbitro (
    Pasaporte VARCHAR(30) PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    A_Paterno VARCHAR(50) NOT NULL,
    A_Materno VARCHAR(50),
    F_Nacimiento DATE NOT NULL,
    AnioInicioActividad INT NOT NULL,
    Nacionalidad VARCHAR(50) NOT NULL,
    ReemplazadoPor VARCHAR(30),
    CONSTRAINT FK_Arbitro_Reemplazo FOREIGN KEY (ReemplazadoPor) 
        REFERENCES Arbitro(Pasaporte) ON DELETE SET NULL
);

-- 2. Entidad Equipo
CREATE TABLE Equipo (
    NombreSeleccion VARCHAR(100) PRIMARY KEY,
    NombreDT VARCHAR(100) NOT NULL,
    LugarEntrenamiento VARCHAR(150) NOT NULL
);

-- 3. Entidad Jugador
CREATE TABLE Jugador (
    NroCamiseta INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    A_Paterno VARCHAR(50) NOT NULL,
    A_Materno VARCHAR(50),
    Posicion VARCHAR(30) NOT NULL,
    Apodo VARCHAR(50)
);

-- 4. Entidad Partido
CREATE TABLE Partido (
    ID_Partido INT PRIMARY KEY,
    Arbitro_Pasaporte VARCHAR(30) NOT NULL,
    Instancia VARCHAR(50) NOT NULL,
    Duracion INT NOT NULL DEFAULT 90,
    Fecha DATE NOT NULL,
    Hora TIME NOT NULL,
    Dia VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Partido_Arbitro FOREIGN KEY (Arbitro_Pasaporte) 
        REFERENCES Arbitro(Pasaporte)
);

-- 5. Entidad Estadio
CREATE TABLE Estadio (
    Nombre VARCHAR(100) PRIMARY KEY,
    Ciudad VARCHAR(100) NOT NULL,
    CapacidadMaxima INT NOT NULL
);

-- 6. Entidad Hincha
CREATE TABLE Hincha (
    NroTiket VARCHAR(50) PRIMARY KEY,
    Ubicacion VARCHAR(50) NOT NULL,
    Zona VARCHAR(50) NOT NULL,
    LugarAsiento VARCHAR(20) NOT NULL,
    Vestimenta VARCHAR(100)
);

-- ------------------------------------------------------------------------------
-- Tablas Intermedias de Unión para Relaciones Muchos a Muchos (M:N)
-- ------------------------------------------------------------------------------

-- 7. PartidoEquipo (M:N entre Partido y Equipo)
CREATE TABLE PartidoEquipo (
    Partido_ID INT NOT NULL,
    Equipo_NombreSeleccion VARCHAR(100) NOT NULL,
    PRIMARY KEY (Partido_ID, Equipo_NombreSeleccion),
    CONSTRAINT FK_PartidoEquipo_Partido FOREIGN KEY (Partido_ID) 
        REFERENCES Partido(ID_Partido) ON DELETE CASCADE,
    CONSTRAINT FK_PartidoEquipo_Equipo FOREIGN KEY (Equipo_NombreSeleccion) 
        REFERENCES Equipo(NombreSeleccion) ON DELETE CASCADE
);

-- 8. Ocurre (M:N entre Partido y Estadio con atributos propios)
CREATE TABLE Ocurre (
    Partido_ID INT NOT NULL,
    Estadio_Nombre VARCHAR(100) NOT NULL,
    CapacidadHabilitada INT NOT NULL,
    CantidadPolicia INT NOT NULL DEFAULT 0,
    PRIMARY KEY (Partido_ID, Estadio_Nombre),
    CONSTRAINT FK_Ocurre_Partido FOREIGN KEY (Partido_ID) 
        REFERENCES Partido(ID_Partido) ON DELETE CASCADE,
    CONSTRAINT FK_Ocurre_Estadio FOREIGN KEY (Estadio_Nombre) 
        REFERENCES Estadio(Nombre) ON DELETE CASCADE
);

-- 9. EstadioHincha (M:N entre Estadio e Hincha)
CREATE TABLE EstadioHincha (
    Estadio_Nombre VARCHAR(100) NOT NULL,
    Hincha_NroTiket VARCHAR(50) NOT NULL,
    PRIMARY KEY (Estadio_Nombre, Hincha_NroTiket),
    CONSTRAINT FK_EstadioHincha_Estadio FOREIGN KEY (Estadio_Nombre) 
        REFERENCES Estadio(Nombre) ON DELETE CASCADE,
    CONSTRAINT FK_EstadioHincha_Hincha FOREIGN KEY (Hincha_NroTiket) 
        REFERENCES Hincha(NroTiket) ON DELETE CASCADE
);

-- 10. EquipoJugador (M:N entre Equipo y Jugador)
CREATE TABLE EquipoJugador (
    Equipo_NombreSeleccion VARCHAR(100) NOT NULL,
    Jugador_NroCamiseta INT NOT NULL,
    PRIMARY KEY (Equipo_NombreSeleccion, Jugador_NroCamiseta),
    CONSTRAINT FK_EquipoJugador_Equipo FOREIGN KEY (Equipo_NombreSeleccion) 
        REFERENCES Equipo(NombreSeleccion) ON DELETE CASCADE,
    CONSTRAINT FK_EquipoJugador_Jugador FOREIGN KEY (Jugador_NroCamiseta) 
        REFERENCES Jugador(NroCamiseta) ON DELETE CASCADE
);
