# RetailChain — UNION y UNION ALL

**Alumno:** Aranda, Mauro Nahuel
**Curso:** Data Analytics — Coderhouse
**Motor:** SQL Server 2025 (SQL Server Management Studio 22)

## Contenido del repositorio

| Archivo | Qué contiene |
|---|---|
| `schema.sql` | Crea la base `RetailChain_DB`, las dos tablas de inventario y carga los 14 registros. Es repetible. |
| `soluciones.sql` | Las tres consultas: catálogo unificado con UNION, auditoría de stock con UNION ALL y la comparación de conteos. |

Para reproducirlo: ejecutar primero `schema.sql` y después `soluciones.sql`.

---

## 1. Cuántas filas devuelve cada consulta y por qué son distintas

| Consulta | Operador | Filas |
|---|---|---|
| Catálogo unificado | `UNION` | **11** |
| Auditoría de stock | `UNION ALL` | **14** |

Las dos sucursales aportan 7 registros cada una, o sea 14 filas en total. `UNION ALL` devuelve esas 14 porque se limita a apilar un resultado debajo del otro. `UNION` devuelve 11 porque, antes de entregar el resultado, descarta las filas que aparecen repetidas.

Las tres filas eliminadas son exactamente estas, que existen en las dos sucursales con el mismo id, el mismo nombre y la misma categoría:

- `103 — Monitor 4K 27" — Computación`
- `104 — Teclado Mecánico — Accesorios`
- `106 — SSD Externo 1TB — Almacenamiento`

Hay dos detalles de estos datos que conviene mirar de cerca, porque son los que se prestan a confusión:

**La Webcam no se elimina.** Los registros `107 — Webcam HD 1080p — Accesorios` (Norte) y `111 — Webcam HD 1080p — Accesorios` (Sur) tienen el mismo nombre y la misma categoría, pero distinto `id_producto`. Para `UNION` son filas diferentes y las conserva a las dos. El operador compara la fila completa, no el producto: si el catálogo real tiene un problema de duplicación de códigos, `UNION` no lo resuelve.

**Si hubiera incluido `stock`, `UNION` habría devuelto 14.** El Monitor 4K tiene stock 5 en Norte y 3 en Sur, el Teclado 20 y 18, el SSD 10 y 7. Con esa columna adentro, ninguna fila sería idéntica a otra y no se descartaría ninguna, de modo que las dos consultas darían el mismo número y la diferencia entre los operadores quedaría invisible. Por eso el catálogo se arma sin el stock: además de ser lo correcto para el área comercial, es lo que hace que `UNION` tenga algo que eliminar.

## 2. Por qué `UNION ALL` es más eficiente

`UNION ALL` hace una sola cosa: concatena los dos conjuntos y los devuelve. Su costo crece de forma lineal con la cantidad de filas y puede empezar a entregar resultados apenas lee las primeras.

`UNION` hace eso **y además** una operación de eliminación de duplicados, que es la que consume los recursos extra. Para saber si una fila está repetida, el motor tiene que comparar cada fila contra todas las demás, y para eso necesita ordenarlas o construir una tabla hash en memoria. En el plan de ejecución de SQL Server esto aparece como un operador `Sort (Distinct Sort)` o `Hash Match (Aggregate)` que `UNION ALL` no tiene.

Eso trae tres consecuencias prácticas:

- **Es bloqueante.** El motor no puede devolver ninguna fila hasta haber leído las dos consultas enteras, porque hasta el final no sabe si va a aparecer un duplicado.
- **Consume memoria.** Si el conjunto no entra en la memoria asignada, SQL Server vuelca a disco (*spill a tempdb*), y ahí el tiempo de respuesta se dispara.
- **Compara todas las columnas.** Cuantas más columnas tenga el SELECT, más caro es el chequeo.

Con 14 filas la diferencia es imperceptible. Con millones de filas, usar `UNION` cuando alcanzaba `UNION ALL` es una de las causas más comunes de consultas lentas.

## 3. En qué casos de negocio usaría cada uno

**`UNION` — cuando lo que importa es la entidad y repetirla es un error.**

- *Fusión de dos empresas:* para armar el padrón único de proveedores a partir de los sistemas de ambas, donde un proveedor que trabajaba con las dos tiene que figurar una sola vez antes de negociar condiciones.
- *Campaña de email marketing:* para unificar los suscriptores de dos bases distintas. Si una persona está en las dos y no se deduplica, recibe el mismo correo dos veces, lo que además de molesto eleva la tasa de desuscripción.

**`UNION ALL` — cuando cada registro es un hecho que ocurrió y perderlo falsea el total.**

- *Cierre trimestral:* apilar los archivos mensuales de transacciones de enero, febrero y marzo para calcular la facturación del trimestre. Dos ventas del mismo producto, por el mismo importe y el mismo día son dos ventas distintas; con `UNION` una de las dos desaparecería y el total quedaría por debajo del real.
- *Registro de asistencia o de logs:* consolidar las marcas de ingreso de varias sucursales. Dos empleados que fichan en el mismo minuto generan filas idénticas que igual deben contarse por separado.

La regla que se desprende: si el duplicado es un **error de carga**, va `UNION`; si el duplicado es un **hecho real repetido**, va `UNION ALL`.

## 4. Qué pasa si las columnas no coinciden

**Distinta cantidad de columnas.** La consulta ni siquiera se ejecuta: falla en la compilación. SQL Server devuelve el error 205:

```
Msg 205, Level 16, State 1
All queries combined using a UNION, INTERSECT or EXCEPT operator
must have an equal number of expressions in their target lists.
```

**Distinta cantidad de columnas, mismo número pero tipos incompatibles.** Acá el comportamiento depende de si los tipos se pueden convertir entre sí:

- Si son **compatibles**, no hay error: SQL Server aplica una conversión implícita al tipo de mayor precedencia. Por ejemplo, un `INT` unido a un `DECIMAL(10,2)` devuelve `DECIMAL`. Esto es cómodo pero conviene vigilarlo, porque la conversión puede cambiar la precisión del resultado sin avisar.
- Si son **incompatibles**, falla en ejecución. Unir una columna de texto contra una numérica produce el error 245:

```
Msg 245, Level 16, State 1
Conversion failed when converting the varchar value 'Norte' to data type int.
```

**El orden importa.** Los nombres de las columnas no se comparan: la correspondencia es exclusivamente posicional. Si en una consulta el orden es `(id, nombre)` y en la otra `(nombre, id)`, y ambos tipos son texto, SQL Server no da error pero devuelve los datos cruzados. Es el caso más peligroso de los cuatro, porque el resultado es incorrecto en silencio. Los encabezados que se muestran son siempre los de la primera consulta.
