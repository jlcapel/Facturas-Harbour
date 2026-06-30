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
   LOCAL oDlg, oPanel
   LOCAL db, cLang
   LOCAL oFontTitle, oFontSub, oFontBtn, oFontBtnDesc

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

   PREPARE FONT oFontTitle NAME "Arial" WIDTH 0 HEIGHT -24 WEIGHT 700
   PREPARE FONT oFontSub NAME "Arial" WIDTH 0 HEIGHT -12 WEIGHT 400
   PREPARE FONT oFontBtn NAME "Arial" WIDTH 0 HEIGHT -14 WEIGHT 700
   PREPARE FONT oFontBtnDesc NAME "Arial" WIDTH 0 HEIGHT -10 WEIGHT 400

   INIT DIALOG oDlg ;
      TITLE L("AppTitle") ;
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

   @ 0, 0 SAY "" SIZE 1024, 80 BACKCOLOR hwg_ColorRGB2N(27, 79, 114) ;
      COLOR hwg_ColorRGB2N(255, 255, 255) FONT oFontTitle

   @ 20, 15 SAY L("AppTitle") SIZE 600, 30 ;
      COLOR hwg_ColorRGB2N(255, 255, 255) FONT oFontTitle BACKCOLOR hwg_ColorRGB2N(27, 79, 114) TRANSPARENT

   @ 20, 50 SAY L("AppSubtitle") SIZE 600, 20 ;
      COLOR hwg_ColorRGB2N(189, 210, 224) FONT oFontSub BACKCOLOR hwg_ColorRGB2N(27, 79, 114) TRANSPARENT

   @ 20, 95 SAY L("DashboardTitle") SIZE 400, 24 FONT oFontBtn

   DashboardButton(oDlg, 20, 130, L("DashClientes"), L("DashClientesDesc"), {|db| ClientesView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 260, 130, L("DashArticulos"), L("DashArticulosDesc"), {|db| ArticulosView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 500, 130, L("DashFacturas"), L("DashFacturasDesc"), {|db| FacturasView(db)}, db, oFontBtn, oFontBtnDesc)

   DashboardButton(oDlg, 20, 260, L("DashProveedores"), L("DashProveedoresDesc"), {|db| ProveedoresView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 260, 260, L("DashGastos"), L("DashGastosDesc"), {|db| GastosView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 500, 260, L("DashModelos"), L("DashModelosDesc"), {|db| ModelosAeatView(db)}, db, oFontBtn, oFontBtnDesc)

   DashboardButton(oDlg, 20, 390, L("DashEmpresa"), L("DashEmpresaDesc"), {|db| EmpresaView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 260, 390, L("DashValidacion"), L("DashValidacionDesc"), {|db| ValidacionView(db)}, db, oFontBtn, oFontBtnDesc)
   DashboardButton(oDlg, 500, 390, L("DashExportar"), L("DashExportarDesc"), {|db| ExportarRegAeat(db)}, db, oFontBtn, oFontBtnDesc)

   @ 20, 530 SAY L("AppVersion") SIZE 300, 20 ;
      COLOR hwg_ColorRGB2N(127, 140, 141) FONT oFontSub

   @ 880, 660 BUTTON L("DashSalir") SIZE 100, 30 ON CLICK {|| oDlg:Close()}

   ADD STATUS TO oDlg PARTS 400, 300

   ACTIVATE DIALOG oDlg CENTER

   db := NIL
RETURN

STATIC FUNCTION DashboardButton(oDlg, nX, nY, cTitle, cDesc, bAction, db, oFontTitle, oFontDesc)
   LOCAL oBtn
   @ nX, nY OWNERBUTTON oBtn ;
      SIZE 220, 100 ;
      TEXT cTitle ;
      COLOR hwg_ColorRGB2N(255, 255, 255) ;
      FONT oFontTitle ;
      BACKCOLOR hwg_ColorRGB2N(41, 128, 185) ;
      ON CLICK Eval(bAction, db) ;
      TOOLTIP cDesc

   @ nX, nY + 60 SAY cDesc SIZE 220, 20 ;
      COLOR hwg_ColorRGB2N(127, 140, 141) FONT oFontDesc TRANSPARENT

RETURN NIL

FUNCTION ObtenerTextoInfo(db)
   RETURN "BD: " + ObtenerDbPath() + ";" + ;
      "Paises: " + hb_ntos(ContarTabla(db, "Paises")) + ";" + ;
      "IVA: " + hb_ntos(ContarTabla(db, "TiposIva")) + ";" + ;
      "Identif: " + hb_ntos(ContarTabla(db, "TiposIdentificacion")) + ";" + ;
      "Config: " + hb_ntos(ContarTabla(db, "Configuracion")) + ";" + ;
      "Gastos: " + hb_ntos(ContarTabla(db, "CategoriasGasto"))

STATIC FUNCTION ContarTabla(db, cTabla)
   LOCAL stmt, nCount
   stmt := sqlite3_prepare(db, "SELECT COUNT(*) FROM " + cTabla)
   nCount := 0
   IF !Empty(stmt) .AND. sqlite3_step(stmt) == SQLITE_ROW
      nCount := sqlite3_column_int(stmt, 0)
   ENDIF
   sqlite3_finalize(stmt)
   RETURN nCount

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
