/*
 * Facturas-Harbour — App de facturación VERI*FACTU (España)
 * Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
 * Licensed under GPLv3. Commercial license available.
 */

#include "hwgui.ch"
#include "hbsqlit3.ch"

STATIC s_Db

PROCEDURE Main()
   LOCAL oDlg, cLang, oTitleFnt
   LOCAL nBx := 16, nBw := 150, nBy

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

   PREPARE FONT oTitleFnt NAME "Arial" WIDTH 0 HEIGHT -20 WEIGHT 700

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE 960, 640 ;
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
         MENUITEM L("MenuRegistrosXml") ACTION {|| ExportarRegAeat()}
         MENUITEM L("MenuEventosXml") ACTION {|| ExportarEventosXml()}
         SEPARATOR
         MENUITEM L("MenuGastosCsv") ACTION {|| ExportarGastosCsv()}
      ENDMENU
   ENDMENU

   // === SIDEBAR: botones verticales alineados ===
   nBy := 16

   @ nBy, nBx BUTTON "Facturas"     SIZE nBw, 26 ON CLICK {|| FacturasView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Clientes"     SIZE nBw, 26 ON CLICK {|| ClientesView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Artículos"    SIZE nBw, 26 ON CLICK {|| ArticulosView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Proveedores"  SIZE nBw, 26 ON CLICK {|| ProveedoresView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Gastos"       SIZE nBw, 26 ON CLICK {|| GastosView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "B. Inversión" SIZE nBw, 26 ON CLICK {|| BienesInversionView(s_Db)}
   nBy += 34
   @ nBy, nBx LINE LENGTH nBw
   nBy += 16
   @ nBy, nBx BUTTON "Empresa"      SIZE nBw, 26 ON CLICK {|| EmpresaView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Tipos IVA"    SIZE nBw, 26 ON CLICK {|| TiposIvaView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Países"       SIZE nBw, 26 ON CLICK {|| PaisesView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Identific."   SIZE nBw, 26 ON CLICK {|| TiposIdentificacionView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Categ. Gasto" SIZE nBw, 26 ON CLICK {|| CategoriasGastoView(s_Db)}
   nBy += 34
   @ nBy, nBx LINE LENGTH nBw
   nBy += 16
   @ nBy, nBx BUTTON "Validación"   SIZE nBw, 26 ON CLICK {|| ValidacionView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "VIES"         SIZE nBw, 26 ON CLICK {|| ViesView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Modelos AEAT" SIZE nBw, 26 ON CLICK {|| ModelosAeatView(s_Db)}
   nBy += 34
   @ nBy, nBx BUTTON "Exportación"  SIZE nBw, 26 ON CLICK {|| MenuExportar()}

   // === CONTENT AREA: bienvenida ===
   @ 20, 190 SAY "Facturas - VERI*FACTU" SIZE 400, 28 ;
      COLOR hwg_ColorRGB2N(30, 64, 114) FONT oTitleFnt

   @ 52, 190 SAY "Seleccione una opción en el panel izquierdo" SIZE 400, 18 ;
      COLOR hwg_ColorRGB2N(100, 116, 139)

   ADD STATUS TO oDlg PARTS 400, 200

   ACTIVATE DIALOG oDlg CENTER

   s_Db := NIL
RETURN

// === Diálogos auxiliares ===

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
