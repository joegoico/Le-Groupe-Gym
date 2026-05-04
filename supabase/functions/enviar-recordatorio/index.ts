import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"
import { SESClient, SendTemplatedEmailCommand } from "https://esm.sh/@aws-sdk/client-ses"

const sesClient = new SESClient({
  region: Deno.env.get("AWS_REGION_GYM") || "us-east-2",
  credentials: {
    accessKeyId: Deno.env.get("AWS_ACCESS_KEY_ID_GYM")!,
    secretAccessKey: Deno.env.get("AWS_SECRET_ACCESS_KEY_GYM")!,
  },
})

serve(async (req) => {
  try {
    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    )

    // --- ELIMINAMOS req.json() para que no de error 500 al estar vacío ---

    // 1. Buscamos TODOS los deudores
    const { data: deudores, error: deudoresErr } = await supabase
      .from('Deudor')
      .select(`
        dias_adeudados,
        nombre,
        Alumno ( Mail )
      `)

    if (deudoresErr) throw deudoresErr
    if (!deudores || deudores.length === 0) {
      return new Response(JSON.stringify({ message: "No hay deudores para procesar" }))
    }

    // 2. Traemos precios y descuento (una sola vez para optimizar)
    const { data: precios } = await supabase.from('Precios').select('cantidad_dias, valor')
    const { data: descData } = await supabase.from('Descuentos').select('Valor').limit(1).single()

    const getPrecio = (cant: number) => {
      const p = precios?.find(p => p.cantidad_dias === cant)?.valor
      return p ? `$${p.toLocaleString('es-AR')}` : "Consultar"
    }

    const valorDescuento = `$${descData?.Valor || 0}`

    // 3. Bucle de envío masivo
    const resultados = await Promise.allSettled(
      deudores.map(async (deudor) => {
        const command = new SendTemplatedEmailCommand({
          Source: "recordatorios@legroupegym.com",
          Destination: { ToAddresses: [deudor.Alumno.Mail] },
          Template: "RecordatorioPagoVencido",
          TemplateData: JSON.stringify({
            nombre: `${deudor.nombre}`,
            dias_vencidos: deudor.dias_adeudados,
            precio2x: getPrecio(2),
            precio3x: getPrecio(3),
            precio4x: getPrecio(4),
            precio5x: getPrecio(5),
            descuento: valorDescuento
          }),
        })
        return sesClient.send(command)
      })
    )

    // 4. Reporte final para ver en la consola
    const enviados = resultados.filter(r => r.status === 'fulfilled').length
    const fallidos = resultados.filter(r => r.status === 'rejected').length

    return new Response(
      JSON.stringify({ message: "Proceso completado", enviados, fallidos }),
      { headers: { "Content-Type": "application/json" } }
    )

  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { 
      status: 500,
      headers: { "Content-Type": "application/json" }
    })
  }
})