# Feature: Registro e Identificación de Personas (Mobile)

## Responsabilidad
* Registro rápido de damnificados y rescatistas en el terreno.
* Captura de DNI/identificación, datos médicos esenciales, grupo sanguíneo y estado.
* Generación local de UUID v4 para cada persona creada offline.

## Flujo de Datos
1. Creación de persona -> Guardar en SQLite local (`people_table`).
2. Encolar evento `CREATE` en `sync_queue` con el payload de la persona.
3. El `SyncManager` enviará el evento a NestJS (`/api/people`) cuando haya conectividad.
