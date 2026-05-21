# Informe Técnico
# Sistema de Monitoreo de Emisiones CO2 — Parque Automotor Gubernamental

| Campo | Detalle |
|-------|---------|
| **Autor** | Johan Fernando Sanchez Rincon |
| **Fecha** | Mayo 2026 |
| **Versión** | 1.0 |
| **Tecnología** | Oracle Database 19c+ / Spring Boot 3.2 |

---

## 1. Introducción

El presente informe documenta el diseño, modelado e implementación de un sistema de base de datos relacional para el monitoreo y análisis de emisiones de dióxido de carbono (CO2) del parque automotor de una entidad gubernamental colombiana.

El sistema fue construido sobre Oracle Database 19c, tecnología estándar empresarial con soporte oficial a largo plazo, y cuenta con una API REST implementada en Spring Boot 3.2 para integraciones con aplicaciones cliente. Toda la solución está diseñada para escalar a millones de mediciones manteniendo tiempos de respuesta menores a 2 segundos.

---

## 2. Contexto del Negocio

La entidad requiere:

- **Registro** de ciudades, tipos de vehículo, combustibles, propietarios, vehículos, mediciones diarias de CO2, mantenimientos y normativas ambientales.
- **Control de cumplimiento:** detectar vehículos que superen los límites de la Resolución 910 de 2008 del Ministerio de Ambiente de Colombia.
- **Reportes analíticos:** ranking de contaminación, evolución mensual, detección de vehículos fuera de norma, e impacto de mantenimientos en emisiones.
- **Rendimiento:** la base debe soportar millones de mediciones y responder consultas analíticas en menos de 2 segundos.

---

## 3. Modelo Conceptual

### Entidades Principales

| Entidad | Descripción |
|---------|-------------|
| **CIUDAD** | Ciudad donde opera el vehículo |
| **TIPO_VEHICULO** | Categoría del vehículo (automóvil, bus, camión, moto) |
| **COMBUSTIBLE** | Tipo de combustible (gasolina, diésel, GNV, eléctrico, híbrido) |
| **PROPIETARIO** | Entidad natural o jurídica propietaria del vehículo |
| **VEHICULO** | Unidad del parque automotor — entidad central |
| **MEDICION_CO2** | Medición diaria de emisiones — tabla de hechos principal |
| **MANTENIMIENTO** | Intervención mecánica sobre un vehículo |
| **NORMATIVA** | Límite legal de CO2 por tipo de vehículo y período |

### Relaciones y Cardinalidades

- Una **CIUDAD** registra N **VEHÍCULOS** (1:N)
- Un **TIPO_VEHICULO** clasifica N **VEHÍCULOS** (1:N)
- Un **COMBUSTIBLE** es usado por N **VEHÍCULOS** (1:N)
- Un **PROPIETARIO** posee N **VEHÍCULOS** (1:N)
- Un **VEHICULO** genera N **MEDICION_CO2** (1:N)
- Un **VEHICULO** recibe N **MANTENIMIENTOS** (1:N)
- Un **TIPO_VEHICULO** tiene N **NORMATIVAS** vigentes (1:N)

---

## 4. Modelo Lógico (3FN)

El modelo fue normalizado hasta **Tercera Forma Normal (3FN)**:

- **1FN:** todos los atributos son atómicos (no hay grupos repetidos ni multivaluados).
- **2FN:** cada atributo no clave depende completamente de la PK (sin dependencias parciales).
- **3FN:** no existen dependencias transitivas — `factor_co2_teorico` está en `COMBUSTIBLE`, no en `VEHICULO`; `factor_emision_base` está en `TIPO_VEHICULO`, no en `MEDICION_CO2`.

### Restricciones de Integridad Implementadas

| Tabla | Tipo | Restricción |
|-------|------|-------------|
| `CIUDAD` | CHECK | `poblacion >= 0` |
| `TIPO_VEHICULO` | CHECK | `factor_emision_base > 0` |
| `TIPO_VEHICULO` | UNIQUE | `nombre` único por tipo |
| `PROPIETARIO` | CHECK | `tipo_persona IN ('NATURAL','JURIDICA')` |
| `PROPIETARIO` | UNIQUE | `email` único |
| `VEHICULO` | CHECK | `ano_fabricacion BETWEEN 1900 AND SYSDATE` |
| `VEHICULO` | UNIQUE | `placa` única |
| `MEDICION_CO2` | CHECK | `co2_g_km BETWEEN 0 AND 1000` |
| `MEDICION_CO2` | CHECK | `humedad BETWEEN 0 AND 100` |
| `NORMATIVA` | CHECK | `co2_max_permitido > 0` |
| `NORMATIVA` | CHECK | `ano_desde <= ano_hasta` |

---

## 5. Modelo Físico Oracle

### Tipos de Datos Utilizados

| Tipo Oracle | Justificación de uso |
|-------------|----------------------|
| `NUMBER` | PKs, enteros (cilindraje, año, población) |
| `NUMBER(8,2)` | Valores CO2 con precisión de 2 decimales |
| `NUMBER(5,2)` | Temperatura y humedad con precisión de 2 decimales |
| `NUMBER(6,4)` | Factores de emisión con 4 decimales de precisión |
| `VARCHAR2(n)` | Cadenas con longitud máxima definida (ahorro de espacio vs CHAR) |
| `DATE` | Fechas de medición y mantenimiento (incluye hora en Oracle) |

### Secuencias

Se crearon 8 secuencias (`seq_ciudad`, `seq_tipo`, `seq_combustible`, `seq_propietario`, `seq_vehiculo`, `seq_medicion`, `seq_mantenimiento`, `seq_normativa`) con:
- `START WITH 1`: inician en 1
- `INCREMENT BY 1`: incremento unitario
- `NOCACHE`: evita huecos en IDs cuando hay rollbacks
- `NOCYCLE`: no reinicia al llegar al límite máximo

---

## 6. Explicación de Índices

### Índices Simples (B-Tree)

| Índice | Columna | Justificación |
|--------|---------|---------------|
| `idx_vehiculo_ciudad` | `id_ciudad` | Acelera JOINs frecuentes ciudad-vehículo |
| `idx_vehiculo_tipo` | `id_tipo` | Acelera JOINs con normativa (misma columna) |
| `idx_vehiculo_placa` | `placa` | Búsqueda directa por placa en API REST |
| `idx_medicion_vehiculo` | `id_vehiculo` | Consultas "todas las mediciones de un vehículo" |
| `idx_medicion_fecha` | `fecha` | Filtros por rango de fechas, potencia partition pruning |

### Índices Compuestos

| Índice | Columnas | Beneficio |
|--------|----------|-----------|
| `idx_medicion_vehiculo_fecha` | `(id_vehiculo, fecha)` | Cubre consultas con AMBAS columnas → INDEX RANGE SCAN más selectivo que índices individuales |
| `idx_mantenimiento_vehiculo_fecha` | `(id_vehiculo, fecha)` | Optimiza análisis pre/post mantenimiento |
| `idx_medicion_co2_desc` | `(co2_g_km DESC, fecha DESC)` | Ranking de vehículos más contaminantes |

### Índice Basado en Función (FBI)

```sql
CREATE INDEX idx_medicion_anio_mes
ON medicion_co2 (EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)) LOCAL;
```

Cuando una consulta usa `WHERE EXTRACT(MONTH FROM fecha) = 3`, Oracle normalmente no puede usar el índice de la columna `fecha` porque la función la transforma. El FBI pre-calcula el resultado de `EXTRACT` y lo indexa directamente, habilitando INDEX RANGE SCAN.

### Por qué todos los índices de MEDICION_CO2 son LOCAL

`LOCAL` = un segmento de índice por partición de tabla. Beneficios:
- Al eliminar una partición (`DROP PARTITION`), solo se elimina el segmento de índice correspondiente — los demás permanecen válidos.
- Los índices `GLOBAL` se invalidan completos cuando se elimina cualquier partición.
- Permite mantenimiento paralelo por partición.

---

## 7. Particionamiento de MEDICION_CO2

### Estrategia: PARTITION BY RANGE (fecha) trimestral

```sql
PARTITION p_2026_q1 VALUES LESS THAN (DATE '2026-04-01')
PARTITION p_2026_q2 VALUES LESS THAN (DATE '2026-07-01')
...
PARTITION p_futuro  VALUES LESS THAN (MAXVALUE)
```

### Por qué el particionamiento mejora el rendimiento

**Partition Pruning:** cuando una consulta incluye `WHERE fecha BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'`, Oracle elimina del plan de ejecución todas las particiones que no pueden contener datos del rango — accede **solo a `p_2026_q1`**. En una tabla con 10 millones de filas dividida en 12 particiones, esto implica acceder a ~830,000 filas en lugar de 10 millones (**reducción del 92% de I/O**).

**Partition-Wise Join:** en JOINs entre tablas particionadas, Oracle puede ejecutar el JOIN en paralelo por partición.

**Mantenimiento simplificado:** eliminar datos históricos es instantáneo con `ALTER TABLE medicion_co2 DROP PARTITION p_2024_q1`, sin generar redo logs masivos como un `DELETE` masivo.

**Gestión de índices LOCAL:** cada partición tiene su propio segmento de índice, lo que permite operaciones de mantenimiento (rebuild, analyze) por partición sin afectar la disponibilidad del resto.

---

## 8. Explicación del Tuning

### Recolección de Estadísticas

```sql
DBMS_STATS.GATHER_TABLE_STATS(
    ownname    => USER,
    tabname    => 'MEDICION_CO2',
    cascade    => TRUE,       -- incluye índices
    granularity => 'ALL',     -- por partición
    degree     => 4           -- paralelismo
);
```

Sin estadísticas actualizadas, el CBO usa estimaciones incorrectas y puede elegir un FULL SCAN sobre un INDEX SCAN que sería 100x más rápido.

### Anti-Patrón vs. Consulta Optimizada

| Versión | Predicado | Plan de Oracle | Costo relativo |
|---------|-----------|---------------|----------------|
| Lenta | `TO_CHAR(fecha,'YYYY-MM') = '2026-03'` | FULL TABLE SCAN | 10,000,000 filas |
| Rápida | `fecha BETWEEN DATE '2026-03-01' AND DATE '2026-03-31'` | PARTITION RANGE SINGLE + INDEX RANGE SCAN | ~830,000 filas |

### Hints del Optimizador

```sql
SELECT /*+ INDEX(m idx_medicion_vehiculo_fecha) */ ...
```

Los hints se usan como último recurso cuando el CBO elige un plan subóptimo a pesar de tener estadísticas actualizadas. No deben ser la primera solución.

---

## 9. Planes de Ejecución

### Consulta A1 — Ranking de contaminantes

```
Id  Operation                        Name                       Pstart  Pstop
0   SELECT STATEMENT
1     SORT ORDER BY
2       VIEW
3         WINDOW SORT
4           HASH GROUP BY
5             HASH JOIN
6               NESTED LOOPS
7                 PARTITION RANGE ITERATOR                       KEY     KEY
8                   INDEX RANGE SCAN  IDX_MEDICION_VEHICULO_FECHA
9                 TABLE ACCESS BY ROWID  VEHICULO
10              TABLE ACCESS FULL     TIPO_VEHICULO
```

**Lectura del plan:**
- `PARTITION RANGE ITERATOR` con `Pstart=KEY, Pstop=KEY`: partition pruning activo — solo se acceden las particiones del rango de fechas del WHERE.
- `INDEX RANGE SCAN` sobre `idx_medicion_vehiculo_fecha`: usa el índice compuesto, evita acceso completo a la tabla.
- `HASH JOIN`: eficiente para grandes volúmenes, Oracle construye tabla hash en memoria.

### Consulta de Partition Pruning

```
Id  Operation                Name         Pstart  Pstop
0   SELECT STATEMENT
1     SORT AGGREGATE
2       PARTITION RANGE SINGLE           5       5
3         TABLE ACCESS FULL   MEDICION_CO2  5     5
```

`PARTITION RANGE SINGLE` con `Pstart=5, Pstop=5` confirma que Oracle accede solo a la partición 5 (`p_2026_q1`) de las 11 disponibles.

---

## 10. Comparación de Rendimiento

| Consulta | Sin tuning (estimado) | Con tuning (estimado) | Mejora |
|----------|----------------------|----------------------|--------|
| Ranking top 5 (10M filas) | ~4.2 s | ~0.3 s | **14x** |
| Filtro por mes completo | ~3.8 s | ~0.4 s | **9x** |
| Evolución mensual LAG | ~5.1 s | ~0.7 s | **7x** |
| Pre/post mantenimiento | ~2.9 s | ~0.4 s | **7x** |
| Vehículos fuera de norma | ~3.3 s | ~0.5 s | **6x** |

*Tiempos estimados sobre instancia Oracle con 10 millones de mediciones, 4 CPUs, 16 GB RAM.*

---

## 11. Cómo Funcionan las Consultas Analíticas

### RANK() — Consulta A1
`RANK()` es una función de ventana que asigna un número ordinal a cada fila dentro de una partición. Con `ORDER BY AVG(co2_g_km) DESC`, el vehículo más contaminante recibe rango 1. En empates, ambas filas reciben el mismo rango y el siguiente se salta (1,1,3). A diferencia de `DENSE_RANK()` que no salta (1,1,2).

### LAG() — Consulta A2
`LAG(promedio_co2) OVER (PARTITION BY id_vehiculo ORDER BY anio, mes)` accede al valor de la fila inmediatamente anterior dentro de la partición del mismo vehículo. Es más eficiente que un auto-JOIN porque evita un segundo scan de la tabla — Oracle lo implementa como una única pasada de ventana deslizante.

### AVG() OVER con ROWS BETWEEN — Consulta A2
`AVG(promedio_co2) OVER (PARTITION BY id_vehiculo ORDER BY anio, mes ROWS BETWEEN 2 PRECEDING AND CURRENT ROW)` calcula la media de la fila actual y las 2 anteriores, creando un promedio móvil de 3 meses. La cláusula `ROWS BETWEEN` define el tamaño físico de la ventana en filas.

### CTEs WITH — Consultas A3 y A4
Los CTEs (Common Table Expressions) se definen con la cláusula `WITH` y permiten dar nombre a subconsultas para reutilizarlas. El optimizador Oracle puede materializarlas una sola vez y reutilizar el resultado, evitando scans repetidos. Además mejoran significativamente la legibilidad del código.

---

## 12. Conclusiones

1. El modelo relacional normalizado en 3FN garantiza consistencia, elimina redundancia y simplifica el mantenimiento del esquema.
2. El particionamiento trimestral de `MEDICION_CO2` es la decisión de arquitectura más crítica para escalar a millones de registros con SLA < 2 segundos.
3. Los índices compuestos `(id_vehiculo, fecha)` son el complemento esencial del particionamiento para las consultas analíticas más frecuentes.
4. Las funciones de ventana Oracle (`RANK`, `LAG`, `AVG OVER`) simplifican consultas que serían muy complejas con joins recursivos o múltiples subconsultas.
5. La API REST Spring Boot expone los datos de forma segura y desacoplada, permitiendo integración con cualquier cliente sin exponer la base de datos directamente.
6. La combinación partition pruning + index range scan + estadísticas actualizadas permite cumplir el SLA de respuesta < 2 segundos incluso con volúmenes de producción.

---

*Johan Fernando Sanchez Rincon — Prueba Técnica Ingeniero de Bases de Datos — Mayo 2026*
