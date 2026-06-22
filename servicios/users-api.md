---
title: users-api
parent: Servicios
nav_order: 2
---

# users-api

Servicio de backend de usuarios. Construido con **Python / FastAPI**.

## Responsabilidades

- Registro, autenticación (JWT) y perfil de usuarios.
- Recuperación de contraseña por mail vía SendGrid.
- Registro de push tokens de Expo, consumidos por `orders-api` para las notificaciones.
- Reporte de eventos de usuarios registrados a `metrics-api`.
- Bloqueo de usuarios con **revocación inmediata de JWT** (escribe la blacklist en Redis que Kong consulta).

## Revocación de JWT

Al banear un usuario, `block_user` lo marca inactivo en la base, borra sus refresh tokens y escribe `blacklist:<role>:<id>` en Redis (TTL ≈ vida del access token), para que Kong lo rechace al instante. El flujo de refresh, además, verifica contra la base que el usuario siga activo. Si `REDIS_HOST` está vacío, la revocación queda deshabilitada (writer no-op) y los baneos caen al vencimiento natural del token. Variables: `REDIS_HOST`, `REDIS_PORT`, `REDIS_PASSWORD`, `REDIS_TLS`. Ver [Revocación de JWT](../revocacion-jwt).

## Recuperación de contraseña

Usa SendGrid. Si falta `SENDGRID_API_KEY`, no se envía mail real y se loguea el intento. Variables relacionadas:

- `SENDGRID_API_KEY`
- `PASSWORD_RECOVERY_FRONTEND_URL`: link puente HTTPS que redirige a la app mobile.

## Pre-requisitos

- Docker Engine 24+
- Docker Compose v2.20+
- Red Docker `microservices` creada
- Python 3.13 (imagen base) o Python 3.10+ para desarrollo local
- Gestor de paquetes `uv` (recomendado)
- Archivo `.env` completo (ver `.env.example`)

## Tests

### Con uv

```bash
uv sync --dev
uv run pytest
```

### Con venv + pip

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
pytest
```

## Ejecución

### Red Docker compartida (una sola vez)

```bash
docker network create microservices
```

### Levantar con Docker Compose (recomendado)

Construye la imagen, levanta PostgreSQL, ejecuta migraciones e inicia la API:

```bash
docker compose up -d --build
```

Levantar pgAdmin (solo desarrollo):

```bash
docker compose --profile dev up -d pgadmin
```

Swagger disponible en `http://localhost:${PORT:-8080}/docs`.
