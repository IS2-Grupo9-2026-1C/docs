---
title: orders-api
parent: Servicios
nav_order: 4
---

# orders-api

Servicio de carrito y órdenes de compra. Construido con **Go**. El flujo de compra y sus decisiones de diseño están documentados en [Checkout](../checkout).

## Responsabilidades

- Gestionar el carrito de cada usuario.
- Gestionar el ciclo de vida de una orden (creación, pago, confirmación, cancelación).
- Procesar pagos a través de una pasarela: Stripe en producción, mock en desarrollo.
- Validar y aplicar cupones de descuento consultando a `items-api`.
- Enviar push notifications a la app vía Expo (los tokens los provee `users-api`).
- Reportar cambios de estado de órdenes a `metrics-api`.

## Pre-requisitos

- Go 1.25+
- Docker Engine 24+ y Docker Compose
- PostgreSQL en ejecución
- Archivo `.env` (copiar desde `.env.example`)

## Variables de entorno principales

- `PORT` / `ORDERS_PORT`: puerto del servicio (default `8082`)
- `DATABASE_*` o `DATABASE_URL`: conexión a PostgreSQL (Neon en producción)
- `ITEMS_API_URL`: validación de items y cupones
- `METRICS_API_URL`: reporte de eventos de órdenes
- `USERS_API_URL`: obtención de push tokens
- `INTERNAL_KEY`: header `X-Internal-Key` para llamadas internas
- `STRIPE_SECRET_KEY`: clave de Stripe (si está vacía se usa el mock)
- `EXPO_PUSH_API_URL`: endpoint de Expo Push

## Tests

```bash
go test ./... -v
```

## Ejecución

### Con Docker Compose (recomendado)

```bash
docker compose up -d --build
```

Levantar pgAdmin (solo desarrollo):

```bash
docker compose --profile dev up -d pgadmin
```

Swagger disponible en `http://localhost:${PORT:-8082}/swagger/index.html`.

### Ejecución local

```bash
go run ./src/cmd
```

## Observabilidad

Logging estructurado JSON con trazabilidad por `X-Request-ID` y errores en formato `application/problem+json` (RFC 7807). Expone métricas operativas para Prometheus, con dashboard provisionado en Grafana y métricas de containers vía cAdvisor.
