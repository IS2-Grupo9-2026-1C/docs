---
title: Retrospectiva
nav_order: 8
---

# Retrospectiva del proyecto

## Decisiones iniciales que nos destrabaron

Una de las decisiones más importantes al comienzo fue resolver temprano el armado del workflow de CI/CD. Tener el pipeline de despliegue funcionando desde el principio nos permitió desplegar a producción de forma rápida y continua, en lugar de dejar la integración y el deploy para el final. Así, cada cambio que terminábamos podía llegar a producción sin demasiada fricción.

En la misma línea, ponernos de acuerdo temprano sobre los microservicios y la arquitectura fue igual de clave. Definir de antemano cómo se iba a dividir el sistema y cómo se comunicarían sus partes nos dio una base estable para empezar a construir rápido, sin tener que renegociar decisiones estructurales en cada funcionalidad nueva.

## Cómo organizamos el trabajo

Al principio dividimos las tareas separando back-end y front-end. Bastante pronto nos dimos cuenta de que esa división nos trababa más de lo que nos ayudaba, porque generaba dependencias, esperas y traspasos constantes entre quienes trabajaban en cada capa.

La alternativa que tomamos fue abordar cada issue de punta a punta: una misma persona se ocupaba tanto del back-end como del front-end de esa funcionalidad. El cambio eliminó los bloqueos entre capas y le dio mucha más continuidad al desarrollo.

Para no gastar demasiado tiempo definiendo tareas, decidimos tomar cada criterio de aceptación (CA) como un issue. Nuestra *definition of done* fue, entonces, simple y exigente a la vez: que ese criterio se cumpliera efectivamente y estuviera desplegado en producción.

## Hosting e infraestructura

Sumar Render y Neon como soluciones de hosting tuvo un impacto enorme, porque nos ahorró muchísimo trabajo de armado de infraestructura de despliegue y nos dejó concentrarnos en construir el producto.

De todos modos, reconocemos que este enfoque tiene un techo. Si el proyecto llegara a escalar hacia una aplicación de uso comercial y real, tendríamos que migrar a otros servicios de hosting capaces de soportar la carga efectiva, ya que el esquema serverless actual no está pensado para ese volumen de demanda.

## Revisiones y proceso de Pull Requests

Tratamos de sostener revisiones obligatorias en cada Pull Request asociado a un issue. Sin embargo, a medida que avanzaba el proyecto y necesitábamos meter más cambios para cumplir con el plazo, empezamos a mergear directamente sobre la rama `develop`, siempre con los cambios verificados localmente y con los tests pasando.

Fue una concesión consciente al contexto: priorizamos la velocidad de entrega frente al deadline, apoyándonos en la verificación local y en los tests en verde como red de seguridad.

## El rol de la inteligencia artificial

La inteligencia artificial fue una herramienta de gran valor, porque aceleró muchísimo los distintos procesos. Aun así, en todo momento mantuvimos la responsabilidad sobre las decisiones principales y sobre verificar el correcto funcionamiento de la aplicación. Su aporte se notó, sobre todo, en poder explorar opciones, alternativas, tecnologías y servicios de cloud mucho más rápido de lo que habríamos podido por nuestra cuenta.

La principal reflexión que nos llevamos es que el mayor desafío de la ingeniería no está en el código en sí, sino en poder entender un problema del mundo real, relevarlo bien y pensar una solución a partir de las herramientas que tenemos disponibles.
