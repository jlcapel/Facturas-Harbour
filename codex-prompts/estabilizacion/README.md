# Cadena de estabilización fiscal

Ejecuta estas fases estrictamente en orden. No ejecutes una fase si el `contexto` anterior indica `BLOQUEADA` o `ERROR`.

```bash
cd /home/jose/programacion/Facturas-Harbour
codex exec codex-prompts/estabilizacion/fase-01.md
```

Cada fase lee únicamente `AGENTS.md`, `reglas-base.md`, su `contexto` anterior y los ficheros que lista su propio prompt. Al finalizar escribe el siguiente `contexto-XX.md`, de un máximo de 25 líneas. Ese fichero es el único traspaso de contexto a la fase siguiente.

| Fase | Objetivo |
|---|---|
| 01 | Fijar y documentar el contrato de referencia .NET |
| 02 | Crear el arnés aislado de pruebas Harbour |
| 03 | Corregir y probar hash y QR canónicos |
| 04 | Corregir y probar desglose IVA |
| 05 | Corregir y probar cadenas y timestamps |
| 06 | Endurecer TLS y certificado cliente AEAT |
| 07 | Preparar migraciones SQLite idempotentes |
| 08 | Hacer atómica el alta de factura |
| 09 | Clonar el flujo fiscal de corrección o subsanación |
| 10 | Clonar el flujo fiscal de anulación |
| 11 | Corregir NTP y backup SQLite/WAL |
| 12 | Probar contrato SOAP/XML sin llamadas externas |
| 13 | Preparar y ejecutar la validación runtime/UI segura |
| 14 | Preparar distribución Linux/Windows desde la referencia |
| 15 | Consolidar evidencia y documentación de release |

La producción AEAT queda prohibida hasta que las fases 01–12 estén validadas y exista autorización expresa fuera de esta cadena.
