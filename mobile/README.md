# Innovatec 2026 - Aplicación Móvil (Flutter)

Aplicación móvil offline-first para respuesta y coordinación en emergencias y desastres naturales.

## Arquitectura del Proyecto Móvil

```text
mobile/lib/
├── core/                  # Elementos transversales reutilizables
│   ├── config/            # Configuración de entornos y timeouts (AppConfig)
│   ├── constants/         # Constantes globales y tipos de entidades
│   ├── errors/            # Clases base de fallos (ServerFailure, NetworkFailure, etc.)
│   ├── network/           # Cliente HTTP base (ApiClient)
│   └── utils/             # Utilidades de fecha UTC y UUID v4
│
├── database/              # Almacenamiento local SQLite
│   ├── tables/            # Definiciones DDL de tablas locales (SyncQueueTable)
│   ├── dao/               # Data Access Objects (SyncQueueDao)
│   └── app_database.dart  # Abstracción y ciclo de vida de la BD local
│
├── sync/                  # Motor de sincronización offline-first
│   ├── sync_event.dart    # Modelo de evento con IDempotencia y versión
│   └── sync_manager.dart  # Lógica de encolado local y transmisión al backend
│
├── features/              # Módulos funcionales de la aplicación
│   ├── auth/              # Autenticación y perfil de usuario
│   ├── people/            # Registro e identificación rápida de personas
│   ├── families/          # Familias y búsqueda de personas desaparecidas
│   ├── emergencies/       # Gestión y alerta de incidentes
│   ├── shelters/          # Albergues y ocupación de camas/servicios
│   ├── reports/           # Reportes de situación desde campo
│   └── map/               # Mapa interactivo y visualización geoespacial
│
└── main.dart              # Punto de entrada de la aplicación
```

## Principio Offline-First

1. **Persistencia local primero:** Toda acción realizada por el usuario se guarda inmediatamente en SQLite.
2. **Cola de eventos diferida (`sync_queue`):** Las mutaciones generan un `SyncEvent` con `eventId` (UUID) y se almacenan como `PENDING`.
3. **Sincronización:** Cuando hay conectividad con el backend NestJS, el `SyncManager` envía los eventos a través de HTTPS.
4. **Respaldo en contingencia:** Si las redes celulares colapsan, la arquitectura está preparada para canalizar los eventos mediante BLE Mesh o SMS.

## Comandos Útiles

```bash
# Obtener dependencias
flutter pub get

# Ejecutar análisis estático (0 lints)
flutter analyze

# Ejecutar pruebas unitarias y de widgets
flutter test

# Ejecutar la aplicación en emulador o dispositivo
flutter run
```
