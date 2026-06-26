---
title: Uso de IA
nav_order: 5
---

# Uso de IA

A lo largo del desarrollo del proyecto utilizamos herramientas de inteligencia artificial de forma intensiva, tanto para escribir código como para tomar decisiones de diseño, investigar alternativas y producir documentación. Esta sección resume qué herramientas usamos y en qué partes del trabajo nos resultaron útiles.

## Herramientas utilizadas

| Herramienta | Uso principal |
|---|---|
| **Claude Code** | Asistente principal de desarrollo: escritura de código, debugging, scripts y documentación |
| **Plan mode (Claude Code)** | Planificación de cambios antes de implementarlos, para acordar el enfoque antes de tocar código |
| **GitHub Copilot** | Autocompletado y sugerencias en línea durante la escritura de código |
| **Skill `frontend-developer`** | Apoyo en el frontend durante las etapas iniciales del proyecto |
| **Superpowers (skills)** | Conjunto de skills para estructurar y mejorar el flujo de trabajo con IA |
| **Skill de code review** | Detección de falencias en cambios antes de pushear y corrección de PRs de compañeros |
| **Reviews multi-agénticos** | Revisión de código con múltiples agentes en paralelo |
| **MCP de GitHub** | Creación ágil de user stories e interacción con el repositorio |
| **Gemini** | Consultas y exploración de alternativas |
| **Figma Make / Claude Design** | Diseño de algunas de las pantallas de la aplicación |

## Flujo de trabajo y dirección

No usamos la IA de forma improvisada, sino dentro de un flujo de trabajo estructurado y con artefactos versionados en los repositorios:

- Archivos de guía para el asistente (`CLAUDE.md`) con los comandos, convenciones y contexto de cada proyecto, para que las sugerencias respeten las decisiones del equipo.
- Un agente especializado de frontend definido en la carpeta de configuración del asistente (`.claude/agents`).
- Planes y especificaciones de diseño escritos **antes** de implementar (carpeta `superpowers`), que dejaban registrado el enfoque acordado.

El ciclo habitual fue: planificar el cambio (plan mode) y acordar el enfoque, implementar, y revisar con la skill de code review y reviews multi-agénticos antes de pushear. La IA propone y acelera, pero la dirección, la revisión y la aceptación de cada cambio quedaron siempre del lado del equipo.

## En qué nos resultó útil

Más allá de escribir código, la IA fue valiosa en varios frentes del proyecto:

- **Decisiones de diseño e infraestructura.** Investigación de alternativas para decisiones importantes: qué proveedor de nube usar y qué planes ofrecen, qué utilizar para las push notifications, y problemas más centrados en el diseño de software en sí.
- **Resolución de bugs y errores.** Ayuda para diagnosticar y corregir bugs y errores durante el desarrollo.
- **Armado inicial del proyecto.** Generación del esqueleto inicial del proyecto, los archivos de Docker Compose y los distintos scripts que fuimos utilizando.
- **Tests.** Escritura de tests para los distintos servicios.
- **Documentación.** Redacción de documentación técnica del sistema.
- **Revisión de código.** Detección de problemas en cambios propios antes de pushearlos y revisión/corrección de PRs de compañeros, incluyendo revisiones con múltiples agentes.
- **User stories.** Creación de historias de usuario de forma rápida a través del MCP de GitHub.

## Análisis de la consigna y requisitos no funcionales

Otro uso importante fue el análisis crítico del trabajo práctico frente a la consigna. Apoyándonos en la IA detectamos puntos débiles del sistema en distintos aspectos —resiliencia, seguridad, entre otros— y los abordamos antes de que se convirtieran en problemas.

Para esto hicimos uso intensivo de documentos `.md` que detallan lo faltante en cuanto a requisitos no funcionales y que dejan un análisis completo de los distintos apartados (auditorías de requisitos no funcionales, de seguridad y de integridad del flujo de datos, entre otras). Estos documentos sirvieron tanto para identificar brechas como para llevar registro de lo trabajado y lo pendiente.

## Exploración de alternativas ante limitaciones

La IA también fue útil para encontrar caminos alternativos cuando nos topamos con limitaciones o errores.

Un ejemplo concreto fue cuando el servicio de observabilidad consumió todo el uso mensual disponible en Render. Con ayuda de la IA exploramos alternativas para poder seguir utilizando el servicio sin mantener los servicios siempre despiertos ni agotar la cuota mensual. El detalle de la decisión está documentado en el ADR de [Observabilidad de métricas: push vs. pull](adrs/observabilidad-push-vs-pull).

En todos los casos, las decisiones de arquitectura fueron del equipo: la IA ayudó a investigar y comparar alternativas, pero la elección final la tomamos nosotros y quedó registrada en los [ADRs](adrs).
