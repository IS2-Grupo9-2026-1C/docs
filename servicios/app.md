---
title: app
parent: Servicios
nav_order: 5
---

# App

Cliente mobile del sistema Bazaar. Permite a los usuarios registrarse, autenticarse, navegar el catálogo de productos y realizar compras. Se comunica exclusivamente con el backend a través del API Gateway mediante llamadas REST autenticadas con JWT.

## Stack

- [Expo](https://expo.dev/) (managed workflow)
- React Native + TypeScript
- React Navigation (stack navigator)
- expo-secure-store (almacenamiento seguro de tokens)

## Requisitos previos

- Node.js 20+
- npm 10+
- [Expo Go](https://expo.dev/client) en tu dispositivo o un simulador iOS/Android

## Instalación

```bash
git clone git@github.com:IS2-Grupo9-2026-1C/app.git
cd app
npm install
```

> **Nota:** Los scripts usan `--localhost` por defecto (funciona en simuladores). Para usar Expo Go en un dispositivo físico, desactivá el firewall de macOS y ejecutá `npx expo start` (sin `--localhost`).

## Configuración

El archivo de configuración está en [src/config/index.ts](src/config/index.ts). Modificá la constante `ENV` para elegir el entorno:

```ts
// 'local' apunta a http://localhost:3000
// 'production' apunta a la URL de producción
const ENV: Environment = 'local';
```

## Ejecutar la app

```bash
# Menú interactivo (elegí iOS, Android o Web)
npm start

# Directamente en simulador iOS
npm run ios

# Directamente en emulador Android
npm run android
```

## Lint y formato

```bash
# Verificar errores de lint
npm run lint

# Corregir automáticamente
npm run lint:fix

# Formatear con Prettier
npm run format

# Verificar tipos TypeScript
npm run typecheck
```

## CI/CD

Cada PR a `master` o `develop` ejecuta automáticamente:

| Job         | Qué hace                      |
| ----------- | ----------------------------- |
| `lint`      | Verifica reglas de ESLint     |
| `typecheck` | Compila TypeScript sin emitir |

### CD — Builds automáticos

| Evento                                 | Workflow      | Resultado                             |
| -------------------------------------- | ------------- | ------------------------------------- |
| Merge de PR `release/x.x.x` → `master` | `cd.yml`      | APK `app-vx.x.x.apk` → GitHub Release |
| Manual (Actions → Preview Build)       | `preview.yml` | APK de preview → GitHub Pre-Release   |

Los builds usan `eas build --local` (corren en GitHub Actions, no en los servidores de Expo). Los APKs **no aparecen en expo.dev** — se descargan desde la pestaña **Releases** del repo en GitHub.

### Release build (en merge a master)

Se dispara automáticamente al mergear un PR cuya branch empiece con `release/`:

```bash
# 1. Crear release branch desde develop
git checkout develop
git checkout -b release/1.0.0

# 2. (Opcional) Ajustes de último momento, bump de versión, etc.

# 3. Pushear y abrir PR a master
git push origin release/1.0.0
# Abrir PR: release/1.0.0 → master

# 4. Al mergear el PR se genera automáticamente:
#    - Build del APK (app-v1.0.0.apk)
#    - GitHub Release con tag v1.0.0
```

### Preview build (a demanda)

Para generar un APK de testing desde cualquier branch sin hacer release:

1. Ir a GitHub → **Actions** → **"Preview Build (on demand)"**
2. Click en **"Run workflow"**
3. Elegir la branch (ej: `develop`, `feat/nueva-pantalla`)
4. Opcionalmente agregar una descripción (ej: "demo para el TP")
5. Click en **"Run workflow"**

El APK aparece en **Releases** como pre-release.

## Guía de contribución

1. Crear una rama desde `develop`: `git checkout -b feat/nombre-feature`
2. Desarrollar la funcionalidad
3. Verificar que `npm run lint` y `npm run typecheck` pasen
4. Abrir un Pull Request hacia `develop`
5. Requiere al menos 1 aprobación antes de mergear
6. `master` recibe merges únicamente desde branches `release/x.x.x`
