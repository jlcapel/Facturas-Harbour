Estado: COMPLETADA — la evidencia de release queda consolidada y la aptitud para producción se mantiene BLOQUEADA.
Ficheros modificados: `docs/EVIDENCIA_RELEASE.md`, `README.md`, `ROADMAP.md` y este contexto; no se creó ADR porque el formato de empaquetado fue una autorización de producto, no una decisión respaldada por la referencia .NET.
Pruebas ejecutadas: `scripts/tests/ejecutar_fiscales.sh`, `./build.sh`, `./build.sh win` y `git diff --check`, todos correctos y en secuencia.
Decisiones clonadas de .NET: la release conserva versión `1.0.15`; los estados fiscales, esquema, SOAP, backup y NTP se documentan sólo con sus pruebas registradas, sin inferir validación de producción.
Riesgos o pendientes: matriz UI GTK3/WinAPI, PDF en ambos sistemas, instalación/desinstalación limpia DEB, `makensis` e instalador Windows, preproducción AEAT con certificado de prueba, evidencia de CSV y aprobación humana de release.
Siguiente paso permitido: realizar únicamente las validaciones manuales pendientes con usuario/VM y certificados de prueba autorizados; no activar producción AEAT hasta completar la evidencia y la aprobación del responsable.
