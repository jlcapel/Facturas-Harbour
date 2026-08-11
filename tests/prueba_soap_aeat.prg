#require "hbtest"
#include "hbtest.ch"

PROCEDURE Main()
   LOCAL hAlta := RegistroPrueba(0), hAnulacion := RegistroPrueba(1)
   LOCAL cAlta, cAnulacion, cConsulta, aRespuesta, aPreparacion
   LOCAL lAlta, lExenta, lAnulacion, lConsulta, lEscape, lCsv, lErrores, lDesconocida, lCertificado, lHtml

   cAlta := ConstruirSoapAeat(hAlta)
   lAlta := At('<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"', cAlta) > 0 .AND. ;
      At('<sf:RegistroAlta>', cAlta) > 0 .AND. At('<sf:SistemaInformatico>', cAlta) > 0 .AND. ;
      At('<sf:ImporteTotal>121.80</sf:ImporteTotal>', cAlta) > 0 .AND. At('<sf:Huella>AAAAAAAA', cAlta) > 0
   lEscape := At('Servicio &amp; &lt;especial&gt; &quot;x&quot; &apos;', cAlta) > 0

   hAlta["Desglose"] := '{"DetalleDesglose":[{"Impuesto":"01","ClaveRegimen":"01","CalificacionOperacion":null,"OperacionExenta":"E5","TipoImpositivo":0,"BaseImponibleOimporteNoSujeto":100,"CuotaRepercutida":0}]}'
   cAlta := ConstruirSoapAeat(hAlta)
   lExenta := At('<sf:OperacionExenta>E5</sf:OperacionExenta>', cAlta) > 0 .AND. At('<sf:CalificacionOperacion>', cAlta) == 0

   cAnulacion := ConstruirSoapAeat(hAnulacion)
   lAnulacion := At('<sf:RegistroAnulacion>', cAnulacion) > 0 .AND. At('<sf:RegistroAlta>', cAnulacion) == 0 .AND. ;
      At('<sf:IDEmisorFacturaAnulada>B12345678</sf:IDEmisorFacturaAnulada>', cAnulacion) > 0 .AND. ;
      At('<sf:NumSerieFacturaAnulada>F2026-000001</sf:NumSerieFacturaAnulada>', cAnulacion) > 0 .AND. ;
      At('<sf:FechaExpedicionFacturaAnulada>04-07-2026</sf:FechaExpedicionFacturaAnulada>', cAnulacion) > 0

   cConsulta := ConstruirSoapConsultaAeat(RegistroPrueba(0))
   lConsulta := At('<sf:RegistroAlta>', cConsulta) > 0 .AND. At('<sf:Huella>AAAAAAAA', cConsulta) > 0 .AND. ;
      At('<sf:NumSerieFactura>F2026-000001</sf:NumSerieFactura>', cConsulta) > 0

   aRespuesta := ProcesarRespuestaAeat('<soap:Envelope><soap:Body><sfLR:CSV> CSV-123 </sfLR:CSV></soap:Body></soap:Envelope>', .T.)
   lCsv := aRespuesta[1] .AND. aRespuesta[2] == "CSV-123" .AND. aRespuesta[3] == "ServiceRegistroEnviado"

   aRespuesta := ProcesarRespuestaAeat('<Respuesta><sf:Error>Error 4101</sf:Error><Error>Factura &amp; duplicada</Error></Respuesta>', .T.)
   lErrores := !aRespuesta[1] .AND. aRespuesta[2] == "" .AND. aRespuesta[3] == "Error 4101; Factura & duplicada"

   aRespuesta := ProcesarRespuestaAeat('<Respuesta><Estado>Pendiente</Estado></Respuesta>', .T.)
   lDesconocida := !aRespuesta[1] .AND. aRespuesta[3] == "ServiceRespuestaSinCsv"

   aRespuesta := ProcesarRespuestaAeat('<HTML><h3>Descripcion: Certificado &amp; no válido</h3></HTML>', .T.)
   lHtml := !aRespuesta[1] .AND. At("ServiceRespuestaHtml", aRespuesta[3]) > 0 .AND. At("Certificado & no válido", aRespuesta[3]) > 0

   aPreparacion := PrepararEnvioAeat(NIL)
   lCertificado := !aPreparacion[1] .AND. aPreparacion[2] == "CERTIFICADO_AUSENTE"

   HBTEST lAlta IS .T.
   HBTEST lExenta IS .T.
   HBTEST lAnulacion IS .T.
   HBTEST lConsulta IS .T.
   HBTEST lEscape IS .T.
   HBTEST lCsv IS .T.
   HBTEST lErrores IS .T.
   HBTEST lDesconocida IS .T.
   HBTEST lHtml IS .T.
   HBTEST lCertificado IS .T.
   ErrorLevel(Iif(lAlta .AND. lExenta .AND. lAnulacion .AND. lConsulta .AND. lEscape .AND. ;
      lCsv .AND. lErrores .AND. lDesconocida .AND. lHtml .AND. lCertificado, 0, 1))
RETURN

STATIC FUNCTION RegistroPrueba(nTipoRegistro)
   LOCAL hRegistro := {=>}

   hRegistro["TipoRegistro"] := LTrim(Str(nTipoRegistro))
   hRegistro["Hash"] := Replicate("A", 64)
   hRegistro["NifEmisor"] := "B12345678"
   hRegistro["NumeroFactura"] := "F2026-000001"
   hRegistro["FechaEmision"] := "2026-07-04"
   hRegistro["IvaImporte"] := "21.55"
   hRegistro["Total"] := "121.80"
   hRegistro["IdFacturaAnulada"] := "F2026-000001"
   hRegistro["FechaFacturaAnulada"] := "2026-07-04"
   hRegistro["IDVersion"] := "1.0"
   hRegistro["NombreRazonEmisor"] := "Empresa Test"
   hRegistro["TipoFactura"] := "F1"
   hRegistro["FechaOperacion"] := "2026-07-04"
   hRegistro["DescripcionOperacion"] := "Servicio & <especial> " + Chr(34) + "x" + Chr(34) + " '"
   hRegistro["FacturaSimplificadaArt7273"] := "N"
   hRegistro["FacturaSinIdentifDestinatarioArt61d"] := "N"
   hRegistro["Macrodato"] := "N"
   hRegistro["Destinatarios"] := '[{"NombreRazon":"Cliente Test","NIF":"00000000T","EsNacional":true}]'
   hRegistro["Desglose"] := '{"DetalleDesglose":[{"Impuesto":"01","ClaveRegimen":"01","CalificacionOperacion":"S1","OperacionExenta":null,"TipoImpositivo":21.5,"BaseImponibleOimporteNoSujeto":100.25,"CuotaRepercutida":21.55}]}'
   hRegistro["Encadenamiento"] := '{"PrimerRegistro":"S"}'
   hRegistro["SistemaInformatico"] := '{"NombreRazon":"Empresa Test","NIF":"B12345678","NombreSistemaInformatico":"Facturas","IdSistemaInformatico":"FV","Version":"1.0.0","NumeroInstalacion":"1","TipoUsoPosibleSoloVerifactu":"S","TipoUsoPosibleMultiOT":"N","IndicadorMultiplesOT":"N"}'
   hRegistro["FechaHoraHusoGenRegistro"] := "2026-07-04T10:00:00Z"
   hRegistro["TipoHuella"] := "01"
RETURN hRegistro

FUNCTION ObtenerConfiguracion(db, cClave)
   IF cClave == "VeriFactu.Ambiente"
      RETURN "2"
   ENDIF
RETURN NIL

FUNCTION ExportarRegistrosAEAT(db)
RETURN ""

FUNCTION RegistrarEvento(db, cTipo, cDescripcion)
RETURN NIL

FUNCTION LogInfo(cTexto)
RETURN NIL

FUNCTION LogError(cOrigen, cTexto)
RETURN NIL

FUNCTION L(cClave)
RETURN cClave
