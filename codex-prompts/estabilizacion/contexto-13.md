Estado: COMPLETADA — EVAL: RESUELTO por inspección reproducible del preprocesado; la validación visual en GTK3 y WinAPI queda pendiente en `matriz-ui.md`.
Ficheros modificados: `src/main.prg`, `codex-prompts/estabilizacion/matriz-ui.md` y este contexto.
Pruebas ejecutadas: `scripts/tests/ejecutar_fiscales.sh`, preprocesado de `src/main.prg` que genera un único `{|| Accion()}` por `MENUITEM`, `./build.sh` y `./build.sh win`, todos correctos ejecutados secuencialmente.
Decisiones clonadas de .NET: no cambió conducta de negocio; sólo se corrige el despacho HWGUI para que cada menú conserve la acción existente hacia las mismas vistas y servicios de la referencia.
Riesgos o pendientes: no se ejecutó la UI contra datos de usuario ni se abrió el binario Windows en Windows; la matriz requiere usuario/VM aislado y prohíbe AEAT, NIF y VIES reales. `build.sh` usa `/tmp/facturas_build`, por lo que sus builds no se ejecutan en paralelo.
Siguiente paso permitido: fase 14 puede inspeccionar las carpetas de publicación de `/home/jose/programacion/Facturas/` y preparar únicamente el empaquetado equivalente, sin certificados ni datos de usuario.
