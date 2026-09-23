# Arquitectura del Sistema - Innovatec 2026

## 1. Visión General y Flujo de Datos

El sistema **Innovatec 2026** está diseñado para operar en condiciones extremas de desastres naturales y situaciones de emergencia humanitaria, donde la infraestructura de telecomunicaciones tradicional suele colapsar de forma total o intermitente.

Por esta razón, la arquitectura del sistema se rige bajo el principio **Offline-First**, compuesto por un flujo de cinco capas jerárquicas:

```text
┌──────────────────────────────────────────────┐
│                Flutter Mobile                │
│       UI / GPS / BLE / SMS / Local Cache     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                 SQLite Local                 │
│      Almacenamiento offline y sync_queue     │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│                 Sync Manager                 │
│     Encolado, reintentos y enrutamiento      │
│          (HTTPS / BLE Mesh / SMS)            │
└──────────────────────┬───────────────────────┘
                       │ HTTPS (o Gateway en contingencia)
                       ▼
┌──────────────────────────────────────────────┐
│             NestJS Backend API               │
│  Modular Monolith / Auth / RBAC / Idempotent │
└──────────────────────┬───────────────────────┘
                       │
                       ▼
┌──────────────────────────────────────────────┐
│             PostgreSQL + PostGIS             │
│      Base de datos central relacional y      │
│             consultas geoespaciales          │
└──────────────────────────────────────────────┘
```

---

## 2. Decisiones Fundamentales de Almacenamiento

### 2.1. ¿Por qué existe SQLite en los dispositivos móviles?
En zonas de impacto de un desastre natural (terremotos, inundaciones, huracanes), no es posible garantizar acceso a internet ni a redes celulares comerciales.
* **Autonomía operativa:** SQLite permite que rescatistas, brigadistas y personal médico sigan registrando personas heridas, evaluando albergues y tomando reportes sin interrupción.
* **Persistencia inmediata:** Ningún dato se retiene únicamente en la memoria RAM volatil de la app; cada cambio se graba de inmediato en el almacenamiento no volátil local.
* **No es una réplica idéntica:** La base de datos local SQLite **no** almacena toda la base de datos central de PostgreSQL, sino únicamente la información contextual necesaria para el rol y la zona geográfica del dispositivo (ver *Principio de mínimo almacenamiento*).

### 2.2. ¿Por qué PostgreSQL + PostGIS es la base central?
* **Punto de verdad consolidado:** Consolida la información recolectada por cientos de rescatistas en campo y sistemas de emergencia gubernamentales.
* **Capacidades geoespaciales nativas (PostGIS):** Permite realizar consultas de distancia, pertenencia a polígonos de zonas de riesgo (`ST_Contains`), cálculo de radios de impacto (`ST_DWithin`), y rutas de evacuación óptimas hacia albergues.
* **Integridad transaccional ACID:** Asegura consistencia en asignación de recursos, capacidad en camas de albergues y reunificación familiar.

### 2.3. ¿Por qué Flutter NO se conecta directamente a PostgreSQL?
Conectar una aplicación móvil directamente a una base de datos central es un antipatrón crítico, especialmente en entornos de emergencia:
1. **Seguridad y exposición de credenciales:** Exponer el puerto de PostgreSQL o almacenar credenciales de BD en una app cliente permite que cualquier atacante descompile el binario y obtenga acceso directo a toda la infraestructura.
2. **Control de acceso y RBAC:** El backend NestJS actúa como guardián estricto que valida tokens JWT, sanitiza entradas y aplica reglas de negocio antes de tocar la base de datos.
3. **Manejo de red y conexiones:** Las conexiones directas de PostgreSQL requieren conexiones TCP persistentes que fallan ante la inestabilidad de redes móviles. Las APIs REST sobre HTTPS manejan de forma natural la naturaleza desconectada del cliente.
4. **Idempotencia y validación:** El backend valida la firma de los eventos de sincronización y evita datos corruptos.

---

## 3. Arquitectura de Sincronización Offline-First

### 3.1. Estructura del Evento de Sincronización
Cada mutación realizada en el dispositivo móvil (creación, edición o eliminación lógica) se abstrae como un evento inmutable en la tabla local `sync_queue`:

```json
{
  "event_id": "c1f7b8a0-2f1b-4b11-9a74-9842a5e4a812",
  "device_id": "dev-rescatista-alfa-01",
  "entity_type": "person",
  "entity_id": "8a4f91b0-96f1-4c12-8e77-512c5b331001",
  "operation": "CREATE",
  "version": 1,
  "payload": {
    "first_name": "María",
    "last_name": "López",
    "status": "INJURED",
    "blood_type": "O+"
  },
  "created_at": "2026-09-23T20:30:00.000Z",
  "synced_at": null,
  "status": "PENDING"
}
```

### 3.2. Idempotencia y Canales de Transporte Alternativos (BLE y SMS)
En escenarios de contingencia, los eventos no solo viajan por internet convencional; pueden propagarse a través de:
1. **BLE Mesh (Bluetooth Low Energy):** Dispositivos cercanos intercambian ráfagas de eventos `sync_queue` de dispositivo a dispositivo (malla ad-hoc) hasta alcanzar un dispositivo que tenga conectividad satelital o celular.
2. **SMS Gateway:** Enlaces SMS codificados en Base64 o paquetes comprimidos hacia servidores de contingencia.
3. **HTTPS / Wi-Fi / Celular:** Conexión estándar a `/api/sync/events`.

> [!IMPORTANT]
> **Garantía de Idempotencia:**
> Debido a que un mismo evento puede propagarse simultáneamente por BLE, ser enviado por SMS y transmitirse posteriormente por HTTPS, el backend NestJS implementa **idempotencia estricta por `event_id` (UUID)**.
> Cuando el backend recibe un evento, consulta la tabla central `sync_events`. Si el `event_id` ya fue procesado, ignora la mutación repetida y responde exitosamente con `DUPLICATE_IGNORED` sin duplicar registros.

---

## 4. Estándares Técnicos Globales

### 4.1. Uso de UUID v4 como Identificador Principal
* **Problema con autoincrementales:** En una arquitectura distribuida offline, dos rescatistas sin conexión crearían registros con el mismo ID entero (ej: ID 1, 2, 3), provocando colisiones catastróficas al sincronizar.
* **Solución:** Todas las entidades (`User`, `Person`, `Emergency`, `Shelter`, `SyncEvent`, etc.) utilizan UUID v4 generado de forma descentralizada. El cliente puede crear la entidad localmente con su ID definitivo sin requerir validación previa del servidor.

### 4.2. Uso Estricto de UTC para Marcas de Tiempo
* Todos los dispositivos móviles y el backend guardan marcas de tiempo en formato **ISO 8601 UTC** (`YYYY-MM-DDTHH:mm:ss.sssZ`).
* Esto elimina la ambigüedad generada por zonas horarias dispares, cambios de horario de verano o configuraciones locales erróneas de reloj en los dispositivos.

---

## 5. Seguridad y Manejo de Información

### 5.1. Separación de Datos Públicos vs. Datos Sensibles
* **Datos Públicos / Operativos:** Ubicación de albergues abiertos, alertas meteorológicas, capacidad de refugios, mapas de zonas de riesgo. Estos datos pueden transmitirse y consultarse libremente.
* **Datos Sensibles / Médicos:** DNI/identificación nacional, historial médico, grupo sanguíneo, reportes de menores desaparecidos, credenciales y números de contacto de familiares.
  * El acceso a datos sensibles requiere roles autenticados (`RESCUER`, `COORDINATOR`, `ADMIN`).
  * En reposo en SQLite móvil, los campos sensibles deben encriptarse mediante llaves seguras del dispositivo (Android Keystore / iOS Keychain).

### 5.2. Principio de Mínimo Almacenamiento en Dispositivos
Para proteger la privacidad de las personas ante robo, pérdida o incautación de teléfonos de brigadistas:
* El dispositivo móvil descarga únicamente datos del cuadrante operativo asignado.
* Una vez que un reporte de persona o evento de sincronización es confirmado por el backend (`COMPLETED`), el payload detallado puede ser depurado periódicamente de la cola local.

### 5.3. Identidad de Dispositivos y Criptografía
* Cada terminal móvil registra un `device_id` y su correspondiente `public_key` en la entidad `devices`.
* Esto sienta las bases para firmar criptográficamente los eventos de sincronización generados en campo, previniendo la inyección de reportes falsos durante la emergencia.

---

## 6. Arquitectura del Backend: Modular Monolith

### 6.1. ¿Por qué un Monolito Modular en lugar de Microservicios?
1. **Reducción de fricción y complejidad inicial:** Un sistema de microservicios en esta fase acarrearía sobrecostos masivos en despliegue, latencia de red inter-servicios, orquestación distribuida (Kubernetes, Kafka) y dificultad para pruebas locales por cuatro desarrolladores.
2. **Cohesión modular:** El backend está organizado en módulos de dominio desacoplados (`auth`, `users`, `people`, `families`, `emergencies`, `shelters`, `reports`, `sync`, `devices`).
3. **Transición futura sin fricción:** Al mantener interfaces limpias y dependencias estrictamente inyectadas, cualquiera de estos módulos podrá extraerse a un microservicio independiente (por ejemplo, el módulo de geolocalización o de ingesta de eventos de sincronización masivos) si la carga operativa futura lo justifica.

---

## 7. Mapa de Módulos y Responsabilidades del Backend

| Módulo | Prefijo de Ruta | Responsabilidad Principal |
| :--- | :--- | :--- |
| **Health** | `/api/health` | Estado del backend y chequeo activo de conexión con PostgreSQL |
| **Auth** | `/api/auth` | Login, refresco de token JWT y credenciales |
| **Users** | `/api/users` | Gestión de usuarios del sistema y asignación de roles RBAC |
| **People** | `/api/people` | Padrón de damnificados, ficha médica y búsqueda por identidad |
| **Families** | `/api/families` | Núcleos familiares y búsqueda de personas desaparecidas |
| **Emergencies** | `/api/emergencies`| Catálogo de emergencias activas, severidad y eventos asociados |
| **Shelters** | `/api/shelters` | Disponibilidad de albergues, servicios y estancias |
| **Reports** | `/api/reports` | Ingesta de reportes ciudadanos y de brigadas |
| **Sync** | `/api/sync` | Recepción de eventos distribuidos con garantía de idempotencia |
| **Devices** | `/api/devices` | Registro, telemetría y llaves públicas de terminales móviles |
