---
title: users-api
parent: Servicios
nav_order: 2
---

# users-api

Servicio de backend de usuarios. Construido con **Python / FastAPI**.

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
