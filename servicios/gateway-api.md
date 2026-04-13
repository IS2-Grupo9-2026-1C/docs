---
title: gateway-api
parent: Servicios
nav_order: 1
---

# gateway-api

API Gateway centralizado basado en **Kong DB-less**. Valida tokens JWT (RS256), extrae el email del usuario y lo inyecta como header `X-User-Email` hacia los microservicios internos.

## Pre-requisitos

- Docker y Docker Compose
- Red Docker `microservices` creada
- Par de claves RSA generado

## Configuración inicial

### 1. Red Docker compartida

```bash
docker network create microservices
```

### 2. Variables de entorno

Copiar `.env.example` a `.env` y completar `UPSTREAM_USERS_URL` con la URL del servicio `users-api`.

### 3. Generar kong.yml

Kong lee su configuración desde `kong.yml`, generado a partir de la plantilla `kong.yml.tpl`:

```bash
envsubst '${UPSTREAM_USERS_URL}' < kong.yml.tpl > kong.yml
```

Este paso es necesario tanto en local como en cada deploy, ya que la URL varía por entorno.

## Ejecución

```bash
docker compose up -d
```

El gateway queda disponible en `http://localhost:8000`.

## Flujo de autenticación

1. El cliente envía un request con header `Authorization: Bearer <jwt>`.
2. Kong valida la firma RS256 del token.
3. Kong extrae el claim `email` y lo inyecta como `X-User-Email` en el request hacia el microservicio destino.
4. Los microservicios confían en `X-User-Email` sin revalidar el token.
