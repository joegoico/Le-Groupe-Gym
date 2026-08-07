-- Cambios posteriores a la migración inicial. Seguro para `supabase db push`.
begin;

revoke all on table
  public."Alumno", public."Bloques_Rutina", public."Categorias_Ejercicio",
  public."Categorias_gastos", public."Descuentos", public."Deudor",
  public."Dias_Rutina", public."Ejercicios", public."Gastos", public."Ingresos",
  public."Log_Sistema", public."Pagos", public."Precios", public."Rel_Ejercicio_Categoria",
  public."Rutina_Ejercicios", public."Rutinas", public."Solicitudes_Rutina"
from anon;

alter default privileges for role postgres in schema public
revoke all on tables
from anon;

alter default privileges for role postgres in schema public
revoke
execute on functions
from anon;

revoke all on function public.delete_rutina_pdf() from public, anon, authenticated;

revoke all on function public.fn_actualizar_contabilidad_mes ()
from public, anon, authenticated;

revoke all on function public.fn_limpiar_deudor ()
from public, anon, authenticated;

revoke all on function public.insert_ingreso_from_pago ()
from public, anon, authenticated;

revoke all on function public.limit_rutinas_por_alumno ()
from public, anon, authenticated;

revoke all on function public.limpiar_deudores_antiguos ()
from public, anon, authenticated;

revoke all on function public.revisar_vencimientos_y_deudores ()
from public, anon, authenticated;

create or replace function public.insert_ingreso_from_pago
()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if tg_op = 'INSERT' then
    insert into public."Ingresos" (fecha_ingreso, concepto, monto, medio_de_pago, id_pago, user_id)
    values (new."Fecha_de_pago", 'Plan de ' || new.cantidad_dias || ' días', new.monto,
            new.medio_de_pago, new.id_pago, new.user_id);
    insert into public."Log_Sistema" (evento, detalle, user_id)
    values ('Ingreso generado', 'Se generó el ingreso asociado al pago ' || new.id_pago || '.', new.user_id);
  else
    update public."Ingresos"
    set fecha_ingreso = new."Fecha_de_pago", concepto = 'Plan de ' || new.cantidad_dias || ' días',
        monto = new.monto, medio_de_pago = new.medio_de_pago
    where id_pago = new.id_pago;
    insert into public."Log_Sistema" (evento, detalle, user_id)
    values ('Ingreso actualizado', 'Se actualizó el ingreso asociado al pago ' || new.id_pago || '.', new.user_id);
  end if;
  return new;
end;
$$;

drop trigger if exists trigger_ingreso_from_pago on public."Pagos";

create trigger trigger_ingreso_from_pago
after insert or update of "Fecha_de_pago", monto, medio_de_pago, cantidad_dias
on public."Pagos" for each row execute function public.insert_ingreso_from_pago
();

revoke all on function public.insert_ingreso_from_pago ()
from public, anon, authenticated;

create or replace function public.insert_rutina_completa(
  p_nombre text, p_id_alumno uuid, p_notas_generales text, p_es_predeterminada boolean, p_dias jsonb
) returns bigint language plpgsql security definer set search_path = public, pg_temp as $$
declare v_id_rutina bigint; v_user_id uuid := auth.uid(); v_dia jsonb; v_id_dia bigint; v_bloque jsonb; v_id_bloque bigint; v_ejercicio jsonb;
begin
  if v_user_id is null then raise exception 'No hay sesión activa.' using errcode = '28000'; end if;
  if jsonb_typeof(p_dias) <> 'array' then raise exception 'El detalle de días es inválido.' using errcode = '22023'; end if;
  if not coalesce(p_es_predeterminada, false) and p_id_alumno is null then raise exception 'La rutina debe pertenecer a un alumno.' using errcode = '23514'; end if;
  if p_id_alumno is not null and not exists (select 1 from public."Alumno" where id_alumno = p_id_alumno and user_id = v_user_id) then raise exception 'No tenés permisos sobre el alumno indicado.' using errcode = '42501'; end if;
  insert into public."Rutinas" (nombre_rutina,id_alumno,notas_generales,es_predeterminada,user_id) values (p_nombre,p_id_alumno,p_notas_generales,coalesce(p_es_predeterminada,false),v_user_id) returning id_rutina into v_id_rutina;
  for v_dia in select * from jsonb_array_elements(p_dias) loop
    insert into public."Dias_Rutina" (id_rutina,nombre_dia,orden) values (v_id_rutina,v_dia->>'nombre_dia',(v_dia->>'orden')::integer) returning id_dia into v_id_dia;
    for v_bloque in select * from jsonb_array_elements(coalesce(v_dia->'bloques','[]'::jsonb)) loop
      insert into public."Bloques_Rutina" (id_dia,nombre,orden) values (v_id_dia,v_bloque->>'nombre',(v_bloque->>'orden')::integer) returning id_bloque into v_id_bloque;
      for v_ejercicio in select * from jsonb_array_elements(coalesce(v_bloque->'ejercicios','[]'::jsonb)) loop
        if not exists (select 1 from public."Ejercicios" where id_ejercicio=(v_ejercicio->>'id_ejercicio')::integer) then raise exception 'El ejercicio indicado no existe.' using errcode='23503'; end if;
        insert into public."Rutina_Ejercicios" (id_dia,id_bloque,id_ejercicio,series,repeticiones,orden,observaciones) values (v_id_dia,v_id_bloque,(v_ejercicio->>'id_ejercicio')::integer,(v_ejercicio->>'series')::integer,v_ejercicio->>'repeticiones',(v_ejercicio->>'orden')::integer,coalesce(v_ejercicio->>'observaciones',''));
      end loop;
    end loop;
  end loop;
  insert into public."Log_Sistema" (evento,detalle,user_id) values ('Rutina creada','Se creó la rutina "' || p_nombre || '" (' || v_id_rutina || ').',v_user_id);
  return v_id_rutina;
end;
$$;

create or replace function public.update_rutina(p_id_rutina integer,p_nombre character varying,p_notas_generales text,p_dias jsonb)
returns void language plpgsql security definer set search_path = public, pg_temp as $$
declare v_user_id uuid := auth.uid(); v_dia jsonb; v_bloque jsonb; v_ejercicio jsonb; v_id_dia integer; v_id_bloque integer; v_bloque_orden integer;
begin
  if v_user_id is null then raise exception 'No hay sesión activa.' using errcode='28000'; end if;
  if jsonb_typeof(p_dias) <> 'array' then raise exception 'El detalle de días es inválido.' using errcode='22023'; end if;
  if not exists (select 1 from public."Rutinas" where id_rutina=p_id_rutina and user_id=v_user_id) then raise exception 'No tenés permisos sobre la rutina indicada.' using errcode='42501'; end if;
  update public."Rutinas" set nombre_rutina=p_nombre,notas_generales=p_notas_generales where id_rutina=p_id_rutina and user_id=v_user_id;
  delete from public."Dias_Rutina" where id_rutina=p_id_rutina;
  for v_dia in select * from jsonb_array_elements(p_dias) loop
    insert into public."Dias_Rutina" (id_rutina,nombre_dia,orden) values (p_id_rutina,v_dia->>'nombre_dia',(v_dia->>'orden')::integer) returning id_dia into v_id_dia; v_bloque_orden:=0;
    for v_bloque in select * from jsonb_array_elements(coalesce(v_dia->'bloques','[]'::jsonb)) loop
      insert into public."Bloques_Rutina" (id_dia,nombre,orden) values (v_id_dia,v_bloque->>'nombre',v_bloque_orden) returning id_bloque into v_id_bloque; v_bloque_orden:=v_bloque_orden+1;
      for v_ejercicio in select * from jsonb_array_elements(coalesce(v_bloque->'ejercicios','[]'::jsonb)) loop
        if not exists (select 1 from public."Ejercicios" where id_ejercicio=(v_ejercicio->>'id_ejercicio')::integer) then raise exception 'El ejercicio indicado no existe.' using errcode='23503'; end if;
        insert into public."Rutina_Ejercicios" (id_dia,id_bloque,id_ejercicio,series,repeticiones,orden) values (v_id_dia,v_id_bloque,(v_ejercicio->>'id_ejercicio')::integer,(v_ejercicio->>'series')::integer,v_ejercicio->>'repeticiones',(v_ejercicio->>'orden')::integer);
      end loop;
    end loop;
  end loop;
  insert into public."Log_Sistema" (evento,detalle,user_id) values ('Rutina actualizada','Se actualizó la rutina "' || p_nombre || '" (' || p_id_rutina || ').',v_user_id);
end;
$$;

create or replace function public.revisar_vencimientos_y_deudores()
returns void language plpgsql set search_path = public, pg_temp as $$
declare r_alumno record; v_ultima_fecha_pago date; v_dias_desde_pago integer; v_atraso_real integer;
begin
  for r_alumno in select id_alumno,"Nombre","Apellido",user_id from public."Alumno" loop
    select max("Fecha_de_pago") into v_ultima_fecha_pago from public."Pagos" where id_alumno=r_alumno.id_alumno;
    if v_ultima_fecha_pago is not null and current_date-v_ultima_fecha_pago>30 then
      v_dias_desde_pago:=current_date-v_ultima_fecha_pago; v_atraso_real:=v_dias_desde_pago-30;
      insert into public."Deudor" (id_deudor,dias_adeudados,nombre,apellido,user_id) values (r_alumno.id_alumno,v_atraso_real,r_alumno."Nombre",r_alumno."Apellido",r_alumno.user_id)
      on conflict (id_deudor) do update set dias_adeudados=excluded.dias_adeudados,nombre=excluded.nombre,apellido=excluded.apellido,user_id=excluded.user_id;
      insert into public."Log_Sistema" (evento,detalle,user_id) values ('Deudor actualizado','Se actualizó la deuda de ' || r_alumno."Nombre" || ' ' || r_alumno."Apellido" || '.',r_alumno.user_id);
    end if;
  end loop;
end;
$$;

create or replace function public.fn_limpiar_deudor()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
declare diferencia_dias integer; nombre_alumno text;
begin
  select "Nombre" || ' ' || "Apellido" into nombre_alumno from public."Alumno" where id_alumno=new.id_alumno;
  diferencia_dias:=current_date-new."Fecha_de_pago"::date;
  if diferencia_dias<=30 then delete from public."Deudor" where id_deudor=new.id_alumno and user_id=new.user_id; end if;
  insert into public."Log_Sistema" (evento,detalle,user_id) values (case when diferencia_dias<=30 then 'Pago reciente' else 'Pago antiguo' end,'Alumno ' || coalesce(nombre_alumno,'Desconocido') || ' registró un pago.',new.user_id);
  return new;
end;
$$;

alter function public.get_resumenes_mensuales(date,date,date) security invoker;

revoke all on function public.insert_rutina_completa (
    text,
    uuid,
    text,
    boolean,
    jsonb
)
from public, anon;

revoke all on function public.update_rutina (
    integer,
    character varying,
    text,
    jsonb
)
from public, anon;

revoke all on function public.get_resumenes_mensuales (date, date, date)
from public, anon;

grant
execute on function public.insert_rutina_completa (
    text,
    uuid,
    text,
    boolean,
    jsonb
) to authenticated,
service_role;

grant
execute on function public.update_rutina (
    integer,
    character varying,
    text,
    jsonb
) to authenticated,
service_role;

grant
execute on function public.get_resumenes_mensuales (date, date, date) to authenticated,
service_role;

drop policy if exists "CRUD propio deudor" on public."Deudor";
drop policy if exists "DELETE for auth" on public."Deudor";

drop policy if exists "Lectura propia de deudores" on public."Deudor";

create policy "Lectura propia de deudores" on public."Deudor" for select to authenticated using (user_id=auth.uid());

create or replace function public.delete_rutina_pdf()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
begin
  if old.url_pdf is not null then
    delete from storage.objects
    where bucket_id = 'rutinas-pdf'
      and name = concat('alumnos/', old.id_alumno, '/rutina_', old.id_rutina, '.pdf');
    insert into public."Log_Sistema" (evento, detalle, user_id)
    values ('PDF de rutina eliminado', 'Se eliminó el PDF de la rutina ' || old.id_rutina || '.', old.user_id);
  end if;
  return old;
end;
$$;

create or replace function public.limit_rutinas_por_alumno()
returns trigger language plpgsql security definer set search_path = public, pg_temp as $$
declare v_eliminadas integer;
begin
  delete from public."Rutinas"
  where id_alumno = new.id_alumno
    and id_rutina not in (
      select id_rutina from public."Rutinas"
      where id_alumno = new.id_alumno
      order by fecha_creacion desc
      limit 3
    );
  get diagnostics v_eliminadas = row_count;
  if v_eliminadas > 0 then
    insert into public."Log_Sistema" (evento, detalle, user_id)
    values ('Rutinas antiguas eliminadas', 'Se eliminaron ' || v_eliminadas || ' rutina(s) por el límite del alumno.', new.user_id);
  end if;
  return new;
end;
$$;

commit;