---
title: backoffice
parent: Servicios
nav_order: 7
---

# backoffice

Panel de administración web del sistema. Construido con **React + Vite + TypeScript**. Consume el backend a través del API Gateway.

## Responsabilidades

- Administración del catálogo de productos.
- Gestión de órdenes.
- Visualización de métricas del sistema (usuarios registrados y órdenes por estado).
- Autenticación de administradores.

## Autenticación

A diferencia de la app mobile (que manda el JWT como `Authorization: Bearer`), el backoffice usa un esquema basado en **cookies httpOnly + CSRF**:

- El token de acceso viaja en una cookie httpOnly (`admin_access_token`); el JavaScript del frontend no lo lee. Las requests se hacen con `credentials: 'include'` para que el navegador adjunte la cookie.
- Contra CSRF se usa **double-submit token**: el cliente manda el header `X-CSRF-Token` (`backoffice/src/services/api.ts`), que Kong valida contra la cookie `admin_csrf_token` en las operaciones que mutan estado.
- Kong reconoce la cookie como fuente del JWT (`cookie_names: [admin_access_token]`) y, tras validarlo, inyecta `X-User-Id` y `X-User-Role` hacia los microservicios.
