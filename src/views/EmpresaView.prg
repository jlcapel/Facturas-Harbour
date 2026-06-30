#include "hwgui.ch"

FUNCTION EmpresaView(db)
   LOCAL oDlg

   INIT DIALOG oDlg ;
      TITLE L("EmpresaConfigVerifactu") ;
      AT 0, 0 ;
      SIZE 620, 630 ;
      STYLE WS_POPUP + WS_CAPTION + WS_SYSMENU + WS_SIZEBOX + DS_CENTER

   @ 10, 10 GROUPBOX L("EmpresaTitle")
   EmpresaControls(db, oDlg)

   @ 10, 230 GROUPBOX "Veri*Factu"
   VerifactuControls(db, oDlg)

   @ 10, 405 GROUPBOX "Certificado AEAT"
   CertificadoControls(db, oDlg)

   @ 10, 475 GROUPBOX "IVA por defecto"
   IvaControls(db, oDlg)

   @ 320, 475 GROUPBOX "IRPF"
   IrpfControls(db, oDlg)

   @ 10, 540 GROUPBOX L("UtilidadesIdioma")
   @ 30, 558 SAY L("UtilidadesIdiomaLabel") SIZE 60, 22
   IdiomaControls(db, oDlg)

   @ 230, 570 BUTTON L("CommonCerrar") SIZE 90, 28 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER
RETURN NIL

STATIC FUNCTION EmpresaControls(db, oDlg)
   LOCAL cNif, cNombre, cDireccion, cPoblacion, cProvincia, cCp, cTelefono, cEmail, cWeb

   cNif := ObtenerConfiguracion(db, "Empresa.Nif")
   cNombre := ObtenerConfiguracion(db, "Empresa.Nombre")
   cDireccion := ObtenerConfiguracion(db, "Empresa.Direccion")
   cPoblacion := ObtenerConfiguracion(db, "Empresa.Poblacion")
   cProvincia := ObtenerConfiguracion(db, "Empresa.Provincia")
   cCp := ObtenerConfiguracion(db, "Empresa.CodigoPostal")
   cTelefono := ObtenerConfiguracion(db, "Empresa.Telefono")
   cEmail := ObtenerConfiguracion(db, "Empresa.Email")
   cWeb := ObtenerConfiguracion(db, "Empresa.Web")

   @ 30, 40 SAY "NIF:" SIZE 80, 22 OF oDlg
   @ 120, 38 GET cNif SIZE 150, 26 OF oDlg
   @ 30, 70 SAY L("BienesNombreLabel") SIZE 80, 22 OF oDlg
   @ 120, 68 GET cNombre SIZE 300, 26 OF oDlg
   @ 30, 100 SAY L("ClientesDireccion") SIZE 80, 22 OF oDlg
   @ 120, 98 GET cDireccion SIZE 300, 26 OF oDlg
   @ 30, 130 SAY L("ClientesPoblacionLabel") SIZE 80, 22 OF oDlg
   @ 120, 128 GET cPoblacion SIZE 150, 26 OF oDlg
   @ 290, 130 SAY L("ClientesProvincia") SIZE 80, 22 OF oDlg
   @ 370, 128 GET cProvincia SIZE 120, 26 OF oDlg
   @ 30, 160 SAY "C.Postal:" SIZE 80, 22 OF oDlg
   @ 120, 158 GET cCp SIZE 100, 26 OF oDlg
   @ 290, 160 SAY L("ClientesTelefonoLabel") SIZE 80, 22 OF oDlg
   @ 370, 158 GET cTelefono SIZE 120, 26 OF oDlg
   @ 30, 190 SAY L("ClientesEmailLabel") SIZE 80, 22 OF oDlg
   @ 120, 188 GET cEmail SIZE 200, 26 OF oDlg

   @ 400, 195 BUTTON "Guardar Empresa" SIZE 110, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "Empresa.Nif", AllTrim(cNif)), ;
      EstablecerConfiguracion(db, "Empresa.Nombre", AllTrim(cNombre)), ;
      EstablecerConfiguracion(db, "Empresa.Direccion", AllTrim(cDireccion)), ;
      EstablecerConfiguracion(db, "Empresa.Poblacion", AllTrim(cPoblacion)), ;
      EstablecerConfiguracion(db, "Empresa.Provincia", AllTrim(cProvincia)), ;
      EstablecerConfiguracion(db, "Empresa.CodigoPostal", AllTrim(cCp)), ;
      EstablecerConfiguracion(db, "Empresa.Telefono", AllTrim(cTelefono)), ;
      EstablecerConfiguracion(db, "Empresa.Email", AllTrim(cEmail)), ;
      EstablecerConfiguracion(db, "Empresa.Web", AllTrim(cWeb)), ;
      hwg_MsgInfo("Datos de empresa guardados", "Información") }
RETURN NIL

STATIC FUNCTION VerifactuControls(db, oDlg)
   LOCAL cNif, cIdEmisor, cSoftware, cVersion
   LOCAL cAmbiente, nAmbiente

   cNif := ObtenerConfiguracion(db, "VeriFactu.Nif")
   cIdEmisor := ObtenerConfiguracion(db, "VeriFactu.IdEmisor")
   cSoftware := ObtenerConfiguracion(db, "VeriFactu.NombreSoftware")
   cVersion := ObtenerConfiguracion(db, "VeriFactu.VersionSoftware")
   cAmbiente := ObtenerConfiguracion(db, "VeriFactu.Ambiente")
   nAmbiente := Val(cAmbiente)
   IF nAmbiente < 1 .OR. nAmbiente > 2
      nAmbiente := 1
   ENDIF

   @ 30, 260 SAY "NIF Emisor:" SIZE 100, 22 OF oDlg
   @ 140, 258 GET cNif SIZE 150, 26 OF oDlg
   @ 30, 290 SAY "ID Emisor:" SIZE 100, 22 OF oDlg
   @ 140, 288 GET cIdEmisor SIZE 150, 26 OF oDlg
   @ 30, 320 SAY "Software:" SIZE 100, 22 OF oDlg
   @ 140, 318 GET cSoftware SIZE 200, 26 OF oDlg
   @ 30, 350 SAY "Versión:" SIZE 100, 22 OF oDlg
   @ 140, 348 GET cVersion SIZE 100, 26 OF oDlg

   @ 30, 375 SAY "Entorno:" SIZE 100, 22 OF oDlg
   @ 140, 373 COMBOBOX nAmbiente ITEMS {"Producción", "Pruebas"} SIZE 120, 200 OF oDlg

   @ 400, 375 BUTTON "Guardar Veri*Factu" SIZE 110, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "VeriFactu.Nif", AllTrim(cNif)), ;
      EstablecerConfiguracion(db, "VeriFactu.IdEmisor", AllTrim(cIdEmisor)), ;
      EstablecerConfiguracion(db, "VeriFactu.NombreSoftware", AllTrim(cSoftware)), ;
      EstablecerConfiguracion(db, "VeriFactu.VersionSoftware", AllTrim(cVersion)), ;
      EstablecerConfiguracion(db, "VeriFactu.Ambiente", hb_ntos(nAmbiente)), ;
      hwg_MsgInfo("Datos VERI*FACTU guardados", "Información") }
RETURN NIL

STATIC FUNCTION CertificadoControls(db, oDlg)
   LOCAL cRuta, cPass

   cRuta := ObtenerConfiguracion(db, "VeriFactu.CertificadoRuta")
   cPass := ObtenerConfiguracion(db, "VeriFactu.CertificadoPassword")

   @ 30, 430 SAY "Certificado PKCS#12:" SIZE 130, 22 OF oDlg
   @ 170, 428 GET cRuta SIZE 300, 26 OF oDlg
   @ 30, 460 SAY L("EmpresaContrasena") SIZE 100, 22 OF oDlg
   @ 140, 458 GET cPass SIZE 150, 26 OF oDlg
   @ 400, 460 BUTTON "Guardar Certificado" SIZE 120, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "VeriFactu.CertificadoRuta", AllTrim(cRuta)), ;
      EstablecerConfiguracion(db, "VeriFactu.CertificadoPassword", AllTrim(cPass)), ;
      hwg_MsgInfo("Certificado guardado", "Información") }
RETURN NIL

STATIC FUNCTION IvaControls(db, oDlg)
   LOCAL cGral, cRed, cSuper

   cGral := ObtenerConfiguracion(db, "IVA.General")
   cRed := ObtenerConfiguracion(db, "IVA.Reducido")
   cSuper := ObtenerConfiguracion(db, "IVA.Superreducido")
   IF Empty(cGral); cGral := "21.00"; ENDIF
   IF Empty(cRed); cRed := "10.00"; ENDIF
   IF Empty(cSuper); cSuper := "4.00"; ENDIF

   @ 30, 430 SAY "% General:" SIZE 80, 22 OF oDlg
   @ 120, 428 GET cGral SIZE 80, 26 PICTURE "99.99" OF oDlg
   @ 30, 460 SAY "% Reducido:" SIZE 80, 22 OF oDlg
   @ 120, 458 GET cRed SIZE 80, 26 PICTURE "99.99" OF oDlg
   @ 30, 490 SAY "% Superred.:" SIZE 80, 22 OF oDlg
   @ 120, 488 GET cSuper SIZE 80, 26 PICTURE "99.99" OF oDlg

   @ 20, 490 BUTTON "Guardar IVA" SIZE 90, 22 OF oDlg ON CLICK {;
      EstablecerConfiguracion(db, "IVA.General", AllTrim(cGral)), ;
      EstablecerConfiguracion(db, "IVA.Reducido", AllTrim(cRed)), ;
      EstablecerConfiguracion(db, "IVA.Superreducido", AllTrim(cSuper)), ;
      hwg_MsgInfo("IVA guardado", "Información") }
RETURN NIL

STATIC FUNCTION IrpfControls(db, oDlg)
   LOCAL cIrpf

   cIrpf := ObtenerConfiguracion(db, "IRPF.Porcentaje")
   IF Empty(cIrpf); cIrpf := "15.00"; ENDIF

   @ 300, 430 SAY "% Retención IRPF:" SIZE 110, 22 OF oDlg
   @ 420, 428 GET cIrpf SIZE 80, 26 PICTURE "99.99" OF oDlg

   @ 300, 460 SAY "Se aplica sobre" SIZE 110, 22 OF oDlg
   @ 300, 480 SAY "la base imponible." SIZE 110, 22 OF oDlg

    @ 400, 480 BUTTON "Guardar IRPF" SIZE 90, 22 OF oDlg ON CLICK {;
       EstablecerConfiguracion(db, "IRPF.Porcentaje", AllTrim(cIrpf)), ;
       hwg_MsgInfo("IRPF guardado", "Información") }
RETURN NIL

STATIC FUNCTION IdiomaControls(db, oDlg)
   LOCAL aIdiomas := {L("LangEspanol"), L("LangEnglish"), L("LangFrancais"), L("LangCatalan"), L("LangEuskera")}
   LOCAL nIdx := 1, cIdioma, oCb

   cIdioma := ObtenerConfiguracion(db, "Language")
   SWITCH cIdioma
   CASE "en"; nIdx := 2; EXIT
   CASE "fr"; nIdx := 3; EXIT
   CASE "ca"; nIdx := 4; EXIT
   CASE "eu"; nIdx := 5; EXIT
   ENDSWITCH

   @ 90, 555 COMBOBOX oCb ITEMS aIdiomas SIZE 120, 200 OF oDlg
   oCb:value := nIdx
   @ 220, 555 BUTTON "Aplicar" SIZE 60, 22 OF oDlg ON CLICK {|| ;
      nIdx := oCb:value, ;
      LocalCambiarIdioma(db, nIdx), ;
      hwg_MsgInfo("Idioma cambiado. Reinicie la aplicación para ver los cambios.", "Idioma") }
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
