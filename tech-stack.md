---
title: Tech Stack
nav_order: 3
---

# Tech Stack

Tecnologías del sistema y el motivo de cada elección.

## Frontend

| Tecnología | Uso | Motivo |
|---|---|---|
| **Expo / React Native** | Aplicación mobile (`app`) | Un solo codebase TypeScript para iOS y Android. Expo (EAS) resuelve los builds sin tener que configurar el entorno nativo. |
| **React / Vite** | Backoffice web (`backoffice`) | SPA liviana para uso interno. Vite da un dev server rápido y un build simple, y comparte TypeScript con la app. |

---

## Backend

| Tecnología | Uso | Motivo |
|---|---|---|
| **FastAPI** (Python) | `users-api`, `metrics-api` | Productividad alta, validación con Pydantic y Swagger automático. Encaja con servicios de CRUD y datos. |
| **Go** | `items-api`, `orders-api` | Performance y control fino de transacciones y locking, necesarios para el checkout (`SELECT FOR UPDATE` e idempotencia). Binarios chicos para Docker. |
| **SQLAlchemy + Alembic** | ORM y migraciones (servicios Python) | ORM maduro con migraciones versionadas y reversibles. |

Los dos servicios Go comparten layout, manejo de errores y middleware, lo que baja el costo de mantener ambos.

---

## Bases de Datos

| Tecnología | Tipo | Motivo |
|---|---|---|
| **PostgreSQL** (Neon) | Relacional | Transacciones ACID, requisito para stock y órdenes. Una base por servicio. Neon ofrece Postgres serverless con tier gratis. |

Se descartó Redis para el carrito porque la consigna pide persistencia y el volumen del TP no justifica sumar otra pieza de infraestructura.

---

## API Gateway

| Tecnología | Motivo |
|---|---|
| **Kong** (DB-less) | Punto de entrada único. Valida JWT y enruta con configuración declarativa (`kong.yml`), sin una base de datos propia que mantener. |

---

## Integraciones externas

| Tecnología | Uso | Motivo |
|---|---|---|
| **Stripe** | Pagos (`orders-api`) | Pasarela estándar con modo test. El SDK maneja los datos de tarjeta, que nunca pasan por nuestro backend. |
| **SendGrid** | Recuperación de contraseña por mail (`users-api`) | Envío de mails transaccionales con tier gratis. |
| **Expo Push** | Notificaciones push (`orders-api`) | Integrado al stack Expo de la app, evita montar FCM y APNs por separado. |
| **Cloudinary** | Imágenes de productos | Hosting y transformación de imágenes con tier gratis. Evita guardar binarios en la base. |

---

## Observabilidad

| Tecnología | Uso | Motivo |
|---|---|---|
| **Prometheus** | Scraping de métricas operativas | Estándar de facto, integra con el resto del stack. |
| **Grafana** | Dashboards por servicio | Visualización directa sobre Prometheus. |
| **cAdvisor** | Métricas de containers (CPU, memoria, red) | Expone uso de recursos sin instrumentar el código de la app. |

---

## Testing

| Tecnología | Uso | Motivo |
|---|---|---|
| **pytest + Testcontainers** | Servicios Python | Tests de integración contra una Postgres real y efímera, sin mockear la base. |
| **testing** (stdlib) | Servicios Go | Alcanza para los servicios Go sin sumar dependencias. |

---

## Containerización

| Tecnología | Uso | Motivo |
|---|---|---|
| **Docker** | Containerización de microservicios | Entorno reproducible e igual entre máquinas. |
| **Docker Compose** | Orquestación local | Levanta todos los servicios con su base en un comando. |

---

## CI/CD

| Tecnología | Uso | Motivo |
|---|---|---|
| **GitHub Actions** | Tests y pipeline de CI | Integrado al repo, corre tests y lint en cada PR sin infra externa. |
| **Railway / Render** | Deploy automático desde `master` | Deploy continuo con tier gratis, suficiente para el TP. |
