---
title: users-api
parent: Servicios
nav_order: 2
---

# Users API - IS2 Grupo 9 (2026 1C)

Backend de usuarios para el trabajo practico grupal de Ingenieria de Software II - FIUBA.

## Stack

- Python 3.10+
- FastAPI
- SQLAlchemy
- Alembic
- PostgreSQL
- Pytest + Testcontainers
- Docker + Docker Compose

## Requisitos previos

- Python 3.10 o superior
- uv (recomendado) o pip + venv
- Docker Engine 24+
- Docker Compose v2.20+ (comando docker compose)

## Instalacion

```bash
git clone <url-del-repo>
cd users-api
```

## Configuracion

1. Crear archivo de entorno desde el ejemplo:

```bash
cp .env.example .env
```

2. Completar variables minimas:

- ENVIRONMENT
- HOST
- PORT
- DATABASE_HOST
- DATABASE_NAME
- DATABASE_PORT
- DATABASE_USER
- DATABASE_PASSWORD
- SECRET_KEY
- ALGORITHM
- ACCESS_TOKEN_EXPIRE_MINUTES

3. Password recovery (sin envio real de emails):

- El sistema genera token y registra en logs el link de recuperacion.
- No hay integracion activa con proveedor de correo en esta version.

Variable relacionada:

- PASSWORD_RECOVERY_FRONTEND_URL

## Ejecutar con Docker (recomendado)

Levanta Postgres, corre migraciones y luego inicia la API.

```bash
docker compose up -d --build
```

Opcional: levantar pgAdmin en perfil de desarrollo.

```bash
docker compose --profile dev up -d pgadmin
```

Endpoints utiles:

- API docs: http://localhost:8080/docs
- Health liveness: http://localhost:8080/livez
- Health readiness: http://localhost:8080/readyz

## Ejecutar local (sin Docker)

### Opcion A: uv

```bash
uv sync --dev
uv run alembic upgrade head
uv run uvicorn app.main:app --reload --host 127.0.0.1 --port 8080
```

### Opcion B: venv + pip

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -e .
alembic upgrade head
uvicorn app.main:app --reload --host 127.0.0.1 --port 8080
```

## Tests

Con uv:

```bash
uv run pytest
```

Con venv:

```bash
pytest
```

## Calidad de codigo

Formateo y lint (si tenes pre-commit instalado):

```bash
pre-commit run --all-files
```

Herramientas configuradas:

- black
- isort
- flake8
- pre-commit-hooks

## Endpoints principales

- POST /users/register
- POST /users/token
- GET /users/me
- POST /users/password-recovery/request
- POST /users/password-recovery/validate
- POST /users/password-recovery/confirm
- GET /livez
- GET /readyz

## Estructura del proyecto

```text
users-api/
|- app/
|  |- api/                # Routers, dependencies y respuestas de error
|  |- core/               # Configuracion, seguridad, logging y handlers
|  |- db/                 # Base y sesion de SQLAlchemy
|  |- models/             # Modelos ORM
|  |- repositories/       # Acceso a datos
|  |- schemas/            # Schemas de request/response
|  |- services/           # Logica de negocio
|- migrations/            # Alembic
|- tests/                 # Tests de integracion y soporte
|- docker-compose.yml
|- Dockerfile
|- pyproject.toml
```
