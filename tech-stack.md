---
title: Tech Stack
nav_order: 3
---

# Tech Stack

## Frontend

| Tecnología | Uso |
|---|---|
| **Expo / React Native** | Aplicación mobile (`app`) |
| **React / Vite** | Backoffice web (`backoffice`) |

---

## Backend

| Tecnología | Uso |
|---|---|
| **FastAPI** (Python) | `users-api`, `metrics-api` |
| **Go** | `items-api`, `orders-api` |
| **SQLAlchemy + Alembic** | ORM y migraciones (servicios Python) |

---

## Bases de Datos

| Tecnología | Tipo | Estado |
|---|---|---|
| **PostgreSQL** | Relacional | Una base por servicio, en Neon |

---

## API Gateway

| Tecnología | Estado |
|---|---|
| **Kong** (DB-less) | Confirmado |

---

## Integraciones externas

| Tecnología | Uso |
|---|---|
| **Stripe** | Payment provider (`orders-api`) |
| **SendGrid** | Recuperación de contraseña por mail (`users-api`) |
| **Expo Push** | Notificaciones push a la app (`orders-api`) |
| **Cloudinary** | Almacenamiento de imágenes de productos |

---

## Observabilidad

| Tecnología | Uso |
|---|---|
| **Prometheus** | Scraping de métricas operativas |
| **Grafana** | Dashboards operativos por servicio |
| **cAdvisor** | Métricas de containers (CPU, memoria, red) |

---

## Testing

| Tecnología | Uso |
|---|---|
| **pytest + Testcontainers** | Servicios Python |
| **testing** (stdlib) | Servicios Go |

---

## Containerización

| Tecnología | Uso |
|---|---|
| **Docker** | Containerización de microservicios |
| **Docker Compose** | Orquestación local de servicios |

---

## Almacenamiento de Assets

| Tecnología | Uso | Estado |
|---|---|---|
| **Cloudinary** | Almacenamiento de imágenes de productos | En desarrollo |

---

## CI/CD

| Tecnología | Uso |
|---|---|
| **GitHub Actions** | Ejecución de tests y pipeline de CI |
| **Railway / Render** | Deploy automático desde rama `master` |
