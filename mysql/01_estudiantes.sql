-- ==============================================================================
-- Script: mysql/01_estudiantes.sql
-- Motor: MySQL 8.x / MariaDB 10.x+
-- Descripción: Creación de tabla estudiantes con motor InnoDB, AUTO_INCREMENT,
--              inserciones por lote (multi-row) y manejo de duplicados.
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS academia_db
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE academia_db;

DROP TABLE IF EXISTS estudiantes;

CREATE TABLE estudiantes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    estado ENUM('activo', 'inactivo', 'graduado') DEFAULT 'activo',
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 1. Inserción en bloque (multi-row insert del script original new.sql)
INSERT INTO estudiantes (nombre) 
VALUES 
    ('marco'),
    ('pablutus'),
    ('carlos'),
    ('daniela');

-- 2. Inserción con Upsert (ON DUPLICATE KEY UPDATE)
INSERT INTO estudiantes (id, nombre, estado)
VALUES (1, 'marco aurelio', 'activo')
AS nuevo
ON DUPLICATE KEY UPDATE
    nombre = nuevo.nombre,
    estado = nuevo.estado;

-- 3. Consulta de verificación
SELECT id, nombre, estado, fecha_creacion 
FROM estudiantes 
ORDER BY id ASC;
