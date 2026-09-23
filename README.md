# Innovatec 2026 - Sistema de Gestión en Situaciones de Emergencia y Desastres

Sistema multiplataforma diseñado para responder ante situaciones de desastre natural y emergencia humanitaria, garantizando funcionamiento continuo bajo conectividad nula o intermitente mediante arquitectura **Offline-First**, sincronización idempotente y canales de comunicación alternativos (BLE y SMS).

---

## 1. Arquitectura General del Sistema

```text
┌─────────────────────────┐
│      Flutter Mobile     │  ← Aplicación cliente móvil
│                         │    SQLite local / Operación sin internet
│ UI / GPS / BLE / SMS    │    Encolado de eventos en sync_queue
└────────────┬────────────┘
             │ HTTPS (REST)
             ▼
┌─────────────────────────┐
│      NestJS Backend     │  ← Monolito modular
│                         │    REST API / RBAC / Validación
│ REST API / Auth / Sync  │    Idempotencia de eventos / Swagger
└────────────┬────────────┘
             │ Prisma ORM
             ▼
┌─────────────────────────┐
│  PostgreSQL + PostGIS   │  ← Base de datos centralizada
│                         │    Consultas geoespaciales / Persistencia
│  Docker Containerizado  │    Albergues, zonas de riesgo y personas
└─────────────────────────┘
```

Para una explicación exhaustiva de las decisiones técnicas (por qué SQLite, por qué PostGIS, por qué no conectar Flutter directo a la base de datos, idempotencia de eventos, etc.), consulta la documentación completa en:
👉 [**`docs/architecture.md`**](docs/architecture.md)

---

## 2. Requisitos Previos

Asegúrate de contar con las siguientes herramientas instaladas en tu entorno de desarrollo:

* **Docker Engine** (20.10+) y **Docker Compose v2+** (`docker compose`)
* **Node.js** (v20+ o v22+ / LTS) y **npm** (v10+)
* **Flutter SDK** (3.24+ / 3.47+) y **Dart SDK** (3.5+)
* Emulador Android, simulador iOS o dispositivo físico configurado.

---

## 3. Estructura del Repositorio

```text
Innovatec2026/
├── mobile/                   # Proyecto Flutter
│   ├── lib/
│   │   ├── core/             # Configuración, constantes, red, errores y utilidades
│   │   ├── database/         # SQLite local (tablas, DAO, app_database)
│   │   ├── sync/             # Motor de sincronización offline-first
│   │   ├── features/         # Módulos: auth, people, families, emergencies, shelters, etc.
│   │   └── main.dart         # Punto de entrada de la app
│   ├── test/                 # Pruebas unitarias y de widgets
│   └── pubspec.yaml          # Dependencias y configuración de Flutter
│
├── backend/                  # Backend en NestJS (Modular Monolith)
│   ├── src/
│   │   ├── auth/             # Módulo de autenticación y JWT
│   │   ├── users/            # Módulo de usuarios y control de acceso
│   │   ├── people/           # Padrón de personas damnificadas y rescatistas
│   │   ├── families/         # Familias y personas desaparecidas
│   │   ├── emergencies/      # Emergencias, severidad y eventos asociados
│   │   ├── shelters/         # Albergues, servicios y estancias
│   │   ├── reports/          # Reportes ciudadanos y de situación
│   │   ├── sync/             # Ingesta idempotente de eventos de sincronización
│   │   ├── devices/          # Registro de dispositivos móviles y llaves
│   │   ├── health/           # Endpoint de salud y diagnóstico de BD (/api/health)
│   │   ├── prisma/           # Servicio y conexión de base de datos
│   │   ├── common/           # Decoradores RBAC, filtros globales y guards
│   │   ├── app.module.ts     # Módulo raíz de NestJS
│   │   └── main.ts           # Configuración de Swagger (/api/docs), CORS y pipes
│   ├── prisma/
│   │   ├── schema.prisma     # Esquema relacional central
│   │   └── migrations/       # Historial de migraciones SQL aplicadas
│   ├── package.json
│   └── tsconfig.json
│
├── database/                 # Infraestructura de base de datos local
│   ├── docker-compose.yml    # PostgreSQL 16 con extensión PostGIS 3.4
│   └── README.md             # Guía de operación del contenedor
│
├── docs/                     # Documentación técnica
│   └── architecture.md       # Justificación arquitectónica y estándares
│
├── .env.example              # Plantilla de variables de entorno globales
├── .gitignore                # Reglas de exclusión de Git
└── README.md                 # Guía principal del proyecto
```

---

## 4. Guía de Inicio Rápido (Paso a Paso)

### Paso 1: Configurar Variables de Entorno

Copia el archivo de ejemplo para preparar el entorno del backend:

```bash
# Copiar plantilla en la raíz y en el directorio del backend
cp .env.example .env
cp .env.example backend/.env
```

*(Si el puerto 3000 de tu máquina anfitrión ya está ocupado, el backend está preconfigurado en el puerto `3001`).*

---

### Paso 2: Iniciar PostgreSQL + PostGIS con Docker

Levanta el contenedor de la base de datos en segundo plano:

```bash
docker compose -f database/docker-compose.yml up -d
```

Verifica que el contenedor esté corriendo y saludable:

```bash
docker compose -f database/docker-compose.yml ps
```

---

### Paso 3: Configurar y Ejecutar el Backend

1. Entra a la carpeta `backend` e instala las dependencias:

   ```bash
   cd backend
   npm install
   ```

2. Genera el cliente de Prisma y aplica las migraciones a PostgreSQL:

   ```bash
   npx prisma generate
   npx prisma migrate dev
   ```

3. Inicia el servidor en modo desarrollo con recarga en caliente:

   ```bash
   npm run start:dev
   ```

4. Abre tu navegador web y comprueba los servicios:
   * **Swagger / Documentación interactiva de la API:** [http://localhost:3001/api/docs](http://localhost:3001/api/docs)
   * **Endpoint de Salud (Verifica BD activa):** [http://localhost:3001/api/health](http://localhost:3001/api/health)

---

### Paso 4: Ejecutar la Aplicación Móvil (Flutter)

En una nueva terminal, desplázate a la carpeta `mobile`:

```bash
cd mobile

# Descargar paquetes de Flutter
flutter pub get

# Ejecutar análisis estático de código
flutter analyze

# Ejecutar las pruebas unitarias
flutter test

# Iniciar la aplicación
flutter run
```

> **Nota para Emulador Android:** El emulador de Android accede al localhost de tu computadora anfitriona a través de la dirección IP `http://10.0.2.2:3001/api`, la cual ya se encuentra preconfigurada en `mobile/lib/core/config/app_config.dart`.

---

## 5. Convenciones y Estándares del Proyecto

Para facilitar el trabajo concurrente de 4 desarrolladores sin conflictos de fusión ni de integridad de datos:

1. **Identificadores (UUID):**
   * Todas las entidades primarias utilizan identificadores **UUID v4** en formato string.
   * **Prohibido** usar autoincrementales numéricos para datos sincronizables, ya que generarían colisiones cuando múltiples dispositivos operen sin conexión.
2. **Marcas de Tiempo (UTC):**
   * Toda fecha y hora almacenada o transmitida debe ser estrictamente en formato ISO 8601 UTC (`DateTime.now().toUtc().toIso8601String()`).
3. **Idempotencia:**
   * Cualquier evento de mutación distribuido generado en el móvil incluye un `event_id` (UUID). El endpoint `POST /api/sync/events` garantiza que un mismo evento no se duplique aun cuando se reciba por múltiples vías (HTTPS, BLE, SMS).
4. **Seguridad de Secretos:**
   * Los archivos `.env` reales **nunca** deben agregarse al control de versiones. Usa siempre `.env.example` para documentar nuevas variables.
5. **No Conexión Directa a la BD desde Móvil:**
   * Flutter solo se comunica con la API REST de NestJS mediante HTTPS.

---

## 6. Distribución de Trabajo para el Equipo

La arquitectura modular permite que cada integrante del equipo asuma la implementación de un frente sin interferir con los demás:

| Desarrollador | Módulos Asignados | Tareas Iniciales |
| :--- | :--- | :--- |
| **Dev 1** | **Identidad & Seguridad** | Implementar registro, login con hash bcrypt, emisión y validación de JWT, guards RBAC en `backend/src/auth` y persistencia de sesión segura en `mobile/lib/features/auth`. |
| **Dev 2** | **Personas, Familias & Reunificación** | Implementar lógica de padrón de personas, relaciones de parentesco, reportes de personas desaparecidas en `backend/src/people` y pantallas de captura rápida en `mobile/lib/features/people`. |
| **Dev 3** | **Emergencias, Albergues & Reportes** | Implementar endpoints CRUD y filtros de estado para incidentes y capacidad de albergues en `backend/src/emergencies` y `backend/src/shelters`, y vistas en `mobile/lib/features/shelters`. |
| **Dev 4** | **Geolocalización & Sincronización** | Implementar consultas espaciales con PostGIS en `backend/src/sync`, renderizado del mapa con marcadores en `mobile/lib/features/map` y lógica de procesamiento de la cola `sync_queue`. |
