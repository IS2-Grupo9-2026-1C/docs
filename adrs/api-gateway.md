---
title: API Gateway centralizado
parent: ADRs
nav_order: 3
---

# API Gateway centralizado

## Estado

Aceptado.

## Contexto

La arquitectura de microservicios utilizada genera la necesidad de implementar un API Gateway que centralice el enrutamiento hacia los distintos servicios backend. La validación de tokens de sesión y el rate limiting son cuestiones de seguridad y protección perimetral dentro de nuestra arquitectura, lo que reafirma la necesidad de tener microservicios desacoplados de esto y un gateway que centralice esta lógica.

## Decisión

Se implementó API Gateway basado en Kong DB-less; la implementación detallada se encuentra en [gateway-api](../servicios/gateway-api).

### Opciones consideradas

- **Kong con base de datos (PostgreSQL):** Kong soporta un modo con base de datos que habilita una Admin API dinámica y plugins adicionales. Se descartó porque para el alcance del TP toda la configuración puede vivir en un único `kong.yml` declarativo; agregar una base de datos solo por el gateway hubiera sumado complejidad operativa sin beneficio real.
- **Nginx (configuración manual):** En una etapa inicial se evaluó usar Nginx directamente como reverse proxy. Se descartó porque implementar validación JWT, rate limiting e inyección de headers requería módulos externos y Lua custom, replicando a mano lo que Kong ya provee de forma declarativa.

## Consecuencias

- Toda la configuración del gateway — rutas, plugins, upstreams — vive en un único `kong.yml`. Agregar un nuevo servicio o endpoint es cuestión de añadir unas líneas al archivo y reiniciar el container; no hay Admin API ni estado externo que sincronizar.
- Los plugins de JWT, rate limiting, CORS y CSRF se activan por ruta con pocas líneas de configuración, sin escribir código.
- El modo DB-less implica que los cambios requieren redeploy del container (no hay hot-reload dinámico), lo cual es aceptable para el ritmo de cambios de un TP.
- Los microservicios quedan completamente desacoplados de la lógica de autenticación y protección perimetral; confían en los headers `X-User-Id` y `X-User-Role` que el gateway ya validó.
