---
title: orders-api
parent: Servicios
nav_order: 4
---

# orders-api

Servicio encargado del flujo de compra. Integra con **Stripe** para el procesamiento de pagos externos.

{: .note }
Este servicio está en desarrollo. La documentación se completará próximamente.

## Responsabilidades

- Gestionar el ciclo de vida de una orden (creación, confirmación, cancelación)
- Integrar con la pasarela de pagos (Stripe)
- Publicar eventos de órdenes hacia `metrics-api`

## Base de datos

Posee su propia base de datos PostgreSQL dedicada (Neon).
