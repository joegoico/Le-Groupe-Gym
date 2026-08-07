-- Contrato de sincronización: cada pago conserva un único ingreso asociado
-- cuando se modifica.
-- Ejecutar después de `supabase db reset`.

begin;

do $$
declare
  v_pago_id uuid := gen_random_uuid();
  v_ingreso public."Ingresos"%rowtype;
begin
  insert into public."Pagos" (
    id_pago,
    "Fecha_de_pago",
    monto,
    medio_de_pago,
    cantidad_dias
  ) values (
    v_pago_id,
    date '2026-08-01',
    10000,
    'Efectivo',
    3
  );

  update public."Pagos"
  set
    "Fecha_de_pago" = date '2026-08-03',
    monto = 12500,
    medio_de_pago = 'Transferencia',
    cantidad_dias = 5
  where id_pago = v_pago_id;

  select * into v_ingreso
  from public."Ingresos"
  where id_pago = v_pago_id;

  if not found then
    raise exception 'Falta el ingreso asociado al pago actualizado';
  end if;

  if v_ingreso.fecha_ingreso <> date '2026-08-03'
    or v_ingreso.monto <> 12500
    or v_ingreso.medio_de_pago <> 'Transferencia'
    or v_ingreso.concepto <> 'Plan de 5 días' then
    raise exception 'El ingreso asociado no refleja los datos editados del pago';
  end if;

  if (select count(*) from public."Ingresos" where id_pago = v_pago_id) <> 1 then
    raise exception 'La edición del pago no debe crear un ingreso adicional';
  end if;
end;
$$;

rollback;
