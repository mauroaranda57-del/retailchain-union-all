-- =====================================================================
-- Proyecto : RetailChain  -  UNION y UNION ALL
-- Curso    : Data Analytics - Coderhouse
-- Alumno   : Aranda, Mauro Nahuel
-- Motor    : SQL Server 2025 (SQL Server Management Studio 22)
-- Base     : RetailChain_DB (creada en schema.sql)
-- =====================================================================

USE RetailChain_DB;
GO

-- =====================================================================
-- CONSULTA 1 - UNION
-- Reporte de Catalogo Unificado para el area comercial.
-- Pregunta de negocio: que productos unicos comercializa la empresa
-- en toda su red de sucursales.
--
-- La columna stock se deja fuera a proposito. UNION elimina filas
-- identicas, no productos repetidos: como el Monitor 4K tiene stock 5
-- en Norte y 3 en Sur, incluyendo stock las dos filas serian distintas
-- y no se descartaria ninguna. Ademas el catalogo comercial describe
-- que se vende, no cuanto hay.
-- =====================================================================
SELECT id_producto, nombre_producto, categoria
FROM inventario_sucursal_norte
UNION
SELECT id_producto, nombre_producto, categoria
FROM inventario_sucursal_sur
ORDER BY id_producto;
GO
-- Resultado: 11 filas.

-- =====================================================================
-- CONSULTA 2 - UNION ALL
-- Auditoria de Stock Total para el area de operaciones.
-- Pregunta de negocio: cuantos registros fisicos de stock existen en
-- total entre ambas sucursales.
--
-- Aca se usa UNION ALL porque cada registro corresponde a mercaderia
-- real en un deposito distinto: descartarlo por parecido a otro seria
-- perder stock que existe. Se agrega la columna 'sucursal' como valor
-- literal para poder rastrear el origen de cada fila.
-- =====================================================================
SELECT 'Norte' AS sucursal, id_producto, nombre_producto, categoria, stock
FROM inventario_sucursal_norte
UNION ALL
SELECT 'Sur'   AS sucursal, id_producto, nombre_producto, categoria, stock
FROM inventario_sucursal_sur
ORDER BY id_producto, sucursal;
GO
-- Resultado: 14 filas.

-- =====================================================================
-- CONSULTA 3 - COMPARACION DE RESULTADOS
-- El ORDER BY no se incluye dentro de las subconsultas: SQL Server no
-- lo admite en una tabla derivada sin TOP, y para contar filas no hace
-- ninguna falta.
-- =====================================================================
SELECT COUNT(*) AS filas_union FROM (
    SELECT id_producto, nombre_producto, categoria FROM inventario_sucursal_norte
    UNION
    SELECT id_producto, nombre_producto, categoria FROM inventario_sucursal_sur
) AS resultado_union;

SELECT COUNT(*) AS filas_union_all FROM (
    SELECT id_producto, nombre_producto, categoria, stock FROM inventario_sucursal_norte
    UNION ALL
    SELECT id_producto, nombre_producto, categoria, stock FROM inventario_sucursal_sur
) AS resultado_union_all;
GO
-- Resultado: 11 y 14.
