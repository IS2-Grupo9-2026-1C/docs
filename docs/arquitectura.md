# Arquitectura del Sistema E-Commerce

## Visión General

El sistema está diseñado como una arquitectura de **microservicios** con un API Gateway centralizado que actúa como punto de entrada único para todos los clientes.

![Diagrama de Arquitectura](./docs/image%20(4).png)

---

## Componentes

### Cliente
- **Aplicación móvil** — accede a la plataforma desde dispositivos móviles.

Se comunica exclusivamente a través del **API Gateway**.

---

### API Gateway (`api-gateway`)

Punto de entrada centralizado que enruta las solicitudes hacia los microservicios correspondientes. Abstrae la complejidad interna del sistema y expone una interfaz unificada a los clientes.

---

### Microservicios

#### `users-api`
Gestiona todo lo relacionado con los usuarios.

**Endpoints principales:**
- A completar

Posee su propia base de datos dedicada.

---

#### `items-api`
Gestiona el catálogo de productos.

**Endpoints principales:**
- A completar

Posee su propia base de datos dedicada.

---

#### `orders-api`
Gestiona el flujo de compra.

**Endpoints principales:**
- A completar

Posee su propia base de datos dedicada e integra con **Stripe/Procesadora** para el procesamiento de pagos externos.

---

### `metrics-api`

Servicio transversal que recibe eventos desde los tres microservicios principales (`users-api`, `items-api`, `orders-api`) y los persiste en una base de datos centralizada de métricas.

Permite observabilidad y análisis del comportamiento del sistema sin acoplar esa responsabilidad a los servicios de negocio.

## Principios de Diseño

- **Separación de responsabilidades**: cada microservicio tiene su dominio acotado y su propia base de datos, evitando acoplamiento de datos.
- **Base de datos por servicio**: ningún servicio accede directamente a la base de datos de otro.
- **Gateway único**: los clientes no conocen la topología interna; toda comunicación pasa por el API Gateway.
- **Métricas desacopladas**: la recolección de métricas es transversal pero no bloquea el flujo principal de cada servicio.