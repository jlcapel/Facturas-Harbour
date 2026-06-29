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

PROCEDURE Main()
   LOCAL oDlg
   LOCAL db

   InicializarBaseDatos()

   db := AbrirBaseDatos()

   INIT DIALOG oDlg ;
      TITLE "Facturas-Harbour" ;
      AT 0, 0 ;
      SIZE 800, 500 ;
      STYLE WS_DLGFRAME + WS_SYSMENU + DS_CENTER

   MENU OF oDlg
      MENU TITLE "Maestros"
         MENUITEM "Países" ACTION {|| PaisesView(db)}
         MENUITEM "Tipos de IVA" ACTION {|| TiposIvaView(db)}
         MENUITEM "Tipos de Identificación" ACTION {|| TiposIdentificacionView(db)}
         SEPARATOR
         MENUITEM "Clientes" ACTION {|| ClientesView(db)}
         MENUITEM "Artículos" ACTION {|| ArticulosView(db)}
      ENDMENU
      MENU TITLE "Empresa"
         MENUITEM "Configuración" ACTION {|| EmpresaView(db)}
      ENDMENU
      MENU TITLE "Facturas"
         MENUITEM "Listado" ACTION {|| FacturasView(db)}
      ENDMENU
   ENDMENU

   @ 20, 20 SAY "Facturas-Harbour — App de facturación VERI*FACTU" SIZE 400, 22
   @ 20, 50 SAY "Seleccione una opción del menú" SIZE 300, 22
   @ 20, 400 BUTTON "Salir" SIZE 80, 30 ON CLICK {|| oDlg:Close()}

   ACTIVATE DIALOG oDlg CENTER

   db := NIL
RETURN

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
