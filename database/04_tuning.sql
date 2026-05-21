-- ============================================================
-- PROYECTO:  Sistema de Monitoreo de Emisiones CO2
-- ARCHIVO:   04_tuning.sql
-- AUTOR:     Johan Fernando Sanchez Rincon
-- FECHA:     Mayo 2026
-- ============================================================

-- SECCIÓN 1: Recolectar estadísticas del optimizador
BEGIN
    DBMS_STATS.GATHER_TABLE_STATS(USER,'MEDICION_CO2',cascade=>TRUE,degree=>4,granularity=>'ALL',method_opt=>'FOR ALL COLUMNS SIZE AUTO');
    DBMS_STATS.GATHER_TABLE_STATS(USER,'VEHICULO',cascade=>TRUE);
    DBMS_STATS.GATHER_TABLE_STATS(USER,'MANTENIMIENTO',cascade=>TRUE);
END;
/

-- SECCIÓN 2: EXPLAIN PLAN — Ranking de contaminantes (A1)
DELETE FROM plan_table WHERE statement_id='RANKING_CO2';
EXPLAIN PLAN SET STATEMENT_ID='RANKING_CO2' FOR
    SELECT ranking.* FROM (
      SELECT v.placa,ROUND(AVG(m.co2_g_km),2) AS promedio,
             RANK() OVER(ORDER BY AVG(m.co2_g_km) DESC) AS ranking
      FROM medicion_co2 m JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
      WHERE m.fecha>=ADD_MONTHS(TRUNC(SYSDATE,'MM'),-3)
      GROUP BY v.id_vehiculo,v.placa
    ) ranking WHERE ranking<=5;
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('plan_table','RANKING_CO2','ALL'));

-- SECCIÓN 3: EXPLAIN PLAN — Partition pruning
DELETE FROM plan_table WHERE statement_id='PART_TEST';
EXPLAIN PLAN SET STATEMENT_ID='PART_TEST' FOR
    SELECT COUNT(*),AVG(co2_g_km) FROM medicion_co2
    WHERE fecha BETWEEN DATE '2026-01-01' AND DATE '2026-03-31';
SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY('plan_table','PART_TEST','PARTITION'));

-- SECCIÓN 4: Consulta LENTA vs OPTIMIZADA
-- VERSION LENTA — NO usar (función sobre columna indexada = full scan)
/*
SELECT v.placa, COUNT(*) FROM medicion_co2 m JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
WHERE TO_CHAR(m.fecha,'YYYY-MM')='2026-03' GROUP BY v.placa;
*/
-- VERSION OPTIMIZADA — rango literal = INDEX RANGE SCAN + partition pruning
SELECT v.placa, COUNT(*) AS mediciones
FROM medicion_co2 m JOIN vehiculo v ON m.id_vehiculo=v.id_vehiculo
WHERE m.fecha BETWEEN DATE '2026-03-01' AND DATE '2026-03-31'
GROUP BY v.placa ORDER BY mediciones DESC;

-- SECCIÓN 5: Hint de optimizador (último recurso)
SELECT /*+ INDEX(m idx_medicion_vehiculo_fecha) */
    m.id_vehiculo, m.fecha, m.co2_g_km
FROM medicion_co2 m
WHERE m.id_vehiculo=7 AND m.fecha BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
ORDER BY m.fecha;

-- SECCIÓN 6: Ver particiones y estadísticas
SELECT partition_name,high_value,num_rows,blocks
FROM user_tab_partitions WHERE table_name='MEDICION_CO2'
ORDER BY partition_position;

-- SECCIÓN 7: Ver índices del esquema
SELECT i.index_name,i.table_name,i.partitioned,i.status,ic.column_name,ic.column_position
FROM user_indexes i JOIN user_ind_columns ic ON i.index_name=ic.index_name
WHERE i.table_name IN('MEDICION_CO2','VEHICULO','MANTENIMIENTO')
ORDER BY i.table_name,i.index_name,ic.column_position;

-- SECCIÓN 8: Top 10 consultas más costosas de la sesión
SELECT sql_id,executions,
       ROUND(elapsed_time/1000000,2) AS elapsed_seg,
       ROUND(elapsed_time/NULLIF(executions,0)/1000000,3) AS avg_seg,
       buffer_gets,disk_reads,
       SUBSTR(sql_text,1,80) AS sql_texto
FROM v$sql WHERE parsing_schema_name=USER AND executions>0
ORDER BY elapsed_time DESC FETCH FIRST 10 ROWS ONLY;
-- Autor: Johan Fernando Sanchez Rincon — Mayo 2026
