---
title: "Revocación de JWT (NoSQL)"
parent: ADRs
nav_order: 5
---

# Revocación de JWT con Redis

## Contexto de la decisión

La implementación de revocación de tokens JWT fue un requisito obligatorio del trabajo práctico. Al analizar cómo cumplirlo, se evaluó usar Redis o bien una base MongoDB (por ejemplo, para almacenar el carrito de compras junto con la blacklist). Esta segunda opción fue descartada: hubiera sido una decisión forzada por la obligatoriedad del requisito, sin justificación técnica real. En cambio, Redis resuelve un problema genuino que tenía la aplicación — el baneo inmediato de usuarios con tokens aún vigentes — con una solución simple, de baja latencia y coherente con el estado de desarrollo de la plataforma.

---

Cómo se logra que un usuario baneado pierda el acceso **al instante**, en lugar de seguir operando hasta que su token expire naturalmente (~15 min).

## El problema

El JWT es **autocontenido**: cualquier servicio valida su firma sin consultar una base central. Eso lo hace rápido, pero implica que una vez emitido sigue siendo válido hasta que expira. Si un admin **banea** a un usuario, su token seguiría funcionando hasta 15 minutos más.

La solución es una **blacklist** en **Redis** (in-memory, latencia sub-ms): una marca que dice "rechazar a este usuario ahora", consultada en cada request.

## Las dos mitades

| Rol | Componente | Qué hace |
|---|---|---|
| **Writer** | `users-api` | Al banear, escribe la entrada de blacklist en Redis. |
| **Reader** | `gateway-api` (Kong) | En cada request a una ruta protegida consulta la blacklist y, si el usuario está, corta con `401`. |

Redis es la lista compartida. Ambos servicios deben apuntar al **mismo** Redis y coincidir en el formato de la clave.

## Formato de la clave

```
blacklist:user:42   →   "revoked"   (TTL: ~15 min, igual al del access token)
```

- `42` es el ID del usuario (claim `sub` del JWT).
- El **TTL** coincide con la vida del access token: cuando vence, la entrada se borra sola (no se acumula basura).
- La clave incluye el **rol** (`blacklist:user:42` vs `blacklist:admin:42`) porque usuarios y admins numeran sus IDs por separado; sin el rol, banear al user 5 también afectaría al admin 5.

## Lado writer (`users-api`)

Al bloquear un usuario, `block_user` hace tres cosas:

1. Marca al usuario como inactivo en la base (fuente de verdad).
2. Borra sus refresh tokens.
3. **Escribe `blacklist:user:<id>` en Redis** ← lo que hace el baneo instantáneo.

### Segundo candado: el chequeo en el refresh

La blacklist sólo cubre el access token corto. Para que un usuario baneado no genere un access token nuevo con su **refresh token** tras expirar la entrada, el flujo de **refresh** verifica contra la base si sigue activo; si fue bloqueado, se rechaza y se borran sus refresh tokens.

- **Blacklist (Redis)** → cierra la puerta por los próximos ~15 min (inmediato).
- **Chequeo en refresh (base)** → impide obtener una llave nueva (durable).

## Lado reader (`gateway-api`)

Kong consulta la blacklist mediante un módulo Lua (`lua/revocation.lua.tpl`) después de leer el token; si encuentra la entrada, responde `401`.

## Configuración

Variables `REDIS_*` en **ambos** servicios:

| Variable | Descripción |
|---|---|
| `REDIS_HOST` | Host de Redis. **Vacío = revocación deshabilitada** (modo no-op, útil para dev local). |
| `REDIS_PORT` | Puerto (default `6379`). |
| `REDIS_PASSWORD` | Credencial. |
| `REDIS_TLS` | `true` en producción (Upstash). |

- **Local:** un único container `redis` (definido en `users-api/docker-compose.yml`) sobre la red externa `microservices`, con **AOF** activado para sobrevivir reinicios. Kong lo resuelve por el nombre `redis`.
- **Producción:** Render + **Upstash**; ambos servicios apuntan sus `REDIS_*` al endpoint de Upstash con `REDIS_TLS=true`.

## Política de fallos

La revocación es un acelerador sobre la fuente de verdad (la base), así que un problema transitorio de Redis no debe tumbar la plataforma — pero una **misconfiguración persistente** sí debe ser ruidosa:

| Situación | Comportamiento | Por qué |
|---|---|---|
| Redis caído / timeout / error TLS transitorio | **fail-OPEN** (permite) | Un blip no debe cortar todo; la ventana de revocación está acotada por el TTL del access token. |
| `REDIS_HOST` vacío | **fail-OPEN** (deshabilitado) | Modo "sin Redis" intencional para dev. |
| `REDIS_PASSWORD` incorrecta / `NOAUTH` | **fail-CLOSED → 503** | Una credencial mala es permanente; fallar abierto desactivaría el control en silencio. |
| Falla la verificación del certificado TLS | **fail-CLOSED → 503** | Es exactamente el MITM que `ssl_verify` defiende; fallar abierto daría el bypass al atacante. |

> Consecuencia operativa: una credencial mal puesta en el **gateway** produce `503` en las rutas protegidas (no una degradación silenciosa). Rotá el token de Upstash y el `REDIS_PASSWORD` del gateway **juntos**.

## Decisiones de diseño

- **El logout no escribe en la blacklist:** la blacklist es por *usuario*, no por dispositivo, así que desloguearte en el teléfono no debería cerrarte la sesión en la notebook. El logout sólo borra el refresh token de esa sesión.
- **Los admins no se blacklistean:** no existe la feature de bloquear admins, pero el formato de clave es role-aware y permitiría agregarlo sin plomería extra.
