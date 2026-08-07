#include "hwgui.ch"
#include "hbsqlit3.ch"

STATIC s_Db
STATIC s_oPanel

PROCEDURE Main()
   LOCAL oDlg, cLang, oTitleFnt

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

   // --- Evento VERI*FACTU: Login ---
   RegistrarEvento(s_Db, "Login", "Inicio de sesión")
   // --- Fin Evento ---

   PREPARE FONT oTitleFnt NAME "Arial" WIDTH 0 HEIGHT -20 WEIGHT 700

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE 860, 540 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   MENU OF oDlg
      MENU TITLE L("MenuMaestros")
         MENUITEM L("MenuPaises") ACTION {|| AbrirVista("Paises", oDlg)}
         MENUITEM L("MenuTiposIva") ACTION {|| AbrirVista("TiposIva", oDlg)}
         MENUITEM L("MenuTiposIdent") ACTION {|| AbrirVista("TiposIdent", oDlg)}
         SEPARATOR
         MENUITEM L("MenuClientes") ACTION {|| AbrirVista("Clientes", oDlg)}
         MENUITEM L("MenuArticulos") ACTION {|| AbrirVista("Articulos", oDlg)}
         SEPARATOR
         MENUITEM L("MenuProveedores") ACTION {|| AbrirVista("Proveedores", oDlg)}
         MENUITEM L("MenuCategoriasGasto") ACTION {|| AbrirVista("CategoriasGasto", oDlg)}
         MENUITEM L("MenuBienesInversion") ACTION {|| AbrirVista("BienesInversion", oDlg)}
      ENDMENU
      MENU TITLE L("MenuEmpresa")
         MENUITEM L("MenuConfiguracion") ACTION {|| AbrirVista("Empresa", oDlg)}
      ENDMENU
      MENU TITLE L("MenuFacturas")
         MENUITEM L("MenuListado") ACTION {|| AbrirVista("Facturas", oDlg)}
      ENDMENU
      MENU TITLE L("MenuGastos")
         MENUITEM L("MenuListado") ACTION {|| AbrirVista("Gastos", oDlg)}
      ENDMENU
      MENU TITLE L("MenuValidacion")
         MENUITEM L("MenuNifAeat") ACTION {|| AbrirVista("ValidacionNif", oDlg)}
         SEPARATOR
         MENUITEM L("MenuVatVies") ACTION {|| AbrirVista("Vies", oDlg)}
      ENDMENU
      MENU TITLE "AEAT"
         MENUITEM L("MenuModelosAeat") ACTION {|| AbrirVista("ModelosAeat", oDlg)}
      ENDMENU
      MENU TITLE L("MenuExportar")
         MENUITEM L("MenuRegistrosXml") ACTION {|| ExportarRegAeat()}
         MENUITEM L("MenuEventosXml") ACTION {|| ExportarEventosXml()}
         SEPARATOR
         MENUITEM L("MenuGastosCsv") ACTION {|| ExportarGastosCsv()}
      ENDMENU
   ENDMENU

   @ 190, 20 SAY "Facturas - VERI*FACTU" SIZE 400, 28 ;
      COLOR hwg_ColorRGB2N(30, 64, 114) FONT oTitleFnt

   @ 130, 32 SAY "Seleccione una opción en el menú superior" SIZE 400, 18 ;
      COLOR hwg_ColorRGB2N(100, 116, 139)

   ADD STATUS TO oDlg PARTS 400, 200

   ACTIVATE DIALOG oDlg CENTER

   s_Db := NIL
RETURN

STATIC FUNCTION AbrirVista(cVista, oDlg)
   LOCAL nX := 5, nY := 55, nW := 848, nH := 430

   IF cVista == "Empresa"
      CerrarVista()
      EmpresaView(s_Db)
      RETURN NIL
   ENDIF

   CerrarVista()

   @ nX, nY PANEL s_oPanel OF oDlg SIZE nW, nH

   DO CASE
   CASE cVista == "Paises"
      PaisesView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "TiposIva"
      TiposIvaView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "TiposIdent"
      TiposIdentificacionView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Clientes"
      ClientesView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Articulos"
      ArticulosView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Proveedores"
      ProveedoresView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "CategoriasGasto"
      CategoriasGastoView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "BienesInversion"
      BienesInversionView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Facturas"
      FacturasView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Gastos"
      GastosView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "ValidacionNif"
      ValidacionView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "Vies"
      ViesView(s_Db, s_oPanel, 0, 0, nW, nH)
   CASE cVista == "ModelosAeat"
      ModelosAeatView(s_Db, s_oPanel, 0, 0, nW, nH)
   ENDCASE

RETURN NIL

FUNCTION CerrarVista()
   IF s_oPanel != NIL
      s_oPanel:Hide()
      s_oPanel := NIL
   ENDIF
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
