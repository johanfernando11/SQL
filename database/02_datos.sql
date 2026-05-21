-- ============================================================
-- PROYECTO:  Sistema de Monitoreo de Emisiones CO2
-- ARCHIVO:   02_datos.sql
-- AUTOR:     Johan Fernando Sanchez Rincon
-- FECHA:     Mayo 2026
-- ============================================================

-- CIUDADES
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Bogotá',       'Cundinamarca',    'Bogotá D.C.',   8380000);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Medellín',     'Antioquia',       'Medellín',      2570000);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Cali',         'Valle del Cauca', 'Cali',          2280000);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Barranquilla', 'Atlántico',       'Barranquilla',  1280000);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Cartagena',    'Bolívar',         'Cartagena',     1080000);
INSERT INTO ciudad VALUES (seq_ciudad.NEXTVAL, 'Bucaramanga',  'Santander',       'Bucaramanga',    590000);

-- TIPOS DE VEHÍCULO
INSERT INTO tipo_vehiculo VALUES (seq_tipo.NEXTVAL, 'Automóvil',   'Vehículo liviano particular',         1.2000);
INSERT INTO tipo_vehiculo VALUES (seq_tipo.NEXTVAL, 'Camioneta',   'Vehículo utilitario liviano',         1.5000);
INSERT INTO tipo_vehiculo VALUES (seq_tipo.NEXTVAL, 'Bus',         'Transporte público urbano',           3.8000);
INSERT INTO tipo_vehiculo VALUES (seq_tipo.NEXTVAL, 'Camión',      'Vehículo de carga pesada',            5.2000);
INSERT INTO tipo_vehiculo VALUES (seq_tipo.NEXTVAL, 'Motocicleta', 'Vehículo de dos ruedas motorizado',   0.8000);

-- COMBUSTIBLES (factor_co2_teorico en g/litro — IPCC 2023)
INSERT INTO combustible VALUES (seq_combustible.NEXTVAL, 'Gasolina',  2392.0000);
INSERT INTO combustible VALUES (seq_combustible.NEXTVAL, 'Diésel',    2640.0000);
INSERT INTO combustible VALUES (seq_combustible.NEXTVAL, 'GNV',       1940.0000);
INSERT INTO combustible VALUES (seq_combustible.NEXTVAL, 'Eléctrico',    0.0000);
INSERT INTO combustible VALUES (seq_combustible.NEXTVAL, 'Híbrido',   1200.0000);

-- PROPIETARIOS
INSERT INTO propietario VALUES (seq_propietario.NEXTVAL, 'Alcaldía de Bogotá',           'JURIDICA', 'flota@bogota.gov.co');
INSERT INTO propietario VALUES (seq_propietario.NEXTVAL, 'Gobernación de Antioquia',     'JURIDICA', 'flota@antioquia.gov.co');
INSERT INTO propietario VALUES (seq_propietario.NEXTVAL, 'Ministerio de Transporte',     'JURIDICA', 'flota@mintransporte.gov.co');
INSERT INTO propietario VALUES (seq_propietario.NEXTVAL, 'Johan Fernando Sanchez Rincon','NATURAL',  'jfsanchez@gmail.com');
INSERT INTO propietario VALUES (seq_propietario.NEXTVAL, 'Diana Patricia Torres López',  'NATURAL',  'dtorres@yahoo.com');

-- VEHÍCULOS (id_ciudad, id_tipo, id_combustible, id_propietario)
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'BKL-312', 'Renault Logan',     2018, 1400, 1, 1, 1, 1);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'MED-087', 'Toyota Hilux',      2019, 2800, 2, 2, 2, 2);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'CLO-554', 'Hino Bus 300',      2015, 5800, 3, 3, 2, 3);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'BAQ-221', 'Chevrolet NPR',     2016, 5200, 4, 4, 2, 1);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'CTG-118', 'Honda CB 150',      2021,  150, 5, 5, 1, 4);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'BUC-443', 'Volkswagen Passat', 2020, 1800, 6, 1, 5, 5);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'BKL-799', 'Ford F-150',        2017, 3500, 1, 2, 1, 3);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'MED-362', 'Nissan Leaf',       2022,    0, 2, 1, 4, 2);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'CLO-680', 'Kia Sorento',       2019, 2000, 3, 2, 5, 1);
INSERT INTO vehiculo VALUES (seq_vehiculo.NEXTVAL, 'BAQ-905', 'Hyundai Ioniq',     2023,    0, 4, 1, 4, 3);

-- NORMATIVAS (Resolución 910 de 2008 — Colombia)
INSERT INTO normativa VALUES (seq_normativa.NEXTVAL, 1, 2000, 2026, 120);
INSERT INTO normativa VALUES (seq_normativa.NEXTVAL, 2, 2000, 2026, 160);
INSERT INTO normativa VALUES (seq_normativa.NEXTVAL, 3, 2000, 2026, 300);
INSERT INTO normativa VALUES (seq_normativa.NEXTVAL, 4, 2000, 2026, 450);
INSERT INTO normativa VALUES (seq_normativa.NEXTVAL, 5, 2000, 2026,  90);

-- MEDICIONES CO2 (100 registros — 10 por vehículo)
-- Vehículo 1 — BKL-312 Automóvil Gasolina
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2025-11-05',115.5,18.2,65.0,45200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2025-11-15',118.3,19.1,63.5,45600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2025-12-01',121.7,16.5,70.0,46100);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2025-12-20',124.2,17.0,68.0,46800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-01-10',119.8,20.5,60.0,47200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-01-25',116.4,21.0,58.0,47700);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-02-08',113.2,22.0,55.0,48100);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-02-20',111.5,23.5,52.0,48500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-03-05',108.9,24.0,50.0,48900);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,1,DATE '2026-03-15',105.6,25.0,48.0,49300);
-- Vehículo 2 — MED-087 Camioneta Diésel
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2025-11-03',185.0,17.0,72.0,82500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2025-11-18',188.5,18.5,70.0,83100);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2025-12-02',192.3,15.0,75.0,83800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2025-12-18',196.8,16.0,73.0,84500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-01-07',201.5,19.0,68.0,85200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-01-22',205.2,20.0,65.0,85900);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-02-05',198.7,21.5,62.0,86600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-02-19',195.1,22.0,60.0,87300);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-03-04',190.4,23.0,57.0,88000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,2,DATE '2026-03-19',186.9,24.5,55.0,88700);
-- Vehículo 3 — CLO-554 Bus Diésel
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2025-11-01',340.0,20.0,68.0,215000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2025-11-16',355.2,21.0,66.0,216500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2025-12-01',368.7,19.0,71.0,218000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2025-12-16',372.5,18.0,73.0,219500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-01-05',380.1,22.0,65.0,221000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-01-20',385.8,23.0,63.0,222500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-02-04',390.3,24.0,61.0,224000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-02-18',345.6,22.5,67.0,225500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-03-03',320.4,21.0,70.0,227000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,3,DATE '2026-03-18',298.5,20.0,72.0,228500);
-- Vehículo 4 — BAQ-221 Camión Diésel
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2025-11-04',415.0,28.5,75.0,350000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2025-11-19',428.3,29.0,73.0,352000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2025-12-03',435.7,27.5,76.0,354000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2025-12-19',442.1,28.0,74.0,356000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-01-08',455.5,30.0,70.0,358000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-01-23',460.2,31.0,68.0,360000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-02-06',448.8,29.5,71.0,362000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-02-21',438.4,28.5,73.0,364000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-03-07',425.9,27.5,75.0,366000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,4,DATE '2026-03-22',412.3,26.5,77.0,368000);
-- Vehículo 5 — CTG-118 Motocicleta Gasolina
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2025-11-06', 72.5,29.0,80.0,18500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2025-11-21', 74.3,30.0,78.0,18750);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2025-12-04', 75.8,28.5,81.0,19000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2025-12-22', 77.2,29.5,79.0,19250);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-01-09', 78.9,31.0,76.0,19500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-01-24', 80.1,32.0,74.0,19750);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-02-07', 81.5,30.5,77.0,20000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-02-22', 79.8,29.5,79.0,20250);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-03-08', 77.4,28.5,81.0,20500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,5,DATE '2026-03-23', 75.1,27.5,83.0,20750);
-- Vehículo 6 — BUC-443 VW Passat Híbrido
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2025-11-07', 88.0,16.0,60.0,35200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2025-11-22', 86.5,17.0,58.0,35600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2025-12-05', 85.2,15.5,62.0,36000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2025-12-23', 83.7,16.0,61.0,36400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-01-11', 82.4,18.0,57.0,36800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-01-26', 80.9,19.0,55.0,37200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-02-09', 79.1,20.0,53.0,37600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-02-23', 77.5,21.0,51.0,38000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-03-09', 75.8,22.5,50.0,38400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,6,DATE '2026-03-24', 74.2,23.0,49.0,38800);
-- Vehículo 7 — BKL-799 Ford F-150 (mejora post-mantenimiento 15-ene-2026)
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2025-11-08',210.5,18.0,64.0,125000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2025-11-23',215.8,19.0,62.0,125800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2025-12-06',220.1,17.5,65.0,126600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2025-12-24',225.4,18.0,63.0,127400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-01-12',230.7,20.0,60.0,128200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-01-27',178.3,21.0,58.0,129000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-02-10',175.9,22.0,55.0,129800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-02-24',172.4,23.0,53.0,130600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-03-10',169.8,24.0,51.0,131400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,7,DATE '2026-03-25',167.2,25.0,50.0,132200);
-- Vehículo 8 — MED-362 Nissan Leaf Eléctrico
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2025-11-09',  0.0,21.0,55.0,12000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2025-11-24',  0.0,22.0,53.0,12350);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2025-12-07',  0.0,20.5,56.0,12700);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2025-12-25',  0.0,21.0,54.0,13050);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-01-13',  0.0,23.0,51.0,13400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-01-28',  0.0,24.0,49.0,13750);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-02-11',  0.0,25.0,47.0,14100);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-02-25',  0.0,26.0,45.0,14450);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-03-11',  0.0,27.0,43.0,14800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,8,DATE '2026-03-26',  0.0,28.0,42.0,15150);
-- Vehículo 9 — CLO-680 Kia Sorento Híbrido
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2025-11-10',130.5,20.0,70.0,55000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2025-11-25',133.2,21.0,68.0,55500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2025-12-08',135.8,19.5,71.0,56000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2025-12-26',138.4,20.0,69.0,56500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-01-14',141.0,22.0,66.0,57000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-01-29',143.6,23.0,64.0,57500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-02-12',146.2,24.0,62.0,58000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-02-26',148.8,25.0,60.0,58500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-03-12',151.4,26.0,58.0,59000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,9,DATE '2026-03-27',153.0,27.0,57.0,59500);
-- Vehículo 10 — BAQ-905 Hyundai Ioniq Eléctrico
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2025-11-11', 0.0,27.0,80.0, 5000);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2025-11-26', 0.0,28.0,78.0, 5300);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2025-12-09', 0.0,26.5,81.0, 5600);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2025-12-27', 0.0,27.0,79.0, 5900);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-01-15', 0.0,29.0,76.0, 6200);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-01-30', 0.0,30.0,74.0, 6500);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-02-13', 0.0,31.0,72.0, 6800);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-02-27', 0.0,32.0,70.0, 7100);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-03-13', 0.0,33.0,68.0, 7400);
INSERT INTO medicion_co2 VALUES (seq_medicion.NEXTVAL,10,DATE '2026-03-28', 0.0,34.0,67.0, 7700);

-- MANTENIMIENTOS (15 registros)
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 1,DATE '2025-10-15','PREVENTIVO',  350000,'Tecnicentro Norte',   'Cambio de aceite y filtros');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 2,DATE '2025-09-20','PREVENTIVO',  580000,'Servicio Toyota',     'Revisión general 80.000 km');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 3,DATE '2025-08-10','CORRECTIVO', 1250000,'Taller Hino Oficial', 'Reparación sistema de inyección');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 4,DATE '2025-10-05','PREVENTIVO',  820000,'Chevrolet Service',   'Cambio de frenos y aceite');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 5,DATE '2025-11-30','PREVENTIVO',   95000,'Honda Center',        'Revisión general');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 6,DATE '2025-10-28','PREVENTIVO',  420000,'VW Service',          'Mantenimiento 35.000 km');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 7,DATE '2026-01-15','CORRECTIVO', 1850000,'Ford Autorizado',     'Limpieza inyectores y filtro DPF');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 8,DATE '2025-12-15','PREVENTIVO',  180000,'Nissan EV Center',    'Revisión sistema eléctrico');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 9,DATE '2025-09-10','PREVENTIVO',  490000,'Kia Service',         'Revisión sistema híbrido');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL,10,DATE '2025-11-20','PREVENTIVO',  220000,'Hyundai EV',          'Revisión batería y software');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 1,DATE '2026-02-01','PREDICTIVO',  280000,'Tecnicentro Norte',   'Diagnóstico OBD2 preventivo');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 3,DATE '2026-01-10','PREVENTIVO',  650000,'Taller Hino Oficial', 'Cambio filtro de partículas');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 4,DATE '2026-02-15','CORRECTIVO', 1100000,'Repuestos Pesados SA','Reparación turbocompresor');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 2,DATE '2026-01-18','PREVENTIVO',  430000,'Servicio Toyota',     'Cambio correa de distribución');
INSERT INTO mantenimiento VALUES (seq_mantenimiento.NEXTVAL, 7,DATE '2025-10-20','PREVENTIVO',  560000,'Ford Autorizado',     'Revisión general previa');

-- MERGE: upsert medición del día para vehículo 1
MERGE INTO medicion_co2 tgt
USING (SELECT 1 AS id_vehiculo, TRUNC(SYSDATE) AS fecha,
              112.5 AS co2_g_km, 22.3 AS temperatura,
              61.0 AS humedad, 49500 AS kilometraje FROM dual) src
ON (tgt.id_vehiculo = src.id_vehiculo AND tgt.fecha = src.fecha)
WHEN MATCHED THEN
    UPDATE SET tgt.co2_g_km=src.co2_g_km, tgt.temperatura=src.temperatura,
               tgt.humedad=src.humedad, tgt.kilometraje=src.kilometraje
WHEN NOT MATCHED THEN
    INSERT (id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
    VALUES (seq_medicion.NEXTVAL,src.id_vehiculo,src.fecha,
            src.co2_g_km,src.temperatura,src.humedad,src.kilometraje);

-- INSERT ALL multicondicional: clasifica mediciones por nivel CO2
INSERT ALL
    WHEN co2_g_km < 100 THEN
        INTO medicion_baja(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
        VALUES(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
    WHEN co2_g_km BETWEEN 100 AND 200 THEN
        INTO medicion_media(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
        VALUES(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
    WHEN co2_g_km > 200 THEN
        INTO medicion_alta(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
        VALUES(id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje)
SELECT id_medicion,id_vehiculo,fecha,co2_g_km,temperatura,humedad,kilometraje
FROM medicion_co2;

COMMIT;
-- Autor: Johan Fernando Sanchez Rincon — Mayo 2026
