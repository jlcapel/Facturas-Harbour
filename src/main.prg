#include "hwgui.ch"
#include "hbsqlit3.ch"

STATIC s_Db
STATIC s_oPanel

PROCEDURE Main()
   LOCAL oVentana, cLang, oTitleFnt

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

   RegistrarEvento(s_Db, "Login", L("MainEventoLogin"))

   PREPARE FONT oTitleFnt NAME "Arial" WIDTH 0 HEIGHT -20 WEIGHT 700

   INIT WINDOW oVentana MAIN ;
      TITLE "Facturas-Harbour" ;
      AT 50, 60 ;
      SIZE 860, 540 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   MENU OF oVentana
      MENU TITLE L("MenuMaestros")
         MENUITEM L("MenuPaises") ACTION AbrirVista("Paises", oVentana)
         MENUITEM L("MenuTiposIva") ACTION AbrirVista("TiposIva", oVentana)
         MENUITEM L("MenuTiposIdent") ACTION AbrirVista("TiposIdent", oVentana)
         SEPARATOR
         MENUITEM L("MenuClientes") ACTION AbrirVista("Clientes", oVentana)
         MENUITEM L("MenuArticulos") ACTION AbrirVista("Articulos", oVentana)
         SEPARATOR
         MENUITEM L("MenuProveedores") ACTION AbrirVista("Proveedores", oVentana)
         MENUITEM L("MenuCategoriasGasto") ACTION AbrirVista("CategoriasGasto", oVentana)
         MENUITEM L("MenuBienesInversion") ACTION AbrirVista("BienesInversion", oVentana)
      ENDMENU
      MENU TITLE L("MenuEmpresa")
         MENUITEM L("MenuConfiguracion") ACTION AbrirVista("Empresa", oVentana)
      ENDMENU
      MENU TITLE L("MenuFacturas")
         MENUITEM L("MenuListado") ACTION AbrirVista("Facturas", oVentana)
      ENDMENU
      MENU TITLE L("MenuGastos")
         MENUITEM L("MenuListado") ACTION AbrirVista("Gastos", oVentana)
      ENDMENU
      MENU TITLE L("MenuValidacion")
         MENUITEM L("MenuNifAeat") ACTION AbrirVista("ValidacionNif", oVentana)
         SEPARATOR
         MENUITEM L("MenuVatVies") ACTION AbrirVista("Vies", oVentana)
      ENDMENU
      MENU TITLE "AEAT"
         MENUITEM L("MenuModelosAeat") ACTION AbrirVista("ModelosAeat", oVentana)
      ENDMENU
      MENU TITLE L("MenuExportar")
         MENUITEM L("MenuRegistrosXml") ACTION ExportarRegAeat()
         MENUITEM L("MenuEventosXml") ACTION ExportarEventosXml()
         SEPARATOR
         MENUITEM L("MenuGastosCsv") ACTION ExportarGastosCsv()
      ENDMENU
   ENDMENU

   @ 190, 20 SAY "Facturas - VERI*FACTU" SIZE 400, 28 ;
      COLOR hwg_ColorRGB2N(30, 64, 114) FONT oTitleFnt

   @ 130, 32 SAY L("MainMsgSeleccionOpcion") SIZE 400, 18 ;
      COLOR hwg_ColorRGB2N(100, 116, 139)

   ACTIVATE WINDOW oVentana

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
   hwg_MsgInfo(StrTran(L("MainExportRegistros"), "{1}", cPath), L("MainTituloExportacion"))
RETURN NIL

STATIC FUNCTION ExportarEventosXml()
   LOCAL cPath := GuardarXmlEventos(s_Db)
   hwg_MsgInfo(StrTran(L("MainExportEventos"), "{1}", cPath), L("MainTituloExportacion"))
RETURN NIL

STATIC FUNCTION ExportarGastosCsv()
   LOCAL cYear := hwg_MsgGet(L("MainAnioTitulo"), L("MainAnioPrompt"), hb_ntos(Year(Date())))
   LOCAL nYear, cPath
   IF Empty(cYear); RETURN; ENDIF
   nYear := Val(cYear)
   IF nYear < 2000 .OR. nYear > 2100; hwg_MsgInfo(L("MainAnioNoValido"), L("CommonError")); RETURN; ENDIF
   cPath := GuardarCsvGastos(s_Db, nYear)
   hwg_MsgInfo(StrTran(L("MainExportGastos"), "{1}", cPath), L("MainTituloExportacion"))
RETURN NIL
