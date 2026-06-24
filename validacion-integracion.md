---
title: Validación de Integración
nav_order: 5
---

# Validación de integración del flujo crítico

Esta guía documenta cómo validar el flujo crítico de compra contra los servicios remotos antes de aprobar un cambio que vaya a producción.

## Regla operativa

Cada vez que se realiza un cambio con destino a producción se debe ejecutar esta prueba de integración de punta a punta.

No alcanza con que pasen los tests unitarios o los checks de CI de cada servicio. Si el smoke del flujo crítico falla, el cambio no debe promoverse a producción hasta entender la causa y corregirla.

## Qué valida esta prueba

El smoke definido en [`performance-tests/scenarios/smoke/buyer-flow.js`](../performance-tests/scenarios/smoke/buyer-flow.js) recorre una compra mínima a través del API Gateway y verifica:

1. `POST /auth/token`
2. `GET /items` y `GET /items/:id`
3. `DELETE /carts/me` y `POST /carts/me/items`
4. `POST /orders/checkout`
5. `PATCH /items/:id` durante el teardown

Con una sola ejecución alcanza para detectar si un cambio rompió la integración entre `gateway-api`, `users-api`, `items-api` y `orders-api`.

## Precondiciones

- Tener Docker disponible, porque `k6` corre en contenedor.
- Ejecutar los comandos desde la raíz del repositorio.
- Usar el ambiente remoto correcto a través de la URL pública del Gateway.
- Contar con los datos de prueba configurados en [`performance-tests/config/test-data.json`](../performance-tests/config/test-data.json).

## Paso 1: mantener despiertos los servicios remotos

Render puede dormir servicios por inactividad. Antes de correr el smoke, dejar abierta una terminal manteniendo vivos los servicios con [`docs/scripts/keep-awake.sh`](scripts/keep-awake.sh):

```bash
./docs/scripts/keep-awake.sh
```

El script hace ping periódico a los endpoints públicos y evita cold starts durante la validación. Debe quedar corriendo hasta terminar la prueba.

## Paso 2: preparar la configuración del smoke

En otra terminal, crear el archivo de entorno de `performance-tests` si todavía no existe:

```bash
cp performance-tests/.env.example performance-tests/.env
```

Para correr contra Render, reemplazar `BASE_URL` por la URL pública del Gateway. Por ejemplo:

```bash
BASE_URL=https://gateway-api-ih4e.onrender.com
```

Se recomienda conservar:

```bash
PAYMENT_METHOD_ID=mock_ok_loadtest
```

Ese valor usa el pago simulado y evita depender de Stripe para esta validación corta.

## Paso 3: ejecutar el smoke contra el ambiente remoto

Desde la raíz del repo:

```bash
make -C performance-tests smoke BASE_URL=https://gateway-api-ih4e.onrender.com
```

Si se quiere dejar explícito también el medio de pago de prueba:

```bash
make -C performance-tests smoke \
  BASE_URL=https://gateway-api-ih4e.onrender.com \
  PAYMENT_METHOD_ID=mock_ok_loadtest
```

## Criterio de aprobación

La validación se considera exitosa solamente si:

- el comando termina con exit code `0`;
- no falla ningún `check` del escenario;
- `http_req_failed` queda en `0`;
- el checkout devuelve `201` y resultado `approved`.

Si cualquiera de esos puntos falla, el cambio debe tratarse como bloqueo de release.

## Cuándo correrla

Esta prueba debe ejecutarse, como mínimo, en estos casos:

- antes de desplegar un cambio que afecte el flujo de compra;
- antes de promover cambios en `gateway-api`, `users-api`, `items-api` u `orders-api`;
- después de modificar autenticación, carrito, checkout, catálogo o pagos;
- después de cambios de configuración, infraestructura o dependencias que puedan afectar la integración.

## Alcance y objetivo

Esta no es una prueba de carga ni de capacidad. Su objetivo es validar rápido que el flujo crítico de negocio siga funcionando de punta a punta sobre el ambiente remoto.

Si se necesita analizar rendimiento o concurrencia, usar los demás escenarios documentados en [`performance-tests/README.md`](../performance-tests/README.md).
