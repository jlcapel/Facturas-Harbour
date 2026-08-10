# FASE 15 — Evidencia y decisión de release

Lee `AGENTS.md`, `reglas-base.md` y `contexto-14.md`.

## Objetivo único

Consolidar únicamente la evidencia realmente obtenida por las fases anteriores y dejar el repositorio listo para una revisión humana de release.

## Acciones obligatorias

1. Crea `docs/EVIDENCIA_RELEASE.md` con una tabla por: contrato .NET, migraciones, pruebas, builds Linux/Windows, SOAP sin red, UI GTK3, UI WinAPI, backup, PDF, empaquetado y preproducción AEAT.
2. Marca cada fila como `VERIFICADO`, `NO VERIFICADO` o `BLOQUEADO`; nunca infieras éxito desde una fase anterior.
3. Actualiza `README.md` y `ROADMAP.md` sólo para reflejar evidencia existente, sin marcar hitos como completados si falta una prueba o validación de preproducción.
4. Actualiza o crea ADRs sólo si una decisión de alcance, migración o distribución fue realmente tomada y quedó respaldada por la referencia .NET.
5. Ejecuta la suite fiscal, `./build.sh`, `./build.sh win` y `git diff --check`.

## Ficheros permitidos

- `docs/EVIDENCIA_RELEASE.md`
- `README.md`
- `ROADMAP.md`
- `adr/**`
- `codex-prompts/estabilizacion/contexto-15.md`

## Validación y salida

Escribe `contexto-15.md` con el estado global y la lista exacta de evidencia ausente. No declares aptitud para producción ni actives AEAT. Termina.
