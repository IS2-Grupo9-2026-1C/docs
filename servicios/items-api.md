---
title: items-api
parent: Servicios
nav_order: 3
---

# items-api

Servicio de backend del catálogo de productos y cupones de descuento. Construido con **Go**. Los cupones se validan internamente desde `orders-api` durante el checkout. Las imágenes de los productos se hostean en **Cloudinary**.

## Funcionalidades

### Catálogo de productos

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/items` | Crear un item |
| `GET` | `/items` | Listar el catálogo público |
| `GET` | `/items/{id}` | Detalle de un item |
| `GET` | `/my-items` | Items del vendedor autenticado |
| `GET` | `/my-items/{id}` | Detalle de un item propio |
| `PATCH` | `/items/{id}` | Editar un item |
| `DELETE` | `/items/{id}` | Eliminar un item |
| `POST` / `PUT` | `/items/{id}/images` | Subir / reemplazar imágenes (Cloudinary) |

### Reserva de stock (consumida por `orders-api` en el checkout)

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/items/{id}/reserve` | Reserva stock con TTL de 5 min (no descuenta `stock`, inserta en `stock_reservations`). Devuelve `409` si no hay disponibilidad |
| `POST` | `/items/{id}/commit-reservation` | Confirma la reserva: descuenta `stock` y borra la fila de reserva |
| `POST` | `/items/{id}/release` | Libera la reserva sin tocar el stock |

La disponibilidad se calcula como `stock - SUM(reservas activas)` bajo `SELECT ... FOR UPDATE`, y las reservas vencidas se borran de forma lazy en la misma transacción. Ver [Checkout](../checkout) para el flujo completo.

### Administración (backoffice)

| Método | Ruta | Descripción |
|---|---|---|
| `GET` | `/admin/items` | Listar items para moderación |
| `GET` | `/admin/items/{id}` | Detalle administrativo |
| `POST` | `/admin/items/{id}/disable` · `/enable` | Deshabilitar / habilitar un item |

### Cupones

| Método | Ruta | Descripción |
|---|---|---|
| `POST` | `/coupons` | Crear un cupón |
| `GET` | `/my-coupons` | Cupones del vendedor |
| `PATCH` / `DELETE` | `/coupons/{id}` | Editar / eliminar un cupón |

### Endpoints internos (autenticados con `X-Internal-Key`)

| Método | Ruta | Consumidor | Descripción |
|---|---|---|---|
| `POST` | `/internal/coupons/validate` | `orders-api` | Validar un cupón en el checkout |
| `POST` | `/internal/coupons/redeem` | `orders-api` | Registrar la redención |
| `POST` | `/internal/coupons/release-redemption` | `orders-api` | Liberar una redención reservada |
| `POST` | `/sellers/{sellerId}/block` · `/unblock` | `users-api` | Bloquear / desbloquear los items de un vendedor |

> La lista completa de parámetros y respuestas está en el Swagger del servicio (ver más abajo).

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

**Métricas operativas:** la API expone métricas técnicas en `/metrics`. Prometheus scrapea la API y cAdvisor, y Grafana queda provisionado con el dashboard `Items API - Operational`.

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
