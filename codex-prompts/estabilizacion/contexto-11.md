# Contexto fase 11

Estado: COMPLETADA.
Ficheros modificados: `src/services/NtpService.prg`, `src/services/BackupService.prg`, `src/services/VeriFactuService.prg`, `build.sh`, `tests/prueba_backup_ntp.prg`, `tests/prueba_cadenas_timestamps.prg` y este contexto.
Pruebas ejecutadas: backup/NTP temporal con respuesta NTP sintética, WAL abierto, retención, `PRAGMA integrity_check` y restauración; humo fiscal, alta atómica y cadenas correctos; `./build.sh`, `./build.sh win` y `git diff --check`, correctos.
Decisiones clonadas de .NET: `NtpService.cs` consulta UDP `hora.roa.es:123` con paquete de 48 bytes, timeout 5 s y fallback UTC local; los registros fiscales llaman a esa fuente. `Utils.CrearBackupSqlite` exige instantánea SQLite consistente: Harbour usa `sqlite3_backup_init/step/finish` tanto al crear como al restaurar, valida integridad y conserva diez copias por nombre real de `hb_DirScan`.
Riesgos o pendientes: el enlace Windows añadió `-liphlpapi` por autorización explícita para satisfacer `GetAdaptersInfo` de INET; no se tocó la BD de usuario ni se hizo ninguna llamada NTP externa. La fase 12 debe conservar los dobles locales y no alterar NTP ni backup.
Siguiente paso permitido: fase 12 puede tocar exclusivamente `AeatClientService.prg`, `Helpers.prg`, pruebas, protocolo de preproducción y contexto; debe extraer los fixtures de `AeatClientServiceTests`, validar XML/CSV sin red y no invocar AEAT.
