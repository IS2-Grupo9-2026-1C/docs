---
title: Monto mínimo por ítem para pagos con Stripe
parent: ADRs
nav_order: 9
---

# Monto mínimo por ítem para pagos con Stripe

## Estado

Aceptado.

## Contexto

El gateway de pagos es Stripe (ver [Gateway de pagos: Stripe](gateway-pagos)) y los cobros se hacen en **dólares (USD)**. Stripe solo acepta cargos en el rango **US$0.50 – US$999.999,99**, así que existen un piso y un techo de monto impuestos por el gateway, no por una regla de negocio propia.

Una primera implementación validaba el total del checkout contra ese rango en el backend (devolviendo un error de rango de monto) y replicaba los mismos límites en el frontend para anticipar el error. Al revisarlo, concluimos que **acoplar el producto a un mínimo y un máximo duros empeora el concepto**: un marketplace no debería rechazar ítems por su precio ni exhibir topes artificiales que en realidad son una limitación del medio de pago elegido.

## Decisión

**No establecemos un mínimo ni un máximo de monto propios.** Se removieron tanto la validación del backend como los límites del frontend. El checkout cobra el total tal cual.

Las únicas restricciones que quedan son las de **Stripe en USD**: un total fuera del rango del gateway —inferior a ~US$0.50 o superior a US$999.999,99— será rechazado por el propio Stripe al momento del cobro. Aceptamos esos límites como contrapartida de haber elegido Stripe en dólares, en lugar de codificar topes en nuestro dominio.

## Consecuencias

- El producto no impone topes artificiales de precio: no se acota el catálogo ni el monto de compra por una restricción que es del medio de pago.
- Persisten los límites de Stripe-en-USD (piso ~US$0.50 y techo US$999.999,99): un total fuera de ese rango falla en el gateway con un error genérico, **sin un mensaje anticipado** que lo explique (es el trade-off de no validar de antemano).
- Si en el futuro se quisiera dar un mensaje claro para esos casos sin reintroducir validación de negocio, podría anticiparse el rango exacto de Stripe (piso y techo), dejando claro que ambos son límites del gateway y no topes propios. Cambiar de moneda o de gateway (ver [Gateway de pagos: Stripe](gateway-pagos)) movería o eliminaría ese rango.
