---
title: Categorías hardcodeadas en app
parent: ADRs
nav_order: 6
---

# Categorías hardcodeadas en app

## Estado

Aceptado.

## Contexto

Al publicar un ítem se le debe asignar una categoría. Una alternativa sería modelar las categorías como una entidad gestionable (persistidas en items-api, con un ABM desde el backoffice), pero eso agrega un subsistema completo —almacenamiento, endpoints, UI de administración— que no aporta valor al objetivo de esta etapa.

El foco del proyecto está en ejercitar los flujos centrales: publicación de ítems, carrito y checkout con pagos de **distintos montos y cantidades**. Un conjunto fijo y acotado de categorías ya cubre un rango de precios suficiente para probar esos escenarios (desde ítems baratos hasta vehículos), sin necesidad de que las categorías sean configurables.

## Decisión

Las categorías son una **lista estática hardcodeada en el frontend**, definida en la app y replicada en el backoffice. Son 8: Electrónica, Muebles, Ropa, Deportes, Hogar, Juguetes, Vehículos y Otros.

items-api no modela las categorías: guarda el identificador de categoría como texto libre y solo valida que no esté vacío. No existe una entidad de categorías ni validación contra un conjunto permitido en el backend; el catálogo canónico vive en el frontend.

## Consecuencias

- Simplicidad: no se construye un subsistema de gestión de categorías que no se necesita en esta etapa, y el conjunto fijo alcanza para probar montos y cantidades variados.
- La lista está **duplicada** entre app y backoffice: agregar, quitar o renombrar una categoría exige editar ambas copias y desplegar (no es configurable en runtime).
- items-api acepta cualquier identificador de categoría no vacío: la coherencia con el catálogo depende de que los clientes solo envíen valores de la lista; no hay garantía a nivel de backend.
- Evolución futura: si se quisiera que las categorías fueran configurables, se haría un **ABM desde el backoffice** (persistencia en items-api, endpoints y UI de administración), reemplazando esta decisión por un ADR nuevo.
