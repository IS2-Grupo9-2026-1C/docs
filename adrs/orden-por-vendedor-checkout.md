---
title: Orden por vendedor en checkout
parent: ADRs
nav_order: 10
---

# Orden por vendedor en checkout

## Estado

Aceptado.

## Contexto

La plataforma es un marketplace multi-vendedor: un mismo carrito puede tener ítems de distintos vendedores. Al pagar, hay que decidir cómo se materializa esa compra en órdenes. Las dos opciones son:

- **Una orden única consolidada** por checkout (todos los ítems, sin importar el vendedor, en una sola orden).
- **Una orden por vendedor:** el checkout parte el carrito por vendedor y genera una orden por cada uno, con un único cobro por el total.

El punto clave es que cada vendedor gestiona su parte de la venta de forma independiente —confirma, prepara y envía a su ritmo— y debe ver y operar solo lo suyo.

## Decisión

Elegimos **una orden por vendedor**. Un checkout agrupa el carrito por vendedor y crea una orden por cada uno; el cobro es **único** por el total de la compra. Cada vendedor avanza el ciclo de estados de su orden (pendiente de pago → confirmada → enviada → entregada) y solo accede a sus propias ventas.

Razones frente a la orden única consolidada:

- **Fulfillment independiente:** no tiene sentido un estado global único cuando varios vendedores despachan por separado y en tiempos distintos.
- **Modelo de dominio limpio:** una orden pertenece a un solo vendedor (relación 1:1). Esto simplifica permisos, historial de estados, tracking y métricas por vendedor.
- **Tracking y envío por vendedor:** el código de seguimiento, "marcar como enviada" y "confirmar entrega" aplican naturalmente a la orden de cada vendedor.
- **Realismo de marketplace:** es el comportamiento esperado (como en MercadoLibre o Amazon): un carrito con varios vendedores produce varios pedidos.
- **Aislamiento:** un problema con los ítems de un vendedor queda acotado a su orden.

Se resigna la simplicidad de la orden única: una relación pago↔orden de uno a uno, una vista de "una compra = un pedido" y una cancelación total más directa.

## Consecuencias

- Un único cobro puede generar varias órdenes. Para que la idempotencia funcione por orden, la clave de idempotencia lleva un sufijo por vendedor (ver [Estrategia de consistencia distribuida, idempotencia y retry/backoff](consistencia-distribuida)).
- Desde la vista del comprador, una sola compra puede aparecer como varios pedidos; la UI debe comunicarlo con claridad.
- Cancelaciones o reembolsos totales requieren coordinar varias órdenes en lugar de una.
- A cambio, vendedores, estados, envíos y métricas quedan modelados de forma natural y desacoplada por vendedor.
