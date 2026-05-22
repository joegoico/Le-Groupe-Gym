import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
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
    // El webhook de Supabase envía el registro insertado en 'record'
    const { record } = await req.json()

    // Mapeamos los campos de tu tabla 'Pagos' (o como se llame) a las variables del template
    // Asumo que 'record' trae: nombre_alumno, mail_alumno, mes_pagado, fecha, monto, dias_plan
    const emailCommand = new SendTemplatedEmailCommand({
      Source: "contacto@legroupegym.com",
      Destination: { ToAddresses: [record.mail_alumno] },
      Template: "PagoRegistradoConfirmacion",
      TemplateData: JSON.stringify({
        nombre: record.nombre_alumno,
        mesPagado: record.mes_pagado,
        fechaPago: record.fecha_pago, // Formato DD/MM/YYYY
        dias: record.dias_plan,
        monto: `$${record.monto.toLocaleString('es-AR')}`
      }),
    })

    await sesClient.send(emailCommand)

    return new Response(JSON.stringify({ success: true }), { 
      headers: { "Content-Type": "application/json" } 
    })
  } catch (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }
})
