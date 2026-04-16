---
title: gateway-api
parent: Servicios
nav_order: 1
---

# gateway-api

API Gateway centralizado basado en Kong DB-less. Valida tokens JWT (RS256), extrae el ID del usuario (claim `sub`) y lo inyecta como header `X-User-Id` hacia los microservicios.

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

- `UPSTREAM_USERS_URL` — URL del servicio `users-api`
- `UPSTREAM_ITEMS_URL` — URL del servicio `items-api`
- `RSA_PUBLIC_KEY_B64` — clave pública RSA en base64 para validar JWT

### 3. Generar kong.yml

Kong lee su configuración desde `kong.yml`, que se genera a partir de la plantilla `kong.yml.tpl` sustituyendo las URLs de los upstreams y la clave pública RSA. Este paso es necesario tanto en local como en cada deploy, ya que los valores varían por entorno.

```bash
envsubst '${UPSTREAM_USERS_URL} ${UPSTREAM_ITEMS_URL} ${RSA_PUBLIC_KEY}' < kong.yml.tpl > kong.yml
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
| `GET /livez` | Liveness probe — responde `200 ok` si el proceso Kong está vivo y aceptando conexiones HTTP. No consulta ningún sistema externo. |
| `GET /readyz` | Readiness probe — verifica el estado interno de Kong consultando su Admin API (`/status`). Confirma que Kong ha cargado su configuración y está operacional. |
