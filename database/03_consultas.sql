-- ============================================================
-- PROYECTO:  Sistema de Monitoreo de Emisiones CO2
-- ARCHIVO:   03_consultas.sql
-- AUTOR:     Johan Fernando Sanchez Rincon
-- FECHA:     Mayo 2026
-- ============================================================

-- B1: Vehículos con ciudad y tipo de vehículo
SELECT v.id_vehiculo,v.placa,v.modelo,v.ano_fabricacion,v.cilindraje,
       c.nombre AS ciudad,c.departamento,t.nombre AS tipo_vehiculo,
       cb.nombre AS combustible,p.nombre AS propietario
FROM vehiculo v
JOIN ciudad c ON v.id_ciudad=c.id_ciudad
JOIN tipo_vehiculo t ON v.id_tipo=t.id_tipo
JOIN combustible cb ON v.id_combustible=cb.id_combustible
JOIN propietario p ON v.id_propietario=p.id_propietario
ORDER BY c.nombre,t.nombre,v.placa;

-- B2: Promedio de CO2 por ciudad
SELECT c.nombre AS ciudad,c.departamento,
       COUNT(DISTINCT v.id_vehiculo) AS total_vehiculos,
       COUNT(m.id_medicion) AS total_mediciones,
       ROUND(AVG(m.co2_g_km),2) AS promedio_co2,
       ROUND(MIN(m.co2_g_km),2) AS minimo_co2,
       ROUND(MAX(m.co2_g_km),2) AS maximo_co2
FROM ciudad c
JOIN vehiculo v ON c.id_ciudad=v.id_ciudad
JOIN medicion_co2 m ON v.id_vehiculo=m.id_vehiculo
GROUP BY c.id_ciudad,c.nombre,c.departamento
ORDER BY promedio_co2 DESC;

-- B3: Vehículos que superan normativa vigente
SELECT v.placa,v.modelo,t.nombre AS tipo_vehiculo,
       n.co2_max_permitido AS limite_normativa,
       ROUND(avg_m.promedio_co2,2) AS promedio_co2_reciente,
       ROUND(avg_m.promedio_co2 - n.co2_max_permitido,2) AS exceso,
       c.nombre AS ciudad
FROM vehiculo v
JOIN tipo_vehiculo t ON v.id_tipo=t.id_tipo
JOIN ciudad c ON v.id_ciudad=c.id_ciudad
JOIN normativa n ON n.id_tipo=v.id_tipo
  AND EXTRACT(YEAR FROM SYSDATE) BETWEEN n.ano_desde AND n.ano_hasta
JOIN (SELECT id_vehiculo,AVG(co2_g_km) AS promedio_co2
      FROM medicion_co2 WHERE fecha>=SYSDATE-90 GROUP BY id_vehiculo) avg_m
  ON avg_m.id_vehiculo=v.id_vehiculo
WHERE avg_m.promedio_co2 > n.co2_max_permitido
ORDER BY exceso DESC;

-- B4: Total mantenimientos y gasto por vehículo
SELECT v.placa,v.modelo,t.nombre AS tipo_vehiculo,c.nombre AS ciudad,
       COUNT(m.id_mantenimiento) AS total_mantenimientos,
       SUM(m.costo) AS gasto_total_cop,
       ROUND(AVG(m.costo),0) AS costo_promedio,
       MAX(m.fecha) AS ultimo_mantenimiento
FROM vehiculo v
JOIN tipo_vehiculo t ON v.id_tipo=t.id_tipo
JOIN ciudad c ON v.id_ciudad=c.id_ciudad
LEFT JOIN mantenimiento m ON v.id_vehiculo=m.id_vehiculo
GROUP BY v.id_vehiculo,v.placa,v.modelo,t.nombre,c.nombre
ORDER BY gasto_total_cop DESC NULLS LAST;

-- B5: Última medición por vehículo
SELECT u.placa,u.modelo,u.tipo_vehiculo,u.ciudad,
       u.fecha AS ultima_fecha,u.co2_g_km,u.kilometraje
FROM (
  SELECT v.placa,v.modelo,t.nombre AS tipo_vehiculo,c.nombre AS ciudad,
         m.fecha,m.co2_g_km,m.kilometraje,
         ROW_NUMBER() OVER(PARTITION BY v.id_vehiculo ORDER BY m.fecha DESC) AS rn
  FROM medicion_co2 m
  JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
  JOIN tipo_vehiculo t ON v.id_tipo=t.id_tipo
  JOIN ciudad c ON v.id_ciudad=c.id_ciudad
) u WHERE u.rn=1 ORDER BY u.ultima_fecha DESC;

-- A1: Ranking top 5 vehículos más contaminantes (RANK)
SELECT ranking.* FROM (
  SELECT v.placa,v.modelo,t.nombre AS tipo_vehiculo,c.nombre AS ciudad,
         COUNT(m.id_medicion) AS total_mediciones,
         ROUND(AVG(m.co2_g_km),2) AS promedio_co2,
         RANK() OVER(ORDER BY AVG(m.co2_g_km) DESC) AS ranking_contaminacion
  FROM medicion_co2 m
  JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
  JOIN tipo_vehiculo t ON v.id_tipo=t.id_tipo
  JOIN ciudad c ON v.id_ciudad=c.id_ciudad
  WHERE m.fecha >= ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)
  GROUP BY v.id_vehiculo,v.placa,v.modelo,t.nombre,c.nombre
) ranking WHERE ranking_contaminacion<=5 ORDER BY ranking_contaminacion;

-- A2: Evolución mensual con LAG y promedio móvil 3 meses
WITH evolucion AS (
  SELECT v.id_vehiculo,v.placa,v.modelo,
         EXTRACT(YEAR FROM m.fecha) AS anio,
         EXTRACT(MONTH FROM m.fecha) AS mes,
         TO_CHAR(m.fecha,'YYYY-MM') AS periodo,
         ROUND(AVG(m.co2_g_km),2) AS promedio_co2
  FROM medicion_co2 m JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
  WHERE m.fecha >= ADD_MONTHS(TRUNC(SYSDATE,'YYYY'),-12)
  GROUP BY v.id_vehiculo,v.placa,v.modelo,
           EXTRACT(YEAR FROM m.fecha),EXTRACT(MONTH FROM m.fecha),
           TO_CHAR(m.fecha,'YYYY-MM')
)
SELECT placa,modelo,periodo,promedio_co2,
       LAG(promedio_co2) OVER(PARTITION BY id_vehiculo ORDER BY anio,mes) AS co2_mes_anterior,
       ROUND(promedio_co2 - LAG(promedio_co2) OVER(PARTITION BY id_vehiculo ORDER BY anio,mes),2) AS diferencia,
       ROUND(AVG(promedio_co2) OVER(PARTITION BY id_vehiculo ORDER BY anio,mes
             ROWS BETWEEN 2 PRECEDING AND CURRENT ROW),2) AS promedio_movil_3m
FROM evolucion ORDER BY placa,anio,mes;

-- A3: Vehículos con mejora > 10% post-mantenimiento (CTEs)
WITH pre AS (
  SELECT mn.id_mantenimiento,mn.id_vehiculo,mn.fecha AS fecha_mant,
         mn.tipo_mantenimiento,mn.taller,
         AVG(mc.co2_g_km) AS co2_antes
  FROM mantenimiento mn
  JOIN medicion_co2 mc ON mc.id_vehiculo=mn.id_vehiculo
    AND mc.fecha BETWEEN mn.fecha-30 AND mn.fecha-1
  GROUP BY mn.id_mantenimiento,mn.id_vehiculo,mn.fecha,mn.tipo_mantenimiento,mn.taller
),
post AS (
  SELECT mn.id_mantenimiento,AVG(mc.co2_g_km) AS co2_despues
  FROM mantenimiento mn
  JOIN medicion_co2 mc ON mc.id_vehiculo=mn.id_vehiculo
    AND mc.fecha BETWEEN mn.fecha+1 AND mn.fecha+30
  GROUP BY mn.id_mantenimiento
)
SELECT v.placa,v.modelo,pre.fecha_mant,pre.tipo_mantenimiento,pre.taller,
       ROUND(pre.co2_antes,2) AS co2_antes,
       ROUND(post.co2_despues,2) AS co2_despues,
       ROUND(pre.co2_antes-post.co2_despues,2) AS reduccion,
       ROUND((pre.co2_antes-post.co2_despues)/pre.co2_antes*100,1) AS pct_mejora
FROM pre JOIN post ON pre.id_mantenimiento=post.id_mantenimiento
JOIN vehiculo v ON v.id_vehiculo=pre.id_vehiculo
WHERE (pre.co2_antes-post.co2_despues)/pre.co2_antes > 0.10
ORDER BY pct_mejora DESC;

-- A4: % vehículos fuera de norma por ciudad
WITH fuera AS (
  SELECT DISTINCT v.id_vehiculo,v.id_ciudad
  FROM vehiculo v
  JOIN normativa n ON n.id_tipo=v.id_tipo
    AND EXTRACT(YEAR FROM SYSDATE) BETWEEN n.ano_desde AND n.ano_hasta
  JOIN medicion_co2 mc ON mc.id_vehiculo=v.id_vehiculo
  WHERE mc.co2_g_km > n.co2_max_permitido
),
totales AS (
  SELECT id_ciudad, COUNT(DISTINCT id_vehiculo) AS total
  FROM vehiculo GROUP BY id_ciudad
)
SELECT c.nombre AS ciudad,c.departamento,
       tot.total AS total_vehiculos,
       COUNT(f.id_vehiculo) AS vehiculos_fuera_norma,
       ROUND(COUNT(f.id_vehiculo)*100.0/NULLIF(tot.total,0),1) AS pct_fuera_norma
FROM ciudad c
JOIN totales tot ON tot.id_ciudad=c.id_ciudad
LEFT JOIN fuera f ON f.id_ciudad=c.id_ciudad
GROUP BY c.id_ciudad,c.nombre,c.departamento,tot.total
ORDER BY pct_fuera_norma DESC NULLS LAST;
-- Autor: Johan Fernando Sanchez Rincon — Mayo 2026
