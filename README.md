# 🏋️‍♂️ Le Groupe Gym - Sistema de Gestión Integral

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![AWS SES](https://img.shields.io/badge/AWS_SES-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)
![Deno](https://img.shields.io/badge/Deno-000000?style=for-the-badge&logo=deno&logoColor=white)
![SonarQube](https://img.shields.io/badge/SonarQube-4E9BCD?style=for-the-badge&logo=sonarqube&logoColor=white)

Plataforma de gestión integral para gimnasios construida con **Flutter** (optimizada para Web y Escritorio) bajo un modelo **Backend-as-a-Service (BaaS)** utilizando **Supabase** y funciones Serverless. 

Este proyecto fue desarrollado con un fuerte enfoque en **arquitectura limpia, Test-Driven Development (TDD) y optimización de rendimiento**.

## 🚧 Estado Actual y Roadmap (Próximos Pasos)

Actualmente, el proyecto se encuentra en una fase de **optimización de rendimiento y refactorización técnica**, con foco exclusivo en llevar al máximo la fluidez y el uso de memoria del **módulo de armado de rutinas** (Routine Builder) y la generación de sus PDFs en el cliente.

Una vez estabilizada esta funcionalidad core, el roadmap del sistema contempla el desarrollo del ecosistema administrativo completo:
* **Módulo Integral de Alumnos:** Alta, baja y modificación de perfiles con historial de rutinas asignadas.
* **Gestión de Pagos y Vencimientos:** Control de fechas de cobro y registro de transacciones.
* **Panel de Deudores:** Identificación automatizada de cuotas vencidas y alumnos en mora.
* **Dashboard Financiero:** Métricas mensuales y reportes de ingresos consolidados.

---

## 🚀 Características Principales

* **Routine Builder (Constructor de Rutinas):** Interfaz interactiva para el armado de rutinas personalizadas (bloques, superseries).
* **Generación Nativa de PDFs:** El motor de renderizado de PDFs se ejecuta íntegramente en el cliente (Frontend) para reducir costos de cómputo en el servidor.
* **Distribución Automatizada de Emails:** Integración con **AWS SES** a través de Edge Functions para el envío automático de rutinas y reportes en formato PDF a los alumnos.

---

## 🏗️ Arquitectura y Stack Tecnológico

El proyecto está diseñado para ser altamente escalable y mantener los costos operativos al mínimo (Serverless) aprovechando los *Free Tiers* de plataformas Cloud.

### Frontend
* **Framework:** Flutter (Web / Linux).
* **State Management:** `Provider` con estricta **Separación de Responsabilidades**.
    * *Providers Locales / Scoped* para módulos de memoria intensiva (ej. `RoutineBuilderController`).
* **Rendimiento:** Implementación de selectores quirúrgicos (`context.select`) y virtualización de listas para mitigar *rebuilds* innecesarios, analizados mediante **Flutter DevTools** (Timeline / Memory Allocation).

### Backend & Base de Datos
* **Base de Datos:** PostgreSQL alojada en **Supabase**, con políticas de seguridad por nivel de fila (RLS) habilitadas.
* **Lógica Serverless:** **Edge Functions** (Deno) utilizadas como puente liviano entre el cliente y servicios de terceros.

### Infraestructura y Cloud
* **Mailing:** **Amazon SES (Simple Email Service)**. Las credenciales están resguardadas en el backend; el cliente invoca la Edge Function, la cual ejecuta de forma segura el `SendEmailCommand` hacia AWS.

---

## 🧪 Calidad de Software y Metodología

Para asegurar la robustez a largo plazo y facilitar la mantenibilidad, el desarrollo se guía por prácticas de la industria:

* **Test-Driven Development (TDD):** La lógica de negocio principal y los controladores de estado fueron desarrollados escribiendo los tests unitarios primero (`flutter test`).
* **Análisis Estático Continuo:** Integración con **SonarQube** / SonarScanner. El código se evalúa contra reglas estrictas de Dart, detectando *code smells*, complejidad ciclomática excesiva y midiendo la cobertura de código (`lcov.info`).
* **Optimización Asistida por IA:** Uso de herramientas de agentes de Google (Antigravity/Gemini) bajo el estándar **Agent Skills** para auditar micro-tirones (jank) y pérdidas de memoria en los volcados del Dart VM Service.

---

## ⚙️ Estructura del Proyecto (Destacada)

```text
.
├── assets
│   └── Roboto
│       └── static
├── build
│ 
├── lib
│   ├── core
│   ├── data
│   │   ├── models
│   │   └── repositories
│   ├── presentacion
│   │   ├── builder
│   │   │   └── widgets
│   │   ├── dashboard
│   │   │   └── widgets
│   │   ├── forms
│   │   └── pages
│   ├── providers
│   └── services
├── linux
│   ├── flutter
│   │   └── ephemeral
│   │       └── flutter_linux
│   └── runner
├── supabase
│   └── functions
│       ├── confirmar-pago
│       ├── enviar-recordatorio
│       └── enviar-rutina
├── test
│   ├── form_tests
│   └── mocks
└── web
    └── icons

