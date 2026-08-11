# Contexto fase 05

Estado: COMPLETADA.
Ficheros modificados: `src/services/VeriFactuService.prg`, `tests/prueba_cadenas_timestamps.prg` y este contexto.
Pruebas ejecutadas: `prueba_cadenas_timestamps.prg`, `./build.sh` y `./build.sh win`, todas correctas.
Decisiones clonadas de .NET: `VerificarCadena` comprueba HashAnterior e IdRegistroAnterior esperados y recalcula cada hash con `FechaHoraHusoGenRegistro` persistida.
Decisiones clonadas de .NET: `EventoService.Registrar` usa un único instante, usuario e identificador anterior tanto para hash como para persistencia; la verificación comprueba ambos enlaces.
Decisiones clonadas de .NET: `SqlDateTimeToDateTime` recupera fecha y hora de los timestamps ISO UTC antes de recalcular hashes.
Riesgos o pendientes: los registros o eventos Harbour creados antes de esta corrección no incluyen el mismo material de hash y pueden fallar la nueva verificación; no se alteró ninguna BD de usuario.
Siguiente paso permitido: fase 06 puede endurecer TLS y certificado cliente AEAT sin modificar el contrato fiscal ni las cadenas validadas.
