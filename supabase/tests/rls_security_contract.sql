-- Contrato de seguridad para ejecutar después de `supabase db reset`.
-- Falla con un error si una migración vuelve a exponer datos o RPCs de otro
-- usuario. No crea ni modifica datos de la aplicación.

begin;

do $$
declare
  protected_tables constant text[] := array[
    'Alumno', 'Categorias_gastos', 'Descuentos', 'Deudor', 'Gastos',
    'Ingresos', 'Pagos', 'Precios', 'Rutinas', 'Solicitudes_Rutina'
  ];
  table_name text;
  definition text;
begin
  foreach table_name in array protected_tables loop
    if not exists (
      select 1
      from pg_policies
      where schemaname = 'public'
        and tablename = table_name
        and roles @> array['authenticated']::name[]
        and coalesce(qual, '') like '%auth.uid()%'
        and coalesce(with_check, '') like '%auth.uid()%'
    ) then
      raise exception 'Falta una política RLS de ownership para public.%', table_name;
    end if;
  end loop;

  foreach table_name in array array['Dias_Rutina', 'Bloques_Rutina', 'Rutina_Ejercicios'] loop
    if not exists (
      select 1
      from pg_policies
      where schemaname = 'public'
        and tablename = table_name
        and roles @> array['authenticated']::name[]
        and coalesce(qual, '') like '%auth.uid()%'
        and coalesce(with_check, '') like '%auth.uid()%'
    ) then
      raise exception 'Falta una política RLS derivada de la rutina para public.%', table_name;
    end if;
  end loop;

  if has_function_privilege('anon', 'public.insert_rutina_completa(text, uuid, text, boolean, jsonb)', 'execute')
    or has_function_privilege('anon', 'public.update_rutina(integer, character varying, text, jsonb)', 'execute')
    or has_function_privilege('anon', 'public.get_resumenes_mensuales(date, date, date)', 'execute') then
    raise exception 'Las RPC de negocio no pueden ejecutarse con el rol anon';
  end if;

  if not has_function_privilege('authenticated', 'public.insert_rutina_completa(text, uuid, text, boolean, jsonb)', 'execute')
    or not has_function_privilege('authenticated', 'public.update_rutina(integer, character varying, text, jsonb)', 'execute')
    or not has_function_privilege('authenticated', 'public.get_resumenes_mensuales(date, date, date)', 'execute') then
    raise exception 'Las RPC de negocio deben permanecer disponibles para authenticated';
  end if;

  select pg_get_functiondef('public.insert_rutina_completa(text, uuid, text, boolean, jsonb)'::regprocedure)
    into definition;
  if definition not like '%auth.uid()%' or definition not like '%p_id_alumno%' then
    raise exception 'insert_rutina_completa debe validar la propiedad del alumno';
  end if;

  select pg_get_functiondef('public.update_rutina(integer, character varying, text, jsonb)'::regprocedure)
    into definition;
  if definition not like '%auth.uid()%' or definition not like '%p_id_rutina%' then
    raise exception 'update_rutina debe validar la propiedad antes de eliminar hijos';
  end if;

  if (select prosecdef from pg_proc where oid = 'public.get_resumenes_mensuales(date, date, date)'::regprocedure) then
    raise exception 'get_resumenes_mensuales debe ejecutarse con los permisos del invocante';
  end if;
end;
$$;

rollback;
