#include "hwgui.ch"

FUNCTION EmpresaView(db)
   LOCAL oDlg

   INIT DIALOG oDlg ;
      TITLE L("EmpresaConfigVerifactu") ;
      AT 0, 0 ;
      SIZE 640, 670 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 10, 20 GROUPBOX L("EmpresaDatosEmisor") SIZE 590, 195
   EmpresaControls(db, oDlg)

   @ 10, 230 GROUPBOX L("EmpresaConfigVerifactu") SIZE 590, 100
   VerifactuControls(db, oDlg)

   @ 10, 345 GROUPBOX L("EmpresaCertificadoDigital") SIZE 590, 90
   CertificadoControls(db, oDlg)

   @ 10, 450 GROUPBOX L("EmpresaSistemaInformatico") SIZE 590, 160
   SistemaInfoControls(db, oDlg)

   @ 10, 625 GROUPBOX L("UtilidadesIdioma") SIZE 590, 30
   @ 30, 635 SAY L("UtilidadesIdiomaLabel") SIZE 60, 22
   IdiomaControls(db, oDlg)

   @ 520, 638 BUTTON L("CommonCerrar") SIZE 90, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION EmpresaControls(db, oDlg)
   LOCAL cNif, cNombre, cDireccion, cPoblacion, cProvincia, cCp, cTelefono, cEmail

   cNif := ObtenerConfiguracionStr(db, "Empresa.Nif")
   cNombre := ObtenerConfiguracionStr(db, "Empresa.Nombre")
   cDireccion := ObtenerConfiguracionStr(db, "Empresa.Direccion")
   cPoblacion := ObtenerConfiguracionStr(db, "Empresa.Poblacion")
   cProvincia := ObtenerConfiguracionStr(db, "Empresa.Provincia")
   cCp := ObtenerConfiguracionStr(db, "Empresa.CodigoPostal")
   cTelefono := ObtenerConfiguracionStr(db, "Empresa.Telefono")
   cEmail := ObtenerConfiguracionStr(db, "Empresa.Email")

   @ 30, 40 SAY L("EmpresaNifLabel") SIZE 80, 22 OF oDlg
   @ 120, 38 GET cNif SIZE 150, 26 OF oDlg

   @ 30, 72 SAY L("EmpresaRazonSocialLabel") SIZE 80, 22 OF oDlg
   @ 120, 70 GET cNombre SIZE 300, 26 OF oDlg

   @ 30, 104 SAY L("EmpresaDireccionLabel") SIZE 80, 22 OF oDlg
   @ 120, 102 GET cDireccion SIZE 300, 26 OF oDlg

   @ 30, 136 SAY L("EmpresaPoblacion") SIZE 80, 22 OF oDlg
   @ 120, 134 GET cPoblacion SIZE 150, 26 OF oDlg
   @ 280, 136 SAY L("EmpresaProvincia") SIZE 80, 22 OF oDlg
   @ 350, 134 GET cProvincia SIZE 120, 26 OF oDlg

   @ 30, 168 SAY L("EmpresaCp") SIZE 80, 22 OF oDlg
   @ 120, 166 GET cCp SIZE 100, 26 OF oDlg
   @ 280, 168 SAY L("EmpresaTelefonoLabel") SIZE 60, 22 OF oDlg
   @ 350, 166 GET cTelefono SIZE 120, 26 OF oDlg

   @ 30, 195 SAY L("EmpresaEmailLabel") SIZE 80, 22 OF oDlg
   @ 120, 193 GET cEmail SIZE 250, 26 OF oDlg

   @ 420, 193 BUTTON L("CommonGuardar") SIZE 90, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "Empresa.Nif", AllTrim(cNif)), ;
      EstablecerConfiguracion(db, "Empresa.Nombre", AllTrim(cNombre)), ;
      EstablecerConfiguracion(db, "Empresa.Direccion", AllTrim(cDireccion)), ;
      EstablecerConfiguracion(db, "Empresa.Poblacion", AllTrim(cPoblacion)), ;
      EstablecerConfiguracion(db, "Empresa.Provincia", AllTrim(cProvincia)), ;
      EstablecerConfiguracion(db, "Empresa.CodigoPostal", AllTrim(cCp)), ;
      EstablecerConfiguracion(db, "Empresa.Telefono", AllTrim(cTelefono)), ;
      EstablecerConfiguracion(db, "Empresa.Email", AllTrim(cEmail)), ;
      hwg_MsgInfo(L("CommonGuardado"), L("EmpresaDatosEmisor")) }
RETURN NIL

STATIC FUNCTION VerifactuControls(db, oDlg)
   LOCAL cAmbiente, nAmbiente, cIrpf

   cAmbiente := ObtenerConfiguracionStr(db, "VeriFactu.Ambiente")
   nAmbiente := Val(cAmbiente)
   IF nAmbiente < 1 .OR. nAmbiente > 2
      nAmbiente := 1
   ENDIF

   cIrpf := ObtenerConfiguracionStr(db, "IRPF.Porcentaje")
   IF Empty(cIrpf); cIrpf := "15.00"; ENDIF

   @ 30, 258 SAY L("EmpresaEntornoAeat") SIZE 100, 22 OF oDlg
   @ 140, 256 GET COMBOBOX nAmbiente ITEMS {"Producción", "Pruebas"} SIZE 130, 200 OF oDlg

   @ 300, 258 SAY L("EmpresaRetencionIrpf") SIZE 110, 22 OF oDlg
   @ 420, 256 GET cIrpf SIZE 80, 26 PICTURE "99.99" OF oDlg

   @ 420, 293 BUTTON L("CommonGuardar") SIZE 90, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "VeriFactu.Ambiente", hb_ntos(nAmbiente)), ;
      EstablecerConfiguracion(db, "IRPF.Porcentaje", AllTrim(cIrpf)), ;
      hwg_MsgInfo(L("CommonGuardado"), L("EmpresaConfigVerifactu")) }
RETURN NIL

STATIC FUNCTION CertificadoControls(db, oDlg)
   LOCAL cRuta, cPass

   cRuta := ObtenerConfiguracionStr(db, "VeriFactu.CertificadoRuta")
   cPass := ObtenerConfiguracionStr(db, "VeriFactu.CertificadoPassword")

   @ 30, 373 SAY L("EmpresaArchivoPfx") SIZE 130, 22 OF oDlg
   @ 170, 371 GET cRuta SIZE 300, 26 OF oDlg

   @ 30, 403 SAY L("EmpresaContrasena") SIZE 100, 22 OF oDlg
   @ 140, 401 GET cPass SIZE 150, 26 OF oDlg

   @ 420, 401 BUTTON L("CommonGuardar") SIZE 100, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "VeriFactu.CertificadoRuta", AllTrim(cRuta)), ;
      EstablecerConfiguracion(db, "VeriFactu.CertificadoPassword", AllTrim(cPass)), ;
      hwg_MsgInfo(L("CommonGuardado"), L("EmpresaCertificadoDigital")) }
RETURN NIL

STATIC FUNCTION SistemaInfoControls(db, oDlg)
   LOCAL cNomSis, cIdSis, cVerSif, cNumInst, cSoloVf, cMultiOt, cMultiplesOt

   cNomSis := ObtenerConfiguracionStr(db, "VeriFactu.NombreSoftware")
   cIdSis := ObtenerConfiguracionStr(db, "VeriFactu.IdEmisor")
   cVerSif := ObtenerConfiguracionStr(db, "VeriFactu.VersionSoftware")
   cNumInst := ObtenerConfiguracionStr(db, "VeriFactu.NumeroInstalacion")
   cSoloVf := ObtenerConfiguracionStr(db, "VeriFactu.SoloVerifactu")
   cMultiOt := ObtenerConfiguracionStr(db, "VeriFactu.MultiOTPosible")
   cMultiplesOt := ObtenerConfiguracionStr(db, "VeriFactu.IndicadorMultiplesOT")

   IF Empty(cNumInst); cNumInst := "1"; ENDIF
   IF Empty(cSoloVf); cSoloVf := "S"; ENDIF
   IF Empty(cMultiOt); cMultiOt := "N"; ENDIF
   IF Empty(cMultiplesOt); cMultiplesOt := "N"; ENDIF

   @ 30, 478 SAY L("EmpresaNombreSistema") SIZE 110, 22 OF oDlg
   @ 150, 476 GET cNomSis SIZE 200, 26 OF oDlg

   @ 30, 508 SAY L("EmpresaIdSistema") SIZE 80, 22 OF oDlg
   @ 120, 506 GET cIdSis SIZE 80, 26 OF oDlg
   @ 220, 508 SAY L("EmpresaVersionSIF") SIZE 80, 22 OF oDlg
   @ 300, 506 GET cVerSif SIZE 100, 26 OF oDlg
   @ 420, 508 SAY L("EmpresaNumInstalacion") SIZE 100, 22 OF oDlg
   @ 530, 506 GET cNumInst SIZE 50, 26 OF oDlg

   @ 30, 538 SAY L("EmpresaSoloVerifactu") SIZE 140, 22 OF oDlg
   @ 180, 536 GET cSoloVf SIZE 40, 26 OF oDlg
   @ 240, 538 SAY L("EmpresaMultiOt") SIZE 130, 22 OF oDlg
   @ 380, 536 GET cMultiOt SIZE 40, 26 OF oDlg

   @ 30, 568 SAY L("EmpresaMultiplesOt") SIZE 130, 22 OF oDlg
   @ 170, 566 GET cMultiplesOt SIZE 40, 26 OF oDlg

   @ 420, 566 BUTTON L("CommonGuardar") SIZE 90, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "VeriFactu.NombreSoftware", AllTrim(cNomSis)), ;
      EstablecerConfiguracion(db, "VeriFactu.IdEmisor", AllTrim(cIdSis)), ;
      EstablecerConfiguracion(db, "VeriFactu.VersionSoftware", AllTrim(cVerSif)), ;
      EstablecerConfiguracion(db, "VeriFactu.NumeroInstalacion", AllTrim(cNumInst)), ;
      EstablecerConfiguracion(db, "VeriFactu.SoloVerifactu", AllTrim(cSoloVf)), ;
      EstablecerConfiguracion(db, "VeriFactu.MultiOTPosible", AllTrim(cMultiOt)), ;
      EstablecerConfiguracion(db, "VeriFactu.IndicadorMultiplesOT", AllTrim(cMultiplesOt)), ;
      hwg_MsgInfo(L("CommonGuardado"), L("EmpresaSistemaInformatico")) }
RETURN NIL

STATIC FUNCTION IdiomaControls(db, oDlg)
   LOCAL aIdiomas := {L("LangEspanol"), L("LangEnglish"), L("LangFrancais"), L("LangCatalan"), L("LangEuskera")}
   LOCAL nIdx := 1, cIdioma, oCb

   cIdioma := ObtenerConfiguracionStr(db, "Language")
   SWITCH cIdioma
   CASE "en"; nIdx := 2; EXIT
   CASE "fr"; nIdx := 3; EXIT
   CASE "ca"; nIdx := 4; EXIT
   CASE "eu"; nIdx := 5; EXIT
   ENDSWITCH

   @ 100, 633 GET COMBOBOX oCb VAR nIdx ITEMS aIdiomas SIZE 120, 200 OF oDlg
   @ 230, 633 BUTTON "Aplicar" SIZE 60, 22 OF oDlg ON CLICK {|| ;
      LocalCambiarIdioma(db, nIdx), ;
      hwg_MsgInfo(L("UtilidadesIdiomaInstante"), L("UtilidadesIdioma")) }
RETURN NIL

STATIC FUNCTION LocalCambiarIdioma(db, nIdx)
   LOCAL cCode
   SWITCH nIdx
   CASE 1; cCode := "es"; EXIT
   CASE 2; cCode := "en"; EXIT
   CASE 3; cCode := "fr"; EXIT
   CASE 4; cCode := "ca"; EXIT
   CASE 5; cCode := "eu"; EXIT
   ENDSWITCH
   EstablecerConfiguracion(db, "Language", cCode)
   LocalizationSetLang(cCode)
RETURN NIL
