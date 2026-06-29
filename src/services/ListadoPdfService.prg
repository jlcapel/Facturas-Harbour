#require "hbhpdf"
#include "harupdf.ch"

FUNCTION GenerarListadoPdf(db, cTitulo, aData, aCols, cRuta)
   LOCAL pdf, page, fontN, fontB, fontS, y, i, nPag := 1
   LOCAL aInfo := ObtenerInfoListado(db)
   LOCAL nColW, cFecha := DToC(Date()) + " " + Left(hb_TToC(hb_DateTime(), 2), 5)

   pdf := HPDF_New()
   IF pdf == NIL; RETURN .F.; ENDIF

   HPDF_SetCompressionMode(pdf, HPDF_COMP_ALL)
   page := HPDF_AddPage(pdf)
   HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE)

   fontN := HPDF_GetFont(pdf, "Helvetica", NIL)
   fontB := HPDF_GetFont(pdf, "Helvetica-Bold", NIL)
   fontS := HPDF_GetFont(pdf, "Helvetica", NIL)

   y := 560

   PintarCabeceraListado(page, fontB, fontN, aInfo, cTitulo, cFecha, @y)
   y -= 10
   PintarTablaHeaderListado(page, fontB, aCols, @y)

   FOR i := 1 TO Len(aData)
      IF y < 60
         PintarPieListado(page, fontS, cTitulo, @nPag, @y)
         page := HPDF_AddPage(pdf)
         HPDF_Page_SetSize(page, HPDF_PAGE_SIZE_A4, HPDF_PAGE_LANDSCAPE)
         nPag++
         y := 560
         PintarCabeceraListado(page, fontB, fontN, aInfo, cTitulo, cFecha, @y)
         y -= 10
         PintarTablaHeaderListado(page, fontB, aCols, @y)
      ENDIF
      PintarFilaListado(page, fontN, aData[i], aCols, i, @y)
   NEXT

   PintarPieListado(page, fontS, cTitulo, @nPag, @y)

   HPDF_SaveToFile(pdf, cRuta)
   HPDF_Free(pdf)
   RETURN hb_FileExists(cRuta)

STATIC FUNCTION ObtenerInfoListado(db)
   LOCAL aInfo := { "", "" }
   aInfo[1] := NVL(ObtenerConfiguracion(db, "Empresa.Nombre"), "")
   aInfo[2] := NVL(ObtenerConfiguracion(db, "Empresa.Nif"), "")
   RETURN aInfo

STATIC FUNCTION NVL(uVal, uDef)
   IF uVal == NIL .OR. Empty(uVal); RETURN uDef; ENDIF
   RETURN uVal

STATIC PROCEDURE PintarCabeceraListado(page, fontB, fontN, aInfo, cTitulo, cFecha, y)
   HPDF_Page_SetFontAndSize(page, fontB, 14)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 30, y, aInfo[1])
   HPDF_Page_EndText(page)

   HPDF_Page_SetFontAndSize(page, fontN, 9)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 30, y - 14, "NIF: " + aInfo[2])
   HPDF_Page_EndText(page)

   HPDF_Page_SetFontAndSize(page, fontB, 16)
   HPDF_Page_SetRGBFill(page, 0, 0, 0.5)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 770 - HPDF_Page_TextWidth(page, cTitulo), y, cTitulo)
   HPDF_Page_EndText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_SetFontAndSize(page, fontS, 8)
   HPDF_Page_SetRGBFill(page, 0.5, 0.5, 0.5)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 770 - HPDF_Page_TextWidth(page, cFecha), y - 14, cFecha)
   HPDF_Page_EndText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   y -= 30
   PintarLineaHListado(page, y)
   y -= 10
RETURN

STATIC PROCEDURE PintarTablaHeaderListado(page, fontB, aCols, y)
   LOCAL x := 30, nI, aCol

   HPDF_Page_SetRGBFill(page, 0.9, 0.9, 0.9)
   HPDF_Page_Rectangle(page, x, y - 2, 740, 14)
   HPDF_Page_Fill(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_SetFontAndSize(page, fontB, 8)
   HPDF_Page_BeginText(page)
   FOR nI := 1 TO Len(aCols)
      aCol := aCols[nI]
      HPDF_Page_TextOut(page, x + 3, y + 2, Left(aCol[1], aCol[2] / 5))
      x += aCol[2]
   NEXT
   HPDF_Page_EndText(page)
   y -= 18
RETURN

STATIC PROCEDURE PintarFilaListado(page, fontN, aFila, aCols, nFila, y)
   LOCAL x := 30, nI, aCol, cVal, nW

   IF nFila % 2 == 0
      HPDF_Page_SetRGBFill(page, 0.95, 0.95, 0.97)
      HPDF_Page_Rectangle(page, x, y - 2, 740, 14)
      HPDF_Page_Fill(page)
   ENDIF
   HPDF_Page_SetRGBFill(page, 0, 0, 0)

   HPDF_Page_SetFontAndSize(page, fontN, 8)
   HPDF_Page_BeginText(page)
   FOR nI := 1 TO Len(aCols)
      aCol := aCols[nI]
      nW := aCol[2]
      cVal := aFila[aCol[3]]
      IF nI <= Len(aFila)
         IF Len(aCol) >= 4 .AND. aCol[4]
            HPDF_Page_TextOut(page, x + nW - HPDF_Page_TextWidth(page, cVal) - 3, y + 2, Left(cVal, nW / 4))
         ELSE
            HPDF_Page_TextOut(page, x + 3, y + 2, Left(cVal, nW / 4))
         ENDIF
      ENDIF
      x += nW
   NEXT
   HPDF_Page_EndText(page)
   y -= 14
RETURN

STATIC PROCEDURE PintarPieListado(page, fontS, cTitulo, nPag, y)
   y := 25
   PintarLineaHListado(page, y)
   y -= 10
   HPDF_Page_SetFontAndSize(page, fontS, 8)
   HPDF_Page_SetRGBFill(page, 0.5, 0.5, 0.5)
   HPDF_Page_BeginText(page)
   HPDF_Page_TextOut(page, 30, y, cTitulo)
   HPDF_Page_TextOut(page, 770 - 40, y, "Pág. " + hb_ntos(nPag))
   HPDF_Page_EndText(page)
   HPDF_Page_SetRGBFill(page, 0, 0, 0)
RETURN

STATIC PROCEDURE PintarLineaHListado(page, y)
   HPDF_Page_SetLineWidth(page, 0.5)
   HPDF_Page_MoveTo(page, 30, y)
   HPDF_Page_LineTo(page, 770, y)
   HPDF_Page_Stroke(page)
RETURN

FUNCTION AbrirListadoPdf(db, cTitulo, aData, aCols)
   LOCAL cDir := "/tmp/Facturas/Listados", cFile, cRuta
   hb_DirBuild(cDir)
   cFile := StrTran(cTitulo, " ", "_") + ".pdf"
   cRuta := cDir + "/" + cFile
   IF !GenerarListadoPdf(db, cTitulo, aData, aCols, cRuta)
      RETURN NIL
   ENDIF
   RETURN cRuta
