# Feature: Autenticación y Perfil de Usuario (Mobile)

## Responsabilidad
Gestión de credenciales locales, tokens JWT, roles y permisos (RBAC) en el dispositivo.

## Flujo Offline-First
* Las credenciales o sesión activa se almacenan de forma segura (e.g. Secure Storage).
* En modo offline, el usuario mantiene acceso a las funciones operativas de acuerdo a su último rol verificado.
* Al recuperar conexión, valida el token con `POST /api/auth/refresh` o `POST /api/auth/login`.
