# Contexto inicial de estabilización
Estado: LISTA PARA FASE 01.
Stack fijo: Harbour + HWGUI + SQLite/hbsqlit3 + hbcurl + hbhpdf + hbzebra.
La compilación actual Linux y Windows termina correctamente.
No hay suite Harbour ni CI en el repositorio; `hbtest` está instalado localmente.
No se han ejecutado la GUI, AEAT, VIES ni NIF contra datos de usuario durante la auditoría.
Hallazgos bloqueantes: TLS AEAT sin verificar, importes con relleno en hash/QR, desglose IVA con índices erróneos y anulación no persistible.
Hallazgos importantes: edición inserta en lugar de corregir, alta no atómica, verificación de cadena pierde hora, backup WAL no es seguro y su retención falla.
`Error.log` histórico registra `No exported method: EVAL` al activar la ventana principal; no está reproducido.
La referencia .NET contiene servicios y pruebas fiscales en `/home/jose/programacion/Facturas/Facturas` y `Facturas.Tests`.
El plan vigente está en `ROADMAP.md`, hitos 11–14.
Siguiente paso permitido: ejecutar `fase-01.md`.
