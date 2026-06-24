---
title: Despliegue en la nube
parent: ADRs
nav_order: 2
---

# Despliegue en la nube

## Estado

Aceptado.

## Contexto

Necesitábamos hosting para los servicios y una base de datos, con despliegue continuo (CD) listo cuanto antes, para enfocar el esfuerzo del equipo en el desarrollo del producto y no en infraestructura. Evaluamos varios proveedores:

- **AWS:** descartado por costos y, sobre todo, por el riesgo de que cobre con facilidad si uno se excede del límite gratuito.
- **GCP:** considerado; algunos integrantes del equipo tenían algo de experiencia previa.
- **Oracle Cloud:** recomendado por conocidos, con un plan gratuito muy generoso y sin necesidad de cargar una tarjeta de crédito.
- **Azure:** estuvo entre las opciones, pero nunca terminó de destacar.

El criterio decisivo fue la **facilidad de setup**: priorizamos alternativas simples de poner en marcha para tener el CD funcionando rápido.

## Decisión

Adoptamos un esquema de hosting repartido entre varios proveedores, eligiendo en cada caso la opción gratuita más cómoda:

- **Servicios de aplicación en Render** (con base de datos PostgreSQL en **Neon**). Empezamos con Railway + Neon, pero cambiamos rápidamente a Render + Neon por tener un plan gratuito más cómodo y generoso. En Render se hostean el gateway, los servicios de usuarios, órdenes, ítems y métricas, y un *bridge* para la recuperación de contraseña de la app (redirige a la sección de la aplicación donde se restablece la contraseña).
- **Observabilidad (Loki + Grafana) en una VM de Oracle Cloud**, aprovechando su plan gratuito. Para acceder a los dashboards de Grafana usamos No-IP como dominio.
- **Redis en la nube con Upstash.**
- **Imágenes de productos en Cloudinary**, que las almacena y gestiona (hosting y transformaciones) en su tier gratuito, sin guardar binarios en la base; los servicios solo persisten la URL.
- **Backoffice en GitHub Pages.**
- **Integración continua (CI) con GitHub Actions:** las verificaciones de cada repositorio (tests y build) corren en GitHub Actions.
- **Despliegue continuo (CD) de la aplicación móvil con GitHub Actions:** el CD de la app se ejecuta desde GitHub Actions, que dispara el build en el servidor de Expo. Expo genera el APK y la distribución es **manual**: cada usuario descarga el APK desde ahí (no hay publicación en tiendas).

La principal desventaja de Render es que es *serverless*: los servicios se duermen y hay que despertarlos antes de usar la app. Además impone un límite de **750 horas mensuales** de servicios activos, por lo que no es viable mantenerlos despiertos con un script que les pegue constantemente.

## Consecuencias

- Setup simple y CD listo rápido, sin costos ni riesgo de cargos sorpresivos; el equipo pudo enfocarse en el producto.
- *Cold start*: la primera interacción tras un período de inactividad es lenta porque hay que despertar los servicios de Render.
- El límite de 750 horas mensuales es un recurso escaso que hay que cuidar: no se puede mantener los servicios siempre activos.
- **Incidente previo a la demo/entrega final:** nos excedimos de las horas mensuales en Render porque el servicio de observabilidad en Oracle dirigía tráfico constante hacia los servicios, manteniéndolos vivos. Para evitarlo cambiamos la estrategia de observabilidad de *pull* a *push* (ver [Observabilidad de métricas: push vs. pull](observabilidad-push-vs-pull)).
- Como mitigación inmediata, tuvimos que **migrar a una cuenta gratuita nueva de Render** para recuperar horas disponibles.
- La arquitectura queda repartida entre Render, Neon, Oracle Cloud, Upstash y GitHub Pages: más superficie operativa y varias cuentas/planes gratuitos que administrar.
