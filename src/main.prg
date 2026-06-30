/*
 * Facturas-Harbour — App de facturación VERI*FACTU (España)
 * Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 *
 * ---
 * Commercial license available for proprietary use.
 * Contact: jlcapel@hotmail.com
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "hwgui.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL oDlg
   LOCAL db, cLang
   LOCAL oFntTitle, oFntSub, oFntSec, oFntBtn, oFntBtnDesc

   InicializarBaseDatos()
   db := AbrirBaseDatos()

   IF !EnsureDbReady()
      LogInfo("Main: no se pudo asegurar integridad BD")
   ENDIF
   HacerBackup()
   LocalizationNew()
   cLang := ObtenerConfiguracion(db, "Language")
   IF cLang != NIL
      LocalizationSetLang(cLang)
   ENDIF

   PREPARE FONT oFntTitle NAME "Arial" WIDTH 0 HEIGHT -28 WEIGHT 700
   PREPARE FONT oFntSub NAME "Arial" WIDTH 0 HEIGHT -11 WEIGHT 400
   PREPARE FONT oFntSec NAME "Arial" WIDTH 0 HEIGHT -12 WEIGHT 700
   PREPARE FONT oFntBtn NAME "Arial" WIDTH 0 HEIGHT -10 WEIGHT 700
   PREPARE FONT oFntBtnDesc NAME "Arial" WIDTH 0 HEIGHT -9 WEIGHT 400

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE 1024, 700 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   MENU OF oDlg
      MENU TITLE L("MenuMaestros")
         MENUITEM L("MenuPaises") ACTION {|| PaisesView(db)}
         MENUITEM L("MenuTiposIva") ACTION {|| TiposIvaView(db)}
         MENUITEM L("MenuTiposIdent") ACTION {|| TiposIdentificacionView(db)}
         SEPARATOR
         MENUITEM L("MenuClientes") ACTION {|| ClientesView(db)}
         MENUITEM L("MenuArticulos") ACTION {|| ArticulosView(db)}
         SEPARATOR
         MENUITEM L("MenuProveedores") ACTION {|| ProveedoresView(db)}
         MENUITEM L("MenuCategoriasGasto") ACTION {|| CategoriasGastoView(db)}
         MENUITEM L("MenuBienesInversion") ACTION {|| BienesInversionView(db)}
      ENDMENU
      MENU TITLE L("MenuEmpresa")
         MENUITEM L("MenuConfiguracion") ACTION {|| EmpresaView(db)}
      ENDMENU
      MENU TITLE L("MenuFacturas")
         MENUITEM L("MenuListado") ACTION {|| FacturasView(db)}
      ENDMENU
      MENU TITLE L("MenuGastos")
         MENUITEM L("MenuListado") ACTION {|| GastosView(db)}
      ENDMENU
      MENU TITLE L("MenuValidacion")
         MENUITEM L("MenuNifAeat") ACTION {|| ValidacionView(db)}
         SEPARATOR
         MENUITEM L("MenuVatVies") ACTION {|| ViesView(db)}
      ENDMENU
      MENU TITLE "AEAT"
         MENUITEM L("MenuModelosAeat") ACTION {|| ModelosAeatView(db)}
      ENDMENU
      MENU TITLE L("MenuExportar")
         MENUITEM L("MenuRegistrosXml") ACTION {|| ExportarRegAeat(db)}
         MENUITEM L("MenuEventosXml") ACTION {|| ExportarEventosXml(db)}
         SEPARATOR
         MENUITEM L("MenuGastosCsv") ACTION {|| ExportarGastosCsv(db)}
      ENDMENU
   ENDMENU

   @ 0, 0 SAY "" SIZE 1024, 80 BACKCOLOR hwg_ColorRGB2N(30, 60, 114)

   @ 20, 12 SAY L("AppTitle") SIZE 600, 34 ;
      COLOR hwg_ColorRGB2N(255, 255, 255) FONT oFntTitle TRANSPARENT

   @ 20, 52 SAY L("AppSubtitle") SIZE 600, 20 ;
      COLOR hwg_ColorRGB2N(189, 210, 224) FONT oFntSub TRANSPARENT

   @ 20, 96 SAY L("DashboardTitle") SIZE 400, 22 ;
      COLOR hwg_ColorRGB2N(52, 73, 94) FONT oFntSec

   @ 20, 115 LINE LENGTH 980

   @ 40, 125 SAY L("DashFacturas") SIZE 200, 20 ;
      COLOR hwg_ColorRGB2N(41, 128, 185) FONT oFntSec

   @ 40, 150 SAY L("DashClientesDesc") SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 148 BUTTON "Clientes" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ClientesView(db)}
   @ 360, 148 BUTTON "Artículos" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ArticulosView(db)}
   @ 460, 148 BUTTON "Facturas" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| FacturasView(db)}

   @ 40, 185 SAY L("DashArticulosDesc") SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 183 BUTTON "Países" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| PaisesView(db)}
   @ 360, 183 BUTTON "Tipos IVA" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| TiposIvaView(db)}
   @ 460, 183 BUTTON "Identif." SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| TiposIdentificacionView(db)}

   @ 20, 225 LINE LENGTH 980

   @ 40, 235 SAY L("DashGastosLabel") SIZE 200, 20 ;
      COLOR hwg_ColorRGB2N(39, 174, 96) FONT oFntSec

   @ 40, 260 SAY L("DashProveedoresDesc") SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 258 BUTTON "Proveedores" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ProveedoresView(db)}
   @ 360, 258 BUTTON "Categorías" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| CategoriasGastoView(db)}
   @ 460, 258 BUTTON "B. Inversión" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| BienesInversionView(db)}

   @ 40, 295 SAY L("DashGastosDesc") SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 293 BUTTON "Gastos" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| GastosView(db)}
   @ 360, 293 BUTTON "Modelos AEAT" SIZE 100, 24 FONT oFntBtn ;
      ON CLICK {|| ModelosAeatView(db)}

   @ 20, 335 LINE LENGTH 980

   @ 40, 345 SAY L("DashConfigLabel") SIZE 200, 20 ;
      COLOR hwg_ColorRGB2N(142, 68, 173) FONT oFntSec

   @ 40, 370 SAY L("DashEmpresaDesc") SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 368 BUTTON "Empresa" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| EmpresaView(db)}
   @ 360, 368 BUTTON "Validación" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ValidacionView(db)}
   @ 460, 368 BUTTON "VIES" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ViesView(db)}

   @ 40, 405 SAY "Exportación de datos" SIZE 200, 16 FONT oFntBtnDesc ;
      COLOR hwg_ColorRGB2N(127, 140, 141)
   @ 260, 403 BUTTON "XML AEAT" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ExportarRegAeat(db)}
   @ 360, 403 BUTTON "Eventos XML" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ExportarEventosXml(db)}
   @ 460, 403 BUTTON "Gastos CSV" SIZE 90, 24 FONT oFntBtn ;
      ON CLICK {|| ExportarGastosCsv(db)}

   @ 880, 660 BUTTON L("DashSalir") SIZE 100, 30 ON CLICK {|| oDlg:Close()}

   ADD STATUS TO oDlg PARTS 400, 300

   ACTIVATE DIALOG oDlg CENTER

   db := NIL
RETURN

FUNCTION ObtenerTextoInfo(db)
   RETURN "BD: " + ObtenerDbPath()
RETURN NIL

STATIC FUNCTION ExportarRegAeat(db)
   LOCAL cPath := GuardarXmlRegistros(db)
   hwg_MsgInfo("Registros AEAT exportados: " + cPath, "Exportación")
RETURN NIL

STATIC FUNCTION ExportarEventosXml(db)
   LOCAL cPath := GuardarXmlEventos(db)
   hwg_MsgInfo("Eventos exportados: " + cPath, "Exportación")
RETURN NIL

STATIC FUNCTION ExportarGastosCsv(db)
   LOCAL cYear := hwg_MsgGet("Año", "Introduzca año:", hb_ntos(Year(Date())))
   LOCAL nYear, cPath
   IF Empty(cYear); RETURN; ENDIF
   nYear := Val(cYear)
   IF nYear < 2000 .OR. nYear > 2100; hwg_MsgInfo("Año no válido", "Error"); RETURN; ENDIF
   cPath := GuardarCsvGastos(db, nYear)
   hwg_MsgInfo("Gastos exportados: " + cPath, "Exportación")
RETURN NIL
