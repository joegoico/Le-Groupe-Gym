# 🏋️‍♂️ Le Groupe Gym - Sistema de Gestión Integral

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![AWS SES](https://img.shields.io/badge/AWS_SES-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Deno](https://img.shields.io/badge/Deno-000000?style=for-the-badge&logo=deno&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)

Plataforma de gestion integral para **Le Groupe Gym** construida con **Flutter** y orientada a **Web / Escritorio**, usando **Supabase** como BaaS, **Supabase Storage** para archivos y **Edge Functions** para automatizaciones de correo.

Hoy el proyecto ya no esta en una fase centrada solo en el Routine Builder: el producto incluye modulos operativos de **alumnos, pagos, deudores, precios, rutinas e ingresos**, con una base de tests amplia y una arquitectura consistente basada en **Riverpod + repositorios + Supabase**.

## 🚧 Estado Actual y Roadmap

### Estado actual del proyecto

El sistema ya cuenta con modulos funcionales para la operatoria diaria del gimnasio:

* **Autenticacion** con Supabase Auth y persistencia segura de sesion.
* **Gestion de alumnos** con alta, edicion, eliminacion, busqueda y vista detallada.
* **Gestion de pagos** con registro, edicion, eliminacion, filtros anuales/mensuales y validaciones de negocio.
* **Panel de deudores** con visualizacion de mora, acciones de seguimiento y recordatorios.
* **Gestion de planes y descuentos** para precios configurables desde UI.
* **Dashboard de rutinas** con solicitudes pendientes, rutinas asignadas y rutinas predeterminadas.
* **Routine Builder** con dias, bloques, superseries, notas generales y exportacion a PDF.
* **Resumen de ingresos** con filtros por fecha, mes actual y rango personalizado.

### Focos actuales de evolucion

Los frentes que siguen abiertos estan mas ligados a consolidacion que a funcionalidad basica:

* seguir endureciendo UX y consistencia operativa en modulos administrativos;
* ampliar el modulo financiero mas alla del resumen de ingresos actual;
* continuar refinando performance, cobertura de tests y documentacion tecnica;
* consolidar automatizaciones de backoffice sobre Supabase y Edge Functions.

---

## 🚀 Caracteristicas Principales

* **Gestion completa de alumnos:** listado paginado, buscador, formulario de alta/edicion y vista de detalle.
* **Estado de cuenta del alumno:** ultimo pago, historial anual, rutinas asignadas y acceso rapido al registro de pagos.
* **Registro de pagos con reglas de negocio:**
  * planes por cantidad de dias o pagos personalizados;
  * descuentos aplicables;
  * validacion inline para pagos duplicados del mismo mes;
  * mensajes de error inline para errores de servidor y validaciones;
  * eliminacion de pagos con actualizacion inmediata en UI.
* **Panel de deudores:** chips de filtro por morosidad, cards de deuda y acciones de seguimiento.
* **Modulo de precios:** CRUD de planes y descuentos.
* **Dashboard de rutinas:** panel de solicitudes, listado de rutinas y acceso a rutinas predeterminadas.
* **Routine Builder:**
  * armado por dias y bloques;
  * combinacion de ejercicios en superserie;
  * reordenamiento y movimientos entre bloques;
  * notas generales;
  * exportacion de PDF lista para enviar.
* **Generacion de PDF del lado cliente:** construccion en background con `compute` para no bloquear la UI.
* **Envio automatizado de emails:** integracion con AWS SES via Supabase Edge Functions.
* **Resumen de ingresos:** vista mensual con filtros temporales y detalle por periodo.

### Mejoras recientes ya incorporadas

* El formulario de pagos persiste el pago desde el propio dialogo y muestra errores de unicidad y servidor dentro del formulario.
* La eliminacion de pagos en `AlumnoPagosPage` actualiza la UI al primer intento incluso si la recarga del backend tarda.
* El chip **Personalizado** ya no aparece seleccionado por defecto al registrar un pago, evitando ambiguedad visual.
* Los mocks y tests del dashboard de rutinas quedaron aislados correctamente para evitar mutaciones compartidas entre UI y repositorios mockeados.

---

## 🏗️ Arquitectura y Stack Tecnologico

El proyecto sigue una arquitectura pragmatica en capas, con responsabilidades bastante claras entre UI, estado, acceso a datos y servicios.

### Frontend

* **Framework:** Flutter.
* **Targets activos:** Web y Linux desktop.
* **Navegacion:** `go_router` con guard de autenticacion.
* **Estado:** `flutter_riverpod`.
* **UI:** Material 3, tema oscuro, `google_fonts`, componentes reutilizables y dialogs de confirmacion compartidos.

### Gestion de estado y flujo de datos

* **Providers de infraestructura** para inyectar repositorios concretos de Supabase.
* **FutureProviders family** para vistas dependientes de alumno, pagos y deudores.
* **ConsumerStatefulWidget** en paginas con interaccion local intensa.
* **Actualizaciones optimistas** en flujos como alumnos y pagos para mejorar respuesta percibida.

### Capa de datos

Cada agregado principal del dominio tiene su repositorio dedicado:

* `AlumnoRepository`
* `PagoRepository`
* `DeudorRepository`
* `PrecioRepository`
* `DescuentoRepository`
* `RoutineRepository`
* `SolicitudRutinaRepository`
* `ExerciseRepository`
* `IngresoRepository`
* `GastoRepository`
* `CategoriaGastoRepository`

Las implementaciones concretas viven en `lib/data/repositories/` y consumen **Supabase Postgres** y **Supabase Storage**.

### Backend y automatizaciones

* **Supabase Auth** para login.
* **Supabase Postgres** como fuente principal de datos.
* **Supabase Storage** para PDFs de rutinas (`rutinas-pdf`).
* **Supabase Edge Functions (Deno)** para integraciones serverless.
* **AWS SES** para envio de emails transaccionales y recordatorios.

### Servicios de aplicacion

* `AuthService`: cierre de sesion y encapsulacion del acceso al cliente de auth.
* `PdfGenerator`: genera PDFs de rutinas con soporte para dias, bloques, superseries y notas.
* `StorageService`: sube y elimina PDFs del bucket de Supabase Storage.
* `EmailService`: invoca la Edge Function para enviar rutinas por correo.
* `SecureLocalStorage`: persiste la sesion de Supabase con `flutter_secure_storage`.

### Edge Functions disponibles

* `enviar-rutina`: envia por email una rutina PDF al alumno.
* `confirmar-pago`: dispara confirmaciones de pago usando plantilla de SES.
* `enviar-recordatorio`: procesa deudores y envia recordatorios masivos de pago.

---

## 🧩 Modulos funcionales implementados

### 1. Alumnos

* listado inicial y carga incremental;
* busqueda puntual con selector reutilizable;
* alta, edicion y eliminacion;
* navegacion a detalle y pagos.

### 2. Detalle de alumno

* resumen visual del estado de cuenta;
* historial de pagos;
* rutinas asignadas;
* acceso rapido a acciones relacionadas.

### 3. Pagos

* registro de pago por plan o personalizado;
* medios de pago segmentados;
* descuentos;
* comentarios obligatorios para personalizados;
* manejo de duplicidad mensual;
* edicion y eliminacion.

### 4. Deudores

* listado por estado de mora;
* recordatorios por correo;
* acciones sobre cada deudor;
* integracion con informacion de ultimo pago.

### 5. Precios y descuentos

* mantenimiento de planes por cantidad de dias;
* CRUD de descuentos;
* formularios y widgets dedicados.

### 6. Rutinas

* dashboard de solicitudes pendientes;
* panel de rutinas activas;
* rutinas predeterminadas;
* builder visual para crear/editar rutinas.

### 7. Ingresos

* resumen mensual;
* filtros por hoy, mes actual, fecha especifica y rango de fechas;
* detalle navegable por periodo.

---

## 🧪 Calidad de Software y Metodologia

El proyecto esta trabajado con una cultura claramente orientada a pruebas y regresion controlada.

* **TDD / test-first** aplicado especialmente en formularios, controladores y correcciones de bugs.
* **419 tests automatizados** relevados en `test/` entre unitarios y widget tests.
* Cobertura distribuida sobre:
  * modelos;
  * repositorios;
  * servicios;
  * routers y auth guard;
  * paginas;
  * formularios;
  * widgets del builder;
  * controladores de rutinas.
* **SonarQube / SonarScanner** configurado para analisis estatico y cobertura via `coverage/lcov.info`.

### Ejemplos de areas ya testeadas

* navegacion con `GoRouter`;
* persistencia segura de sesion;
* generacion de PDF;
* storage de rutinas;
* email payloads;
* dashboard de rutinas;
* formularios de alumnos, pagos, descuentos, precios y solicitudes;
* paginas de alumnos, deudores, pagos, login, ingresos y rutinas.

---

## ⚙️ Configuracion Local

### Requisitos

* Flutter SDK compatible con **Dart 3.12**
* Proyecto Supabase operativo
* Variables de entorno cargadas en `.env`

### Variables minimas de aplicacion

```env
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
```

### Variables usadas por Edge Functions

Segun la funcion desplegada, tambien se utilizan variables como:

```env
AWS_REGION_GYM=...
AWS_ACCESS_KEY_ID_GYM=...
AWS_SECRET_ACCESS_KEY_GYM=...
SES_FROM_EMAIL=...
SUPABASE_SERVICE_ROLE_KEY=...
```

### Comandos utiles

```bash
flutter pub get
flutter run -d chrome
flutter test
flutter analyze
```

---

## 🧠 UX / UI

La interfaz actual esta pensada como un panel operativo interno, no como una landing publica.

* **Sidebar + TopBar** como esqueleto de navegacion persistente.
* **Tema oscuro** consistente en todas las pantallas administrativas.
* **Chips, segmented buttons y dialogs** para interacciones frecuentes y rapidas.
* **Feedback inline** para errores de validacion y errores de negocio donde importa el contexto.
* **Snacks globales** para confirmaciones de acciones asincronas.
* **Actualizacion optimista** en algunos flujos para evitar sensacion de lentitud.

---

## ⚙️ Estructura del Proyecto (Destacada)

```text
.
├── assets
│   ├── logo.png
│   └── Roboto/static
├── lib
│   ├── core
│   ├── data
│   │   ├── models
│   │   └── repositories
│   ├── presentacion
│   │   ├── auth
│   │   ├── builder
│   │   ├── controllers
│   │   ├── dashboard
│   │   ├── forms
│   │   └── pages
│   ├── providers
│   └── services
├── supabase
│   └── functions
│       ├── confirmar-pago
│       ├── enviar-recordatorio
│       └── enviar-rutina
├── test
│   ├── core_tests
│   ├── data_tests
│   ├── mocks
│   ├── presentacion
│   ├── servicvies_tests
│   ├── main_test.dart
│   ├── router_auth_guard_test.dart
│   └── router_test.dart
├── linux
└── web
```

---

## 📌 Resumen

El estado real del proyecto hoy es el de un **panel administrativo funcional para gimnasio**, con un modulo de rutinas especialmente trabajado, pero ya acompañado por modulos operativos de alumnos, pagos, deudores, precios e ingresos. La base tecnica tambien esta bastante mas madura que la que reflejaba el README anterior: hay navegacion protegida, servicios de PDF y email, storage, Edge Functions y una suite de tests extensa sosteniendo la evolucion del sistema.
