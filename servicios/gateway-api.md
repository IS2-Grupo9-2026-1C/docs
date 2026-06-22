---
title: gateway-api
parent: Servicios
nav_order: 1
---

# gateway-api

API Gateway centralizado basado en Kong DB-less. Valida tokens JWT (RS256), extrae el ID del usuario (claim `sub`) y su rol (claim `role`) y los inyecta como headers `X-User-Id` y `X-User-Role` hacia los microservicios. Las llamadas internas se autentican con el header `X-Internal-Key`. Además resuelve CORS, aplica rate-limiting en los endpoints de login y recuperación de contraseña, y soporta autenticación por cookie + CSRF para el backoffice (ver [Seguridad y plugins](#seguridad-y-plugins)).

## Pre-requisitos

- Docker y Docker Compose
- Red Docker `microservices` creada (ver abajo)
- Par de claves RSA generado

## Configuración inicial

### 1. Red Docker compartida

```bash
docker network create microservices
```

Esta red debe existir antes de levantar cualquier servicio. Solo se crea una vez.

### 2. Variables de entorno

Copiar `.env.example` a `.env` y completar según el entorno:

- `UPSTREAM_USERS_URL`: URL del servicio `users-api`
- `UPSTREAM_ITEMS_URL`: URL del servicio `items-api`
- `UPSTREAM_ORDERS_URL`: URL del servicio `orders-api`
- `UPSTREAM_METRICS_URL`: URL del servicio `metrics-api`
- `RSA_PUBLIC_KEY_B64`: clave pública RSA en base64 para validar JWT
- `INTERNAL_KEY`: valor del header interno `X-Internal-Key`
- `CORS_ORIGIN`: origin permitido por el plugin CORS (p. ej. la URL del backoffice)
- `RL_LOGIN_ACCOUNT_MAX`, `RL_LOGIN_IP_MAX`, `RL_LOGIN_WINDOW`: límites de rate-limiting del login (por cuenta, por IP, y ventana en segundos)
- `RL_RECOVERY_ACCOUNT_MAX`, `RL_RECOVERY_IP_MAX`, `RL_RECOVERY_WINDOW`: ídem para la recuperación de contraseña

### 3. Generar kong.yml

Kong lee su configuración desde `kong.yml`, que se genera a partir de la plantilla `kong.yml.tpl` sustituyendo las URLs de los upstreams, la clave pública RSA y los parámetros de CORS y rate-limiting. Este paso es necesario tanto en local como en cada deploy, ya que los valores varían por entorno. El `docker-entrypoint.sh` lo hace automáticamente al arrancar el container: primero decodifica `RSA_PUBLIC_KEY_B64` en `RSA_PUBLIC_KEY` y luego ejecuta:

```bash
envsubst '${UPSTREAM_USERS_URL} ${UPSTREAM_ITEMS_URL} ${UPSTREAM_ORDERS_URL} ${UPSTREAM_METRICS_URL} ${RSA_PUBLIC_KEY} ${INTERNAL_KEY} ${CORS_ORIGIN} ${RL_LOGIN_ACCOUNT_MAX} ${RL_LOGIN_IP_MAX} ${RL_LOGIN_WINDOW} ${RL_RECOVERY_ACCOUNT_MAX} ${RL_RECOVERY_IP_MAX} ${RL_RECOVERY_WINDOW}' < kong.yml.tpl > kong.yml
```

## Comandos de ejecución

```bash
# Levantar gateway (requiere kong.yml generado)
docker compose up -d
```

El gateway queda disponible en `http://localhost:8000`.

## Health checks

| Endpoint | Semántica |
|----------|-----------|
| `GET /livez` | Liveness probe. Responde `200 ok` si el proceso Kong está vivo y aceptando conexiones HTTP. No consulta ningún sistema externo. |
| `GET /readyz` | Readiness probe. Verifica el estado interno de Kong consultando su Admin API (`/status`). Confirma que Kong cargó su configuración y está operacional. |

## Seguridad y plugins

Toda esta lógica vive declarativamente en `kong.yml.tpl`.

### Autenticación JWT

- Valida tokens **RS256** contra la clave pública (`RSA_PUBLIC_KEY`), verificando `exp`.
- El token puede venir en el header `Authorization: Bearer` (app mobile) **o** en la cookie httpOnly `admin_access_token` (backoffice).
- Tras validar, Kong inyecta `X-User-Id` (del claim `sub`) y `X-User-Role` (del claim `role`). Antes de inyectarlos limpia cualquier `X-User-Id`/`X-User-Role`/`X-Internal-Key` que venga del cliente, para que no puedan falsificarse desde afuera.

### CORS

Plugin `cors` global con `credentials: true` (necesario para las cookies del backoffice). El origin permitido se configura con `CORS_ORIGIN`.

### Rate-limiting

Las rutas de **login** y **recuperación de contraseña** tienen rate-limiting por IP y por cuenta, con ventanas fijas configurables vía las variables `RL_LOGIN_*` y `RL_RECOVERY_*`. Al excederse, Kong responde `429` con un cuerpo JSON normalizado.

### CSRF (double-submit) para el backoffice

En las operaciones que mutan estado autenticadas por cookie, Kong exige el header `X-CSRF-Token` y lo valida contra la cookie `admin_csrf_token`. La app mobile, al usar `Authorization: Bearer`, no pasa por este control.

### Revocación de JWT (blacklist en Redis)

Tras validar el token, en cada ruta protegida Kong consulta una blacklist en Redis (módulo Lua `lua/revocation.lua.tpl`) y responde `401` si el usuario fue baneado, sin esperar a que el token expire. Requiere las variables `REDIS_*` apuntando al mismo Redis que `users-api`. Ante fallos transitorios hace fail-open; ante misconfiguración persistente (credencial/TLS) hace fail-closed con `503`. Ver [Revocación de JWT](../revocacion-jwt).
