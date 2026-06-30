/*
 * Facturas-Harbour — App de facturación VERI*FACTU (España)
 * Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
 * Licensed under GPLv3. Commercial license available.
 */

#include "hwgui.ch"
#include "hbsqlit3.ch"

STATIC s_Db

PROCEDURE Main()
   LOCAL oDlg, cLang
   LOCAL oFntBtn
   LOCAL nSx := 14, nSw := 160, nDw := 1050
   LOCAL ny, nCx, nGw, nGh

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

   PREPARE FONT oFntBtn NAME "Arial" WIDTH 0 HEIGHT -10 WEIGHT 400

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE nDw, 660 ;
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

   // ================================================================
   //  SIDEBAR — botones verticales
   // ================================================================
   ny := 16

   @ ny, nSx BUTTON "Facturas"        SIZE nSw, 26 FONT oFntBtn ON CLICK {|| FacturasView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Clientes"        SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ClientesView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Artículos"       SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ArticulosView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Proveedores"     SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ProveedoresView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Gastos"          SIZE nSw, 26 FONT oFntBtn ON CLICK {|| GastosView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "B. Inversión"    SIZE nSw, 26 FONT oFntBtn ON CLICK {|| BienesInversionView(s_Db)}
   ny += 38
   @ ny, nSx LINE LENGTH nSw
   ny += 14
   @ ny, nSx BUTTON "Empresa"         SIZE nSw, 26 FONT oFntBtn ON CLICK {|| EmpresaView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Tipos IVA"       SIZE nSw, 26 FONT oFntBtn ON CLICK {|| TiposIvaView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Países"          SIZE nSw, 26 FONT oFntBtn ON CLICK {|| PaisesView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Identificación"  SIZE nSw, 26 FONT oFntBtn ON CLICK {|| TiposIdentificacionView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Categorías Gasto" SIZE nSw, 26 FONT oFntBtn ON CLICK {|| CategoriasGastoView(s_Db)}
   ny += 38
   @ ny, nSx LINE LENGTH nSw
   ny += 14
   @ ny, nSx BUTTON "Validación NIF"  SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ValidacionView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "VIES"            SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ViesView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Modelos AEAT"    SIZE nSw, 26 FONT oFntBtn ON CLICK {|| ModelosAeatView(s_Db)}
   ny += 32
   @ ny, nSx BUTTON "Exportar"        SIZE nSw, 26 FONT oFntBtn ON CLICK {|| MenuExportar()}

   // ================================================================
   //  CONTENT AREA — GROUP boxes
   // ================================================================
   nCx := 190; nGw := 270; nGh := 190

   @ 16, nCx GROUPBOX "Facturación" SIZE nGw, nGh
   @ 40, nCx + 18 BUTTON "Facturas"  SIZE 110, 26 FONT oFntBtn ON CLICK {|| FacturasView(s_Db)}
   @ 40, nCx + 142 BUTTON "Clientes" SIZE 110, 26 FONT oFntBtn ON CLICK {|| ClientesView(s_Db)}
   @ 72, nCx + 18 BUTTON "Artículos" SIZE 110, 26 FONT oFntBtn ON CLICK {|| ArticulosView(s_Db)}
   @ 72, nCx + 142 BUTTON "Maestros" SIZE 110, 26 FONT oFntBtn ON CLICK {|| MaestrosView()}
   @ 104, nCx + 18 BUTTON "Modelos AEAT" SIZE 234, 26 FONT oFntBtn ON CLICK {|| ModelosAeatView(s_Db)}

   @ 16, nCx + nGw + 18 GROUPBOX "Compras y Gastos" SIZE nGw, nGh
   @ 40, nCx + nGw + 36 BUTTON "Gastos"      SIZE 110, 26 FONT oFntBtn ON CLICK {|| GastosView(s_Db)}
   @ 40, nCx + nGw + 160 BUTTON "Proveedores" SIZE 110, 26 FONT oFntBtn ON CLICK {|| ProveedoresView(s_Db)}
   @ 72, nCx + nGw + 36 BUTTON "Categorías"  SIZE 110, 26 FONT oFntBtn ON CLICK {|| CategoriasGastoView(s_Db)}
   @ 72, nCx + nGw + 160 BUTTON "B. Inversión" SIZE 110, 26 FONT oFntBtn ON CLICK {|| BienesInversionView(s_Db)}
   @ 104, nCx + nGw + 36 BUTTON "Exportar CSV" SIZE 234, 26 FONT oFntBtn ON CLICK {|| ExportarGastosCsv()}

   @ 16, nCx + nGw * 2 + 36 GROUPBOX "Configuración" SIZE nGw, nGh
   @ 40, nCx + nGw * 2 + 54 BUTTON "Empresa"    SIZE 110, 26 FONT oFntBtn ON CLICK {|| EmpresaView(s_Db)}
   @ 40, nCx + nGw * 2 + 178 BUTTON "Validación" SIZE 110, 26 FONT oFntBtn ON CLICK {|| ValidacionView(s_Db)}
   @ 72, nCx + nGw * 2 + 54 BUTTON "VIES"       SIZE 110, 26 FONT oFntBtn ON CLICK {|| ViesView(s_Db)}
   @ 72, nCx + nGw * 2 + 178 BUTTON "Exportar"  SIZE 110, 26 FONT oFntBtn ON CLICK {|| MenuExportar()}
   @ 104, nCx + nGw * 2 + 54 BUTTON "Tipos IVA" SIZE 110, 26 FONT oFntBtn ON CLICK {|| TiposIvaView(s_Db)}
   @ 104, nCx + nGw * 2 + 178 BUTTON "Países"   SIZE 110, 26 FONT oFntBtn ON CLICK {|| PaisesView(s_Db)}

   @ 600, 30 BUTTON "Salir" SIZE 60, 22 ON CLICK {|| oDlg:Close()}

   ADD STATUS TO oDlg PARTS 400, 200

   ACTIVATE DIALOG oDlg CENTER

   s_Db := NIL
RETURN

// ================================================================
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
