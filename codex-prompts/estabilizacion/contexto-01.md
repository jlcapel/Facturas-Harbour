# Contexto fase 01
Estado: COMPLETA.
Ficheros modificados: `codex-prompts/estabilizacion/contrato-dotnet.md`, `contexto-01.md`.
Pruebas ejecutadas: lectura de `git rev-parse HEAD` y `git status --short` en la referencia; sin cambios Harbour.
Decisiones clonadas de .NET: commit `f611291b3ea5bea8c1ba5a3261b7a9cc5c17`; alta, subsanación y anulación son flujos fiscales distintos.
La referencia está sucia solo en licencia y directorios `licencias_*`; no afectan las rutas fiscales contratadas.
Para el arnés, usar `Facturas.Tests/VeriFactuServiceTests.cs`, `QRServiceTests.cs`, `CalculoFacturaServiceTests.cs` y `FacturaServiceLey11Tests.cs`.
Las pruebas Harbour deben aislarse en `/tmp`, no usar red, BD de usuario, certificados ni AEAT.
Riesgos o pendientes: NTP no tiene prueba .NET; anotado `SIN PRUEBA` en el contrato.
Siguiente paso permitido: crear únicamente el arnés de pruebas definido en `fase-02.md`.
