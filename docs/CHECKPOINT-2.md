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

---

## Cobertura de historias

### Obligatorias — 11 / 21 cerradas → **27 / 63 pts (42,9 %)**

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
| 11 | Checkout e inicio de pago | Checkout y Órdenes | 8 | In progress |
| 15 | Gestión de stock y publicaciones | Vendedor | 3 | In progress |
| 17 | Listar usuarios del sistema | Administración | 1 | In review |
| 18 | Bloquear y desbloquear usuario | Administración | 2 | In review |
| 19 | Listar y moderar productos | Administración | 5 | In review |
| 12 | Estado y seguimiento de orden | Checkout y Órdenes | 5 | No iniciado |
| 13 | Historial de compras | Checkout y Órdenes | 2 | No iniciado |
| 16 | Historial de ventas | Vendedor | 3 | No iniciado |
| 20 | Listar órdenes del sistema | Administración | 2 | No iniciado |
| 21 | Métricas del sistema | Métricas | 5 | No iniciado |

#### Proyección por estado
| Estado | Historias | Pts | % obligatorio |
|---|---|---|---|
| Done | 11 | 27 | 42,9 % |
| + In review | +3 | +8 → 35 | 55,6 % |
| + In progress | +2 | +11 → 46 | 73,0 % |
| Pendientes sin iniciar | 5 | 17 | — |

### Optativas — 1 / 21 cerrada → **2 / 62 pts (3,2 %)**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---|---|
| 24 | Visualización de perfil público | Perfil | 2 | Done |

### Resumen global
- **Cerrado**: 29 / 125 pts (**23,2 %**)
- **Proyectado** (Done + In review + In progress): 48 / 125 pts (**38,4 %**)

---

## Riesgos y próximos pasos

1. **Épica Checkout y Órdenes** (15 pts obligatorios) — solo Checkout (8) en progreso. Estado/seguimiento de orden (5) e Historial de compras (2) aún sin arrancar; bloquean el flujo end-to-end de compra.
2. **Métricas del sistema** (5 pts obligatorios) — no iniciada. Suele requerir instrumentación previa, conviene planificar pronto.
3. **Historial de ventas** (3 pts) y **Listar órdenes del sistema** (2 pts) — pendientes; dependen del modelo de órdenes ya en desarrollo.
4. **Optativas**: con solo 2 pts cubiertos hay que validar el mínimo requerido según la cantidad de integrantes y priorizar las de mejor relación esfuerzo/puntaje.
