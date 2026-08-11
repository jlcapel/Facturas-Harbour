#require "hbcurl"
#require "hbsqlit3"
#require "hbjson"
#include "hbcurl.ch"
#include "hbsqlit3.ch"

#define SOAP_NS_SOAP     'xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/"'
#define SOAP_NS_LR       'xmlns:sfLR="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroLR.xsd"'
#define SOAP_NS_SF       'xmlns:sf="https://www2.agenciatributaria.gob.es/static_files/common/internet/dep/aplicaciones/es/aeat/tike/cont/ws/SuministroInformacion.xsd"'

FUNCTION EnviarRegistroAlta(db, nRegistroId)
RETURN EnviarRegistroAeat(db, nRegistroId, .F.)

FUNCTION EnviarRegistroAnulacion(db, nRegistroId)
RETURN EnviarRegistroAeat(db, nRegistroId, .T.)

FUNCTION VerificarEstadoAEAT(db, nRegistroId)
   LOCAL hRegistro, aPreparacion, cRespuesta := "", nResultado

   hRegistro := ObtenerRegistroPorId(db, nRegistroId)
   IF hRegistro == NIL
      RETURN NIL
   ENDIF
   aPreparacion := PrepararEnvioAeat(db)
   IF !aPreparacion[1]
      RETURN DevolverErrorPreparacionAeat(db, aPreparacion)
   ENDIF
   nResultado := LlamarSoap(aPreparacion[3], ConstruirSoapConsultaAeat(hRegistro), aPreparacion, @cRespuesta)
   IF nResultado != 0
      LogError("AeatClientService", "Error de transporte AEAT: " + hb_ntos(nResultado))
      RegistrarEvento(db, "ErrorEnvioAEAT", "Error envío AEAT: " + hb_ntos(nResultado))
      RETURN { .F., "", "Error HTTP: " + hb_ntos(nResultado) }
   ENDIF
RETURN { .T., "", cRespuesta }

STATIC FUNCTION EnviarRegistroAeat(db, nRegistroId, lAnulacion)
   LOCAL hRegistro, aPreparacion, cRespuesta := "", nResultado, aRespuesta
   LOCAL cXmlPath, cTipo, cDescripcion

   hRegistro := ObtenerRegistroPorId(db, nRegistroId)
   IF hRegistro == NIL
      RETURN NIL
   ENDIF
   aPreparacion := PrepararEnvioAeat(db)
   IF !aPreparacion[1]
      RETURN DevolverErrorPreparacionAeat(db, aPreparacion)
   ENDIF
   cXmlPath := ExportarRegistrosAEAT(db)
   IF !Empty(cXmlPath)
      LogInfo("XML de envío generado: " + cXmlPath)
   ENDIF
   nResultado := LlamarSoap(aPreparacion[3], ConstruirSoapAeat(hRegistro), aPreparacion, @cRespuesta)
   IF nResultado != 0
      LogError("AeatClientService", "Error de transporte AEAT: " + hb_ntos(nResultado))
      RegistrarEvento(db, "ErrorEnvioAEAT", "Error envío AEAT: " + hb_ntos(nResultado))
      RETURN { .F., "", "Error HTTP: " + hb_ntos(nResultado) }
   ENDIF
   aRespuesta := ProcesarRespuestaAeat(cRespuesta, .T.)
   IF aRespuesta[1]
      ActualizarRegistroEnviado(db, nRegistroId, aRespuesta[2], cRespuesta)
      cTipo := Iif(lAnulacion, "Anulación", "Factura")
      RegistrarEvento(db, "EnvioAEAT", cTipo + " enviada a AEAT. CSV: " + aRespuesta[2])
      RETURN aRespuesta
   ENDIF
   GuardarRespuestaAEAT(db, nRegistroId, cRespuesta)
   cDescripcion := Left(aRespuesta[3], 200)
   IF !Empty(cDescripcion)
      RegistrarEvento(db, "ErrorEnvioAEAT", "Error envío AEAT: " + cDescripcion)
   ENDIF
RETURN aRespuesta

FUNCTION ConstruirSoapAeat(hRegistro)
   IF Val(RegistroTexto(hRegistro, "TipoRegistro", "0")) == 1
      RETURN ConstruirSoapAnulacion(hRegistro)
   ENDIF
RETURN ConstruirSoapAlta(hRegistro)

FUNCTION ConstruirSoapConsultaAeat(hRegistro)
   LOCAL cXml

   cXml := InicioSobreSoap()
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(hRegistro)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAlta>' + Chr(10)
   cXml += '<sf:IDVersion>' + EscapeXml(RegistroTexto(hRegistro, "IDVersion", "1.0")) + '</sf:IDVersion>' + Chr(10)
   cXml += ConstruirIdFactura(hRegistro, .F.)
   cXml += '<sf:Huella>' + EscapeXml(RegistroTexto(hRegistro, "Hash", "")) + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAlta>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
RETURN cXml + '</soap:Envelope>' + Chr(10)

FUNCTION ProcesarRespuestaAeat(cRespuesta, lHttpOk)
   LOCAL cCsv, cErrores, cDescripcion, cMensaje

   IF EsRespuestaHtml(cRespuesta)
      cMensaje := L("ServiceRespuestaHtml")
      cDescripcion := ExtraerErrorHtml(cRespuesta)
      IF !Empty(cDescripcion)
         cMensaje += Chr(10) + Chr(10) + cDescripcion
      ENDIF
      RETURN { .F., "", cMensaje }
   ENDIF
   IF !lHttpOk
      IF Empty(AllTrim(cRespuesta))
         RETURN { .F., "", L("ServiceErrorEnvio") }
      ENDIF
      RETURN { .F., "", cRespuesta }
   ENDIF
   cCsv := ExtraerValorXml(cRespuesta, "CSV")
   IF !Empty(cCsv)
      RETURN { .T., cCsv, L("ServiceRegistroEnviado") }
   ENDIF
   cErrores := ExtraerErroresXml(cRespuesta)
   IF !Empty(cErrores)
      RETURN { .F., "", cErrores }
   ENDIF
RETURN { .F., "", L("ServiceRespuestaSinCsv") }

FUNCTION EscapeXml(cTexto)
   IF cTexto == NIL
      RETURN ""
   ENDIF
   cTexto := StrTran(cTexto, "&", "&amp;")
   cTexto := StrTran(cTexto, "<", "&lt;")
   cTexto := StrTran(cTexto, ">", "&gt;")
   cTexto := StrTran(cTexto, '"', "&quot;")
RETURN StrTran(cTexto, "'", "&apos;")

STATIC FUNCTION ConstruirSoapAlta(hRegistro)
   LOCAL cXml, cDesglose, cDestinatarios, cEncadenamiento, cSistema

   cXml := InicioSobreSoap()
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(hRegistro)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAlta>' + Chr(10)
   cXml += '<sf:IDVersion>' + EscapeXml(RegistroTexto(hRegistro, "IDVersion", "1.0")) + '</sf:IDVersion>' + Chr(10)
   cXml += ConstruirIdFactura(hRegistro, .F.)
   cXml += CampoOpcionalXml("RefExterna", RegistroTexto(hRegistro, "RefExterna", ""))
   cXml += '<sf:NombreRazonEmisor>' + EscapeXml(RegistroTexto(hRegistro, "NombreRazonEmisor", "")) + '</sf:NombreRazonEmisor>' + Chr(10)
   IF RegistroTexto(hRegistro, "Subsanacion", "") == "S"
      cXml += '<sf:Subsanacion>S</sf:Subsanacion>' + Chr(10)
   ENDIF
   cXml += CampoOpcionalXml("RechazoPrevio", RegistroTexto(hRegistro, "RechazoPrevio", ""))
   cXml += '<sf:TipoFactura>' + EscapeXml(RegistroTexto(hRegistro, "TipoFactura", "F1")) + '</sf:TipoFactura>' + Chr(10)
   cXml += CampoOpcionalXml("TipoRectificativa", RegistroTexto(hRegistro, "TipoRectificativa", ""))
   cXml += ConstruirListaFacturas(RegistroTexto(hRegistro, "FacturasRectificadas", ""), "FacturasRectificadas", "IDFacturaRectificada")
   cXml += ConstruirListaFacturas(RegistroTexto(hRegistro, "FacturasSustituidas", ""), "FacturasSustituidas", "IDFacturaSustituida")
   cXml += ConstruirImporteRectificacion(RegistroTexto(hRegistro, "ImporteRectificacion", ""))
   cXml += '<sf:FechaOperacion>' + EscapeXml(FechaAeat(RegistroTexto(hRegistro, "FechaOperacion", RegistroTexto(hRegistro, "FechaEmision", "")))) + '</sf:FechaOperacion>' + Chr(10)
   cXml += '<sf:DescripcionOperacion>' + EscapeXml(RegistroTexto(hRegistro, "DescripcionOperacion", "")) + '</sf:DescripcionOperacion>' + Chr(10)
   cXml += '<sf:FacturaSimplificadaArt7273>' + EscapeXml(RegistroTexto(hRegistro, "FacturaSimplificadaArt7273", "N")) + '</sf:FacturaSimplificadaArt7273>' + Chr(10)
   cXml += '<sf:FacturaSinIdentifDestinatarioArt61d>' + EscapeXml(RegistroTexto(hRegistro, "FacturaSinIdentifDestinatarioArt61d", "N")) + '</sf:FacturaSinIdentifDestinatarioArt61d>' + Chr(10)
   cXml += '<sf:Macrodato>' + EscapeXml(RegistroTexto(hRegistro, "Macrodato", "N")) + '</sf:Macrodato>' + Chr(10)
   IF RegistroTexto(hRegistro, "EmitidaPorTerceroODestinatario", "") == "T" .OR. RegistroTexto(hRegistro, "EmitidaPorTerceroODestinatario", "") == "D"
      cXml += CampoOpcionalXml("EmitidaPorTerceroODestinatario", RegistroTexto(hRegistro, "EmitidaPorTerceroODestinatario", ""))
   ENDIF
   cXml += ConstruirTercero(RegistroTexto(hRegistro, "Tercero", ""))
   cDestinatarios := ConstruirDestinatarios(RegistroTexto(hRegistro, "Destinatarios", ""))
   cXml += cDestinatarios
   cXml += CampoOpcionalXml("Cupon", RegistroTexto(hRegistro, "Cupon", ""))
   cDesglose := ConstruirDesglose(RegistroTexto(hRegistro, "Desglose", ""))
   cXml += cDesglose
   cXml += '<sf:CuotaTotal>' + FormatearImporteXml(RegistroTexto(hRegistro, "IvaImporte", "0")) + '</sf:CuotaTotal>' + Chr(10)
   cXml += '<sf:ImporteTotal>' + FormatearImporteXml(RegistroTexto(hRegistro, "Total", "0")) + '</sf:ImporteTotal>' + Chr(10)
   cEncadenamiento := ConstruirEncadenamiento(RegistroTexto(hRegistro, "Encadenamiento", ""))
   IF !Empty(cEncadenamiento)
      cXml += '<sf:Encadenamiento>' + cEncadenamiento + '</sf:Encadenamiento>' + Chr(10)
   ENDIF
   cSistema := ConstruirSistemaInformatico(RegistroTexto(hRegistro, "SistemaInformatico", ""))
   cXml += cSistema
   cXml += '<sf:FechaHoraHusoGenRegistro>' + EscapeXml(RegistroTexto(hRegistro, "FechaHoraHusoGenRegistro", "")) + '</sf:FechaHoraHusoGenRegistro>' + Chr(10)
   cXml += CampoOpcionalXml("NumRegistroAcuerdoFacturacion", RegistroTexto(hRegistro, "NumRegistroAcuerdoFacturacion", ""))
   cXml += CampoOpcionalXml("IdAcuerdoSistemaInformatico", RegistroTexto(hRegistro, "IdAcuerdoSistemaInformatico", ""))
   cXml += '<sf:TipoHuella>' + EscapeXml(RegistroTexto(hRegistro, "TipoHuella", "01")) + '</sf:TipoHuella>' + Chr(10)
   cXml += '<sf:Huella>' + EscapeXml(RegistroTexto(hRegistro, "Hash", "")) + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAlta>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
RETURN cXml + '</soap:Envelope>' + Chr(10)

STATIC FUNCTION ConstruirSoapAnulacion(hRegistro)
   LOCAL cXml, cEncadenamiento, cSistema

   cXml := InicioSobreSoap()
   cXml += '<soap:Body>' + Chr(10)
   cXml += '<sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += ConstruirCabecera(hRegistro)
   cXml += '<sfLR:RegistroFactura>' + Chr(10)
   cXml += '<sf:RegistroAnulacion>' + Chr(10)
   cXml += '<sf:IDVersion>' + EscapeXml(RegistroTexto(hRegistro, "IDVersion", "1.0")) + '</sf:IDVersion>' + Chr(10)
   cXml += ConstruirIdFactura(hRegistro, .T.)
   cXml += CampoOpcionalXml("RefExterna", RegistroTexto(hRegistro, "RefExterna", ""))
   cXml += CampoOpcionalXml("SinRegistroPrevio", RegistroTexto(hRegistro, "SinRegistroPrevio", ""))
   cXml += CampoOpcionalXml("RechazoPrevio", RegistroTexto(hRegistro, "RechazoPrevioAnulacion", ""))
   cXml += CampoOpcionalXml("GeneradoPor", RegistroTexto(hRegistro, "GeneradoPor", ""))
   cEncadenamiento := ConstruirEncadenamiento(RegistroTexto(hRegistro, "Encadenamiento", ""))
   IF !Empty(cEncadenamiento)
      cXml += '<sf:Encadenamiento>' + cEncadenamiento + '</sf:Encadenamiento>' + Chr(10)
   ENDIF
   cSistema := ConstruirSistemaInformatico(RegistroTexto(hRegistro, "SistemaInformatico", ""))
   cXml += cSistema
   cXml += '<sf:FechaHoraHusoGenRegistro>' + EscapeXml(RegistroTexto(hRegistro, "FechaHoraHusoGenRegistro", "")) + '</sf:FechaHoraHusoGenRegistro>' + Chr(10)
   cXml += '<sf:TipoHuella>' + EscapeXml(RegistroTexto(hRegistro, "TipoHuella", "01")) + '</sf:TipoHuella>' + Chr(10)
   cXml += '<sf:Huella>' + EscapeXml(RegistroTexto(hRegistro, "Hash", "")) + '</sf:Huella>' + Chr(10)
   cXml += '</sf:RegistroAnulacion>' + Chr(10)
   cXml += '</sfLR:RegistroFactura>' + Chr(10)
   cXml += '</sfLR:RegFactuSistemaFacturacion>' + Chr(10)
   cXml += '</soap:Body>' + Chr(10)
RETURN cXml + '</soap:Envelope>' + Chr(10)

STATIC FUNCTION InicioSobreSoap()
RETURN '<?xml version="1.0" encoding="UTF-8"?>' + Chr(10) + ;
   '<soap:Envelope ' + SOAP_NS_SOAP + ' ' + SOAP_NS_LR + ' ' + SOAP_NS_SF + '>' + Chr(10)

STATIC FUNCTION ConstruirCabecera(hRegistro)
   LOCAL cNombre := RegistroTexto(hRegistro, "NombreRazonEmisor", "")
   LOCAL cNif := RegistroTexto(hRegistro, "NifEmisor", "")

RETURN '<sfLR:Cabecera>' + Chr(10) + ;
   '<sf:ObligadoEmision>' + Chr(10) + ;
   '<sf:NombreRazon>' + EscapeXml(cNombre) + '</sf:NombreRazon>' + Chr(10) + ;
   '<sf:NIF>' + EscapeXml(cNif) + '</sf:NIF>' + Chr(10) + ;
   '</sf:ObligadoEmision>' + Chr(10) + ;
   '</sfLR:Cabecera>' + Chr(10)

STATIC FUNCTION ConstruirIdFactura(hRegistro, lAnulacion)
   LOCAL cNif := RegistroTexto(hRegistro, "NifEmisor", "")
   LOCAL cNumero := RegistroTexto(hRegistro, "NumeroFactura", "")
   LOCAL cFecha := RegistroTexto(hRegistro, "FechaEmision", "")

   IF lAnulacion
      cNumero := RegistroTexto(hRegistro, "IdFacturaAnulada", cNumero)
      cFecha := RegistroTexto(hRegistro, "FechaFacturaAnulada", cFecha)
      RETURN '<sf:IDFactura>' + Chr(10) + ;
         '<sf:IDEmisorFacturaAnulada>' + EscapeXml(cNif) + '</sf:IDEmisorFacturaAnulada>' + Chr(10) + ;
         '<sf:NumSerieFacturaAnulada>' + EscapeXml(cNumero) + '</sf:NumSerieFacturaAnulada>' + Chr(10) + ;
         '<sf:FechaExpedicionFacturaAnulada>' + EscapeXml(FechaAeat(cFecha)) + '</sf:FechaExpedicionFacturaAnulada>' + Chr(10) + ;
         '</sf:IDFactura>' + Chr(10)
   ENDIF
RETURN '<sf:IDFactura>' + Chr(10) + ;
   '<sf:IDEmisorFactura>' + EscapeXml(cNif) + '</sf:IDEmisorFactura>' + Chr(10) + ;
   '<sf:NumSerieFactura>' + EscapeXml(cNumero) + '</sf:NumSerieFactura>' + Chr(10) + ;
   '<sf:FechaExpedicionFactura>' + EscapeXml(FechaAeat(cFecha)) + '</sf:FechaExpedicionFactura>' + Chr(10) + ;
   '</sf:IDFactura>' + Chr(10)

STATIC FUNCTION ConstruirDesglose(cJson)
   LOCAL hDesglose := {=>}, aDetalle, nI, hDetalle, cXml := ""
   LOCAL cExenta, cCalificacion

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @hDesglose) == 0 .OR. !hb_HHasKey(hDesglose, "DetalleDesglose")
      RETURN ""
   ENDIF
   aDetalle := hDesglose["DetalleDesglose"]
   IF ValType(aDetalle) != "A"
      RETURN ""
   ENDIF
   cXml := '<sf:Desglose>' + Chr(10)
   FOR nI := 1 TO Len(aDetalle)
      hDetalle := aDetalle[nI]
      IF ValType(hDetalle) != "H"
         LOOP
      ENDIF
      cXml += '<sf:DetalleDesglose>' + Chr(10)
      cXml += CampoXml("Impuesto", ValorJsonTexto(hDetalle, "Impuesto", ""))
      cXml += CampoXml("ClaveRegimen", ValorJsonTexto(hDetalle, "ClaveRegimen", ""))
      cExenta := ValorJsonTexto(hDetalle, "OperacionExenta", "")
      cCalificacion := ValorJsonTexto(hDetalle, "CalificacionOperacion", "")
      IF !Empty(cExenta)
         cXml += CampoXml("OperacionExenta", cExenta)
      ELSEIF !Empty(cCalificacion)
         cXml += CampoXml("CalificacionOperacion", cCalificacion)
      ENDIF
      cXml += CampoXml("TipoImpositivo", FormatearImporteXml(ValorJson(hDetalle, "TipoImpositivo", 0)))
      cXml += CampoXml("BaseImponibleOimporteNoSujeto", FormatearImporteXml(ValorJson(hDetalle, "BaseImponibleOimporteNoSujeto", 0)))
      cXml += CampoXml("CuotaRepercutida", FormatearImporteXml(ValorJson(hDetalle, "CuotaRepercutida", 0)))
      cXml += '</sf:DetalleDesglose>' + Chr(10)
   NEXT
RETURN cXml + '</sf:Desglose>' + Chr(10)

STATIC FUNCTION ConstruirDestinatarios(cJson)
   LOCAL aDestinatarios := {}, nI, hDestinatario, cXml := "", cCodigoPais

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @aDestinatarios) == 0 .OR. ValType(aDestinatarios) != "A"
      RETURN ""
   ENDIF
   cXml := '<sf:Destinatarios>' + Chr(10)
   FOR nI := 1 TO Len(aDestinatarios)
      hDestinatario := aDestinatarios[nI]
      IF ValType(hDestinatario) != "H"
         LOOP
      ENDIF
      cXml += '<sf:IDDestinatario>' + Chr(10)
      cXml += CampoXml("NombreRazon", ValorJsonTexto(hDestinatario, "NombreRazon", ""))
      IF ValorJsonLogico(hDestinatario, "EsNacional")
         cXml += CampoXml("NIF", ValorJsonTexto(hDestinatario, "NIF", ""))
      ELSE
         cXml += '<sf:IDOtro>' + Chr(10)
         cCodigoPais := ValorJsonTexto(hDestinatario, "CodigoPais", "")
         IF Len(cCodigoPais) == 2
            cXml += CampoXml("CodigoPais", cCodigoPais)
         ENDIF
         cXml += CampoXml("IDType", ValorJsonTexto(hDestinatario, "CodigoAEAT", "02"))
         cXml += CampoXml("ID", ValorJsonTexto(hDestinatario, "NIF", ""))
         cXml += '</sf:IDOtro>' + Chr(10)
      ENDIF
      cXml += '</sf:IDDestinatario>' + Chr(10)
   NEXT
RETURN cXml + '</sf:Destinatarios>' + Chr(10)

STATIC FUNCTION ConstruirListaFacturas(cJson, cContenedor, cElemento)
   LOCAL aFacturas := {}, nI, hFactura, cXml := ""

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @aFacturas) == 0 .OR. ValType(aFacturas) != "A"
      RETURN ""
   ENDIF
   cXml := '<sf:' + cContenedor + '>' + Chr(10)
   FOR nI := 1 TO Len(aFacturas)
      hFactura := aFacturas[nI]
      IF ValType(hFactura) != "H"
         LOOP
      ENDIF
      cXml += '<sf:' + cElemento + '>' + Chr(10)
      cXml += CampoXml("IDEmisorFactura", ValorJsonTexto(hFactura, "IDEmisorFactura", ""))
      cXml += CampoXml("NumSerieFactura", ValorJsonTexto(hFactura, "NumSerieFactura", ""))
      cXml += CampoXml("FechaExpedicionFactura", ValorJsonTexto(hFactura, "FechaExpedicionFactura", ""))
      cXml += '</sf:' + cElemento + '>' + Chr(10)
   NEXT
RETURN cXml + '</sf:' + cContenedor + '>' + Chr(10)

STATIC FUNCTION ConstruirImporteRectificacion(cJson)
   LOCAL hImporte := {=>}

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @hImporte) == 0 .OR. ValType(hImporte) != "H"
      RETURN ""
   ENDIF
RETURN '<sf:ImporteRectificacion>' + Chr(10) + ;
   CampoXml("BaseRectificada", FormatearImporteXml(ValorJson(hImporte, "BaseRectificada", 0))) + ;
   CampoXml("CuotaRectificada", FormatearImporteXml(ValorJson(hImporte, "CuotaRectificada", 0))) + ;
   '</sf:ImporteRectificacion>' + Chr(10)

STATIC FUNCTION ConstruirTercero(cJson)
   LOCAL hTercero := {=>}, cNif

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @hTercero) == 0 .OR. ValType(hTercero) != "H"
      RETURN ""
   ENDIF
   cNif := ValorJsonTexto(hTercero, "NIF", "")
RETURN '<sf:Tercero>' + Chr(10) + ;
   CampoXml("NombreRazon", ValorJsonTexto(hTercero, "NombreRazon", "")) + ;
   CampoOpcionalXml("NIF", cNif) + ;
   '</sf:Tercero>' + Chr(10)

STATIC FUNCTION ConstruirEncadenamiento(cJson)
   LOCAL hEncadenamiento := {=>}, hAnterior

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @hEncadenamiento) == 0 .OR. ValType(hEncadenamiento) != "H"
      RETURN ""
   ENDIF
   IF hb_HHasKey(hEncadenamiento, "PrimerRegistro")
      RETURN '<sf:PrimerRegistro>S</sf:PrimerRegistro>' + Chr(10)
   ENDIF
   IF !hb_HHasKey(hEncadenamiento, "RegistroAnterior")
      RETURN ""
   ENDIF
   hAnterior := hEncadenamiento["RegistroAnterior"]
   IF ValType(hAnterior) != "H"
      RETURN ""
   ENDIF
RETURN '<sf:RegistroAnterior>' + Chr(10) + ;
   CampoXml("IDEmisorFactura", ValorJsonTexto(hAnterior, "IDEmisorFactura", "")) + ;
   CampoXml("NumSerieFactura", ValorJsonTexto(hAnterior, "NumSerieFactura", "")) + ;
   CampoXml("FechaExpedicionFactura", ValorJsonTexto(hAnterior, "FechaExpedicionFactura", "")) + ;
   CampoXml("Huella", ValorJsonTexto(hAnterior, "Huella", "")) + ;
   '</sf:RegistroAnterior>' + Chr(10)

STATIC FUNCTION ConstruirSistemaInformatico(cJson)
   LOCAL hSistema := {=>}

   IF Empty(cJson) .OR. hb_jsonDecode(cJson, @hSistema) == 0 .OR. ValType(hSistema) != "H"
      RETURN ""
   ENDIF
RETURN '<sf:SistemaInformatico>' + Chr(10) + ;
   CampoXml("NombreRazon", ValorJsonTexto(hSistema, "NombreRazon", "")) + ;
   CampoXml("NIF", ValorJsonTexto(hSistema, "NIF", "")) + ;
   CampoXml("NombreSistemaInformatico", ValorJsonTexto(hSistema, "NombreSistemaInformatico", "")) + ;
   CampoXml("IdSistemaInformatico", ValorJsonTexto(hSistema, "IdSistemaInformatico", "")) + ;
   CampoXml("Version", ValorJsonTexto(hSistema, "Version", "")) + ;
   CampoXml("NumeroInstalacion", ValorJsonTexto(hSistema, "NumeroInstalacion", "")) + ;
   CampoXml("TipoUsoPosibleSoloVerifactu", ValorJsonTexto(hSistema, "TipoUsoPosibleSoloVerifactu", "")) + ;
   CampoXml("TipoUsoPosibleMultiOT", ValorJsonTexto(hSistema, "TipoUsoPosibleMultiOT", "")) + ;
   CampoXml("IndicadorMultiplesOT", ValorJsonTexto(hSistema, "IndicadorMultiplesOT", "")) + ;
   '</sf:SistemaInformatico>' + Chr(10)

STATIC FUNCTION CampoXml(cNombre, cValor)
RETURN '<sf:' + cNombre + '>' + EscapeXml(cValor) + '</sf:' + cNombre + '>' + Chr(10)

STATIC FUNCTION CampoOpcionalXml(cNombre, cValor)
   IF Empty(cValor)
      RETURN ""
   ENDIF
RETURN CampoXml(cNombre, cValor)

STATIC FUNCTION FormatearImporteXml(xValor)
   IF ValType(xValor) == "N"
      RETURN DecimalAPuntoSinEspacios(RoundFiscal(xValor))
   ENDIF
RETURN DecimalAPuntoSinEspacios(RoundFiscal(Val(xValor)))

STATIC FUNCTION FechaAeat(cFecha)
   IF Len(cFecha) >= 10 .AND. SubStr(cFecha, 5, 1) == "-"
      RETURN SubStr(cFecha, 9, 2) + "-" + SubStr(cFecha, 6, 2) + "-" + Left(cFecha, 4)
   ENDIF
RETURN cFecha

STATIC FUNCTION RegistroTexto(hRegistro, cClave, cDefecto)
   LOCAL xValor

   IF ValType(hRegistro) != "H" .OR. !hb_HHasKey(hRegistro, cClave)
      RETURN cDefecto
   ENDIF
   xValor := hRegistro[cClave]
   IF xValor == NIL
      RETURN cDefecto
   ENDIF
   IF ValType(xValor) == "C"
      RETURN xValor
   ENDIF
RETURN hb_ValToStr(xValor)

STATIC FUNCTION ValorJson(hJson, cClave, xDefecto)
   IF ValType(hJson) != "H" .OR. !hb_HHasKey(hJson, cClave) .OR. hJson[cClave] == NIL
      RETURN xDefecto
   ENDIF
RETURN hJson[cClave]

STATIC FUNCTION ValorJsonTexto(hJson, cClave, cDefecto)
   LOCAL xValor := ValorJson(hJson, cClave, cDefecto)

   IF ValType(xValor) == "C"
      RETURN xValor
   ENDIF
RETURN hb_ValToStr(xValor)

STATIC FUNCTION ValorJsonLogico(hJson, cClave)
   LOCAL xValor := ValorJson(hJson, cClave, .F.)

   IF ValType(xValor) == "L"
      RETURN xValor
   ENDIF
RETURN Lower(hb_ValToStr(xValor)) == "true"

STATIC FUNCTION LlamarSoap(cUrl, cSoap, aPreparacion, cResponse)
   LOCAL hCurl, aHeaders, nResultado

   hCurl := curl_easy_init()
   IF hCurl == NIL
      RETURN -1
   ENDIF
   curl_easy_setopt(hCurl, HB_CURLOPT_URL, cUrl)
   curl_easy_setopt(hCurl, HB_CURLOPT_POST, 1)
   curl_easy_setopt(hCurl, HB_CURLOPT_COPYPOSTFIELDS, cSoap)
   curl_easy_setopt(hCurl, HB_CURLOPT_TIMEOUT, 60)
   curl_easy_setopt(hCurl, HB_CURLOPT_CONNECTTIMEOUT, 10)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYPEER, aPreparacion[6])
   curl_easy_setopt(hCurl, HB_CURLOPT_SSL_VERIFYHOST, aPreparacion[7])
   curl_easy_setopt(hCurl, HB_CURLOPT_NOSIGNAL, 1)
   aHeaders := { "Content-Type: text/xml; charset=utf-8", 'SOAPAction: ""' }
   curl_easy_setopt(hCurl, HB_CURLOPT_HTTPHEADER, aHeaders)
   curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERT, aPreparacion[4])
   curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERTTYPE, aPreparacion[8])
   IF !Empty(aPreparacion[5])
      curl_easy_setopt(hCurl, HB_CURLOPT_SSLCERTPASSWD, aPreparacion[5])
   ENDIF
   curl_easy_setopt(hCurl, HB_CURLOPT_WRITEFUNCTION, {|cDatos| CargaRespuesta(cDatos, @cResponse)})
   nResultado := curl_easy_perform(hCurl)
   curl_easy_cleanup(hCurl)
RETURN nResultado

STATIC FUNCTION CargaRespuesta(cDatos, cRespuesta)
   cRespuesta += cDatos
RETURN Len(cDatos)

FUNCTION PrepararEnvioAeat(db)
   LOCAL cRuta := ObtenerConfiguracion(db, "VeriFactu.CertificadoRuta")
   LOCAL cPass := ObtenerConfiguracion(db, "VeriFactu.CertificadoPassword")
   LOCAL cEndpoint := ObtenerEndpoint(db)

   IF Empty(cEndpoint)
      RETURN {.F., "ENTORNO_INVALIDO", NIL, NIL, NIL, 1, 2, "P12"}
   ENDIF
   IF Empty(cRuta)
      RETURN {.F., "CERTIFICADO_AUSENTE", cEndpoint, NIL, NIL, 1, 2, "P12"}
   ENDIF
   IF !hb_FileExists(cRuta)
      RETURN {.F., "CERTIFICADO_INEXISTENTE", cEndpoint, cRuta, NIL, 1, 2, "P12"}
   ENDIF
RETURN {.T., "", cEndpoint, cRuta, Iif(cPass == NIL, "", cPass), 1, 2, "P12"}

STATIC FUNCTION DevolverErrorPreparacionAeat(db, aPreparacion)
   LOCAL cError := MensajePreparacionAeat(db, aPreparacion)

   LogError("AeatClientService", cError)
   RegistrarEvento(db, "ErrorEnvioAEAT", "Error envío AEAT: " + Left(cError, 200))
RETURN {.F., "", cError}

STATIC FUNCTION MensajePreparacionAeat(db, aPreparacion)
   LOCAL cEntorno := ObtenerConfiguracion(db, "VeriFactu.Ambiente")

   DO CASE
   CASE aPreparacion[2] == "CERTIFICADO_AUSENTE"
      RETURN StrTran(L("ServiceSinCertificado"), "{0}", NombreEntornoAeat(cEntorno))
   CASE aPreparacion[2] == "CERTIFICADO_INEXISTENTE"
      RETURN StrTran(L("ServiceCertNoExiste"), "{0}", aPreparacion[4])
   OTHERWISE
      RETURN StrTran(L("ServiceErrorConexion"), "{0}", "Entorno AEAT no válido")
   ENDCASE
RETURN L("ServiceCertErrorDesc")

STATIC FUNCTION ObtenerEndpoint(db)
   LOCAL cEntorno := ObtenerConfiguracion(db, "VeriFactu.Ambiente")

   IF cEntorno == "1" .OR. cEntorno == "Produccion"
      RETURN "https://www1.agenciatributaria.gob.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
   ENDIF
   IF cEntorno == "2" .OR. cEntorno == "Preproduccion"
      RETURN "https://prewww1.aeat.es/wlpl/TIKE-CONT/ws/SistemaFacturacion/VerifactuSOAP"
   ENDIF
RETURN NIL

STATIC FUNCTION NombreEntornoAeat(cEntorno)
   IF cEntorno == "1" .OR. cEntorno == "Produccion"
      RETURN "Produccion"
   ENDIF
RETURN "Preproduccion"

STATIC FUNCTION ObtenerRegistroPorId(db, nId)
   LOCAL aCampos := { "Id", "FacturaId", "TipoRegistro", "Hash", "NifEmisor", "NumeroFactura", "FechaEmision", "BaseImponible", "IvaImporte", "Total", "IdFacturaAnulada", "FechaFacturaAnulada", "IDVersion", "RefExterna", "NombreRazonEmisor", "Subsanacion", "RechazoPrevio", "TipoFactura", "TipoRectificativa", "FacturasRectificadas", "FacturasSustituidas", "ImporteRectificacion", "FechaOperacion", "DescripcionOperacion", "FacturaSimplificadaArt7273", "FacturaSinIdentifDestinatarioArt61d", "Macrodato", "EmitidaPorTerceroODestinatario", "Tercero", "Destinatarios", "Cupon", "Desglose", "Encadenamiento", "SistemaInformatico", "FechaHoraHusoGenRegistro", "NumRegistroAcuerdoFacturacion", "IdAcuerdoSistemaInformatico", "TipoHuella", "SinRegistroPrevio", "RechazoPrevioAnulacion", "GeneradoPor" }
   LOCAL cSql := "SELECT " + ArrayToSql(aCampos) + " FROM RegistrosFacturacion WHERE Id=?"
   LOCAL stmt := sqlite3_prepare(db, cSql), hRegistro := NIL, nI

   IF Empty(stmt)
      RETURN NIL
   ENDIF
   sqlite3_bind_int(stmt, 1, nId)
   IF sqlite3_step(stmt) == SQLITE_ROW
      hRegistro := {=>}
      FOR nI := 1 TO Len(aCampos)
         hRegistro[aCampos[nI]] := sqlite3_column_text(stmt, nI)
      NEXT
   ENDIF
   sqlite3_finalize(stmt)
RETURN hRegistro

STATIC FUNCTION ArrayToSql(aCampos)
   LOCAL cSql := "", nI

   FOR nI := 1 TO Len(aCampos)
      IF nI > 1
         cSql += ","
      ENDIF
      cSql += aCampos[nI]
   NEXT
RETURN cSql

STATIC FUNCTION ActualizarRegistroEnviado(db, nId, cCsv, cRespuesta)
   LOCAL stmt := sqlite3_prepare(db, "UPDATE RegistrosFacturacion SET CSV=?, EnviadoAEAT=1, FechaEnvioAEAT=datetime('now'), RespuestaAEAT=? WHERE Id=?")

   sqlite3_bind_text(stmt, 1, cCsv)
   sqlite3_bind_text(stmt, 2, cRespuesta)
   sqlite3_bind_int(stmt, 3, nId)
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL

STATIC FUNCTION GuardarRespuestaAEAT(db, nId, cRespuesta)
   LOCAL stmt := sqlite3_prepare(db, "UPDATE RegistrosFacturacion SET RespuestaAEAT=? WHERE Id=?")

   sqlite3_bind_text(stmt, 1, cRespuesta)
   sqlite3_bind_int(stmt, 2, nId)
   sqlite3_step(stmt)
   sqlite3_finalize(stmt)
RETURN NIL

STATIC FUNCTION ExtraerValorXml(cXml, cElemento)
   LOCAL nApertura, nInicio, nCierre, cEtiqueta, cValor

   nApertura := BuscarAperturaElemento(cXml, cElemento, 1)
   IF nApertura == 0
      RETURN ""
   ENDIF
   nInicio := hb_At(">", cXml, nApertura)
   IF nInicio == 0
      RETURN ""
   ENDIF
   cEtiqueta := NombreEtiquetaXml(SubStr(cXml, nApertura + 1, nInicio - nApertura - 1))
   nCierre := hb_At("</" + cEtiqueta, cXml, nInicio + 1)
   IF nCierre == 0
      RETURN ""
   ENDIF
   cValor := AllTrim(SubStr(cXml, nInicio + 1, nCierre - nInicio - 1))
RETURN DecodificarEntidadesXml(cValor)

STATIC FUNCTION ExtraerErroresXml(cXml)
   LOCAL cErrores := "", cError, nPosicion := 1, nApertura, nInicio, nCierre, cEtiqueta

   DO WHILE .T.
      nApertura := BuscarAperturaElemento(cXml, "Error", nPosicion)
      IF nApertura == 0
         EXIT
      ENDIF
      nInicio := hb_At(">", cXml, nApertura)
      IF nInicio == 0
         EXIT
      ENDIF
      cEtiqueta := NombreEtiquetaXml(SubStr(cXml, nApertura + 1, nInicio - nApertura - 1))
      nCierre := hb_At("</" + cEtiqueta, cXml, nInicio + 1)
      IF nCierre == 0
         EXIT
      ENDIF
      cError := AllTrim(SubStr(cXml, nInicio + 1, nCierre - nInicio - 1))
      IF !Empty(cError)
         IF !Empty(cErrores)
            cErrores += "; "
         ENDIF
         cErrores += DecodificarEntidadesXml(cError)
      ENDIF
      nPosicion := nCierre + Len(cEtiqueta) + 3
   ENDDO
RETURN cErrores

STATIC FUNCTION BuscarAperturaElemento(cXml, cElemento, nDesde)
   LOCAL nPosicion := nDesde, nApertura, nFin, cEtiqueta

   DO WHILE .T.
      nApertura := hb_At("<", cXml, nPosicion)
      IF nApertura == 0
         RETURN 0
      ENDIF
      IF SubStr(cXml, nApertura + 1, 1) != "/" .AND. SubStr(cXml, nApertura + 1, 1) != "!" .AND. SubStr(cXml, nApertura + 1, 1) != "?"
         nFin := hb_At(">", cXml, nApertura)
         IF nFin == 0
            RETURN 0
         ENDIF
         cEtiqueta := NombreEtiquetaXml(SubStr(cXml, nApertura + 1, nFin - nApertura - 1))
         IF NombreLocalXml(cEtiqueta) == cElemento
            RETURN nApertura
         ENDIF
      ENDIF
      nPosicion := nApertura + 1
   ENDDO
RETURN 0

STATIC FUNCTION NombreEtiquetaXml(cEtiqueta)
   LOCAL nEspacio := At(" ", cEtiqueta)

   IF nEspacio > 0
      cEtiqueta := Left(cEtiqueta, nEspacio - 1)
   ENDIF
RETURN cEtiqueta

STATIC FUNCTION NombreLocalXml(cEtiqueta)
   LOCAL nDosPuntos := RAt(":", cEtiqueta)

   IF nDosPuntos > 0
      RETURN SubStr(cEtiqueta, nDosPuntos + 1)
   ENDIF
RETURN cEtiqueta

STATIC FUNCTION ExtraerErrorHtml(cHtml)
   LOCAL nInicio := At("<h3>", Lower(cHtml)), nFin, cTexto, nDosPuntos

   IF nInicio == 0
      RETURN ""
   ENDIF
   nInicio += 4
   nFin := At("</h3>", Lower(SubStr(cHtml, nInicio)))
   IF nFin == 0
      RETURN ""
   ENDIF
   cTexto := AllTrim(SubStr(cHtml, nInicio, nFin - 1))
   nDosPuntos := At(":", cTexto)
   IF nDosPuntos > 0 .AND. Left(Lower(cTexto), 11) == "descripcion"
      cTexto := AllTrim(SubStr(cTexto, nDosPuntos + 1))
   ENDIF
RETURN DecodificarEntidadesXml(cTexto)

STATIC FUNCTION DecodificarEntidadesXml(cTexto)
   cTexto := StrTran(cTexto, "&lt;", "<")
   cTexto := StrTran(cTexto, "&gt;", ">")
   cTexto := StrTran(cTexto, "&quot;", '"')
   cTexto := StrTran(cTexto, "&apos;", "'")
RETURN StrTran(cTexto, "&amp;", "&")
