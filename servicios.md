---
title: Servicios
nav_order: 5
has_children: true
---

# Servicios

Documentación de cada microservicio del sistema.

| Servicio | Tecnología | Descripción |
|---|---|---|
| [gateway-api](servicios/gateway-api) | Kong DB-less | API Gateway centralizado, autenticación JWT |
| [users-api](servicios/users-api) | Python / FastAPI | Gestión de usuarios y autenticación |
| [items-api](servicios/items-api) | Go | Catálogo de productos y cupones |
| [orders-api](servicios/orders-api) | Go | Carrito, órdenes y pagos |
| [metrics-api](servicios/metrics-api) | Python / FastAPI | Agregación de métricas del sistema |
| [app](servicios/app) | Expo / React Native | Aplicación mobile |
| [backoffice](servicios/backoffice) | React / Vite | Panel de administración web |
