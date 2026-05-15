# Checkpoint — IS2 Grupo 9 (2026 1C)

Proyecto: [IS2-Grupo9-2026-1C/projects/1](https://github.com/orgs/IS2-Grupo9-2026-1C/projects/1)

## Trabajo realizado en este checkpoint

### Usuarios y Perfil
- **Recupero de contraseña**: implementado y deployado.
- **Perfil de usuario** desarrollado y deployado:
  - Perfil público.
  - Perfil privado (propio).
  - Edición de perfil.

### Catálogo
- **Detalle de ítems** implementado.

### Carrito
- **Carrito** desarrollado y deployado:
  - Manejo correcto de estado de los ítems.
  - El stock queda del lado del checkout (no se descuenta al agregar al carrito).
  - Validaciones para que un seller no pueda agregar al carrito ítems de sus propias publicaciones.

### Checkout
- **Checkout e inicio de pago**: en proceso.

### Vendedor
- **Gestión de stock y publicaciones**: en proceso.

### Backoffice / Administración
- **Login con refresh tokens** implementado.
- **Listado de usuarios** obtenido dinámicamente desde el backend.
- **Deshabilitar usuarios** (bloqueo/desbloqueo) implementado.
- **Deshabilitar productors** implementado.
- **Métricas** de usuarios registrados.

---

## Cobertura de historias

### Obligatorias — 17 / 21 cerradas → **48 / 63 pts (76,2 %)**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---|---|
| 1 | Registro de usuarios | Usuarios | 2 | Done |
| 2 | Login con email y contraseña | Usuarios | 2 | Done |
| 3 | Recupero de contraseña | Usuarios | 3 | Done |
| 4 | Edición de perfil | Perfil | 3 | Done |
| 5 | Visualización de perfil propio | Perfil | 1 | Done |
| 6 | Home | Catálogo | 3 | Done |
| 7 | Listado y búsqueda de productos | Catálogo | 3 | Done |
| 8 | Detalle de producto | Catálogo | 2 | Done |
| 9 | Agregar producto al carrito | Carrito | 2 | Done |
| 10 | Gestión del carrito | Carrito | 3 | Done |
| 14 | Publicar producto | Vendedor | 3 | Done |
| 11 | Checkout e inicio de pago | Checkout y Órdenes | 8 | Done |
| 15 | Gestión de stock y publicaciones | Vendedor | 3 | Done |
| 17 | Listar usuarios del sistema | Administración | 1 | Done |
| 18 | Bloquear y desbloquear usuario | Administración | 2 | Done |
| 19 | Listar y moderar productos | Administración | 5 | Parcialmente |
| 12 | Estado y seguimiento de orden | Checkout y Órdenes | 5 | Done |
| 13 | Historial de compras | Checkout y Órdenes | 2 | Done |
| 16 | Historial de ventas | Vendedor | 3 | No iniciado |
| 20 | Listar órdenes del sistema | Administración | 2 | No iniciado |
| 21 | Métricas del sistema | Métricas | 5 | Parcialmente |

1. **Épica Checkout y Órdenes** (15 pts obligatorios) — Checkout (8) fue una de las últimas historias desarrolladas. Falta integración real con proveedor.
2. **Historial de ventas** (3 pts), **Listar órdenes del sistema** (2 pts) — pendientes; dependían del modelo de órdenes recientemente desarrollado. Listas para comenzar a desarrollar.
3. **Listar y moderar productos** (5 puntos obligatorios) — Parcialmente finalizada. Desarrollado el listado y moderación de productos, pendiente el *CA 4: Ver detalle del producto* (en desarrollo).
4. **Métricas del sistema** (5 pts obligatorios) — Iniciada. Solución planteada con nuevo microservicio metrics-api, solo implementadas las métricas de usuarios registrados. 

#### Proyección por estado
| Estado | Historias | Pts | % obligatorio |
|---|---|---|---|
| Done | 17 | 48 | 76,2 % |
| + Parcialmente (#19, 4/5 pts) | — | +4 → 52 | 82,5 % |
| + Parcialmente (Métricas, 1/5 pts) | — | +1 → 53 | 84,1 % |
| Pendientes sin iniciar | 2 | 5 | — |

### Optativas — 4 / 21 cerradas → **9 / 32 pts (28,1 %)**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---|---|
| 24 | Visualización de perfil público | Perfil | 2 | Done |
| 25 | Compartir link de producto | Catálogo | 2 | Done |
| 27 | Filtros avanzados de búsqueda | Catálogo | 3 | Done |
| 28 | Ordenamiento de resultados | Catálogo | 2 | Done |

Se discutió la lista de historias optativas a desarrollar para comenzar a trabajar en ello. Se planea realizar las siguientes: 

- Visualización de perfil público (2 pts).
- Filtros avanzados de búsqueda (3 pts).
- Ordenamiento de resultados (2 pts).
- Link al producto (2 pts).
- Agregar / quitar de wishlist (2 pts).
- Visualizar wishlist (2 pts).
- Gestionar y crear cupones (5 pts):
- Aplicar cupón en el checkout (3 pts).
- Notificación de cambio de órden (5 pts).
- Notificación de stock bajo al vendedor (2 pts).
- Exportar métricas (2 pts).
- Métricas por categoría (3 pts).

*Total planificado: 33 pts*

### Resumen global
- **Cerrado**: 57 / 95 pts (**60,0 %**)
- **+ Parcialmente** (#19: 4/5 pts, Métricas: 1/5 pts): 62 / 95 pts (**65,3 %**)
- **Pendientes**: 33 / 95 pts

---



## Riesgos y próximos pasos

**Nota:** El requerimiento para el checkpoint 2 era el siguiente: E2E de la plataforma con todos los CRUD básicos al 100% o avanzados. 70% historias requeridas finalizadas, 50% historias optativas finalizadas. Si bien no hay un CRUD básico para cada historia obligatioria, todas las mencionadas están desarrolladas por completo (a excepción de la integración con proveedor real del checkout), más allá de las funcionalidades básicas. Esto se acordó con el corrector y nos permite avanzar directo y más rápidamente con las historias pendientes y requerimientos no funcionales.

1. **Checkout**: sin integración con proveedor real, es necesario implementarlo al ser un requerimiento. Además, hay casos de concurrencia por atender, se analiza aplicar patrón SAGA para mayor robustez y seguridad en las operaciones.
2. **Comunicación entre microservicios**: actualmente la comunicación interna entre microservicios está implementada para que funcione en el caso feliz, pero hay posible estados inconsistentes en caso de errores. Se analiza aplicar patrón Circuit Breaker o retries con backoff, además de diferenciar los fallos transitorios de red con los permantentes y manejar correctamente ambos casos.
3. **Rate limiting:** Pendiente implementar rate limiting en los endpoints de login y recupero, que deben tener límite de intentos por IP y por cuenta. Esto debe ser implementado en el gateway y es uno de los próximos pasos
3. **Tests**: Actualmente se tienen tests unitarios y de integración para cada microservicio, pero están pendientes los tests de integración entre distintos microservicios. Se trabajará en esto cuando se analice lo mencionado en el ítem 2. Además, no hay tests de stress (debe discutirse con corrector qué es lo esperado en este sentido).
4. **Bugs y diseño**: Bugs detectados y cuestiones de UX son analizadas constantemente. Cada uno de los descubrimientos en este sentido son representados en un issue en el projects y son cuestiones atendidas semana tras semana luego de implementar nuevas features. 