# Matriz manual de UI multiplataforma

Esta matriz se ejecuta en un usuario de sistema dedicado o máquina virtual con su propio `~/Facturas`, nunca con la base de datos, certificados ni configuración AEAT del usuario. Antes de empezar, verificar que no hay certificado configurado. No pulsar Consultar en NIF/VIES ni realizar ningún envío AEAT.

Resultado: anotar `OK`, `FALLO` con captura y `NO EJECUTADO` en cada columna. En cada apertura de menú confirmar que no aparece `No exported method: EVAL`, que el foco es visible, Tab/Shift+Tab recorren los controles y Escape/cerrar no deja una ventana modal bloqueada.

| Flujo | Resultado esperado | GTK3/Linux | WinAPI/Windows |
|---|---|---|---|
| Arranque y cierre | Arranca, muestra menú superior, cambia foco y cierra sin error. | PENDIENTE | PENDIENTE |
| Maestros: Países | Abrir; nuevo, editar, desactivar, PDF y volver. | PENDIENTE | PENDIENTE |
| Maestros: Tipos IVA | Abrir; nuevo, editar, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Tipos identificación | Abrir; nuevo, editar, desactivar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Clientes | Abrir; alta, edición con país/tipo ID, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Artículos | Abrir; alta, edición con tipo IVA, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Proveedores | Abrir; alta, edición con país/tipo ID e IBAN, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Categorías gasto | Abrir; alta, edición, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Maestros: Bienes inversión | Abrir; alta, edición, eliminar y PDF. | PENDIENTE | PENDIENTE |
| Empresa | Abrir/cerrar; guardar cada sección y cambiar idioma; comprobar textos del menú al reabrir. | PENDIENTE | PENDIENTE |
| Facturas | Abrir listado y modales; alta, subsanación y anulación sólo con certificado ausente; deben detenerse antes de red y mostrar el resultado local. | PENDIENTE | PENDIENTE |
| Facturas: PDF | Generar y abrir PDF de factura/listado, comprobar contenido y retorno a la aplicación. | PENDIENTE | PENDIENTE |
| Gastos | Abrir; alta, edición, eliminar, marcar pagado/no pagado y PDF. | PENDIENTE | PENDIENTE |
| Validación NIF | Abrir y cerrar la vista; no pulsar Consultar. | PENDIENTE | PENDIENTE |
| Validación VAT/VIES | Abrir y cerrar la vista; no pulsar Consultar. | PENDIENTE | PENDIENTE |
| Modelos AEAT | Abrir; recorrer selección, trimestre/año y generación local; no usar datos reales ni red. | PENDIENTE | PENDIENTE |
| Exportar registros/eventos | Abrir cada acción y verificar el diálogo/ruta de XML local. | PENDIENTE | PENDIENTE |
| Exportar gastos CSV | Introducir año válido e inválido y verificar mensaje/ruta local. | PENDIENTE | PENDIENTE |

La comprobación del error histórico se repite al pulsar cada menú: si reaparece, conservar `Error.log`, plataforma, backend HWGUI y acción exacta. La corrección actual usa una sola clausura creada por `MENUITEM ACTION`; el preprocesado de `src/main.prg` debe contener `Hwg_DefineMenuItem(..., {|| Accion()}, ...)` y nunca un array de bloques.
