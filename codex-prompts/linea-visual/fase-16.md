# Fase 16 — Empresa

Lee `AGENTS.md`, `reglas-base.md`, `patron-ui.md` y `contexto-15.md`.

## Objetivo único

Aplicar tipografía y colores semánticos exclusivamente a `EmpresaView.prg`.

## Ficheros permitidos

- `src/views/EmpresaView.prg`
- `codex-prompts/linea-visual/contexto-16.md`

## Acciones exactas

1. Conserva literalmente el tamaño, estilo, cinco groupboxes, geometría y campos existentes. No sustituyas el modal ni sus secciones.
2. Declara las tres fuentes del patrón en `EmpresaView()` y pásalas como parámetros a `EmpresaControls`, `VerifactuControls`, `CertificadoControls`, `SistemaInfoControls` e `IdiomaControls`; no crees otras fuentes ni estado global.
3. En todos los controles existentes aplica el recurso exacto del mismo tipo definido en `patron-ui.md`. Los cuatro Guardar mantienen su posición y pasan a `w=100,h=30` primarios. Cambiar idioma y Cerrar conservan posición y pasan a `h=30` neutros.
4. No cambies claves de configuración, contraseñas, certificado, entorno AEAT, IRPF, idioma, bloques `ON CLICK` ni el estilo `WS_POPUP` propio de este modal.
5. Ejecuta las tres validaciones obligatorias.

## Salida

Escribe `contexto-16.md` con el formato obligatorio. `Siguiente fase permitida: fase-17.md`.
