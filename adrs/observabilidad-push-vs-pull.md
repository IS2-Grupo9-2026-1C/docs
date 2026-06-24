---
title: "Observabilidad de métricas: push vs. pull"
parent: ADRs
nav_order: 12
---

# Observabilidad de métricas: push vs. pull

## Estado

Aceptado.

## Contexto

Tenemos un stack de observabilidad (Prometheus + Grafana) corriendo en una VM de Oracle Cloud, que recolecta las métricas operativas de los servicios hosteados en Render (ver [Despliegue en la nube](despliegue-nube)).

Los servicios de Render son *serverless*: se duermen cuando están inactivos y hay un límite mensual de horas activas. Esto entra en conflicto directo con el modelo original de observabilidad, que era **pull**: Prometheus, desde la VM, hacía requests periódicos (scraping) a los endpoints de métricas de cada servicio en Render. Ese tráfico entrante mantenía a los servicios **siempre despiertos**, consumiendo horas aun sin uso real. En la reunión previa a la demo y entrega final nos excedimos del límite mensual de Render justamente por esta causa.

## Decisión

Cambiamos del modelo **pull** al modelo **push**: ahora son los propios servicios de Render los que **empujan** sus métricas hacia el stack de observabilidad, y solo lo hacen mientras están despiertos atendiendo tráfico real.

- En la VM corre un *pushgateway* que recibe las métricas, detrás de un reverse proxy con TLS y autenticación básica.
- Prometheus scrapea **únicamente** ese pushgateway local; nunca sale a buscar métricas a Render.
- Cada servicio se configura con la URL de push y sus credenciales, y empuja sus métricas cuando está activo.

El resultado es que la observabilidad deja de generar tráfico hacia Render, y las instancias gratuitas quedan libres de dormirse cuando no hay uso.

## Consecuencias

- Se resuelve la causa raíz del incidente de exceso de horas: la observabilidad ya no mantiene vivos a los servicios (ver [Despliegue en la nube](despliegue-nube)).
- Trade-off de visibilidad: como las métricas solo llegan mientras el servicio está despierto, no hay datos de un servicio dormido. Un dashboard vacío puede significar "dormido", no necesariamente "caído". El modelo pull daba continuidad de muestreo, pero a costa de mantener todo encendido.
- El pushgateway retiene la última muestra recibida hasta que se sobrescribe o se borra, por lo que las métricas de un servicio que se durmió pueden quedar "pegadas" un tiempo; hay que tenerlo en cuenta al leer los dashboards.
- Se agrega un componente (el pushgateway y su ingress con TLS/autenticación) y los servicios pasan a depender de tener configuradas la URL y las credenciales de push.
