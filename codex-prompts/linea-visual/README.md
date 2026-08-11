# Línea visual profesional HWGUI

Ejecuta estas fases estrictamente en orden desde la raíz del repositorio.

```bash
cd /home/jose/programacion/Facturas-Harbour
codex exec codex-prompts/linea-visual/fase-01.md
```

Cada fase lee solamente `AGENTS.md`, `reglas-base.md`, `patron-ui.md`, el `contexto` anterior y los ficheros indicados por su propio prompt. Al terminar escribe el contexto siguiente, de un máximo de 25 líneas. Ese contexto es el único traspaso de información variable entre fases; las dos reglas fijas no se reinterpretan.

| Fase | Objetivo |
|---|---|
| 01 | Corregir el marco principal y la superficie de contenido para HiDPI. |
| 02 | Crear los estilos visuales reutilizables y aplicarlos al marco. |
| 03 | Rediseñar el listado de Tipos de IVA como pantalla patrón. |
| 04 | Rediseñar los formularios de Tipos de IVA. |
| 05 | Aplicar el patrón exclusivamente a Países. |
| 06 | Aplicar el patrón exclusivamente a Tipos de Identificación. |
| 07 | Aplicar el patrón exclusivamente a Categorías de Gasto. |
| 08 | Aplicar el patrón exclusivamente a Bienes de Inversión. |
| 09 | Aplicar el patrón exclusivamente a Clientes. |
| 10 | Aplicar el patrón exclusivamente a Artículos. |
| 11 | Aplicar el patrón exclusivamente a Proveedores. |
| 12 | Aplicar el patrón exclusivamente al listado de Facturas. |
| 13 | Aplicar el patrón exclusivamente al listado de Gastos. |
| 14 | Aplicar el patrón exclusivamente al editor de Factura y de línea. |
| 15 | Aplicar el patrón exclusivamente al editor de Gasto. |
| 16 | Aplicar el patrón exclusivamente a Empresa. |
| 17 | Aplicar el patrón exclusivamente a Validación NIF y VIES. |
| 18 | Aplicar el patrón exclusivamente a Modelos AEAT. |
| 19 | Consolidar evidencia estática y la validación manual pendiente. |

No se ejecuta la aplicación contra la base de datos del usuario en esta cadena. La validación visual interactiva queda explícitamente documentada al final.
