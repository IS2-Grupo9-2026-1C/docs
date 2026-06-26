# Documentación con Just the Docs

Sitio de documentación técnica del sistema e-commerce (Bazaar) — Ingeniería de Software II, FIUBA. Construido con [Jekyll](https://jekyllrb.com/) 4.3 y el tema [Just the Docs](https://just-the-docs.com/).

Sitio publicado: https://is2-grupo9-2026-1c.github.io/docs/

## Build y previsualización local

Requiere Ruby con Bundler instalado.

```bash
bundle install
bundle exec jekyll serve
```

El sitio generado queda en `_site/`.

## Secciones principales

- **Arquitectura** (`arquitectura.md`) — diagrama y componentes del sistema.
- **Tech Stack** (`tech-stack.md`) — tecnologías de frontend, backend, bases de datos y más.
- **Pruebas de Performance** (`performance/`) — informes de carga, stress, capacidad e idempotencia.
- **Servicios** (`servicios.md`, `servicios/`) — documentación por microservicio.
