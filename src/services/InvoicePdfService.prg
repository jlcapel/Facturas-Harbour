#require "hbhpdf"
#include "harupdf.ch"

#define PDF_MARGIN         40
#define HEADER_Y           780
#define LINE_HEIGHT        14
#define TABLE_TOP          500
#define TABLE_LEFT         50
#define COL_CANT           50
#define COL_DESC           200
#define COL_PRECIO         70
#define COL_IVA            55
#define COL_IMPORTE        80
#define TABLE_WIDTH        500
#define TOTAL_LEFT         440

FUNCTION GenerarPdfFactura(db, nFacturaId, cRutaSalida)
   LOCAL aFactura, aLineas, aInfo

   aFactura := ObtenerFacturaPorId(db, nFacturaId)
   IF aFactura == NIL
      RETURN .F.
   ENDIF

   aInfo := ObtenerInfoEmpresa(db)
   RETURN CrearPdf(aFactura, aInfo, cRutaSalida)

STATIC FUNCTION ObtenerInfoEmpresa(db)
   LOCAL aInfo := { "", "", "", "", "", "", "", "", "" }
   aInfo[1] := NVL(ObtenerConfiguracion(db, "Empresa.Nombre"), "")
   aInfo[2] := NVL(ObtenerConfiguracion(db, "Empresa.Nif"), "")
   aInfo[3] := NVL(ObtenerConfiguracion(db, "Empresa.Direccion"), "")
   aInfo[4] := NVL(ObtenerConfiguracion(db, "Empresa.Poblacion"), "")
   aInfo[5] := NVL(ObtenerConfiguracion(db, "Empresa.Provincia"), "")
   aInfo[6] := NVL(ObtenerConfiguracion(db, "Empresa.CodigoPostal"), "")
   aInfo[7] := NVL(ObtenerConfiguracion(db, "Empresa.Telefono"), "")
   aInfo[8] := NVL(ObtenerConfiguracion(db, "Empresa.Email"), "")
   aInfo[9] := NVL(ObtenerConfiguracion(db, "VeriFactu.Ambiente"), "1")
   RETURN aInfo

STATIC FUNCTION CrearPdf(aFactura, aInfo, cRutaSalida)
   LOCAL pdf, page, fontN, fontB, fontS, y, nFila, i, aLinea, nLineas

   pdf := HPDF_New()
   IF pdf == NIL
      RETURN .F.
   ENDIF

   HPDF_SetCompressionMode(pdf, HPDF_COMP_ALL)

   page := HPDF_AddPage(pdf)
   HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT)

   fontN := HPDF_GetFont(pdf, "Helvetica", NIL)
   fontB := HPDF_GetFont(pdf, "Helvetica-Bold", NIL)
   fontS := HPDF_GetFont(pdf, "Helvetica", NIL)

   y := HEADER_Y

   PintarCabecera(page, fontN, fontB, aInfo, aFactura, @y)

   PintarCliente(page, fontN, fontB, aFactura, @y)

   y := TABLE_TOP
   nLineas := Len(aFactura[32])
   PintarTablaHeader(page, fontB, @y)

   FOR i := 1 TO nLineas
      aLinea := aFactura[32][i]
      PintarFilaLinea(page, fontN, aLinea, @y)
      IF y < 80
         page := HPDF_AddPage(pdf)
         HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_PORTRAIT)
         y := HEADER_Y
         PintarTablaHeader(page, fontB, @y)
      ENDIF
   NEXT

   PintarLineaH(page, y)
   y -= 4

   PintarTotales(page, fontN, fontB, aFactura, @y)

   PintarPie(page, fontS, aFactura, @y)

   HPDF_SaveToFile(pdf, cRutaSalida)
   HPDF_Free(pdf)

   RETURN hb_FileExists(cRutaSalida)

STATIC FUNCTION NVL(uVal, uDef)
   IF uVal == NIL .OR. Empty(uVal)
      RETURN uDef
   ENDIF
   RETURN uVal

STATIC FUNCTION FmtDec(nVal)
   RETURN StrTran(Str(nVal, 12, 2), " ", "")

STATIC PROCEDURE PintarCabecera(page, fontN, fontB, aInfo, aFactura, y)
   LOCAL cEntorno := Iif(aInfo[9] == "1", "", " (PRUEBAS)")
   LOCAL cTitulo := "FACTURA" + cEntorno
   LOCAL cNumero := aFactura[2]
   LOCAL dFecha := aFactura[3]
   LOCAL cFecha := DToC(dFecha)
   LOCAL tw

   HPDF_Page_SetFontAndSize(page, fontB, 18)
   tw := HPDF_Page_TextWidth(page, cTitulo)
   HPDF_Page_SetRGBFill(page, 0, 0, 0.5)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 595 - PDF_MARGIN - tw, y, cTitulo)
   HPDF_Page_EndText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   y -= 5

   HPDF_Page_SetFontAndSize(page, fontB, 14)
   tw := HPDF_Page_TextWidth(page, cNumero)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 595 - PDF_MARGIN - tw, y, cNumero)
   HPDF_Page_EndText(page)
   y -= 16

   HPDF_Page_SetFontAndSize(page, fontN, 10)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 595 - PDF_MARGIN - HPDF_Page_TextWidth(page, "Fecha: " + cFecha), y, "Fecha: " + cFecha)
   HPDF_Page_EndText(page)
   y -= 20

   HPDF_Page_SetFontAndSize(page, fontB, 16)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, PDF_MARGIN, y, aInfo[1])
   HPDF_Page_EndText(page)
   y -= 18

   HPDF_Page_SetFontAndSize(page, fontN, 10)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, PDF_MARGIN, y, "NIF: " + aInfo[2])
   HPDF_Page_EndText(page)
   y -= 14

   IF !Empty(aInfo[3])
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, aInfo[3])
      HPDF_Page_EndText(page)
      y -= 14
   ENDIF

   IF !Empty(aInfo[4])
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, aInfo[4] + Iif(!Empty(aInfo[5]), ", " + aInfo[5], "") + Iif(!Empty(aInfo[6]), " - " + aInfo[6], ""))
      HPDF_Page_EndText(page)
      y -= 14
   ENDIF

   IF !Empty(aInfo[7])
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, "Tel: " + aInfo[7])
      HPDF_Page_EndText(page)
      y -= 14
   ENDIF

   IF !Empty(aInfo[8])
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, aInfo[8])
      HPDF_Page_EndText(page)
      y -= 14
   ENDIF

   y -= 10
   PintarLineaH(page, y)
   y -= 20

   IF aInfo[9] == "2"
      HPDF_Page_SetRGBFill(page, 1, 0, 0)
      HPDF_Page_SetFontAndSize(page, fontB, 12)
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, 595 / 2 - 70, y, "DOCUMENTO DE PRUEBA - SIN VALOR FISCAL")
      HPDF_Page_EndText(page)
      HPDF_Page_SetRGBFill(page, 0, 0, 0)
      y -= 20
   ENDIF
RETURN

STATIC PROCEDURE PintarCliente(page, fontN, fontB, aFactura, y)
   LOCAL cCliente := aFactura[19]
   LOCAL cNif := aFactura[20]

   HPDF_Page_SetRGBFill(page, 0.8, 0.8, 0.8)
   HPDF_Page_SetFontAndSize(page, fontB, 10)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, PDF_MARGIN, y, "DATOS DEL CLIENTE")
   HPDF_Page_EndText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
   y -= 14

   HPDF_Page_SetFontAndSize(page, fontN, 10)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, PDF_MARGIN, y, cCliente)
   HPDF_Page_EndText(page)
   y -= 14

   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, PDF_MARGIN, y, "NIF: " + cNif)
   HPDF_Page_EndText(page)
   y -= 18
RETURN

STATIC PROCEDURE PintarTablaHeader(page, fontB, y)
   LOCAL x := PDF_MARGIN

   HPDF_Page_SetRGBFill(page, 0.9, 0.9, 0.9)
   HPDF_Page_Rectangle(page, x, y - 2, TABLE_WIDTH, LINE_HEIGHT)
   HPDF_Page_Fill(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_SetFontAndSize(page, fontB, 9)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, x + 5, y + 2, "Cant.")
   x += COL_CANT
   HPDF_Page_TextOut(page, x + 5, y + 2, "Descripción")
   x += COL_DESC
   HPDF_Page_TextOut(page, x + 5, y + 2, "Precio")
   x += COL_PRECIO
   HPDF_Page_TextOut(page, x + 5, y + 2, "IVA%")
   x += COL_IVA
   HPDF_Page_TextOut(page, x + 5, y + 2, "Importe")
   HPDF_Page_EndText(page)
   y -= LINE_HEIGHT + 4
RETURN

STATIC PROCEDURE PintarFilaLinea(page, fontN, aLinea, y)
   LOCAL x := PDF_MARGIN
   LOCAL cCant := Str(aLinea[5], 6, 2)
   LOCAL cDesc := aLinea[4]
   LOCAL cPrecio := FmtDec(aLinea[6])
   LOCAL cIva := Str(aLinea[7], 5, 1) + "%"
   LOCAL cImporte := FmtDec(aLinea[8])

   HPDF_Page_SetFontAndSize(page, fontN, 9)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, x + 3, y + 2, cCant)
   x += COL_CANT
   HPDF_Page_TextOut(page, x + 3, y + 2, Left(cDesc, 40))
   x += COL_DESC
   HPDF_Page_TextOut(page, x + COL_PRECIO - HPDF_Page_TextWidth(page, cPrecio) - 3, y + 2, cPrecio)
   x += COL_PRECIO
   HPDF_Page_TextOut(page, x + COL_IVA - HPDF_Page_TextWidth(page, cIva) - 3, y + 2, cIva)
   x += COL_IVA
   HPDF_Page_TextOut(page, x + COL_IMPORTE - HPDF_Page_TextWidth(page, cImporte) - 3, y + 2, cImporte)
   HPDF_Page_EndText(page)
   y -= LINE_HEIGHT
RETURN

STATIC PROCEDURE PintarTotales(page, fontN, fontB, aFactura, y)
   LOCAL nBase := aFactura[12]
   LOCAL nIva := aFactura[13]
   LOCAL nIrpfPct := aFactura[14]
   LOCAL nIrpf := aFactura[15]
   LOCAL nTotal := aFactura[16]
   LOCAL xLabel := TOTAL_LEFT
   LOCAL xVal := TOTAL_LEFT + 100

   HPDF_Page_SetFontAndSize(page, fontN, 10)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, xLabel, y, "Base Imponible:")
   HPDF_Page_TextOut(page, xVal + 80 - HPDF_Page_TextWidth(page, FmtDec(nBase)), y, FmtDec(nBase))
   HPDF_Page_EndText(page)
   y -= 16

   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, xLabel, y, "IVA:")
   HPDF_Page_TextOut(page, xVal + 80 - HPDF_Page_TextWidth(page, FmtDec(nIva)), y, FmtDec(nIva))
   HPDF_Page_EndText(page)
   y -= 16

   IF nIrpf > 0
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, xLabel, y, "IRPF (" + Str(nIrpfPct, 4, 1) + "%):")
      HPDF_Page_TextOut(page, xVal + 80 - HPDF_Page_TextWidth(page, "-" + FmtDec(nIrpf)), y, "-" + FmtDec(nIrpf))
      HPDF_Page_EndText(page)
      y -= 16
   ENDIF

   PintarLineaH(page, y)
   y -= 6

   HPDF_Page_SetFontAndSize(page, fontB, 14)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, xLabel, y, "TOTAL:")
   HPDF_Page_SetFontAndSize(page, fontB, 14)
   HPDF_Page_TextOut(page, xVal + 80 - HPDF_Page_TextWidth(page, FmtDec(nTotal)), y, FmtDec(nTotal))
   HPDF_Page_EndText(page)
   y -= 20
RETURN

STATIC PROCEDURE PintarPie(page, fontS, aFactura, y)
   y := 50

   PintarLineaH(page, y)
   y -= 14

   HPDF_Page_SetFontAndSize(page, fontS, 7)
   HPDF_Page_SetRGBFill(page, 0.5, 0.5, 0.5)

   IF aFactura[26] != NIL
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, "Hash: " + Left(aFactura[26], 16) + "...")
      HPDF_Page_EndText(page)
      y -= 10
   ENDIF

   IF aFactura[27] != NIL
      HPDF_Page_BeginText(page)
      HPDF_Page_TextOut(page, PDF_MARGIN, y, "CSV: " + aFactura[27])
      HPDF_Page_EndText(page)
   ENDIF

   HPDF_Page_SetRGBFill(page, 0, 0, 0)
RETURN

STATIC PROCEDURE PintarLineaH(page, y)
   HPDF_Page_SetLineWidth(page, 0.5)
   HPDF_Page_MoveTo(page, PDF_MARGIN, y)
   HPDF_Page_LineTo(page, 595 - PDF_MARGIN, y)
   HPDF_Page_Stroke(page)
RETURN
