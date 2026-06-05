---
title: Checkpoint 3
parent: Checkpoints
nav_order: 2
---

# Checkpoint 3 — IS2 Grupo 9 (2026 1C)

Proyecto: [IS2-Grupo9-2026-1C/projects/1](https://github.com/orgs/IS2-Grupo9-2026-1C/projects/1)

## Criterio de corte

Esta documentación toma como base el tablero del proyecto y considera el trabajo realizado específicamente durante el **Checkpoint 3**. Para evitar contar dos veces historias grandes, el avance se calculó a partir de las historias y sus subtareas por criterio de aceptación.

En el milestone **Checkpoint 3** del Project hay **98 items**. Para el corte final del checkpoint se consideran cerradas las tareas de moderación de productos y listado de órdenes del sistema, que completan el alcance obligatorio.

| Estado | Items |
|---|---:|
| Done | 85 |
| In progress | 2 |
| In review | 0 |
| Backlog | 11 |

---

## Trabajo realizado en este checkpoint

### Checkout y órdenes
- Se completaron casos de error del checkout:
  - Pago rechazado y posibilidad de reintento.
  - Stock insuficiente con detalle de items problemáticos.
  - Error de concurrencia cuando otro comprador consume el último item.
- Se avanzó el seguimiento de órdenes:
  - Transiciones inválidas rechazadas con mensaje claro.
  - Código de seguimiento opcional al marcar una orden como enviada.
  - Detalle de orden con estado, historial de transiciones e items.
  - Confirmación de recepción por parte del comprador.
- Se completó **historial de ventas** para vendedores:
  - Listado de ventas.
  - Detalle de venta.
  - Cambio de estado de la orden.
  - Filtro por estado.

### Backoffice / Administración
- **Métricas del sistema** completadas:
  - Usuarios registrados totales y por período.
  - Órdenes por estado y evolución temporal.
  - Monto transaccionado por período.
  - Ranking de productos más vendidos.
  - Selector de período de 7, 30 y 90 días.
- **Listar órdenes del sistema** completado:
  - Backend con búsqueda por ID, listado paginado y modo solo lectura.
  - Filtro por estado.
  - Barra de búsqueda, tabla paginada y detalle de orden en modo solo lectura en backoffice.
- **Moderación de productos** completada:
  - Listado paginado de productos.
  - Deshabilitación y rehabilitación con confirmación.
  - Vista de detalle con historial de cambios.

### Observabilidad de APIs
- Se incorporó observabilidad operativa con **Prometheus + Grafana + cAdvisor** en las APIs principales (`users-api`, `items-api` y `orders-api`).
- El objetivo es poder ver el comportamiento técnico de los servicios sin depender solo de logs: volumen de requests, errores, latencias y consumo de recursos de los contenedores.
- Cada API expone un endpoint `/metrics` en formato Prometheus. Ese endpoint publica métricas técnicas del servicio y queda disponible para que Prometheus lo consulte periódicamente.
- En cada API se agregó un middleware de métricas HTTP. El middleware intercepta cada request, mide su duración y registra el resultado con etiquetas de método, ruta y estado. Con eso se pueden observar:
  - Cantidad de requests por método, ruta y código de estado.
  - Familia de estado (`2xx`, `4xx`, `5xx`).
  - Latencia por ruta, incluyendo promedio y percentil 90.
  - Requests en curso.
- Además de las métricas propias de la aplicación, se agregó cAdvisor para obtener métricas de infraestructura de los contenedores:
  - Uso de CPU por contenedor.
  - Memoria utilizada.
  - Tráfico de red recibido y enviado.
- Prometheus se encarga de consultar tanto a las APIs como a cAdvisor y almacenar las series temporales. Grafana usa Prometheus como datasource y muestra dashboards operativos ya provisionados.
- Los dashboards permiten visualizar, para cada API:
  - Paneles para requests por status, latencia promedio, P90, requests in flight, CPU, memoria y red.
- Se actualizó `docker-compose.yml` de cada servicio para levantar en conjunto la API, Prometheus, Grafana y cAdvisor en el entorno local.
- Se agregaron tests unitarios para validar el endpoint de métricas y el registro de métricas HTTP.

### Catálogo y vendedor
- Se completaron filtros avanzados de búsqueda en backend:
  - Categorías.
  - Rango de precio.
  - Combinación de filtros.
  - Respuesta sin filtros.
- Se completó la gestión de imágenes de publicaciones:
  - Reordenamiento.
  - Eliminación.
  - Restricción de mínimo una imagen.
- Se corrigió que un vendedor no vea ni compre sus propias publicaciones.
- Se avanzó productos populares en home desde backend:
  - Productos más vendidos de los últimos 30 días.
  - Fallback a populares globales.
  - Personalización por categorías frecuentes cuando hay historial.

### Wishlist
- **Agregar / quitar productos de wishlist** completado:
  - Alta y baja de productos.
  - Indicador de producto guardado en catálogo y detalle.
  - Requiere autenticación.
  - Redirección a login cuando corresponde.
- **Visualización de wishlist** completada:
  - Pantalla con productos guardados.
  - Indicadores de sin stock y no disponible.
  - Estado vacío.

### Cupones
- **Crear y gestionar cupones de descuento** completado:
  - Creación con código único, porcentaje y vencimiento.
  - Validación de código duplicado.
  - Desactivación de cupones.
  - Listado de cupones propios con estado.
- **Aplicar cupón en checkout** quedó parcial:
  - Avanzado en backend para aplicar cupón válido y limitar un cupón por orden.
  - Pendiente la integración completa en el flujo de checkout.

### Notificaciones
- **Notificación de cambio de estado de orden** completada:
  - Envío desde backend al cambiar estado.
  - Recepción y visualización push en la app.
  - Notificación visible en segundo plano.
  - Deep link al detalle de la orden.
- **Notificación de stock bajo al vendedor** completada:
  - Detección de stock bajo.
  - Evita notificaciones duplicadas.
  - Notificación específica para stock agotado.
  - Navegación correcta desde la push notification.

### Calidad y bugs
- Correcciones realizadas durante el checkpoint:
  - Checkout screen.
  - Edición de perfil.
  - Imagen de perfil en producción.
  - Logo/visualización de publicaciones.
  - Refresh al loguearse/desloguearse.
  - Límites de precio y stock al publicar producto.
  - Botones de edición de imágenes.

---

## Cobertura de historias

### Obligatorias — 21 / 21 cerradas → **63 / 63 pts (100 %)**

| # | Historia | Épica | Pts | Estado |
|---|---|---|---:|---|
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
| 11 | Checkout e inicio de pago | Checkout y Órdenes | 8 | Done |
| 12 | Estado y seguimiento de orden | Checkout y Órdenes | 5 | Done |
| 13 | Historial de compras | Checkout y Órdenes | 2 | Done |
| 14 | Publicar producto | Vendedor | 3 | Done |
| 15 | Gestión de stock y publicaciones | Vendedor | 3 | Done |
| 16 | Historial de ventas | Vendedor | 3 | Done |
| 17 | Listar usuarios del sistema | Administración | 1 | Done |
| 18 | Bloquear y desbloquear usuario | Administración | 2 | Done |
| 19 | Listar y moderar productos | Administración | 5 | Done |
| 20 | Listar órdenes del sistema | Administración | 2 | Done |
| 21 | Métricas del sistema | Métricas | 5 | Done |

#### Avance obligatorio

| Estado | Historias | Pts | % obligatorio |
|---|---:|---:|---:|
| Done | 21 | 63 | 100 % |


### Optativas — **25 / 33 pts (75,8 %)**

Se mantiene la misma base de **33 pts optativos**. La tabla muestra las historias con avance o pendiente.

| Historia | Épica | Pts | Estado |
|---|---|---:|---|
| Visualización de perfil público | Perfil | 2 | Done |
| Compartir link de producto | Catálogo | 2 | Done |
| Filtros avanzados de búsqueda | Catálogo | 3 | Done |
| Ordenamiento de resultados | Catálogo | 2 | Done |
| Agregar / quitar de wishlist | Wishlist | 2 | Done |
| Visualizar wishlist | Wishlist | 2 | Done |
| Crear y gestionar cupones | Cupones | 5 | Done |
| Notificación de cambio de estado de orden | Notificaciones | 5 | Done |
| Notificación de stock bajo al vendedor | Notificaciones | 2 | Done |
| Aplicar cupón en checkout | Cupones / Checkout | 3 | Parcial |
| Métricas por categoría | Métricas | 3 | Backlog |
| Exportar metricas | Métricas | 2 | Backlog |

Se considera cerrado lo que tiene backend y frontend funcionales o criterios de aceptación principales completos. Los avances parciales no se suman al porcentaje cerrado para mantener una medición conservadora.

---

## Resumen global

- **Cerrado**: 88 / 95 pts (**92,6 %**)
- **Obligatorias**: 63 / 63 pts (**100 %**)
- **Pendiente relevante**: integración completa de cupones en checkout, métricas por categoría y deuda técnica/calidad.

---

## Riesgos y próximos pasos

1. **Cupones en checkout**: la creación y gestión de cupones está cerrada, pero falta cerrar la aplicación end-to-end del cupón en el checkout.
2. **Métricas por categoría**: continúa pendiente como expansión de métricas.
3. **Calidad y deuda técnica**: quedan tareas de tests, seguridad del manejo de tokens en backoffice y mejoras puntuales de pantallas.
