---
title: Arquitectura
nav_order: 2
---

# Arquitectura del Sistema

## Visión General

El sistema está diseñado como una arquitectura de **microservicios** con un API Gateway centralizado que actúa como punto de entrada único para todos los clientes.

---

## Componentes

### Cliente

- **Aplicación mobile** (`app`): Expo / React Native. Es el cliente principal para usuarios finales.
- **Backoffice** (`backoffice`): React + Vite. Panel de administración web.

Ambos clientes se comunican exclusivamente a través del **API Gateway**.

---

### API Gateway (`gateway-api`)

Punto de entrada centralizado basado en **Kong DB-less**. Enruta las solicitudes hacia los microservicios, valida tokens JWT (RS256), extrae el ID del usuario (claim `sub`) y lo inyecta como header `X-User-Id` hacia los microservicios internos. Las llamadas service-to-service se autentican con el header `X-Internal-Key`. En cada request a rutas protegidas consulta una blacklist en **Redis** para revocar al instante a los usuarios baneados (ver [Revocación de JWT](revocacion-jwt)).

---

### Microservicios

#### `users-api`

Registro, autenticación y perfil de usuarios. Maneja recuperación de contraseña por mail (SendGrid) y registro de push tokens de Expo.

- Lenguaje: **Python / FastAPI**
- Base de datos: PostgreSQL (Neon)

#### `items-api`

Catálogo de productos y cupones de descuento.

- Lenguaje: **Go**
- Base de datos: PostgreSQL (Neon)

#### `orders-api`

Carrito y flujo de compra. Procesa pagos a través de una pasarela (Stripe en producción, mock en desarrollo), valida cupones contra `items-api`, envía push notifications vía Expo y reporta cambios de estado de órdenes a `metrics-api`.

- Lenguaje: **Go**
- Base de datos: PostgreSQL (Neon)

#### `metrics-api`

Agrega eventos del sistema para el backoffice: usuarios registrados y cambios de estado de órdenes. Expone métricas por período (7, 30 o 90 días).

- Lenguaje: **Python / FastAPI**
- Base de datos: PostgreSQL (Neon)
- Autenticación interna mediante header `X-Internal-Key`.

---

## Comunicación entre servicios

- `orders-api` consulta a `items-api` para validar items y cupones.
- `orders-api` consulta a `users-api` para obtener push tokens de Expo.
- `orders-api` y `users-api` reportan eventos a `metrics-api`.
- Todas las llamadas internas viajan con `X-Internal-Key`.

---

## Principios de Diseño

- **Separación de responsabilidades**: cada microservicio tiene su dominio acotado y su propia base de datos.
- **Base de datos por servicio**: ningún servicio accede directamente a la base de datos de otro.
- **Gateway único**: los clientes no conocen la topología interna. Toda comunicación pasa por la API Gateway.
- **Métricas desacopladas**: los servicios publican eventos a `metrics-api` sin bloquear su flujo principal.
