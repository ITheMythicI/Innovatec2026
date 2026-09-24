# Base de Datos PostgreSQL + PostGIS (Docker)

Este directorio contiene la configuración de Docker Compose para la base de datos central de Innovatec 2026.

## Características

* **Motor:** PostgreSQL 16
* **Extensión espacial:** PostGIS 3.4 (imagen oficial `postgis/postgis:16-3.4`)
* **Persistencia:** Volumen Docker gestionado (`innovatec_pgdata`)
* **Healthcheck:** Monitoreo con `pg_isready`

## Requisitos

* Docker Engine (20.10+) o Docker Desktop
* Docker Compose v2+ (`docker compose`)

## Uso

### 1. Iniciar la base de datos en segundo plano

Desde la raíz del proyecto o desde este directorio:

```bash
# Desde la raíz del repositorio:
docker compose -f database/docker-compose.yml up -d

# O entrando a este directorio:
cd database
docker compose up -d
```

### 2. Verificar el estado del contenedor

```bash
docker compose -f database/docker-compose.yml ps
```

Debe mostrar el contenedor `innovatec-postgis` con estado `Up (healthy)`.

### 3. Verificar la extensión PostGIS

Para confirmar que PostGIS está activo y disponible:

```bash
docker exec -it innovatec-postgis psql -U innovatec_user -d innovatec_db -c "SELECT PostGIS_Version();"
```

### 4. Conexión desde el Backend

La cadena de conexión de desarrollo por defecto es:

```env
DATABASE_URL="postgresql://innovatec_user:innovatec_password@localhost:5432/innovatec_db?schema=public"
```

### 5. Detener la base de datos

```bash
docker compose -f database/docker-compose.yml down
```

### 6. Reiniciar / Borrar volumen de datos (Reset completo)

> **Advertencia:** Esto eliminará todos los datos locales persistidos en la base de datos.

```bash
docker compose -f database/docker-compose.yml down -v
```
