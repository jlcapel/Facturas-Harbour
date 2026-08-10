# heredado-00 — Estado inicial del proyecto (INVENTARIO REAL, verificado)

## Proyecto
- App facturación VERI*FACTU en Harbour + HWGUI (GTK3 en Linux, WinAPI en Windows).
- BD: `~/Facturas/facturas.db` (SQLite, 15 tablas + seed). Ya funciona.
- Compilación: `cd /home/jose/programacion/Facturas-Harbour && ./build.sh` → `OK: ./Facturas` (Linux) / `./build.sh win` → `Facturas.exe`. NO ejecutar binarios con GUI en este entorno headless.

## Estructura clave (ya revisada)
- `src/main.prg`: ventana principal 860x540 `WS_DLGFRAME+WS_SYSMENU+DS_CENTER`, menú superior con `L()` (AHORA ROTO porque faltan claves Menu*), título bienvenida hardcodeada, statusbar declarada pero vacía.
- `src/services/LocalizationService.prg`: `LocalizationNew()`, `L(cKey)`, `LocalizationSetLang()`. Idiomas: es/en/fr/ca/eu. Fallback español.
- `src/i18n/strings_{es,en,fr,ca,eu}.prg`: hash `h[...]`.
  - `strings_es.prg` tiene 750 claves; `en/fr/ca/eu` tiene 715 c/u (faltan 36: `ValidationVatFmtAT..SK`, `ValidationVatPrefijoNoReconocido`, `CommonConfigurar`, `CommonConsultar`, `CommonGestionar`, `CommonListado`, `CommonNuevo2`, `CommonXML`, `CommonNueva`, `GastoCsvHeader`).
  - NO existen las claves `Menu*` usadas por main.prg: `MenuMaestros MenuPaises MenuTiposIva MenuTiposIdent MenuClientes MenuArticulos MenuProveedores MenuCategoriasGasto MenuBienesInversion MenuEmpresa MenuConfiguracion MenuFacturas MenuListado MenuGastos MenuValidacion MenuNifAeat MenuVatVies MenuModelosAeat MenuExportar MenuRegistrosXml MenuEventosXml MenuGastosCsv` (22 claves). Actualmente el menú muestra `[[MenuPaises]]`.
- Vistas: `src/views/PaisesView.prg`, `TiposIvaView.prg`, `TiposIdentificacionView.prg`, `ClientesView.prg`, `ArticulosView.prg`, `ProveedoresView.prg`, `CategoriasGastoView.prg`, `BienesInversionView.prg`, `FacturasView.prg`, `FacturaEditView.prg`, `GastosView.prg`, `GastoEditView.prg`, `EmpresaView.prg`, `ModelosAeatView.prg`, `ValidacionView.prg`, `ViesView.prg`. Todas reciben `(db, oParent, nX, nY, nW, nH)` salvo EmpresaView (modal) y los edit (modales).

## PROBLEMAS i18n en vistas (se resuelven en fases 3-6)
- Strings hardcoded en español en todas las vistas: botones `"Nueva"`, `"PDF"`, `"Aplicar"`, `"Abrir Carpeta"`, `"Verificar Cadena"`, títulos `TITLE "Nuevo país"` etc., `hwg_MsgInfo("Seleccione un país","Aviso")`, etc.
- Estimación: ~130 strings sin localizar repartidos por las 16 vistas (contados en fase 1 preliminar).

## Nota sobre idioma
- `EmpresaView` tiene selector de idioma en sección UtilidadesIdioma (combo → `EstablecerConfiguracion(db,"Language", cCode)`), persiste en BD. La app lee "Language" en `main.prg` y llama `LocalizationSetLang`.

## Orientación para CODE:
- No ejecutar aplicaciones que abran ventanas (headless). Compilar y verificar con grep/helpers.
- Para validar i18n al final, usar script grep `L("...")` y comparar con claves definidas (fase 1 provee herramienta de comprobación básica).