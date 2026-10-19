-- =====================================================================
-- Proyecto : RetailChain  -  Inventario por sucursal
-- Curso    : Data Analytics - Coderhouse - Practica UNION / UNION ALL
-- Alumno   : Aranda, Mauro Nahuel
-- Motor    : SQL Server 2025 (SQL Server Management Studio 22)
-- Objetivo : Crear la base y las dos tablas de inventario con sus datos.
-- Nota     : El script es repetible: se puede ejecutar varias veces
--            seguidas sin errores.
-- =====================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'RetailChain_DB')
    CREATE DATABASE RetailChain_DB;
GO

USE RetailChain_DB;
GO

-- =====================================================================
-- DROP
-- =====================================================================
DROP TABLE IF EXISTS inventario_sucursal_norte;
DROP TABLE IF EXISTS inventario_sucursal_sur;
GO

-- =====================================================================
-- CREATE
-- Las dos tablas comparten exactamente la misma estructura: es la
-- condicion que permite combinarlas con UNION y UNION ALL.
-- =====================================================================
CREATE TABLE inventario_sucursal_norte (
    id_producto     INT,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    stock           INT          NOT NULL
);

CREATE TABLE inventario_sucursal_sur (
    id_producto     INT,
    nombre_producto VARCHAR(100) NOT NULL,
    categoria       VARCHAR(50),
    stock           INT          NOT NULL
);
GO

-- =====================================================================
-- INSERT
-- =====================================================================

-- Sucursal Norte (7 registros)
INSERT INTO inventario_sucursal_norte VALUES (101, 'Laptop Pro 15',      'Computación',     8);
INSERT INTO inventario_sucursal_norte VALUES (102, 'Mouse Inalámbrico',  'Accesorios',     30);
INSERT INTO inventario_sucursal_norte VALUES (103, 'Monitor 4K 27"',     'Computación',     5);
INSERT INTO inventario_sucursal_norte VALUES (104, 'Teclado Mecánico',   'Accesorios',     20);
INSERT INTO inventario_sucursal_norte VALUES (105, 'Auriculares BT Pro', 'Audio',          15);
-- Estos dos tambien existen en la Sucursal Sur
INSERT INTO inventario_sucursal_norte VALUES (106, 'SSD Externo 1TB',    'Almacenamiento', 10);
INSERT INTO inventario_sucursal_norte VALUES (107, 'Webcam HD 1080p',    'Accesorios',     12);

-- Sucursal Sur (7 registros)
INSERT INTO inventario_sucursal_sur VALUES (103, 'Monitor 4K 27"',     'Computación',     3);
INSERT INTO inventario_sucursal_sur VALUES (104, 'Teclado Mecánico',   'Accesorios',     18);
INSERT INTO inventario_sucursal_sur VALUES (106, 'SSD Externo 1TB',    'Almacenamiento',  7);
-- Exclusivos de la Sucursal Sur
INSERT INTO inventario_sucursal_sur VALUES (108, 'Laptop Basic 14',    'Computación',     6);
INSERT INTO inventario_sucursal_sur VALUES (109, 'Parlante Bluetooth', 'Audio',          22);
INSERT INTO inventario_sucursal_sur VALUES (110, 'Hub USB-C 7p',       'Accesorios',     35);
INSERT INTO inventario_sucursal_sur VALUES (111, 'Webcam HD 1080p',    'Accesorios',      9);
GO

-- =====================================================================
-- VALIDACION: 7 filas en cada sucursal
-- =====================================================================
SELECT COUNT(*) AS filas_norte FROM inventario_sucursal_norte;
SELECT COUNT(*) AS filas_sur   FROM inventario_sucursal_sur;
GO
