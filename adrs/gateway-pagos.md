---
title: "Gateway de pagos: Stripe"
parent: ADRs
nav_order: 7
---

# Gateway de pagos: Stripe

## Estado

Aceptado.

## Contexto

El flujo de checkout necesita cobrar pagos con tarjeta de forma real contra un proveedor externo. Para el alcance del TP se requería un gateway que:

- ofreciera un entorno de pruebas (modo test) sin movimiento de dinero real,
- expusiera tarjetas de prueba para simular tanto aprobaciones como rechazos (fondos insuficientes, tarjeta robada, etc.),
- tuviera un SDK oficial mantenido para el lenguaje del servicio de órdenes (Go),
- soportara idempotencia nativa para reintentos seguros.

El cobro se implementa en [orders-api](../servicios/orders-api), en `StripePaymentGateway`, usando PaymentIntents (`Confirm: true`) con clave de idempotencia por intento de cobro.

## Decisión

Se eligió **Stripe** como gateway de pagos, integrado mediante el SDK oficial `stripe-go/v82` y operando en **modo test** con claves `sk_test_…`.

La moneda de cobro es **USD** (`Currency: "usd"`).

### Opciones consideradas

- **Stripe en ARS:** se descartó porque en modo test, con moneda ARS, las tarjetas mock que simulan rechazos (fondos insuficientes y demás códigos de error) no disparan el comportamiento esperado. Como necesitábamos poder probar el camino de pago rechazado de punta a punta, no era viable.
- **Stripe en USD (elegida):** las tarjetas de prueba de rechazo funcionan correctamente, lo que permite ejercitar tanto el camino feliz como los rechazos. La contrapartida es la limitación de montos descrita abajo.

## Consecuencias

- El cobro queda atado a USD para que las tarjetas de prueba de rechazo funcionen, lo que habilita probar el flujo completo de aprobación y rechazo.
- **Limitación de montos del checkout** (derivada de los límites de Stripe para PaymentIntents en USD): el total a cobrar debe ser:
  - **mayor o igual a 0,50 USD**, y
  - **menor o igual a 999.999,99 USD**.

  Un checkout fuera de ese rango es rechazado por el gateway, por lo que la validación de montos debe respetar esos límites aguas arriba.
- Al operar en modo test no hay movimiento de dinero real; las claves productivas (`sk_live_…`) quedarían fuera del alcance del TP.
- El SDK oficial de Go simplifica la integración (manejo de errores tipados, idempotencia nativa); ver [Monto mínimo por ítem para pagos con Stripe](monto-minimo-items) para la consecuencia relacionada a nivel de ítem.
