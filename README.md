# Ramirx · Documentación del proyecto

Este repositorio contiene un **proyecto fullstack** compuesto por:

- **Backend**: NestJS + TypeORM + PostgreSQL + JWT + Supabase Storage
- **Frontend**: Flutter (mobile + web) con Riverpod + Dio + go_router

El objetivo es ofrecer un catálogo tipo Shopify para **Servicios**, **Productos** y **Capacitaciones**, con un flujo de carrito/checkout y un panel de administración.

---

## 1) Estructura del monorepo

Carpetas principales:

- `backend/`
  - API REST (NestJS)
  - Auth, multi-tenant, CRUD de artículos, pedidos, uploads
- `frontend_flutter/`
  - App Flutter
  - UI pública + rutas admin

---

## 2) Requisitos

- **Node.js** (recomendado LTS)
- **PostgreSQL** (o una URL `DATABASE_URL` válida)
- **Flutter SDK** (Dart 3.x)

Servicios externos:

- **Supabase Storage**
  - Se usa como storage público para:
    - Imágenes de artículos (admin)
    - Comprobantes de pago (cliente)

---

## 3) Backend (NestJS)

### 3.1 Variables de entorno

El backend lee configuración desde variables de entorno. Las más importantes:

- `DATABASE_URL`
- `JWT_SECRET`
- `SUPABASE_URL`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_STORAGE_BUCKET`

Notas:

- TypeORM corre con `synchronize: true` si `NODE_ENV != production`.
- En producción, se recomienda migraciones (pendiente si no existe flujo aún).

### 3.2 Comandos típicos

Desde `backend/`:

- `npm install`
- `npm run build`
- `npm run start:dev`

### 3.3 Módulos principales

- **Auth** (`/auth/*`)
  - Registro, login, cambio de contraseña
  - `GET /auth/me`
- **Users** (`/users/*`)
  - Perfil persistente (teléfono, WhatsApp, dirección)
  - `GET /users/me`
  - `PATCH /users/me`
- **Uploads** (`/uploads/*`)
  - `POST /uploads/images` (solo admin)
  - `POST /uploads/receipts` (usuario autenticado)
- **Commerce / Orders** (`/orders/*`)
  - `POST /orders` (crea pedido)
  - `GET /orders/me` (mis pedidos)
  - Admin:
    - `GET /orders/admin`
    - `GET /orders/admin/:id`
    - `PATCH /orders/admin/:id`
    - `DELETE /orders/admin/:id`

### 3.4 Estados de pedido

Estados lógicos implementados:

- `draft` (borrador)
- `pending_review` (pendiente por revisar)
- `approved` (aprobado)
- `pending_delivery` (pendiente por entregar)
- `delivered` (entregado)
- `rejected` (rechazado)
- `cancelled` (cancelado)

Reglas básicas de transición (backend valida):

- `draft` -> `pending_review` | `cancelled`
- `pending_review` -> `approved` | `rejected` | `cancelled`
- `approved` -> `pending_delivery` | `cancelled`
- `pending_delivery` -> `delivered` | `cancelled`

Creación de pedidos:

- Si el pedido se crea **con comprobante**: inicia en `pending_review`
- Si se crea **sin comprobante**: inicia en `draft`

---

## 4) Frontend (Flutter)

### 4.1 Variables/configuración

Revisar:

- `lib/core/config.dart`

Ahí se define típicamente el `baseUrl` del backend y el `tenantId` (si aplica en tu despliegue).

### 4.2 Comandos típicos

Desde `frontend_flutter/`:

- `flutter pub get`
- `flutter run` (móvil)
- `flutter run -d chrome` (web)
- `flutter analyze`

### 4.3 Arquitectura (alto nivel)

- **Router**: `go_router` (`lib/core/router/router_provider.dart`)
- **Estado**: Riverpod
- **HTTP**: Dio (configurado en `lib/core/api/api_client.dart`)
- **Auth**:
  - `AuthController` maneja token y rol
  - El token se guarda en storage

---

## 5) Funcionalidades principales

### 5.1 Catálogo

- **Servicios**
- **Productos**
- **Capacitaciones**

Incluye:

- Listados
- Detalles
- `compareAtPrice` (precio tachado) cuando aplica
- Secciones/tabs (configurables)

### 5.2 Admin

Rutas admin (requiere rol `admin`):

- `/admin`
- `/admin/services`
- `/admin/products`
- `/admin/courses`
- `/admin/orders`

Admin puede:

- Crear/editar/eliminar artículos
- Duplicar artículos
- Insertar imágenes en el HTML de descripción (Fase 1)
- Gestionar pedidos:
  - ver lista
  - ver detalle
  - cambiar estado
  - agregar nota interna
  - eliminar pedidos de prueba

### 5.3 Carrito y pedidos

- `/cart`
- Botón **Pagar** abre checkout de Wompi (link fijo por ahora).
- Botón **Enviar comprobante y realizar pedido**:
  - Antes de enviar:
    - valida que el usuario tenga `phone`, `whatsapp`, `shippingAddress` en su cuenta
    - solicita confirmación
    - solicita **nota del cliente (obligatoria)**
  - luego:
    - sube comprobante (imagen o PDF)
    - crea pedido con `customerNote` + `receiptUrl`
    - limpia carrito

---

## 6) Troubleshooting

### 6.1 “El comprobante abre una imagen incorrecta”

Medidas implementadas:

- Subidas a Supabase con `upsert: false` para evitar sobrescrituras accidentales.
- Inferencia de `contentType` según extensión del archivo en `/uploads/receipts`.

Si aún ocurre:

- Confirmar que el archivo seleccionado sea realmente `.pdf`.
- Verificar la URL generada (debe contener carpeta `receipts/` y terminar en `.pdf`).

### 6.2 Flutter Web: “Dart compiler exited unexpectedly”

Pendiente de diagnóstico en este proyecto.

Acciones típicas:

- `flutter clean`
- `flutter pub get`
- probar otro Chrome / versión

---

## 7) Rutas importantes (resumen)

Públicas:

- `/home`
- `/services` y `/services/:id`
- `/products` y `/products/:id`
- `/courses` y `/courses/:id`

Usuario:

- `/account`
- `/cart`

Admin:

- `/admin/*`

