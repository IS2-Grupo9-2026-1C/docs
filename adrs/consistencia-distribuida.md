---
title: Estrategia de consistencia distribuida, idempotencia y retry/backoff
parent: ADRs
nav_order: 3
---

# Estrategia de consistencia distribuida, idempotencia y retry/backoff

## Estado

Aceptado.

## Contexto

El checkout es el flujo crítico del sistema y atraviesa varios servicios en una sola operación de usuario: items-api (reserva de stock y validación/redención de cupones), orders-api (creación y confirmación de órdenes) y Stripe (cobro). Un fallo parcial —por ejemplo, el pago se confirma pero falla la creación o confirmación de la orden— no puede dejar el sistema inconsistente: no debe haber stock descontado sin orden, ni cobro sin orden, ni cupón redimido sin compra.

La comunicación entre servicios es HTTP **síncrona**: no se adoptan colas de mensajes en esta etapa, porque agregan un componente de infraestructura a operar cuya complejidad excede la escala del proyecto, y los flujos críticos se resuelven con los mecanismos que describe esta decisión. La única asincronía son tareas en proceso, no durables, para trabajo no crítico (notificaciones push, métricas). Como no hay coordinador transaccional entre servicios heterogéneos más un gateway de pago externo, una transacción distribuida ACID (2PC) no es viable.

Por ser síncrona, cada llamada entre servicios puede fallar por causas transitorias (hipo de red, error de servidor puntual, pico de latencia) o permanentes (error de cliente, error de dominio). Tratarlas igual es un error: reintentar un fallo permanente es inútil; no reintentar uno transitorio aborta operaciones recuperables. Además, un servicio caído no debe arrastrar a sus llamadores en una cascada de fallos.

## Decisión

### Consistencia distribuida: saga con compensaciones

El checkout es una **saga orquestada por orders-api**, con esta secuencia: reserva de stock → creación de las órdenes (en estado "pendiente de pago") → validación y redención del cupón → cobro → commit de las reservas y confirmación de las órdenes.

- La reserva de stock es **atómica** (se bloquea la fila del ítem y se suman las reservas activas dentro de una misma transacción) y blanda, con un **TTL de 5 minutos**. El stock real solo se descuenta al confirmar la reserva, tras el pago aprobado.
- La orden se crea en estado "pendiente de pago" **antes** del cobro, para poder retomar el flujo de forma idempotente.
- Cada paso que falla se compensa: se libera el stock reservado, se revierte la redención del cupón y se marcan las órdenes como rechazadas. Las compensaciones corren en un contexto desacoplado del request (con su propio timeout), así no se cancelan si el cliente corta la conexión.
- Para el caso "pago confirmado pero falla la orden", la recuperación es **por idempotencia, no por reembolso**: el reintento con la misma clave reanuda el checkout pendiente y reintenta la confirmación sobre la orden existente.

### Idempotencia

Idempotencia explícita basada en clave donde duplicar duele (cobrar, crear orden, descontar stock); mecanismos implícitos en el resto.

- El cliente genera una **clave de idempotencia (UUID) por intento de checkout**; la conserva tras un timeout de pago y la regenera tras un rechazo definitivo.
- orders-api garantiza unicidad con un índice único sobre la combinación de usuario y clave de idempotencia, y al iniciar busca una orden previa con esa clave para reanudar en vez de duplicar.
- La misma clave se propaga a Stripe, de modo que un reintento del cobro no genera un segundo cargo.
- La confirmación de la reserva de stock es idempotente (una segunda confirmación no tiene efecto). La redención de cupón se protege con una restricción de unicidad por cupón y usuario. Operaciones como update de perfil, logout y bloqueo de usuario son idempotentes por naturaleza.

### Manejo de errores y resiliencia entre servicios

Cada cliente HTTP combina clasificación de fallos, retry y circuit breaker:

- **Clasificación:** transitorio (errores de red y de servidor → se reintenta) vs. permanente (errores de cliente y de dominio, como ítem inexistente o stock insuficiente → se propaga o compensa).
- **Retry con backoff exponencial:** 3 intentos con esperas de 100 ms, 400 ms y 1600 ms (acumulado ~2,1 s), solo sobre errores transitorios y respetando la cancelación del contexto.
- **Circuit breaker:** abre tras 5 fallas consecutivas, con ventana de conteo de 60 s, 30 s en estado abierto y un único request de prueba en half-open. Mientras está abierto, corta de inmediato en lugar de seguir golpeando al servicio caído.
- **Timeouts por cliente:** del orden de 2 s para items-api y métricas, 5 s para users-api y 10 s para push.
- El timeout del gateway de pago se trata como un resultado reintentable con la misma clave de idempotencia, no como un fallo duro.

## Consecuencias

- Ningún paso previo queda confirmado si un paso posterior falla; el sistema converge a un estado consistente (consistencia eventual), sin doble cobro ni doble orden ante reintentos.
- El stock reservado se libera solo por TTL aunque se pierda la compensación.
- Los fallos transitorios se absorben de forma transparente; los permanentes se propagan rápido con códigos de error estables (stock insuficiente, pago rechazado, cupón vencido, …). El circuit breaker evita cascadas; los timeouts acotan el peor caso de latencia (a costa de sumar hasta ~2,1 s por dependencia antes de fallar).
- Al ser comunicación síncrona, si items-api está caído el checkout se bloquea (mitigado por timeout y circuit breaker, no eliminado). El requisito condicional sobre colas no se activa; si en el futuro se adopta un broker, los consumidores deberán ser idempotentes y tolerar duplicados o mensajes fuera de orden.

**Limitaciones conocidas (trabajo futuro):**

- La confirmación de las reservas es best-effort: si falla tras un pago aprobado, el stock puede volver al pool por TTL mientras la orden queda confirmada; se registra el incidente, pero no hay reconciliación automática.
- No existe un proceso de limpieza de las órdenes que quedan en "pendiente de pago": si el usuario nunca reintenta tras un timeout, la orden queda colgada (la reserva sí se libera por TTL).
- El bloqueo de vendedor (de users-api hacia items-api) reintenta pero, si agota los intentos, solo registra el error sin compensar: puede quedar un ítem visible con su vendedor bloqueado.
- Kong no tiene healthchecks activos de upstream; la protección de cascada vive en los clientes de aplicación.
- Defectos menores: el reintento idempotente puede insertar una fila de historial "fantasma"; la confirmación de reserva no distingue "ya confirmada" de "expirada".
