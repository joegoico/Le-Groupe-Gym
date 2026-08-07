# Diagnóstico y plan de refactorización

## Paso 1 — superficie de Supabase

La fuente de verdad del esquema es `supabase/migrations/20260804142317_remote_schema.sql`.

La migración `20260804150000_harden_rls_and_rpcs.sql`:

- revoca acceso directo del rol `anon` a todas las tablas de aplicación y evita que ese privilegio se conceda por defecto;
- restringe las RPC públicas a `authenticated` y `service_role`;
- valida en servidor la propiedad del alumno al crear una rutina y de la rutina al actualizarla antes de borrar sus dependencias;
- hace que `get_resumenes_mensuales` se ejecute como invocante;
- conserva `user_id` al crear deudores desde la tarea automática y elimina IDs de usuario hardcodeados.

`Ejercicios` y sus categorías siguen siendo un catálogo compartido de solo lectura porque no tienen `user_id` y la aplicación los consume globalmente. Cambiar ese modelo exige una migración funcional aparte.

El bucket `rutinas-pdf` sigue público de forma temporal para no invalidar enlaces existentes. Su migración a privado, los paths UUID y las URLs firmadas forman una única entrega atómica del paso 2.

## Pruebas

`supabase/tests/rls_security_contract.sql` comprueba que las tablas con propietario mantengan RLS, que las tablas hijas hereden el ownership de la rutina y que las RPC no sean ejecutables por `anon`.

Pendiente de ejecución: el disco raíz del entorno está al 100 %, por lo que no fue posible iniciar Docker/Supabase local ni ejecutar Flutter. No se aplicó ninguna migración al proyecto remoto.
