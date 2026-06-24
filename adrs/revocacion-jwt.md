---
title: "Revocación de JWT (NoSQL)"
parent: ADRs
nav_order: 5
---

# Revocación de JWT con Redis

## Estado

Aceptado.

## Contexto de la decisión

La implementación de revocación de tokens JWT fue un requisito obligatorio del trabajo práctico. Al analizar cómo cumplirlo, se evaluó usar Redis o bien una base MongoDB (por ejemplo, para almacenar el carrito de compras junto con la blacklist). Esta segunda opción fue descartada: hubiera sido una decisión forzada por la obligatoriedad del requisito, sin justificación técnica real. En cambio, Redis resuelve un problema genuino que tenía la aplicación —el baneo inmediato de usuarios con tokens aún vigentes— con una solución simple, de baja latencia y coherente con el estado de desarrollo de la plataforma.

El desafío concreto: cómo lograr que un usuario baneado pierda el acceso **al instante**, en lugar de seguir operando hasta que su token expire naturalmente (~15 min).

## El problema

El JWT es **autocontenido**: cualquier servicio valida su firma sin consultar una base central. Eso lo hace rápido, pero implica que una vez emitido sigue siendo válido hasta que expira. Si un admin **banea** a un usuario, su token seguiría funcionando hasta 15 minutos más.

La solución es una **blacklist** en **Redis** (in-memory, latencia sub-milisegundo): una marca que dice "rechazar a este usuario ahora", consultada en cada request.

## Las dos mitades

- **Writer — users-api:** al banear, escribe la entrada de blacklist en Redis.
- **Reader — gateway-api (Kong):** en cada request a una ruta protegida consulta la blacklist y, si el usuario está, rechaza el pedido como no autorizado.

Redis es la lista compartida. Ambos servicios deben apuntar al **mismo** Redis y coincidir en el formato de la clave.

## Formato de la clave

La clave es por usuario e incluye el **rol**, con un valor que la marca como revocada y un **TTL igual a la vida del access token** (~15 min): cuando vence, la entrada se borra sola y no se acumula basura. Incluir el rol es necesario porque usuarios y admins numeran sus IDs por separado; sin él, banear al usuario 5 también afectaría al admin 5.

## Lado writer (users-api)

Al bloquear un usuario, el flujo hace tres cosas:

1. Marca al usuario como inactivo en la base (fuente de verdad).
2. Borra sus refresh tokens.
3. **Escribe la entrada de blacklist en Redis** ← lo que hace el baneo instantáneo.

### Segundo candado: el chequeo en el refresh

La blacklist sólo cubre el access token corto. Para que un usuario baneado no genere un access token nuevo con su **refresh token** tras expirar la entrada, el flujo de **refresh** verifica contra la base si sigue activo; si fue bloqueado, se rechaza y se borran sus refresh tokens.

- **Blacklist (Redis)** → cierra la puerta por los próximos ~15 min (inmediato).
- **Chequeo en refresh (base)** → impide obtener una llave nueva (durable).

## Lado reader (gateway-api)

Kong consulta la blacklist después de leer el token; si encuentra la entrada, rechaza el request como no autorizado.

## Configuración

La conexión a Redis (host, puerto, credencial y TLS) se configura en **ambos** servicios:

- Si no se configura un host de Redis, la revocación queda **deshabilitada** (modo no-op, útil para desarrollo local).
- En producción la conexión usa TLS.
- **Local:** un único Redis sobre la red de microservicios, con persistencia en disco para sobrevivir reinicios; Kong lo resuelve por nombre.
- **Producción:** Render + **Upstash**; ambos servicios apuntan a Upstash con TLS.

## Política de fallos

La revocación es un acelerador sobre la fuente de verdad (la base), así que un problema transitorio de Redis no debe tumbar la plataforma —pero una **misconfiguración persistente** sí debe ser ruidosa:

- **Redis caído, timeout o error de TLS transitorio →** fail-OPEN (permite). Un blip no debe cortar todo; la ventana de revocación está acotada por el TTL del access token.
- **Sin host de Redis configurado →** fail-OPEN (deshabilitado). Modo "sin Redis" intencional para desarrollo.
- **Credencial inválida →** fail-CLOSED (error de servicio). Una credencial mala es permanente; fallar abierto desactivaría el control en silencio.
- **Falla la verificación del certificado TLS →** fail-CLOSED (error de servicio). Es exactamente el ataque de intermediario que la verificación de certificado defiende; fallar abierto le daría el bypass al atacante.

> Consecuencia operativa: una credencial mal puesta en el **gateway** produce un error de servicio en las rutas protegidas (no una degradación silenciosa). Rotá la credencial de Upstash y la del gateway **juntas**.

## Decisiones de diseño

- **El logout no escribe en la blacklist:** la blacklist es por *usuario*, no por dispositivo, así que desloguearte en el teléfono no debería cerrarte la sesión en la notebook. El logout sólo borra el refresh token de esa sesión.
- **Los admins no se blacklistean:** no existe la feature de bloquear admins, pero el formato de clave contempla el rol y permitiría agregarlo sin plomería extra.
