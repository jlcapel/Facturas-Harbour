# Ejecución encadenada con Codex

Todos los prompts están en este directorio. Se ejecutan EN ORDEN, uno por fase.

## Cómo ejecutar

```bash
cd /home/jose/programacion/Facturas-Harbour
codex exec codex-prompts/fase-01.md   # y así sucesivamente
```

Cada fase lee los ficheros:
1. `AGENTS.md` (raíz del repo)
2. `codex-prompts/reglas-base.md` (reglas globales, constantes)
3. `codex-prompts/heredado-N.md` (contexto de las fases anteriores; N-1 de la fase actual)
4. El propio `fase-N.md` (instrucciones exactas)

## Contrato de contexto (ahorro de tokens)

- `heredado-00.md` = estado inicial ya inventariado del proyecto (NO regenerar).
- Al terminar cada fase N, el agente ESCRIBE `heredado-N.md` con ≤ 25 líneas:
  - Ficheros tocados
  - Claves i18n añadidas (o "ninguna")
  - Decisiones tomadas
  - Qué queda pendiente (si algo falló, la siguiente fase lo sabrá)
- La fase N+1 NO relee las fases anteriores: solo `heredado-N.md`.

## Orden de ejecución

| Fase | Contenido | Bloque |
|---|---|---|
| fase-01 | i18n: claves Menu* añadidas a 5 archivos | A1 |
| fase-02 | i18n: 36 claves faltantes en en/fr/ca/eu + seed Language | A2+A3 |
| fase-03 | i18n: externalizar strings en 5 vistas de maestros | A4a |
| fase-04 | i18n: externalizar FacturasView + FacturaEditView | A4b |
| fase-05 | i18n: Gastos/Proveedores/Categorías/Bienes | A4c |
| fase-06 | i18n: ModelosAeat + Empresa + Validación + VIES | A4d |
| fase-07 | Script verificación i18n (tools/verificar_i18n.sh) | A5 |
| fase-08 | Theme.prg: paleta + fuentes centralizadas | B1 |
| fase-09 | main.prg: bienvenida centrada + WS_SIZEBOX + tema | B2 |
| fase-10 | Unificar botones/paddings en todas las vistas | B3 |
| fase-11 | EmpresaView: 1 solo Guardar + combo con L() | C1 |
| fase-12 | FacturaEditView: alineación labels y totales | C2 |
| fase-13 | ModelosAeatView: grid uniforme de tarjetas | C3 |
| fase-14 | Statusbar operativa + build final Linux y Windows | C4 |
| fase-15 | (opcional) Iconos en botones | D1 |
| fase-16 | (opcional) Selector acento/modo oscuro | D2 |
| fase-17 | (opcional) High-DPI | D3 |

## Regla de oro de esta guía

NO hacemos commits. NO preguntamos. Si algo no compila, se corrige y se sigue.

## Cadena de estabilización fiscal

La cadena posterior a las fases visuales está en [`estabilizacion/README.md`](./estabilizacion/README.md). Se ejecuta de forma independiente desde `fase-01.md` de ese directorio y usa sus propios contextos `contexto-00.md` a `contexto-15.md`.
