import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { SESClient, SendEmailCommand } from 'https://esm.sh/@aws-sdk/client-ses'

const ses = new SESClient({
  region: Deno.env.get('AWS_REGION_GYM')!,
  credentials: {
    accessKeyId: Deno.env.get('AWS_ACCESS_KEY_ID_GYM')!,
    secretAccessKey: Deno.env.get('AWS_SECRET_ACCESS_KEY_GYM')!,
  },
})
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
  'Access-Control-Max-Age': '86400',
}
serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response(null, { 
      status: 204,
      headers: corsHeaders 
    })
  }
  try {
    const { pdfUrl, mailAlumno, nombreAlumno, nombreRutina } = await req.json()

    if (!pdfUrl || !mailAlumno) {
      return new Response(
        JSON.stringify({ error: 'pdfUrl y mailAlumno son requeridos' }),
        { status: 400 }
      )
    }

    await ses.send(
      new SendEmailCommand({
        Source: Deno.env.get('SES_FROM_EMAIL')!,
        Destination: { ToAddresses: [mailAlumno] },
        Message: {
          Subject: {
            Data: `Tu rutina de entrenamiento - ${nombreRutina}`,
            Charset: 'UTF-8',
          },
          Body: {
            Html: {
              Charset: 'UTF-8',
              Data: `
                <!DOCTYPE html>
                <html>
                  <head>
                    <meta charset="utf-8">
                  </head>
                  <body style="margin: 0; padding: 0; background-color: #f4f4f5; font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif; color: #333333;">
                    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f4f4f5; padding: 30px 10px;">
                      <tr>
                        <td align="center">
                          <table width="100%" cellpadding="0" cellspacing="0" style="max-width: 550px; background-color: #ffffff; border-radius: 8px; overflow: hidden; border: 1px solid #e5e7eb;">
                            
                            <tr>
                              <td style="background-color: #111827; padding: 30px 20px; text-align: center;">
                                <h1 style="color: #ffffff; margin: 0; font-size: 24px; letter-spacing: 2px; text-transform: uppercase; font-weight: 700;">Le Groupe Gym</h1>
                              </td>
                            </tr>
                            
                            <tr>
                              <td style="padding: 35px 25px;">
                                <h2 style="margin-top: 0; color: #111827; font-size: 20px; font-weight: 600;">Hola ${nombreAlumno},</h2>
                                
                                <p style="font-size: 15px; line-height: 1.6; color: #4b5563; margin-bottom: 25px;">
                                  Ya preparamos una nueva rutina para vos: <strong style="color: #111827;">${nombreRutina}</strong>.
                                </p>
                                
                                <p style="font-size: 15px; line-height: 1.6; color: #4b5563; margin-bottom: 20px;">
                                  Podés descargar y revisar tu plan de entrenamiento haciendo clic en el siguiente botón:
                                </p>
                                
                                <table width="100%" cellpadding="0" cellspacing="0" style="margin: 25px 0 35px 0;">
                                  <tr>
                                    <td align="center">
                                      <a href="${pdfUrl}" 
                                         style="display: inline-block; padding: 14px 28px; background-color: #111827; color: #ffffff; text-decoration: none; border-radius: 6px; font-weight: 600; font-size: 15px; border: 1px solid #374151;">
                                        Descargar rutina PDF
                                      </a>
                                    </td>
                                  </tr>
                                </table>
                                
                                <table width="100%" cellpadding="0" cellspacing="0" style="border-top: 1px solid #e5e7eb; padding-top: 20px;">
                                  <tr>
                                    <td>
                                      <p style="margin: 0; font-size: 15px; color: #111827; font-weight: 600;">Atentamente,</p>
                                      <p style="margin: 4px 0 0 0; font-size: 15px; color: #4b5563; font-weight: bold;">Le Groupe Gym</p>
                                    </td>
                                  </tr>
                                </table>
                              </td>
                            </tr>
                            
                          </table>
                        </td>
                      </tr>
                    </table>
                  </body>
                </html>
              `,
            },
          },
        },
      })
    )

    return new Response(
      JSON.stringify({ success: true }),
      { status: 200, headers: { ...corsHeaders,'Content-Type': 'application/json' } }
    )
  } catch (error) {
    console.error('Error detallado:', error)
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 500, headers: { ...corsHeaders,'Content-Type': 'application/json' } }
    )
  }
})