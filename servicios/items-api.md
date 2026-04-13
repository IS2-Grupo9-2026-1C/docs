---
title: items-api
parent: Servicios
nav_order: 3
---

# items-api

Servicio de backend del catálogo de productos. Construido con **Go**.

## Pre-requisitos

- Go 1.25+
- Docker Engine 24+
- PostgreSQL en ejecución
- Archivo `.env` con variables de entorno (`PORT`, `DATABASE_HOST`, `DATABASE_PORT`, `DATABASE_NAME`, `DATABASE_USER`, `DATABASE_PASSWORD`)

## Tests

```bash
go test ./... -v
```

## Observabilidad

El servicio incluye logging estructurado JSON en todas las capas (middleware, handler, service, repository).

**Trazabilidad de requests:**
- Header de entrada/salida: `X-Request-ID`
- Si el cliente no envía `X-Request-ID`, el servicio genera uno automáticamente

**Formato de errores** (`application/problem+json`, RFC 7807):

```json
{
  "type": "https://api.items.local/problems/validation_error",
  "title": "Validation error",
  "status": 400,
  "detail": "limit: must be between 1 and 100",
  "instance": "/items",
  "code": "validation_error",
  "traceId": "req-validation-001"
}
```

## Ejecución

### Levantar con Docker Compose (recomendado)

```bash
docker compose up -d --build
```

Levantar pgAdmin (solo desarrollo):

```bash
docker compose --profile dev up -d pgadmin
```

Swagger disponible en `http://localhost:${PORT:-8080}/swagger/index.html`.

### Ejecución local

Levantar PostgreSQL:

```bash
docker run --name items-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=items_db \
  -p 5432:5432 -d postgres:16-alpine
```

Aplicar migraciones:

```bash
docker compose up -d migrations
```

Iniciar la API:

```bash
go run ./src/cmd
```

O usando el script que también genera el Swagger:

```bash
./scripts/run-local.sh
```

### Ejemplo: crear un item

```bash
curl -X POST http://localhost:${PORT:-8080}/items \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Notebook Lenovo",
    "description": "Notebook 16GB RAM",
    "price": 1200.50,
    "stock": 8,
    "status": "ACTIVE",
    "categoryId": "laptops"
  }'
```
