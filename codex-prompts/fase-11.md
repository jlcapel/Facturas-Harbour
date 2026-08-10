# FASE 11 — C1: EmpresaView: un único botón Guardar + idioma limpio

Lee antes: `reglas-base.md`, `heredado-10.md`.

## CONTEXTO
EmpresaView (`src/views/EmpresaView.prg`) es un modal 640x670 con 4 secciones GROUPBOX, cada una con su propio botón "Guardar" (dónde se llama `EstablecerConfiguracion` 3-9 veces + MsgInfo). El usuario percibe esto como inconsistente.

## OBJETIVO (sin cambiar secciones ni disposición de campos)
1. Un único botón "Guardar" global al pie de la ventana, a la derecha (cerca del Cerrar), que persista TODAS las configuraciones de las 4 secciones (Datos Emisor, VERI*FACTU+IRPF, Certificado, Sistema Informático) de una sola vez.
2. Quitar los 4 botones individuales por sección.
3. El botón debe llamar a una sola función `GuardarTodoEmpresa(db, ...)` que guarde todas las claves en un solo `ON CLICK`.

## PASOS
1. Lee el fichero completo de EmpresaView (4 secciones × sus variables).
2. Reúne TODAS las variables (`cNif... cEmail`, `nAmbiente`, `cIrpf`, `cRuta`, cPass`, `cNomSis`... etc.) que viven en funciones divisor SPEC. Redime: los GET son locales a CADA función STATIC (`EmpresaControls`, etc.), por lo que GuardarTodo necesita acceso a las variables de los GET. Si es estructuralmente complejo (no tienes acceso), un diseño alternativo: por cada sección, mantener funciones `EmpresaControls()` etc. que devuelvan un hash `hValores`, y `EmpresaView()` lo agregue y enlace el Guardar único. Elige el camino más simple y robusto (concepto: recolectar valores).
3. Implementación recomendada (asumida):
   - Cada función sección `EmpresaXControls(db, oDlg, hData)`; añade al hash `hData["Nif"]`, etc.
   - `EmpresaView` crea `hData := {=>}`, llama a las 4, y el botón final:
     `EstablecerConfiguracion(...)` para cada clave, de los `hData`, luego `hwg_MsgInfo(L("CommonGuardado"), L("EmpresaDatosEmisor"))`.
   Mantén los nombres de claves EXACTOS actuales (`Empresa.Nif`, `Empresa.Nombre`, `VeriFactu.*`, `IRPF.Porcentaje`, `VeriFactu.CertificadoRuta`, etc.).
4. El combo de idioma (`IdiomaControls`) conserva `.Aplicar` propio (es cambio de runtime, no se guarda en el mismo sitio; NO tocar salvo que sea trivial).
5. El `Cerrar` se mantiene.

## REGLAS
- No cambiar claves de BD, ningún `EstablecerConfiguracion` key.
- No tocar los labels/posiciones de campo.
- El tamaño del diálogo puede crecer ligeramente si el Guardar único lo requiere; mantén 640 x N coherente (ajusta si es necesario a 640x690, lo que sea mínimo).
- Traducción: el botón ya usa `L(...)` — usar claves existentes.

## VALIDACIÓN
- `./build.sh` OK.
- `grep -nE 'BUTTON L\\("CommonGuardar"\\)' src/views/EmpresaView.prg` → esperado exactamente 1 (solo el global) + posible "Aplicar" idiomático.
- Revisa que ninguna clave `EstablecerConfiguracion` aparezca ~4 veces en clicks cada.

## SALIDA
`heredado-11.md`: enfoque elegido, funciones refactorizadas, nº de `EstablecerConfiguracion` totales, resultado del grep, posibles regresiones revisadas (idioma intacto).