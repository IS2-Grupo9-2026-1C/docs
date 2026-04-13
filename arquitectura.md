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

- **Aplicación web** — accede a la plataforma desde el navegador.
- **Aplicación móvil** — accede a la plataforma desde dispositivos móviles.

Ambos clientes se comunican exclusivamente a través del **API Gateway**.

---

### API Gateway (`gateway-api`)

Punto de entrada centralizado basado en **Kong DB-less**. Enruta las solicitudes hacia los microservicios correspondientes, valida tokens JWT (RS256) y extrae el email del usuario inyectándolo como header `X-User-Email` hacia los microservicios internos.

---

### Microservicios

#### `users-api`

Gestiona todo lo relacionado con los usuarios: registro, autenticación y perfil.

- Lenguaje: **Python / FastAPI**
- Base de datos: PostgreSQL (Neon)

#### `items-api`

Gestiona el catálogo de productos.

- Lenguaje: **Go**
- Base de datos: PostgreSQL (Neon)

#### `orders-api`

Gestiona el flujo de compra. Resta definir servicio de procesamiento de pagos.

- Base de datos: PostgreSQL (Neon)

---

### `metrics-api`


---

## Principios de Diseño

- **Separación de responsabilidades**: cada microservicio tiene su dominio acotado y su propia base de datos de ser necesaria, evitando acoplamiento de datos.
- **Base de datos por servicio**: ningún servicio accede directamente a la base de datos de otro.
- **Gateway único**: los clientes no conocen la topología interna. Toda comunicación pasa por la API Gateway.
- **Métricas desacopladas**: No definido por el momento.
