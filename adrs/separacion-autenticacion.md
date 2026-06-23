---
title: Separación de autenticación usuarios y admins
parent: ADRs
nav_order: 10
---

# Separación de autenticación usuarios y admins

## Estado

Aceptado.

## Contexto

El TP requiere que un administrador no pueda bloquearse a sí mismo (CA 4). La forma naive de cumplirlo sería agregar una validación explícita en el endpoint de bloqueo: comparar el `user_id` del target con el `admin_id` del caller y rechazar si coinciden. Pero el problema con esa solución es que asume que usuarios y admins comparten espacio de identidad, lo cual no es necesariamente cierto ni deseable.

## Decisión

Usuarios y administradores son **entidades separadas**: tablas distintas (`users` y `admins`), modelos distintos, y flujos de autenticación distintos (`/auth/token` vs `/auth/admin/token`). El modelo `Admin` no tiene campo `is_active` ni ningún concepto de bloqueo asociado.

El endpoint `POST /users/{user_id}/block` opera exclusivamente sobre `user_repository` — busca un `User` por id. No existe ninguna ruta para bloquear un admin, y el concepto de "bloquear" simplemente no aplica a esa entidad.

## Consecuencias

- CA 4 queda satisfecha por diseño estructural, sin ningún `if admin_id == user_id` en el código.
- Los IDs de usuarios y admins son secuencias independientes: el admin con id `5` y el usuario con id `5` son entidades distintas sin relación.
- No hay forma de que un admin se bloquee a sí mismo porque no existe una operación de bloqueo sobre admins.
