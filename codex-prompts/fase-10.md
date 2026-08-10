# FASE 10 — Unificar botones, alturas y paddings en todas las vistas

Lee antes: `reglas-base.md`, `heredado-09.md`.

## OBJETIVO
Consistencia visual de controles en las 16 vistas listadas a continuación:

1. estandarizar ALTURA DE BOTONES → 28 en toda la app (donde ahora haya 22, 24, 30, 36...).
2. estandarizar `aPadding`/`aHeadPadding` de los BROWSE (donde existan): `oBrw:aHeadPadding[4] := 10` suele estar; añadir el mismo bloque en todos los browses que no lo tengan.
3. estandarizar X inicial de botones inferiores a `nX + 30` (donde hoy haya otro valor), y distancia entre botones a 80 (misma plantilla que `PaisesView.prg`).
4. estandarizar Y de fila de botones a `nY + nH - 55`.

## VISTAS
- PaisesView (ya ok (patrón); copiar si difiere), TiposIvaView, TiposIdentificacionView, ClientesView, ArticulosView, ProveedoresView, BienesInversionView, CategoriasGastoView, FacturasView, GastosView, ValidacionView, ViesView, ModelosAeatView (aquí mantener su grid, solo alturas), y diálogos modales FacturaEditView, GastoEditView, EmpresaView (botones se tratan en fases 11-12 si cambia el layout; aquí solo alturas de botones existentes).

## REGLAS
- NO cambiar posiciones X/Y si el control queda fuera de rango (no lo desborden): si el botón se sale del panel, ajusta a `nW - nX - 70` como máximo.
- NO tocar coordenadas de formularios (lo hace otra fase).
- Solo: alturas, paddings de browse, y el patrón X/Y de botones inferiores SIEMPRE que no haya colisión.
- Documenta exactamente qué `SIZE n, h` de botones cambiaste.

## VALIDACIÓN
- `./build.sh` OK.
- `grep -nE "BUTTON .*SIZE [0-9]+(, (24|26|30|36|40))" src/views/*.prg` → 0 (excluye botones de EmpresaView si no aplicable; en ese caso indica excepción y por qué).

## SALIDA
`heredado-10.md`: tabla por vista con: patrón aplicado, excepciones, nº de botones retocados, verificación del grep del paso anterior.