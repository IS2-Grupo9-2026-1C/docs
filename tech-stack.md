---
title: Tech Stack
nav_order: 3
---

# Tech Stack

Tecnologías del sistema y el motivo de cada elección según el uso que le dimos.

## Frontend

| Tecnología | Uso | Motivo |
|---|---|---|
| **Expo / React Native** | Aplicación mobile (`app`) | La app es el cliente de los compradores: catálogo, carrito, checkout y notificaciones push. Un solo codebase TypeScript cubre iOS y Android, y Expo (EAS) genera el APK desde GitHub Actions. |
| **React / Vite** | Backoffice web (`backoffice`) | Panel interno para administrar el catálogo, moderar productos, ver órdenes y métricas. Como es una SPA de uso interno, Vite alcanza y da un dev server rápido. |

---

## Backend

| Tecnología | Uso | Motivo |
|---|---|---|
| **FastAPI** (Python) | `users-api`, `metrics-api` | Ya teníamos experiencia previa con FastAPI y Python, así que arrancamos rápido. Se usa en los servicios de usuarios y métricas, que son registro, login, recuperación de contraseña y agregación de eventos. Pydantic valida los payloads y Swagger documenta los endpoints. |
| **Go** | `items-api`, `orders-api` | El checkout de `orders-api` necesita transacciones con `SELECT FOR UPDATE` para la reserva de stock y el control de concurrencia del último item. El control fino de `pgx` y `database/sql` encaja mejor que un ORM. `items-api` comparte el mismo runtime. |
| **SQLAlchemy + Alembic** | ORM y migraciones (servicios Python) | Modelan las tablas de `users-api` y `metrics-api`, con migraciones versionadas y reversibles. |

Los dos servicios Go comparten layout, manejo de errores y middleware, lo que baja el costo de mantener ambos.

---

## Bases de Datos

| Tecnología | Tipo | Motivo |
|---|---|---|
| **PostgreSQL** (Neon) | Relacional | El stock, las reservas y las órdenes necesitan transacciones ACID para no sobrevender. Cada servicio tiene su propia base (carrito y órdenes, items y cupones, usuarios, métricas). Neon ofrece Postgres serverless con tier gratis. |

Se descartó Redis para el carrito porque la consigna pide persistencia y el volumen del TP no justifica sumar otra pieza de infraestructura.

---

## API Gateway

| Tecnología | Motivo |
|---|---|
| **Kong** (DB-less) | Es el único punto de entrada. Valida el JWT, inyecta `X-User-Id` y `X-Internal-Key`, y rutea hacia cada servicio con configuración declarativa (`kong.yml`), sin una base de datos propia que mantener. |

---

## Integraciones externas

| Tecnología | Uso | Motivo |
|---|---|---|
| **Stripe** | Pagos en el checkout (`orders-api`) | Se cobra a través de una interfaz `PaymentGateway` con Stripe en producción y un mock en tests. Su modo test permite probar el checkout sin cobros reales, y los datos de tarjeta nunca pasan por nuestro backend. |
| **SendGrid** | Recuperación de contraseña (`users-api`) | Envía el mail con el link de reseteo. Tier gratis suficiente para el TP. |
| **Expo Push** | Notificaciones de órdenes (`orders-api`) | Avisa al comprador los cambios de estado de la orden. Está integrado al stack Expo de la app, así evitamos montar FCM y APNs por separado. |
| **Cloudinary** | Imágenes de productos (`items-api`) | Hostea y transforma las imágenes del catálogo con tier gratis, sin guardar binarios en la base. |

---

## Observabilidad

| Tecnología | Uso | Motivo |
|---|---|---|
| **Prometheus** | Almacenamiento y consulta de métricas operativas | Los servicios exponen sus métricas en `/metrics` (formato Prometheus). En el stack central de observabilidad (`observability/`) Prometheus scrapea un **Pushgateway** al que los servicios publican sus métricas (modelo push), en vez de scrapear cada servicio directamente. |
| **Grafana** | Dashboards por servicio | Visualiza las métricas sobre Prometheus. |
| **cAdvisor** | Métricas de containers (CPU, memoria, red) | Expone el uso de recursos de los containers sin instrumentar el código. Se incluye en el `docker-compose` local de cada servicio (`items-api`, `orders-api`, `users-api`), no en el stack central. |

---

## Testing

| Tecnología | Uso | Motivo |
|---|---|---|
| **pytest + Testcontainers** | `users-api`, `metrics-api` | Corren los tests de integración contra una Postgres real y efímera, sin mockear la base. |
| **testing** (stdlib) | `items-api`, `orders-api` | Alcanza para los servicios Go sin sumar dependencias. |

---

## Containerización

| Tecnología | Uso | Motivo |
|---|---|---|
| **Docker** | Containerización de microservicios | Cada servicio corre igual en cualquier máquina. |
| **Docker Compose** | Orquestación local | Levanta el servicio con su base y las migraciones en un comando. |

---

## CI/CD

| Tecnología | Uso | Motivo |
|---|---|---|
| **GitHub Actions** | Tests y pipeline de CI | Corre lint, typecheck y tests en cada PR, y arma el APK de la app. |
| **Railway / Render** | Deploy automático desde `master` | Deploy continuo con tier gratis, suficiente para el TP. |
