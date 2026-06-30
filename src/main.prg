/*
 * Facturas-Harbour — App de facturación VERI*FACTU (España)
 * Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
 * Licensed under GPLv3. Commercial license available.
 */

#include "hwgui.ch"
#include "hbsqlit3.ch"

#define SIDEBAR_W    220
#define SIDEBAR_BG   hwg_ColorRGB2N(30, 41, 59)
#define SIDEBAR_TEXT hwg_ColorRGB2N(203, 213, 225)
#define SIDEBAR_SEC  hwg_ColorRGB2N(100, 116, 139)
#define PAGE_BG      hwg_ColorRGB2N(241, 245, 249)
#define CARD_BG      hwg_ColorRGB2N(255, 255, 255)
#define TEXT_DARK    hwg_ColorRGB2N(15, 23, 42)
#define TEXT_MUTED   hwg_ColorRGB2N(100, 116, 139)
#define ACCENT_BLUE  hwg_ColorRGB2N(59, 130, 246)
#define ACCENT_GREEN hwg_ColorRGB2N(34, 197, 94)
#define ACCENT_PURPLE hwg_ColorRGB2N(139, 92, 246)

STATIC s_Db  // db handle used by nav callbacks

PROCEDURE Main()
   LOCAL oDlg, cLang
   LOCAL oFntLogo, oFntBrand, oFntSmall
   LOCAL oFntSec, oFntNav
   LOCAL oFntPgTitle, oFntCardTitle, oFntCardDesc, oFntBtn
   LOCAL nCardW, nCardH, nGap, nCX, nCX2, nCY1, nCY2, nCY3

   InicializarBaseDatos()
   s_Db := AbrirBaseDatos()

   IF !EnsureDbReady()
      LogInfo("Main: no se pudo asegurar integridad BD")
   ENDIF
   HacerBackup()
   LocalizationNew()
   cLang := ObtenerConfiguracion(s_Db, "Language")
   IF cLang != NIL
      LocalizationSetLang(cLang)
   ENDIF

   PREPARE FONT oFntLogo NAME "Arial" WIDTH 0 HEIGHT -36 WEIGHT 700
   PREPARE FONT oFntBrand NAME "Arial" WIDTH 0 HEIGHT -20 WEIGHT 700
   PREPARE FONT oFntSmall NAME "Arial" WIDTH 0 HEIGHT -11 WEIGHT 400
   PREPARE FONT oFntSec NAME "Arial" WIDTH 0 HEIGHT -9 WEIGHT 700
   PREPARE FONT oFntNav NAME "Arial" WIDTH 0 HEIGHT -11 WEIGHT 400
   PREPARE FONT oFntPgTitle NAME "Arial" WIDTH 0 HEIGHT -22 WEIGHT 700
   PREPARE FONT oFntCardTitle NAME "Arial" WIDTH 0 HEIGHT -13 WEIGHT 700
   PREPARE FONT oFntCardDesc NAME "Arial" WIDTH 0 HEIGHT -10 WEIGHT 400
   PREPARE FONT oFntBtn NAME "Arial" WIDTH 0 HEIGHT -10 WEIGHT 700

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE 1200, 720 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   MENU OF oDlg
      MENU TITLE L("MenuMaestros")
         MENUITEM L("MenuPaises") ACTION {|| PaisesView(s_Db)}
         MENUITEM L("MenuTiposIva") ACTION {|| TiposIvaView(s_Db)}
         MENUITEM L("MenuTiposIdent") ACTION {|| TiposIdentificacionView(s_Db)}
         SEPARATOR
         MENUITEM L("MenuClientes") ACTION {|| ClientesView(s_Db)}
         MENUITEM L("MenuArticulos") ACTION {|| ArticulosView(s_Db)}
         SEPARATOR
         MENUITEM L("MenuProveedores") ACTION {|| ProveedoresView(s_Db)}
         MENUITEM L("MenuCategoriasGasto") ACTION {|| CategoriasGastoView(s_Db)}
         MENUITEM L("MenuBienesInversion") ACTION {|| BienesInversionView(s_Db)}
      ENDMENU
      MENU TITLE L("MenuEmpresa")
         MENUITEM L("MenuConfiguracion") ACTION {|| EmpresaView(s_Db)}
      ENDMENU
      MENU TITLE L("MenuFacturas")
         MENUITEM L("MenuListado") ACTION {|| FacturasView(s_Db)}
      ENDMENU
      MENU TITLE L("MenuGastos")
         MENUITEM L("MenuListado") ACTION {|| GastosView(s_Db)}
      ENDMENU
      MENU TITLE L("MenuValidacion")
         MENUITEM L("MenuNifAeat") ACTION {|| ValidacionView(s_Db)}
         SEPARATOR
         MENUITEM L("MenuVatVies") ACTION {|| ViesView(s_Db)}
      ENDMENU
      MENU TITLE "AEAT"
         MENUITEM L("MenuModelosAeat") ACTION {|| ModelosAeatView(s_Db)}
      ENDMENU
      MENU TITLE L("MenuExportar")
         MENUITEM L("MenuRegistrosXml") ACTION {|| ExportarRegAeat(s_Db)}
         MENUITEM L("MenuEventosXml") ACTION {|| ExportarEventosXml(s_Db)}
         SEPARATOR
         MENUITEM L("MenuGastosCsv") ACTION {|| ExportarGastosCsv(s_Db)}
      ENDMENU
   ENDMENU

   // =====================================================================
   //  SIDEBAR — dark panel, full height
   // =====================================================================
   @ 0, 0 SAY "" SIZE SIDEBAR_W, 720 BACKCOLOR SIDEBAR_BG

   // Logo circle "F"
   @ 20, 18 SAY "F" SIZE 44, 44 COLOR hwg_ColorRGB2N(255, 255, 255) BACKCOLOR ACCENT_BLUE FONT oFntLogo TRANSPARENT

   @ 72, 22 SAY "Facturas" SIZE 170, 26 COLOR hwg_ColorRGB2N(241, 245, 249) FONT oFntBrand TRANSPARENT

   @ 100, 24 SAY "VERI*FACTU" SIZE 170, 16 COLOR hwg_ColorRGB2N(148, 163, 184) FONT oFntSmall TRANSPARENT

   // Divider
   @ 120, 12 LINE LENGTH 195

   // ---------------------------------------------------------------
   //  PRINCIPAL section
   // ---------------------------------------------------------------
   @ 132, 15 SAY L("MainSidebarPrincipal") SIZE 180, 14 COLOR SIDEBAR_SEC FONT oFntSec TRANSPARENT

   @ 148, 12 BUTTON L("MenuFacturas")        SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| FacturasView(s_Db)}
   @ 176, 12 BUTTON L("MenuClientes")        SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ClientesView(s_Db)}
   @ 204, 12 BUTTON L("MenuArticulos")       SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ArticulosView(s_Db)}
   @ 232, 12 BUTTON L("MenuProveedores")     SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ProveedoresView(s_Db)}
   @ 260, 12 BUTTON L("MenuGastos")          SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| GastosView(s_Db)}
   @ 288, 12 BUTTON L("MenuBienesInversion") SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| BienesInversionView(s_Db)}

   @ 318, 12 LINE LENGTH 195

   @ 328, 15 SAY L("MainSidebarConfig") SIZE 180, 14 COLOR SIDEBAR_SEC FONT oFntSec TRANSPARENT

   @ 348, 12 BUTTON L("ConfigMenuEmpresa")        SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| EmpresaView(s_Db)}
   @ 376, 12 BUTTON L("ConfigMenuTiposIva")       SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| TiposIvaView(s_Db)}
   @ 404, 12 BUTTON L("MenuPaises")               SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| PaisesView(s_Db)}
   @ 432, 12 BUTTON L("ConfigMenuIdentificacion") SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| TiposIdentificacionView(s_Db)}
   @ 460, 12 BUTTON L("ConfigMenuCategoriasGasto") SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| CategoriasGastoView(s_Db)}

   @ 490, 12 LINE LENGTH 195

   @ 500, 15 SAY "UTILIDADES" SIZE 180, 14 COLOR SIDEBAR_SEC FONT oFntSec TRANSPARENT

   @ 520, 12 BUTTON L("DashValidacion")     SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ValidacionView(s_Db)}
   @ 548, 12 BUTTON "VIES"                  SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ViesView(s_Db)}
   @ 576, 12 BUTTON L("UtilMenuModelosAeat") SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| ModelosAeatView(s_Db)}
   @ 604, 12 BUTTON L("MenuExportar")       SIZE 195, 26 COLOR SIDEBAR_TEXT FONT oFntNav ON CLICK {|| MenuExportar()}

   // Version footer
   @ 640, 55 SAY "v1.0 — Harbour + HWGUI" SIZE 180, 14 COLOR hwg_ColorRGB2N(71, 85, 105) FONT oFntSmall TRANSPARENT

   @ 0, SIDEBAR_W SAY "" SIZE 985, 720 BACKCOLOR PAGE_BG

   @ 24, 244 SAY L("DashboardTitle") SIZE 400, 30 COLOR TEXT_DARK FONT oFntPgTitle TRANSPARENT

   // ---------------------------------------------------------------
   //  CARD 1 — Facturación
   // ---------------------------------------------------------------
   nCardW := 300; nCardH := 230; nGap := 18
   nCX := SIDEBAR_W + 14; nCY1 := 68

   @ nCY1, nCX SAY "" SIZE nCardW, nCardH BACKCOLOR CARD_BG

   @ nCY1, nCX     SAY "" SIZE nCardW, 4 BACKCOLOR ACCENT_BLUE
   @ nCY1 + 14, nCX + 14 SAY "Facturación" SIZE 270, 20 COLOR TEXT_DARK FONT oFntCardTitle TRANSPARENT
   @ nCY1 + 36, nCX + 14 SAY "Gestión de clientes, artículos y facturación VERI*FACTU" SIZE 270, 28 COLOR TEXT_MUTED FONT oFntCardDesc TRANSPARENT

   @ nCY1 + 76,  nCX + 14 BUTTON "Facturas"  SIZE 130, 26 FONT oFntBtn ON CLICK {|| FacturasView(s_Db)}
   @ nCY1 + 76,  nCX + 156 BUTTON "Clientes" SIZE 130, 26 FONT oFntBtn ON CLICK {|| ClientesView(s_Db)}

   @ nCY1 + 108, nCX + 14 BUTTON "Artículos" SIZE 130, 26 FONT oFntBtn ON CLICK {|| ArticulosView(s_Db)}
   @ nCY1 + 108, nCX + 156 BUTTON "Maestros" SIZE 130, 26 FONT oFntBtn ON CLICK {|| MaestrosView()}

   @ nCY1 + 150, nCX + 14 BUTTON "Modelos AEAT" SIZE 272, 26 FONT oFntBtn ON CLICK {|| ModelosAeatView(s_Db)}

   // ---------------------------------------------------------------
   //  CARD 2 — Gastos
   // ---------------------------------------------------------------
   nCY2 := nCY1 + nCardH + nGap

   @ nCY2, nCX SAY "" SIZE nCardW, nCardH BACKCOLOR CARD_BG

   @ nCY2, nCX     SAY "" SIZE nCardW, 4 BACKCOLOR ACCENT_GREEN
   @ nCY2 + 14, nCX + 14 SAY "Compras y Gastos" SIZE 270, 20 COLOR TEXT_DARK FONT oFntCardTitle TRANSPARENT
   @ nCY2 + 36, nCX + 14 SAY "Proveedores, gastos y bienes de inversión" SIZE 270, 28 COLOR TEXT_MUTED FONT oFntCardDesc TRANSPARENT

   @ nCY2 + 76,  nCX + 14 BUTTON "Gastos"      SIZE 130, 26 FONT oFntBtn ON CLICK {|| GastosView(s_Db)}
   @ nCY2 + 76,  nCX + 156 BUTTON "Proveedores" SIZE 130, 26 FONT oFntBtn ON CLICK {|| ProveedoresView(s_Db)}

   @ nCY2 + 108, nCX + 14 BUTTON "Categorías"  SIZE 130, 26 FONT oFntBtn ON CLICK {|| CategoriasGastoView(s_Db)}
   @ nCY2 + 108, nCX + 156 BUTTON "B. Inversión" SIZE 130, 26 FONT oFntBtn ON CLICK {|| BienesInversionView(s_Db)}

   @ nCY2 + 150, nCX + 14 BUTTON "Exportar Gastos CSV" SIZE 272, 26 FONT oFntBtn ON CLICK {|| ExportarGastosCsv(s_Db)}

   // ---------------------------------------------------------------
   //  CARD 3 — Configuración & Utilidades
   // ---------------------------------------------------------------
   nCX2 := nCX + nCardW + nGap; nCY3 := nCY1

   @ nCY3, nCX2 SAY "" SIZE nCardW, nCardH BACKCOLOR CARD_BG

   @ nCY3, nCX2     SAY "" SIZE nCardW, 4 BACKCOLOR ACCENT_PURPLE
   @ nCY3 + 14, nCX2 + 14 SAY "Configuración" SIZE 270, 20 COLOR TEXT_DARK FONT oFntCardTitle TRANSPARENT
   @ nCY3 + 36, nCX2 + 14 SAY "Empresa, validación NIF y herramientas AEAT" SIZE 270, 28 COLOR TEXT_MUTED FONT oFntCardDesc TRANSPARENT

   @ nCY3 + 76,  nCX2 + 14 BUTTON "Empresa"     SIZE 130, 26 FONT oFntBtn ON CLICK {|| EmpresaView(s_Db)}
   @ nCY3 + 76,  nCX2 + 156 BUTTON "Validación" SIZE 130, 26 FONT oFntBtn ON CLICK {|| ValidacionView(s_Db)}

   @ nCY3 + 108, nCX2 + 14 BUTTON "VIES"        SIZE 130, 26 FONT oFntBtn ON CLICK {|| ViesView(s_Db)}
   @ nCY3 + 108, nCX2 + 156 BUTTON "Exportar"   SIZE 130, 26 FONT oFntBtn ON CLICK {|| MenuExportar()}

   @ nCY3 + 150, nCX2 + 14 BUTTON "Tipos IVA"   SIZE 130, 26 FONT oFntBtn ON CLICK {|| TiposIvaView(s_Db)}
   @ nCY3 + 150, nCX2 + 156 BUTTON "Países"     SIZE 130, 26 FONT oFntBtn ON CLICK {|| PaisesView(s_Db)}

   // =====================================================================
   //  STATUS BAR
   // =====================================================================
   ADD STATUS TO oDlg PARTS 400, 300

   ACTIVATE DIALOG oDlg CENTER

   s_Db := NIL
RETURN

// =====================================================================
//  Dialogs emergentes
// =====================================================================

STATIC FUNCTION MaestrosView()
   LOCAL oDlg
   INIT DIALOG oDlg TITLE "Maestros" AT 0, 0 SIZE 260, 160 ;
      STYLE WS_DLGFRAME + DS_CENTER
   @ 15, 15 BUTTON "Países"                SIZE 230, 28 ;
      ON CLICK {|| PaisesView(s_Db), oDlg:Close()}
   @ 48, 15 BUTTON "Tipos IVA"             SIZE 230, 28 ;
      ON CLICK {|| TiposIvaView(s_Db), oDlg:Close()}
   @ 81, 15 BUTTON "Tipos Identificación"  SIZE 230, 28 ;
      ON CLICK {|| TiposIdentificacionView(s_Db), oDlg:Close()}
   @ 120, 95 BUTTON "Cancelar" SIZE 80, 26 ;
      ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg
RETURN NIL

STATIC FUNCTION MenuExportar()
   LOCAL oDlg
   INIT DIALOG oDlg TITLE "Exportación" AT 0, 0 SIZE 260, 170 ;
      STYLE WS_DLGFRAME + DS_CENTER
   @ 15, 15 BUTTON "Registros AEAT (XML)" SIZE 230, 28 ;
      ON CLICK {|| ExportarRegAeat(), oDlg:Close()}
   @ 48, 15 BUTTON "Eventos (XML)"        SIZE 230, 28 ;
      ON CLICK {|| ExportarEventosXml(), oDlg:Close()}
   @ 81, 15 BUTTON "Gastos (CSV)"         SIZE 230, 28 ;
      ON CLICK {|| ExportarGastosCsv(), oDlg:Close()}
   @ 128, 100 BUTTON "Cancelar" SIZE 80, 26 ;
      ON CLICK {|| oDlg:Close()}
   ACTIVATE DIALOG oDlg
RETURN NIL

FUNCTION ObtenerTextoInfo()
   RETURN "BD: " + ObtenerDbPath()
RETURN NIL

STATIC FUNCTION ExportarRegAeat()
   LOCAL cPath := GuardarXmlRegistros(s_Db)
   hwg_MsgInfo("Registros AEAT exportados: " + cPath, "Exportación")
RETURN NIL

STATIC FUNCTION ExportarEventosXml()
   LOCAL cPath := GuardarXmlEventos(s_Db)
   hwg_MsgInfo("Eventos exportados: " + cPath, "Exportación")
RETURN NIL

STATIC FUNCTION ExportarGastosCsv()
   LOCAL cYear := hwg_MsgGet("Año", "Introduzca año:", hb_ntos(Year(Date())))
   LOCAL nYear, cPath
   IF Empty(cYear); RETURN; ENDIF
   nYear := Val(cYear)
   IF nYear < 2000 .OR. nYear > 2100; hwg_MsgInfo("Año no válido", "Error"); RETURN; ENDIF
   cPath := GuardarCsvGastos(s_Db, nYear)
   hwg_MsgInfo("Gastos exportados: " + cPath, "Exportación")
RETURN NIL
