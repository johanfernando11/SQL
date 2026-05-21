[README.md](https://github.com/user-attachments/files/28080612/README.md)
# Sistema de Monitoreo de Emisiones CO2
## Parque Automotor Gubernamental

**Autor:** Johan Fernando Sanchez Rincon
**Fecha:** Mayo 2026

[![Oracle 19c](https://img.shields.io/badge/Oracle-19c%2B-red?logo=oracle)](https://oracle.com)
[![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.4-brightgreen?logo=springboot)](https://spring.io)
[![Java](https://img.shields.io/badge/Java-17-blue?logo=openjdk)](https://openjdk.org)
[![Maven](https://img.shields.io/badge/Maven-3.9-orange?logo=apachemaven)](https://maven.apache.org)

---

## Descripcion del Proyecto

Sistema de base de datos relacional desarrollado para una entidad gubernamental colombiana con el objetivo de controlar, monitorear y analizar las emisiones de CO2 del parque automotor oficial.

**Capacidades del sistema:**
- Registro de mediciones diarias de CO2 (g/km) por vehiculo
- Deteccion de vehiculos fuera de normativa ambiental vigente
- Ranking de contaminacion con funciones analiticas Oracle
- Evolucion mensual con tendencias usando LAG y promedio movil
- Analisis de impacto de mantenimientos en las emisiones
- Soporte para millones de registros con respuesta analitica < 2 segundos

---

## Tecnologias

| Capa | Tecnologia | Version |
|------|-----------|---------|
| Base de datos | Oracle Database | 19c+ |
| Lenguaje BD | SQL / PL-SQL | Oracle dialect |
| Backend | Spring Boot | 3.2.4 |
| Lenguaje | Java | 17 |
| Build | Maven | 3.9+ |
| ORM | Spring Data JPA / Hibernate | 6.x |
| API Docs | SpringDoc OpenAPI (Swagger) | 2.3.0 |

---

## Estructura del Proyecto

```
Proyecto_CO2/
│
├── database/
│   ├── 01_modelo_fisico.sql     DDL: tablas, indices, secuencias, particionamiento
│   ├── 02_datos.sql             DML: datos de prueba, MERGE, INSERT ALL
│   ├── 03_consultas.sql         5 basicas + 4 analiticas (RANK, LAG, CTEs)
│   └── 04_tuning.sql            EXPLAIN PLAN, estadisticas, hints, FBI
│
├── diagrams/
│   ├── diagrama_er.png          Diagrama Entidad-Relacion
│   └── diagrama_clases.png      Diagrama de clases Spring Boot
│
├── docs/
│   └── informe_tecnico.md       Informe tecnico completo (exportar a PDF)
│
├── backend/
│   └── src/main/java/com/co2monitor/
│       ├── Co2MonitorApplication.java
│       ├── controller/VehiculoController.java
│       ├── service/VehiculoService.java
│       ├── repository/VehiculoRepository.java
│       ├── entity/                     Vehiculo, MedicionCo2, Ciudad...
│       └── dto/                        VehiculoDTO, NuevaMedicionDTO...
│
├── pom.xml
├── .gitignore
└── README.md
```

---

## Como Ejecutar — Oracle Database

### Prerrequisitos
- Oracle Database 19c+ o Oracle XE 21c
- SQLPlus, SQL Developer o similar
- Usuario con permisos CREATE TABLE, CREATE SEQUENCE, CREATE INDEX

### Paso 1: Conectarse
```bash
sqlplus CO2_MONITOR/tu_password@localhost:1521/XEPDB1
```

### Paso 2: Ejecutar scripts en orden estricto
```sql
@database/01_modelo_fisico.sql
@database/02_datos.sql
@database/03_consultas.sql
@database/04_tuning.sql
```

### Verificacion rapida
```sql
SELECT table_name, num_rows
FROM user_tables
WHERE table_name IN ('VEHICULO','MEDICION_CO2','MANTENIMIENTO')
ORDER BY table_name;
```

---

## Como Ejecutar — Spring Boot

### Prerrequisitos
- Java 17+
- Maven 3.9+

### Configurar conexion en application.properties
```properties
spring.datasource.url=jdbc:oracle:thin:@//localhost:1521/XEPDB1
spring.datasource.username=CO2_MONITOR
spring.datasource.password=tu_password
```

### Compilar y ejecutar
```bash
mvn clean package
java -jar backend/target/co2-monitor-api-1.0.0.jar
```

---

## Como Probar las APIs

Swagger UI: **http://localhost:8080/api/v1/swagger-ui.html**

| Metodo | URL | Descripcion |
|--------|-----|-------------|
| GET | `/api/v1/vehicles` | Lista todos los vehiculos |
| GET | `/api/v1/vehicles/{placa}` | Vehiculo por placa |
| GET | `/api/v1/measurements?vehiculoId=1` | Mediciones de un vehiculo |
| POST | `/api/v1/measurements` | Registrar nueva medicion |
| GET | `/api/v1/reports/top-polluters` | Top 5 mas contaminantes |
| GET | `/api/v1/reports/monthly-evolution` | Evolucion mensual con LAG |

### Ejemplo POST /measurements
```bash
curl -X POST http://localhost:8080/api/v1/measurements \
  -H "Content-Type: application/json" \
  -d '{
    "idVehiculo": 1,
    "fecha": "2026-05-20",
    "co2GKm": 118.5,
    "temperatura": 22.0,
    "humedad": 60.0,
    "kilometraje": 50000
  }'
```

---

## Tuning y Optimizacion

### Partition Pruning
La tabla MEDICION_CO2 esta particionada trimestralmente. Con un filtro por fecha Oracle accede solo a la particion relevante, reduciendo I/O hasta en un 92%.

```sql
-- Solo accede a la particion p_2026_q1
WHERE fecha BETWEEN DATE '2026-01-01' AND DATE '2026-03-31'
```

### Anti-patron evitado
```sql
-- LENTO: funcion sobre columna indexada fuerza FULL TABLE SCAN
WHERE TO_CHAR(fecha, 'YYYY-MM') = '2026-03'

-- RAPIDO: rango literal permite INDEX RANGE SCAN
WHERE fecha BETWEEN DATE '2026-03-01' AND DATE '2026-03-31'
```

### Indices compuestos
El indice `idx_medicion_vehiculo_fecha(id_vehiculo, fecha)` cubre las consultas mas frecuentes con un solo INDEX RANGE SCAN en lugar de dos operaciones separadas.

### Indice basado en funcion (FBI)
`idx_medicion_anio_mes` permite que `EXTRACT(YEAR/MONTH FROM fecha)` use el indice directamente.

---

## Modelo de Datos

| Tabla | Descripcion |
|-------|-------------|
| CIUDAD | Ciudades del parque |
| TIPO_VEHICULO | Categorias vehiculares |
| COMBUSTIBLE | Tipos de combustible |
| PROPIETARIO | Entidades gubernamentales |
| VEHICULO | Flota activa |
| MEDICION_CO2 | Mediciones diarias (particionada) |
| MANTENIMIENTO | Historial de mantenimientos |
| NORMATIVA | Limites legales CO2 |

---

**Autor:** Johan Fernando Sanchez Rincon — Mayo 2026
