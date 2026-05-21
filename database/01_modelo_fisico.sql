-- ============================================================
-- PROYECTO : Sistema de Monitoreo de Emisiones CO2
--            Parque Automotor Gubernamental
-- ARCHIVO  : 01_modelo_fisico.sql  (DDL completo)
-- AUTOR    : Johan Fernando Sanchez Rincon
-- FECHA    : Mayo 2026
-- BASE     : Oracle Database 19c+
-- ============================================================

-- ============================================================
-- SECCION 1: LIMPIEZA PREVIA
-- Descomentar solo si es reinstalacion completa
-- ============================================================
/*
DROP TABLE mantenimiento     CASCADE CONSTRAINTS PURGE;
DROP TABLE normativa         CASCADE CONSTRAINTS PURGE;
DROP TABLE medicion_co2      CASCADE CONSTRAINTS PURGE;
DROP TABLE vehiculo          CASCADE CONSTRAINTS PURGE;
DROP TABLE propietario       CASCADE CONSTRAINTS PURGE;
DROP TABLE combustible       CASCADE CONSTRAINTS PURGE;
DROP TABLE tipo_vehiculo     CASCADE CONSTRAINTS PURGE;
DROP TABLE ciudad            CASCADE CONSTRAINTS PURGE;
DROP TABLE medicion_baja     CASCADE CONSTRAINTS PURGE;
DROP TABLE medicion_media    CASCADE CONSTRAINTS PURGE;
DROP TABLE medicion_alta     CASCADE CONSTRAINTS PURGE;

DROP SEQUENCE seq_ciudad;
DROP SEQUENCE seq_tipo;
DROP SEQUENCE seq_combustible;
DROP SEQUENCE seq_propietario;
DROP SEQUENCE seq_vehiculo;
DROP SEQUENCE seq_medicion;
DROP SEQUENCE seq_mantenimiento;
DROP SEQUENCE seq_normativa;
*/

-- ============================================================
-- SECCION 2: SECUENCIAS
-- Generan PKs autonomamente. NOCACHE garantiza unicidad
-- incluso ante rollbacks. NOCYCLE evita reinicio del contador.
-- ============================================================
CREATE SEQUENCE seq_ciudad        START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_tipo          START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_combustible   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_propietario   START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_vehiculo      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_medicion      START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_mantenimiento START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
CREATE SEQUENCE seq_normativa     START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;

-- ============================================================
-- SECCION 3: TABLAS PRINCIPALES
-- Orden: tablas sin FK primero, luego tablas dependientes
-- ============================================================

-- ------------------------------------------------------------
-- TABLA: CIUDAD
-- ------------------------------------------------------------
CREATE TABLE ciudad (
    id_ciudad    NUMBER         CONSTRAINT pk_ciudad PRIMARY KEY,
    nombre       VARCHAR2(100)  CONSTRAINT nn_ciudad_nombre NOT NULL,
    departamento VARCHAR2(50),
    municipio    VARCHAR2(50),
    poblacion    NUMBER         CONSTRAINT chk_ciudad_poblacion CHECK (poblacion >= 0)
);

COMMENT ON TABLE  ciudad              IS 'Ciudades donde operan los vehiculos del parque automotor gubernamental';
COMMENT ON COLUMN ciudad.id_ciudad    IS 'Clave primaria generada por seq_ciudad';
COMMENT ON COLUMN ciudad.nombre       IS 'Nombre oficial de la ciudad';
COMMENT ON COLUMN ciudad.departamento IS 'Departamento al que pertenece la ciudad';
COMMENT ON COLUMN ciudad.poblacion    IS 'Numero de habitantes (debe ser >= 0)';

-- ------------------------------------------------------------
-- TABLA: TIPO_VEHICULO
-- factor_emision_base: multiplicador teorico de emisiones g/km
-- ------------------------------------------------------------
CREATE TABLE tipo_vehiculo (
    id_tipo             NUMBER        CONSTRAINT pk_tipo_vehiculo PRIMARY KEY,
    nombre              VARCHAR2(50)  CONSTRAINT uq_tipo_nombre UNIQUE
                                      CONSTRAINT nn_tipo_nombre  NOT NULL,
    descripcion         VARCHAR2(200),
    factor_emision_base NUMBER(6,4)   CONSTRAINT chk_tipo_factor CHECK (factor_emision_base > 0)
);

COMMENT ON TABLE  tipo_vehiculo                     IS 'Categorias de vehiculos del parque automotor';
COMMENT ON COLUMN tipo_vehiculo.factor_emision_base IS 'Factor multiplicador de emision base en g/km (debe ser > 0)';

-- ------------------------------------------------------------
-- TABLA: COMBUSTIBLE
-- ------------------------------------------------------------
CREATE TABLE combustible (
    id_combustible     NUMBER        CONSTRAINT pk_combustible PRIMARY KEY,
    nombre             VARCHAR2(30)  CONSTRAINT uq_combustible_nombre UNIQUE
                                     CONSTRAINT nn_combustible_nombre  NOT NULL,
    factor_co2_teorico NUMBER(8,4)
);

COMMENT ON TABLE  combustible                    IS 'Tipos de combustible utilizados por los vehiculos';
COMMENT ON COLUMN combustible.factor_co2_teorico IS 'CO2 teorico emitido en gramos por unidad de combustible';

-- ------------------------------------------------------------
-- TABLA: PROPIETARIO
-- ------------------------------------------------------------
CREATE TABLE propietario (
    id_propietario NUMBER        CONSTRAINT pk_propietario PRIMARY KEY,
    nombre         VARCHAR2(150) CONSTRAINT nn_propietario_nombre NOT NULL,
    tipo_persona   VARCHAR2(10)  CONSTRAINT chk_propietario_tipo
                                  CHECK (tipo_persona IN ('NATURAL','JURIDICA')),
    email          VARCHAR2(100) CONSTRAINT uq_propietario_email UNIQUE
);

COMMENT ON TABLE  propietario              IS 'Propietarios de vehiculos (personas naturales o juridicas)';
COMMENT ON COLUMN propietario.tipo_persona IS 'Solo valores NATURAL o JURIDICA';

-- ------------------------------------------------------------
-- TABLA: VEHICULO
-- Entidad central del sistema.
-- ------------------------------------------------------------
CREATE TABLE vehiculo (
    id_vehiculo     NUMBER       CONSTRAINT pk_vehiculo PRIMARY KEY,
    placa           VARCHAR2(10) CONSTRAINT uq_vehiculo_placa UNIQUE
                                 CONSTRAINT nn_vehiculo_placa  NOT NULL,
    modelo          VARCHAR2(50),
    ano_fabricacion NUMBER       CONSTRAINT chk_vehiculo_ano
                                  CHECK (ano_fabricacion BETWEEN 1900
                                         AND EXTRACT(YEAR FROM SYSDATE)),
    cilindraje      NUMBER,
    id_ciudad       NUMBER       CONSTRAINT nn_vehiculo_ciudad     NOT NULL,
    id_tipo         NUMBER       CONSTRAINT nn_vehiculo_tipo        NOT NULL,
    id_combustible  NUMBER       CONSTRAINT nn_vehiculo_combustible NOT NULL,
    id_propietario  NUMBER       CONSTRAINT nn_vehiculo_propietario NOT NULL
);

COMMENT ON TABLE  vehiculo                 IS 'Vehiculos registrados en el parque automotor gubernamental';
COMMENT ON COLUMN vehiculo.placa           IS 'Placa unica del vehiculo';
COMMENT ON COLUMN vehiculo.ano_fabricacion IS 'Anio de fabricacion entre 1900 y el anio actual';
COMMENT ON COLUMN vehiculo.cilindraje      IS 'Cilindraje del motor en cc';

-- ------------------------------------------------------------
-- TABLA: MEDICION_CO2 (PARTICIONADA)
--
-- RAZON DEL PARTICIONAMIENTO:
--   Con millones de mediciones diarias, una tabla sin particionar
--   obliga al optimizador a escanear todos los bloques.
--   PARTITION BY RANGE(fecha) divide los datos fisicamente en
--   segmentos trimestrales. Consultas con WHERE fecha BETWEEN ...
--   activan "partition pruning": Oracle accede SOLO a la
--   particion relevante, reduciendo I/O hasta un 90%.
-- ------------------------------------------------------------
CREATE TABLE medicion_co2 (
    id_medicion NUMBER        CONSTRAINT pk_medicion PRIMARY KEY,
    id_vehiculo NUMBER        CONSTRAINT nn_medicion_vehiculo NOT NULL,
    fecha       DATE          CONSTRAINT nn_medicion_fecha    NOT NULL,
    co2_g_km    NUMBER(8,2)   CONSTRAINT chk_medicion_co2
                               CHECK (co2_g_km BETWEEN 0 AND 1000),
    temperatura NUMBER(5,2),
    humedad     NUMBER(5,2)   CONSTRAINT chk_medicion_humedad
                               CHECK (humedad BETWEEN 0 AND 100),
    kilometraje NUMBER
)
PARTITION BY RANGE (fecha) (
    PARTITION p_2024_q1 VALUES LESS THAN (DATE '2024-04-01'),
    PARTITION p_2024_q2 VALUES LESS THAN (DATE '2024-07-01'),
    PARTITION p_2024_q3 VALUES LESS THAN (DATE '2024-10-01'),
    PARTITION p_2024_q4 VALUES LESS THAN (DATE '2025-01-01'),
    PARTITION p_2025_q1 VALUES LESS THAN (DATE '2025-04-01'),
    PARTITION p_2025_q2 VALUES LESS THAN (DATE '2025-07-01'),
    PARTITION p_2025_q3 VALUES LESS THAN (DATE '2025-10-01'),
    PARTITION p_2025_q4 VALUES LESS THAN (DATE '2026-01-01'),
    PARTITION p_2026_q1 VALUES LESS THAN (DATE '2026-04-01'),
    PARTITION p_2026_q2 VALUES LESS THAN (DATE '2026-07-01'),
    PARTITION p_futuro  VALUES LESS THAN (MAXVALUE)
);

COMMENT ON TABLE  medicion_co2            IS 'Mediciones diarias de CO2 por vehiculo. Particionada trimestralmente para soporte de millones de registros.';
COMMENT ON COLUMN medicion_co2.co2_g_km   IS 'Emision medida en gramos de CO2 por kilometro (rango 0-1000)';
COMMENT ON COLUMN medicion_co2.temperatura IS 'Temperatura ambiente en grados Celsius al momento de la medicion';
COMMENT ON COLUMN medicion_co2.humedad     IS 'Humedad relativa en porcentaje (0-100)';
COMMENT ON COLUMN medicion_co2.kilometraje IS 'Kilometraje acumulado del vehiculo al momento de la medicion';

-- ------------------------------------------------------------
-- TABLA: MANTENIMIENTO
-- ------------------------------------------------------------
CREATE TABLE mantenimiento (
    id_mantenimiento   NUMBER        CONSTRAINT pk_mantenimiento PRIMARY KEY,
    id_vehiculo        NUMBER        CONSTRAINT nn_mant_vehiculo NOT NULL,
    fecha              DATE          CONSTRAINT nn_mant_fecha    NOT NULL,
    tipo_mantenimiento VARCHAR2(50),
    costo              NUMBER        CONSTRAINT chk_mant_costo CHECK (costo >= 0),
    taller             VARCHAR2(100),
    observaciones      VARCHAR2(500)
);

COMMENT ON TABLE  mantenimiento                   IS 'Historial de mantenimientos por vehiculo';
COMMENT ON COLUMN mantenimiento.tipo_mantenimiento IS 'Tipo: PREVENTIVO, CORRECTIVO, PREDICTIVO';
COMMENT ON COLUMN mantenimiento.costo              IS 'Costo del mantenimiento en pesos colombianos';

-- ------------------------------------------------------------
-- TABLA: NORMATIVA
-- Limites legales de CO2 por tipo de vehiculo y periodo.
-- ------------------------------------------------------------
CREATE TABLE normativa (
    id_normativa      NUMBER CONSTRAINT pk_normativa PRIMARY KEY,
    id_tipo           NUMBER CONSTRAINT nn_normativa_tipo NOT NULL,
    ano_desde         NUMBER,
    ano_hasta         NUMBER,
    co2_max_permitido NUMBER CONSTRAINT chk_normativa_co2  CHECK (co2_max_permitido > 0),
    CONSTRAINT chk_normativa_anos CHECK (ano_desde <= ano_hasta)
);

COMMENT ON TABLE  normativa                    IS 'Normativas ambientales de emision CO2 por tipo de vehiculo';
COMMENT ON COLUMN normativa.co2_max_permitido  IS 'Limite maximo de CO2 en g/km permitido por la norma';

-- ============================================================
-- SECCION 4: TABLAS AUXILIARES PARA INSERT ALL
-- ============================================================
CREATE TABLE medicion_baja  (id_medicion NUMBER, id_vehiculo NUMBER, fecha DATE,
    co2_g_km NUMBER(8,2), temperatura NUMBER(5,2), humedad NUMBER(5,2), kilometraje NUMBER);
CREATE TABLE medicion_media (id_medicion NUMBER, id_vehiculo NUMBER, fecha DATE,
    co2_g_km NUMBER(8,2), temperatura NUMBER(5,2), humedad NUMBER(5,2), kilometraje NUMBER);
CREATE TABLE medicion_alta  (id_medicion NUMBER, id_vehiculo NUMBER, fecha DATE,
    co2_g_km NUMBER(8,2), temperatura NUMBER(5,2), humedad NUMBER(5,2), kilometraje NUMBER);

COMMENT ON TABLE medicion_baja  IS 'Mediciones con CO2 < 100 g/km (nivel bajo) - Johan Fernando Sanchez Rincon';
COMMENT ON TABLE medicion_media IS 'Mediciones con CO2 entre 100 y 200 g/km (nivel medio)';
COMMENT ON TABLE medicion_alta  IS 'Mediciones con CO2 > 200 g/km (nivel critico)';

-- ============================================================
-- SECCION 5: CLAVES FORANEAS
-- ============================================================
ALTER TABLE vehiculo ADD CONSTRAINT fk_vehiculo_ciudad
    FOREIGN KEY (id_ciudad)      REFERENCES ciudad(id_ciudad);
ALTER TABLE vehiculo ADD CONSTRAINT fk_vehiculo_tipo
    FOREIGN KEY (id_tipo)        REFERENCES tipo_vehiculo(id_tipo);
ALTER TABLE vehiculo ADD CONSTRAINT fk_vehiculo_combustible
    FOREIGN KEY (id_combustible) REFERENCES combustible(id_combustible);
ALTER TABLE vehiculo ADD CONSTRAINT fk_vehiculo_propietario
    FOREIGN KEY (id_propietario) REFERENCES propietario(id_propietario);
ALTER TABLE medicion_co2 ADD CONSTRAINT fk_medicion_vehiculo
    FOREIGN KEY (id_vehiculo)    REFERENCES vehiculo(id_vehiculo);
ALTER TABLE mantenimiento ADD CONSTRAINT fk_mantenimiento_vehiculo
    FOREIGN KEY (id_vehiculo)    REFERENCES vehiculo(id_vehiculo);
ALTER TABLE normativa ADD CONSTRAINT fk_normativa_tipo
    FOREIGN KEY (id_tipo)        REFERENCES tipo_vehiculo(id_tipo);

-- ============================================================
-- SECCION 6: INDICES ESTRATEGICOS
--
-- JUSTIFICACION TECNICA:
-- Los indices aceleran SELECTs a costa de I/O en INSERT/UPDATE.
-- Se indexan columnas usadas en JOINs, WHERE y ORDER BY frecuentes.
-- Los indices compuestos sirven cuando ambas columnas aparecen
-- juntas en el predicado WHERE de las consultas analiticas.
-- ============================================================

-- Vehiculos por ciudad (JOIN ciudad-vehiculo)
CREATE INDEX idx_vehiculo_ciudad
    ON vehiculo (id_ciudad);

-- Vehiculos por tipo (JOIN con normativa)
CREATE INDEX idx_vehiculo_tipo
    ON vehiculo (id_tipo);

-- Mediciones por vehiculo (LOCAL = un indice por particion)
CREATE INDEX idx_medicion_vehiculo
    ON medicion_co2 (id_vehiculo) LOCAL;

-- Mediciones por fecha (filtros por rango, partition pruning)
CREATE INDEX idx_medicion_fecha
    ON medicion_co2 (fecha) LOCAL;

-- Indice compuesto vehiculo+fecha: mas selectivo que los simples.
-- Oracle lo usa cuando ambas columnas estan en el WHERE.
-- Cubre la consulta "mediciones de vehiculo X entre fecha A y B".
CREATE INDEX idx_medicion_vehiculo_fecha
    ON medicion_co2 (id_vehiculo, fecha) LOCAL;

-- Mantenimiento por vehiculo+fecha: analisis pre/post mantenimiento
CREATE INDEX idx_mantenimiento_vehiculo_fecha
    ON mantenimiento (id_vehiculo, fecha);

-- Busqueda directa por placa (API GET /vehicles/{placa})
CREATE INDEX idx_vehiculo_placa
    ON vehiculo (placa);

-- Indice compuesto para ranking de contaminantes
CREATE INDEX idx_medicion_co2_ranking
    ON medicion_co2 (co2_g_km DESC, fecha DESC) LOCAL;

-- Indice basado en funcion (FBI): permite INDEX SCAN cuando
-- se usa EXTRACT(YEAR/MONTH FROM fecha) en el WHERE.
CREATE INDEX idx_medicion_anio_mes
    ON medicion_co2 (EXTRACT(YEAR FROM fecha), EXTRACT(MONTH FROM fecha)) LOCAL;

-- ============================================================
-- FIN: 01_modelo_fisico.sql
-- Autor: Johan Fernando Sanchez Rincon
-- ============================================================
