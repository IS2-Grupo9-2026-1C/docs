---
title: Descomposición en microservicios y bounded contexts
parent: ADRs
nav_order: 1
---

# Descomposición en microservicios y bounded contexts

## Estado

Aceptado.

## Contexto

El enunciado exige una arquitectura de microservicios con **una base de datos por servicio** (acceder a la base de otro servicio es una red line). La identificación de los dominios y la descomposición en servicios quedan a criterio del grupo, pero deben justificarse como decisión de arquitectura.

El marketplace tiene concerns claramente distintos: la **identidad** de las cuentas, el **catálogo** que publican los vendedores, la **compra** que hacen los compradores y la **analítica** que consume el backoffice. La pregunta no era si separar, sino **dónde trazar los límites** y **con qué granularidad**: cuántos servicios, y dónde viven piezas ambiguas como el carrito, los cupones y las métricas.

## Decisión

Cuatro microservicios de dominio, cada uno con su propia base PostgreSQL, detrás de un [API Gateway centralizado](api-gateway):

- **`users-api` — Identidad y cuentas.** Registro, login, recupero de contraseña, perfil, push tokens y la gestión de administración (bloqueo/desbloqueo de usuarios). Es la **fuente de verdad de la identidad**: el gateway valida los tokens que emite y el resto de los servicios confía en el `X-User-Id` ya validado, sin volver a consultarlo en cada request.
- **`items-api` — Catálogo.** Productos, stock, imágenes **y cupones de descuento**. El cupón vive acá porque lo crea y administra el vendedor sobre su propio catálogo (código único global, porcentaje, vencimiento); es un concern del catálogo, no de la compra.
- **`orders-api` — Compra.** Carrito, checkout, pagos y el ciclo de vida de las órdenes (estados, tracking, cancelación). El **carrito vive acá** porque es la antesala de la orden: comparte ítems, validación de stock y el flujo de compra. Es el orquestador de la saga de checkout (ver [consistencia distribuida](consistencia-distribuida)).
- **`metrics-api` — Analítica.** Agrega eventos del sistema (usuarios registrados, cambios de estado de órdenes) y los expone por período al backoffice. Tiene un patrón de acceso propio —escritura de eventos en caliente, lectura agregada— que conviene aislar del camino transaccional.

### Decisiones de límite y opciones consideradas

- **Carrito dentro de `orders-api`** (no como servicio propio): un servicio de carrito separado insertaría una frontera de red en medio del flujo más crítico sin un dominio propio que lo justifique. El carrito y la orden son el mismo contexto de compra en dos momentos.
- **Cupones en `items-api`** (no en `orders-api`): el cupón es del dominio del vendedor/catálogo. `orders-api` lo valida y redime durante el checkout mediante una llamada a `items-api`, sin que el dato tenga dueño compartido.
- **`metrics-api` separado** (no embebido en cada servicio): mantener la analítica aparte evita contaminar las bases operativas con tablas de agregación y permite que los servicios **publiquen eventos sin bloquear** su flujo principal (ver [observabilidad push vs. pull](observabilidad-push-vs-pull)).
- **Pagos como interfaz, no como servicio:** se evaluó un servicio de pagos aparte y se descartó. El desacople se obtiene con una interfaz `PaymentGateway` dentro de `orders-api` (Stripe en prod, mock en test; ver [gateway de pagos](gateway-pagos)), sin el costo de otro servicio, base y despliegue.
- **Monolito modular:** descartado por el requisito de microservicios con bases independientes.
- **Granularidad mayor** (auth separado de perfil, catálogo separado de cupones): descartada por sobre-ingeniería a la escala del TP; agrega contratos y despliegues sin un beneficio de dominio claro.

## Consecuencias

- Cada servicio tiene su propia base PostgreSQL y ningún servicio accede a la base de otro: la red line de base de datos por servicio queda satisfecha por diseño.
- Los flujos que cruzan servicios (checkout: `items` + `orders` + `users`; reportes a `metrics`) se resuelven con comunicación HTTP **síncrona** y una **saga orquestada por `orders-api`** (ver [consistencia distribuida](consistencia-distribuida)); el acoplamiento en runtime se mitiga con retry + circuit breaker, no se elimina.
- **Datos duplicados por diseño:** las órdenes conservan un snapshot de los ítems al momento de la compra (nombre, precio), porque esos datos pueden cambiar luego en `items-api` y el historial debe quedar fijo.
- La separación habilita el stack poliglota (Python en `users`/`metrics`, Go en `items`/`orders`); la justificación de lenguajes y persistencia vive en el [tech stack](../tech-stack).
- La identidad transversal reduce el chatter entre servicios: nadie reconsulta `users-api` para autorizar, porque confían en los headers que el gateway ya validó.
- A cambio se acepta más superficie operativa (varias bases, despliegues y contratos a mantener), un costo alineado con el objetivo del TP.
