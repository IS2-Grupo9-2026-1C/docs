---
title: Checkout
nav_order: 4
---

# Checkout y Órdenes

Diseño del flujo de compra de `orders-api`: cómo se reserva stock, cómo se cobra y qué decisiones se tomaron para manejar concurrencia y fallos.

## Resumen del flujo

El checkout es `POST /orders/checkout` con `{address, paymentMethodId, idempotencyKey}`. Pasa por Kong, que valida el JWT e inyecta `X-User-Id` y `X-Internal-Key`. El servicio:

1. Valida la dirección y el método de pago.
2. Chequea la `idempotencyKey` contra órdenes existentes del usuario.
3. Lee el carrito activo.
4. Reserva stock en `items-api` item por item.
5. Crea una orden por vendedor en estado `pendiente_de_pago`.
6. Cobra a través de la payment provider.
7. Según el resultado, confirma o compensa.

## Diagrama de secuencia

![Diagrama de secuencia del checkout]({{ '/assets/img/checkout-secuencia.png' | relative_url }})

## Decisiones de diseño

### Reserva de stock sin mover el stock

`items-api` no descuenta `items.stock` al reservar. Mantiene una tabla `stock_reservations` con `expires_at = NOW() + 5 min`. La disponibilidad real se calcula como:

```
available = stock - SUM(reservas activas)
```

El stock solo se decrementa cuando la orden se confirma (`commit-reservation`). Si el pago se rechaza o el gateway da timeout, se llama a `release` y la reserva se borra sin tocar el stock. Esto evita que una compra a medio terminar bloquee inventario de forma permanente.

### Borrado lazy de reservas vencidas

No hay job ni cron que limpie reservas. Cada vez que entra una reserva nueva, dentro de la misma transacción se hace primero `DELETE` de las reservas vencidas (`expires_at < NOW()`) y recién después se calcula la disponibilidad:

```
BEGIN TX
  DELETE reservas vencidas
  SELECT items FOR UPDATE
  available = stock - SUM(reservas activas)
  INSERT stock_reservations (expires_at = NOW() + 5 min)
COMMIT
```

La ventaja es que el sistema se autolimpia con el propio tráfico: una reserva huérfana (por ejemplo de un `orders-api` que crasheó antes de persistir la orden) deja de contar apenas vence, sin infraestructura extra.

### Concurrencia

Dos puntos de control:

- **Último item entre compradores**: la reserva corre dentro de `BEGIN TX` con `SELECT ... FOR UPDATE` sobre el item. El segundo comprador que llega ve la disponibilidad ya descontada por la reserva del primero y recibe `409 insufficient_stock`. El cálculo siempre es `stock - SUM(reservas activas)` bajo lock, así que no hay sobreventa.
- **Doble checkout del mismo usuario** (doble tap): al crear las órdenes se hace `SELECT ... FOR UPDATE` sobre el carrito. El segundo checkout se serializa detrás del primero y, al obtener el lock, encuentra el carrito vacío.

El siguiente diagrama muestra el caso de la reserva huérfana: el comprador 1 reserva pero su `orders-api` crashea, el comprador 2 falla mientras la reserva sigue viva, y al reintentar después de los 5 minutos el `DELETE` lazy libera la reserva huérfana y la compra avanza.

![Diagrama de concurrencia y reservas vencidas]({{ '/assets/img/checkout-concurrencia.png' | relative_url }})

### Idempotencia

El cliente manda una `idempotencyKey`. Antes de operar se busca una orden previa del mismo usuario con esa key. Si existe, se devuelve sin volver a cobrar. La misma key se reenvía al payment provider para que un reintento tras timeout no genere un doble cobro.

### Una orden por vendedor

Un carrito con items de varios vendedores genera N órdenes, una por `seller_id`, cada una con su estado, historial y total. El comprador paga una sola vez por la suma de los subtotales.

### Snapshot de precios y títulos

El precio y título usados para la orden son los que devuelve `items-api` en el momento de reservar, no los guardados en el carrito. Se copian a `order_items` como snapshot inmutable, de modo que el historial no cambia si el item se edita después.

### Payment provider desacoplado

El cobro pasa por una interfaz `PaymentGateway`. En producción se usa Stripe y en desarrollo y tests un mock. Un router elige la implementación según la configuración, así el flujo de checkout no depende del proveedor concreto.

## Manejo de resultados del pago

| Resultado | Acción |
|---|---|
| Aprobado | `commit-reservation` en cada item (descuenta stock), orden a `confirmada`, se vacía el carrito. |
| Rechazado | Orden a `pago_rechazado`, `release` de cada reserva, carrito intacto para reintentar. |
| Timeout del gateway | Orden queda en `pendiente_de_pago`, `release` de las reservas, se responde `504`. El cliente reintenta con la misma `idempotencyKey`. |

## El carrito no reserva stock

El carrito no toma reservas ni valida cantidades contra el stock. La única validación de disponibilidad por cantidad ocurre en el checkout, al reservar. Esto trae un caso a tener en cuenta.

Un usuario tiene un item en el carrito y otro usuario compra la última unidad. Cuando el primero va al checkout, la reserva falla con `409 insufficient_stock` en el paso 4, antes de crear la orden y antes de cobrar. El usuario no se cobra nada y recibe un error de stock, no un pago rechazado.

`GET /carts/me` solo marca items deshabilitados o eliminados (`has_unavailable_items`), no falta de stock. Por eso el usuario puede ver el item como disponible en el carrito y enterarse de que no hay stock recién al confirmar la compra.

## Máquina de estados

```
pendiente_de_pago --(pago aprobado)--> confirmada
pendiente_de_pago --(pago rechazado)--> pago_rechazado
pago_rechazado    --(reintento)------> pendiente_de_pago (nueva idempotencyKey)
confirmada        --(vendedor)-------> en_preparacion
en_preparacion    --(vendedor)-------> enviada
enviada           --(comprador)------> entregada
```

Los estados `cancelada`, `reembolso_en_proceso` y `reembolso_procesado` existen en el modelo pero no tienen transiciones implementadas (son optativos de la consigna).
