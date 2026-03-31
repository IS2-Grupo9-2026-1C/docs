# Infraestructura

## Base de Datos: Neon

En ambas opciones evaluadas se utiliza **Neon** como proveedor de base de datos PostgreSQL.

Neon es un servicio de PostgreSQL serverless que ofrece branching de bases de datos, escalado automático y un plan gratuito generoso. Su modelo serverless lo hace adecuado para etapas tempranas del proyecto donde el tráfico es impredecible.

---

## Opciones de Hosting Evaluadas

### Opción A: Railway + Neon

**Railway** es una plataforma de deployment orientada a desarrolladores que permite desplegar servicios desde un repositorio Git con configuración mínima.

**Características relevantes:**
- Deploy automático desde GitHub con detección de lenguaje/framework
- Variables de entorno y networking interno entre servicios sin configuración adicional
- Plan gratuito con créditos mensuales; facturación por uso real
- Interfaz simple con logs y métricas integrados por servicio

---

### Opción B: Render + Neon

**Render** es una plataforma cloud que apunta a ser una alternativa moderna a Heroku, con enfoque en simplicidad operativa.

**Características relevantes:**
- A completar

---

## Almacenamiento de Imágenes: Cloudinary

Para el almacenamiento y gestión de fotos de productos se está evaluando el uso de **Cloudinary**.

---

## CI/CD

Se utiliza **GitHub Actions** como plataforma de integración y entrega continua.

El pipeline sigue el siguiente flujo:

1. **Tests** — al hacer push o abrir un PR se ejecuta la suite de tests con pytest via GitHub Actions.
2. **Deploy** — Railway / Render monitorea continuamente la rama `master` y redespliega automáticamente ante cada actualización, sin necesidad de un paso de deploy explícito en el workflow.

---

## Proveedores Descartados para este Checkpoint

Se evaluaron las principales plataformas cloud de nivel enterprise como alternativas de hosting:

- **AWS (Amazon Web Services)**
- **GCP (Google Cloud Platform)**
- **Azure (Microsoft)**
- **Oracle Cloud Infrastructure**

Estas plataformas fueron descartadas para el primer checkpoint del proyecto por dos razones principales:

1. **Complejidad inicial**: la configuración de redes, IAM, contenedores y servicios administrados en estas plataformas requiere un nivel de infraestructura-as-code y conocimiento operativo que excede el alcance de esta etapa del proyecto.
2. **Modelo de facturación**: sus planes implican costos base o una curva de configuración para evitar gastos inesperados que no son adecuados para una fase de desarrollo y validación temprana.

**Estas opciones no han sido descartadas de forma definitiva.** A medida que el proyecto escale y los requisitos de disponibilidad, seguridad y control operativo aumenten, migrar a alguna de estas plataformas será una opción válida y esperada.
