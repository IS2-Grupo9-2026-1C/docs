---
title: Clave interna entre servicios
parent: ADRs
nav_order: 5
---

# Clave interna entre servicios

## Estado

Aceptado.

## Contexto

El plan de despliegue (ver [Despliegue en la nube](despliegue-nube)) usa Render en su tier gratuito. A diferencia de plataformas con redes privadas, Render free tier no permite comunicación directa entre servicios por IP o dominio interno: cada servicio solo es alcanzable mediante su URL pública (`*.onrender.com`).

Esto crea un problema para los endpoints diseñados exclusivamente para tráfico interno — por ejemplo, `GET /internal/users/{id}/devices` (push tokens para notificaciones) y `POST /internal/devices/prune` (limpieza de tokens vencidos), que `orders-api` e `items-api` llaman a `users-api` al despachar compras. Estos endpoints **deben estar expuestos en internet** para que otros servicios los alcancen, pero no deben ser utilizables por usuarios finales ni por terceros.

El gateway (ver [API Gateway centralizado](api-gateway)) actúa como único punto de entrada para el tráfico de usuarios, pero los llamados service-to-service no pasan por él: van directamente de un backend al otro usando su URL pública. No existe un mecanismo de red que los aísle.

## Decisión

Se definió una **clave compartida** (`INTERNAL_KEY`) que actúa como secreto de servicio: cualquier llamado dirigido a un endpoint interno debe incluir el header `X-Internal-Key` con el valor correcto.

El mecanismo opera en dos capas:

**Kong (gateway):** El plugin `request-transformer` sobreescribe el header `X-Internal-Key` en cada request proxied hacia los upstreams (`users-service`, `items-service`, `orders-service`, `metrics-service`), eliminando primero cualquier valor que hubiera mandado el cliente y luego inyectando el valor configurado. Así, todo tráfico que pase por Kong llega a los backends con la key correcta, sin que el cliente final pueda inyectarla ni manipularla.

**Middleware en cada servicio:** Cada backend valida el header al inicio del ciclo de vida del request. En `users-api` y `metrics-api` (Python) hay un middleware HTTP global que rechaza con `401` cualquier request sin la key válida, excluyendo los paths de health (`/livez`, `/readyz`, `/metrics`). En `items-api` y `orders-api` (Go), el middleware equivalente aplica sobre todas las rutas, con el mismo comportamiento cuando `INTERNAL_KEY` no está configurada: ningún request es aceptado.

**Clientes service-to-service:** Cuando un servicio llama a otro directamente (e.g. `items-api` → `users-api` para obtener push tokens del vendedor), el cliente HTTP incluye el header `X-Internal-Key` de forma explícita en cada request.

## Consecuencias

- Los endpoints `/internal/*` quedan accesibles en internet pero rechazarán cualquier request sin la key correcta, lo que los protege del uso no autorizado sin requerir red privada.
- La clave es un secreto compartido entre todos los servicios y el gateway: un leak de `INTERNAL_KEY` permite a cualquier caller externo impersonar un servicio interno. La clave debe rotarse coordinadamente en todas las variables de entorno si se compromete.
- En desarrollo local el middleware está desactivado (`environment == "development"`), por lo que no interfiere con el flujo de trabajo sin necesidad de configurar la variable.
