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

## Stack aprobado

El stack tecnológico general está fijado en la [ADR-001](./adr/ADR-001.md):

- **Harbour** 3.2.0dev — https://github.com/harbour/core
- **HWGUI** — GUI multiplataforma (GTK3 en Linux, WinAPI en Windows)
- **SQLite** mediante `hbsqlit3` — Base de datos local
- **hbcurl** — HTTP/SOAP AEAT, HTTPS y certificado cliente
- **hbhpdf** — Generación de PDFs
- **hbzebra** — Generación de códigos QR

## Compilar

```bash
cd Facturas-Harbour
./build.sh       # Linux
```

Para Windows cross-compilation, ver AGENTS.md.

## Distribución

La versión de distribución actual es `1.0.15`, igual que la referencia .NET. Los artefactos se generan desde Linux y no incluyen certificados, configuraciones AEAT ni bases de datos de usuario.

### Linux Debian/Ubuntu x86_64

El formato es un paquete `.deb`. Incluye el binario y la librería privada de Harbour; declara GTK3, SQLite, cURL, Haru PDF, X11, PCRE y zlib como dependencias del sistema.

```bash
packaging/linux/package-deb.sh --check
packaging/linux/package-deb.sh
sudo apt install ./packaging/out/Facturas-Harbour_1.0.15_amd64.deb
sudo apt remove facturas-harbour
```

El desinstalado conserva `~/Facturas` y su contenido. El binario instalado es `facturas-harbour`.

### Windows x64

El formato es un instalador NSIS. El ejecutable sólo importa DLL del sistema Windows; no se distribuyen certificados ni datos de usuario.

```bash
packaging/windows/package-nsis.sh --check
packaging/windows/package-nsis.sh
```

Se requiere `makensis` y el toolchain MinGW ya documentado en `AGENTS.md`. El instalador crea los accesos del menú Inicio y su desinstalador elimina únicamente la carpeta de programa, conservando los datos de la aplicación.

## Estado del proyecto

La tabla siguiente es el resumen histórico inicial. El estado vigente de estabilización, validación fiscal, pruebas, runtime y distribución está en los hitos 11–14 del [ROADMAP](./ROADMAP.md). No se activará AEAT en producción hasta completar los criterios definidos allí.

La evidencia verificable de la release `1.0.15`, incluidos sus límites, está en [docs/EVIDENCIA_RELEASE.md](./docs/EVIDENCIA_RELEASE.md). El proyecto no está declarado apto para producción.

| Hito | Estado |
|---|---|---|
| 1 — Toolchain + Hola Mundo | ✅ Completado |
| 2 — Modelos + BD SQLite | ✅ Completado |
| 3 — CRUD Maestros | ✅ Completado |
| 4 — Facturas + PDF + VERI*FACTU | 🔄 En progreso (backend OK, falta UI + PDF + SOAP) |

Ver [`ROADMAP.md`](./ROADMAP.md) para el plan de desarrollo detallado.

## Contacto

José L. Capel — jlcapel@hotmail.com
