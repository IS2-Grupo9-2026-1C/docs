---
title: metrics-api
parent: Servicios
nav_order: 5
---

# metrics-api

Servicio de agregación de métricas del sistema. Construido con **Python / FastAPI**. Recibe eventos de otros servicios y los expone agregados para el backoffice.

## Responsabilidades

- Registrar eventos de usuarios registrados.
- Registrar cambios de estado de órdenes.
- Exponer métricas agregadas por período (7, 30 o 90 días).

## Pre-requisitos

- Python 3.10+
- `uv` (recomendado) o pip + venv
- Docker Engine 24+ y Docker Compose v2.20+

## Variables de entorno principales

Copiar `.env.example` a `.env` y completar:

- `ENVIRONMENT`, `HOST`, `PORT`
- `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD`
- `INTERNAL_KEY`: clave del header `X-Internal-Key`

## Ejecución

### Con Docker Compose (recomendado)

```bash
docker compose up -d --build
```

### Local con uv

```bash
uv sync --dev
uv run alembic upgrade head
uv run uvicorn app.main:app --reload --host 127.0.0.1 --port 8080
```

API docs en `http://localhost:8080/docs`.

## Tests

```bash
uv run pytest
```

## Endpoints principales

- `POST /metrics/users/registered`: registra un evento de usuario registrado.
- `GET /metrics/users/registered`: métricas de usuarios registrados (`period`: 7, 30 o 90 días).
- `POST /metrics/orders/status-changed`: registra un cambio de estado de orden.
- `GET /metrics/orders`: métricas de órdenes por estado y período. Sin `period` devuelve totales históricos; con `period` filtra por rango y agrega la serie por día.
- `GET /livez`, `GET /readyz`: health checks.

## Autenticación

Todos los endpoints de métricas requieren el header `X-Internal-Key`, validado por middleware. En `ENVIRONMENT=development` la validación se saltea.

```bash
curl -H "X-Internal-Key: tu-clave-interna" http://localhost:8080/metrics/orders?period=7
```
