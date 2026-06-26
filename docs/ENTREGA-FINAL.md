---
title: Entrega Final
parent: Checkpoints
nav_order: 3
---

# Entrega Final — IS2 Grupo 9 (2026 1C)

Proyecto: [IS2-Grupo9-2026-1C/projects/1](https://github.com/orgs/IS2-Grupo9-2026-1C/projects/1)

## Criterio de corte

Esta documentación refleja el **estado real del código** al momento de la entrega final (26/06/2026), verificado directamente sobre los repositorios de cada componente.

Se considera **cerrado** lo que tiene backend y frontend funcionales con los criterios de aceptación principales cubiertos. Los avances con criterios faltantes no se suman al porcentaje cerrado para mantener una medición conservadora.

| Estado | Historias | Pts |
|---|---:|---:|
| Cerradas — obligatorias | 21 | 63 |
| Cerradas — optativas | 12 | 33 |
| No implementadas — optativas | 9 | 29 |

---

## Trabajo realizado

### Arquitectura
- Plataforma de microservicios políglota con **API Gateway** (Kong DB-less) como único punto de entrada: ruteo, validación de JWT (RS256), inyección de `X-User-Id`/`X-Internal-Key`, rate limiting en login y recupero (por IP y por cuenta) y propagación de `X-Request-ID`.
- **Red lines de arquitectura cumplidas**: cada servicio con su propia base de datos (no hay DB compartida), **dos lenguajes** backend (Python/FastAPI y Go/Gin) y **dos tecnologías de base de datos** (PostgreSQL como SQL + Redis como NoSQL para la blacklist de revocación de JWT).
- Servicios: `users-api` (auth, perfil, wishlist, administración de usuarios), `items-api` (catálogo, publicaciones, stock, cupones, notif. de stock), `orders-api` (carrito, checkout, órdenes, pagos, notif. de estado), `metrics-api` (métricas agregadas event-driven).
- **Media externa**: imágenes de perfil y de producto en **Cloudinary** (solo se persiste la URL).

### Usuarios y Perfil
- Registro con validación de email y fuerza de contraseña (8+ con may/min/dígito/especial) y hashing **Argon2**.
- Login con error genérico y JWT (`sub`+`role`, expiración configurable, refresh token).
- Recupero de contraseña: token de un solo uso, hash SHA-256, expiración ≤1h, mensaje genérico y rate limit por cuenta/IP.
- Edición y visualización de perfil propio; perfil público sin datos privados y oculto para usuarios bloqueados.

### Catálogo
- Home con productos recientes, búsqueda, navegación por categoría y browsing sin autenticación.
- Listado paginado con búsqueda por nombre/descripción que excluye productos sin stock o deshabilitados.
- Detalle de producto con imágenes, vendedor y estados sin stock / deshabilitado.
- Optativas: compartir link de producto, filtros avanzados (categoría, rango de precio, combinación) y ordenamiento (precio asc/desc, más reciente).

### Carrito, Checkout y Órdenes
- Carrito con validación de stock, modificación de cantidad, eliminación y señalización de ítems no disponibles.
- **Checkout** con **Stripe en sandbox** (SDK oficial) y mock externo conmutable para escenarios de fallo (aprobado/rechazado/timeout); dirección de entrega obligatoria y registrada en la orden.
- Modelo de **9 estados** con historial de transiciones y timestamps; transiciones inválidas rechazadas; tracking code opcional al enviar; confirmación de entrega por el comprador.
- Historial de compras (orden desc, filtro por estado).
- Optativa: aplicar cupón en checkout (válido/inválido/vencido, uno por orden, descuento acotado al total).

### Vendedor
- Publicar producto (campos obligatorios, precio>0, stock≥0, ≥1 imagen).
- Gestión de stock y publicaciones: editar, actualizar stock, habilitar/deshabilitar, owner-only y gestión de imágenes (reordenar/eliminar/mín. 1).
- Historial de ventas con detalle (dirección de entrega), cambio de estado y filtro por estado.
- Optativa: crear y gestionar cupones (código único global, 1–100 %, vencimiento, desactivación, listado propio).

### Wishlist y Notificaciones
- Optativas: agregar/quitar de wishlist con indicador en catálogo y detalle; visualización de wishlist con estados sin stock / no disponible y estado vacío.
- Optativas: notificación push de cambio de estado de orden (con deep link al detalle) y notificación de stock bajo / agotado al vendedor.

### Backoffice / Administración
- Listado de usuarios paginado con búsqueda; bloqueo/desbloqueo (oculta los productos del usuario).
- Listado y moderación de productos en todos los estados, deshabilitar/rehabilitar y detalle con historial de cambios.
- Listado de órdenes paginado, filtro por estado, búsqueda por ID y modo solo lectura.
- Manejo de sesión con cookies httpOnly + CSRF double-submit y refresh de token.

### Métricas
- Métricas del sistema: usuarios registrados, órdenes por estado y evolución temporal, monto transaccionado y ranking de más vendidos, con períodos de 7/30/90 días.
- Optativas: métricas por categoría y exportación a CSV de descarga inmediata.

### Observabilidad y resiliencia
- **Consistencia distribuida (SAGA)**: checkout como saga por **coreografía** con compensaciones explícitas (reservar stock → crear orden → cobrar → commit/release) y ventana de gracia ante timeout.
- **Idempotencia**: clave persistida en `orders`, deduplicación y propagación al gateway de pagos.
- **Resiliencia entre servicios**: circuit breaker (`gobreaker`) + retry con backoff exponencial, con clasificación de fallos transitorios vs. permanentes.
- **Health checks diferenciados** `/livez` (sin DB) y `/readyz` (verifica DB) en todos los servicios; **logs estructurados** JSON con niveles (con enmascarado de PII en `users-api`); **trazabilidad** vía `X-Request-ID`.
- **Observabilidad**: cada API expone `/metrics` (Prometheus); stack push-model (Prometheus + Pushgateway + Grafana + Caddy TLS) en VM, más cAdvisor y dashboards locales.
- **Despliegue en la nube** multi-cloud documentado en ADR (Render, Neon, Oracle Cloud, Upstash, GitHub Pages, Cloudinary); entorno local reproducible con `docker-compose` por servicio.
- **CI/CD**: GitHub Actions en push/PR bloquea el merge ante fallos; CD automático (Render para backends, GitHub Pages para backoffice, EAS → GitHub Release APK para la app).
- **Documentación**: README por repo, OpenAPI/Swagger autogenerado (users/items/orders/metrics), diagramas **C4** y **12 ADRs**.

### Testing y calidad
- Tests unitarios e integración **a nivel de cada servicio** (handlers contra su propia base de datos real, con dependencias externas mockeadas); CI con gate de cobertura **≥70 %** en los 4 backends (Testcontainers en Python, `testing` stdlib en Go).
- **Pruebas de carga y estrés (k6)**: escenarios smoke / load / stress / capacity / concurrency, con resultados documentados (latencias p50/p95/p99, tasa de errores y capturas de Grafana) en `docs/performance/`.

### Pendientes / deuda técnica
- **Tests de integración entre servicios**: quedan pendientes; la integración se cubre a nivel de cada servicio con dependencias mockeadas, pero no hay una suite que ejercite el flujo real entre microservicios levantados en conjunto (el flujo extremo a extremo del comprador sí se valida con las pruebas de carga/estrés de k6).
- **Contract testing ausente**: hay OpenAPI como fuente de verdad pero sin verificación automatizada (Pact/Schemathesis/Dredd).
- **Retrospectiva final**: pendiente de redactar.

---

## Cobertura de historias

### Obligatorias — 21 / 21 cerradas → **63 / 63 pts (100 %)**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---:|---|
| 1 | Registro de usuarios | Usuarios | 2 | Done |
| 2 | Login con email y contraseña | Usuarios | 2 | Done |
| 3 | Recupero de contraseña | Usuarios | 3 | Done |
| 4 | Edición de perfil | Perfil | 3 | Done |
| 5 | Visualización de perfil propio | Perfil | 1 | Done |
| 6 | Home | Catálogo | 3 | Done |
| 7 | Listado y búsqueda de productos | Catálogo | 3 | Done |
| 8 | Detalle de producto | Catálogo | 2 | Done |
| 9 | Agregar producto al carrito | Carrito | 2 | Done |
| 10 | Gestión del carrito | Carrito | 3 | Done |
| 11 | Checkout e inicio de pago | Checkout y Órdenes | 8 | Done |
| 12 | Estado y seguimiento de orden | Checkout y Órdenes | 5 | Done |
| 13 | Historial de compras | Checkout y Órdenes | 2 | Done |
| 14 | Publicar producto | Vendedor | 3 | Done |
| 15 | Gestión de stock y publicaciones | Vendedor | 3 | Done |
| 16 | Historial de ventas | Vendedor | 3 | Done |
| 17 | Listar usuarios del sistema | Administración | 1 | Done |
| 18 | Bloquear y desbloquear usuario | Administración | 2 | Done |
| 19 | Listar y moderar productos | Administración | 5 | Done |
| 20 | Listar órdenes del sistema | Administración | 2 | Done |
| 21 | Métricas del sistema | Métricas | 5 | Done |

#### Avance obligatorio

| Estado | Historias | Pts | % obligatorio |
|---|---:|---:|---:|
| Done | 21 | 63 | 100 % |

### Optativas — 12 / 21 cerradas → **33 pts**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---:|---|
| 24 | Visualización de perfil público | Perfil | 2 | Done |
| 25 | Compartir link de producto | Catálogo | 2 | Done |
| 27 | Filtros avanzados de búsqueda | Catálogo | 3 | Done |
| 28 | Ordenamiento de resultados | Catálogo | 2 | Done |
| 29 | Agregar / quitar de wishlist | Wishlist | 2 | Done |
| 30 | Visualización de wishlist | Wishlist | 2 | Done |
| 33 | Crear y gestionar cupones de descuento | Vendedor | 5 | Done |
| 34 | Aplicar cupón en checkout | Checkout y Órdenes | 3 | Done |
| 37 | Notificación de cambio de estado de orden | Notificaciones | 5 | Done |
| 38 | Notificación de stock bajo al vendedor | Notificaciones | 2 | Done |
| 40 | Métricas por categoría | Métricas | 3 | Done |
| 41 | Exportar datos de métricas | Métricas | 2 | Done |

**Avance respecto del Checkpoint 3:** se cerraron las tres historias que quedaban abiertas — **Aplicar cupón en checkout** (era parcial), **Métricas por categoría** y **Exportar métricas** (estaban en backlog).

#### Optativas no implementadas

| # | Historia | Épica | Pts | Estado |
|---|---|---|---:|---|
| 22 | Login con proveedor federado | Usuarios | 3 | No implementada |
| 23 | Registro con PIN | Usuarios | 2 | No implementada |
| 26 | Productos populares en home | Catálogo | 3 | No implementada |
| 31 | Calificar producto y vendedor | Reviews | 5 | No implementada |
| 32 | Reputación del vendedor en perfil público | Reviews | 3 | No implementada |
| 35 | Cancelar orden | Checkout y Órdenes | 3 | No implementada |
| 36 | Reembolso simulado al cancelar | Checkout y Órdenes | 2 | No implementada |
| 39 | Recomendaciones basadas en historial | Recomendaciones | 5 | No implementada |
| 42 | Registro con datos biométricos | Usuarios | 3 | No implementada |

> Los estados de excepción `cancelada`, `reembolso en proceso` y `reembolso procesado` **están contemplados en el modelo de datos** de `orders-api` (como pide el enunciado), aunque las transiciones hacia ellos no están disponibles en la UI por no haberse implementado las historias optativas correspondientes.

---

## Resumen global

- **Obligatorias**: 63 / 63 pts (**100 %**)
- **Optativas cerradas**: 33 pts
- **Total cerrado**: **96 pts** (63 obligatorias + 33 optativas)
