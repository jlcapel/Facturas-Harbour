# Facturas-Harbour

App de facturación VERI*FACTU (España) escrita en Harbour + HWGUI.

Multiplataforma: Linux (GTK3) y Windows (WinAPI via MinGW cross-compilation).

## Licencia

**Dual license:**

1. **GPLv3** — Código fuente abierto. Ver [`LICENSE`](./LICENSE).
2. **Comercial** — Para uso en productos cerrados. Ver [`LICENSE-COMMERCIAL.md`](./LICENSE-COMMERCIAL.md).

Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com

---

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.**

## Stack

- **Harbour** 3.2.0dev — https://github.com/harbour/core
- **HWGUI** — GUI multiplataforma (GTK3 en Linux, WinAPI en Windows)
- **SQLite3** — Base de datos local
- **Haru PDF** — Generación de PDFs
- **libcurl** — SOAP AEAT
- **Mini-XML** — XML parsing

## Compilar

```bash
cd Facturas-Harbour
./build.sh       # Linux
```

Para Windows cross-compilation, ver AGENTS.md.

## Estado del proyecto

| Hito | Estado |
|---|---|
| 1 — Toolchain + Hola Mundo | ✅ Completado |
| 2 — Modelos + BD SQLite | ✅ Completado |
| 3 — CRUD Maestros | 🔄 Pendiente |

Ver [`ROADMAP.md`](./ROADMAP.md) para el plan de desarrollo detallado.

## Contacto

José L. Capel — jlcapel@hotmail.com
