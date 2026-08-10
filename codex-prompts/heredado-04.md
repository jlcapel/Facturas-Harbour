# heredado-04 — Fase 4 completada: FacturasView + FacturaEditView externalizados

## Ficheros modificados
- src/views/FacturasView.prg (externalizado: botón "Nueva", estados Emitida/Anulada, mensajes, botón PDF)
- src/views/FacturaEditView.prg (externalizado: títulos, etiquetas, botones, columnas, mensajes, diálogos línea)
- src/i18n/strings_{es,en,fr,ca,eu}.prg (claves nuevas añadidas a los 5 idiomas)

## i18n: claves añadidas (por idioma)
- **Comunes**: CommonAviso, CommonInformacion, CommonConfirmar, CommonError (y equivalentes en fr/ca/eu)
- **Facturas**: FacturasEstadoEmitida, FacturasEstadoAnulada, FacturasMsgSeleccione, FacturasMsgAnular, FacturasMsgPdfGenerado, FacturasMsgErrorPdf, FacturasBtnNueva
- **FacturaEditView**: FacturaEditTitleEditar, FacturaEditTitleEditarLinea, FacturaEditAnadirLinea, FacturaEditQuitarLinea, FacturaEditLineas, FacturaEditIrpfLabel, FacturaEditCantHead, FacturaEditIvaPctHead, FacturaEditPrecioLabel, FacturaEditCantidadLabel, FacturaEditAnadirLinea, FacturaEditQuitarLinea, FacturaEditTitleEditarLinea, CommonAceptar/Accepter/Aceptar/Aukeratu, FacturaEditMsgGuardada, FacturaEditMinLineas, ArticulosDescripcionLabel (reutilizado), FacturaEditPrecioLabel, FacturaEditCantidadLabel, FacturaEditIrpfLabel, FacturaEditAnadirLinea, FacturaEditQuitarLinea, FacturaEditTitleEditarLinea, CommonAceptar/Accepter/Aceptar/Aukeratu, ArticulosDescripcionLabel (reutilizado), CommonAceptar

## Total claves únicas: ~806 (paridad exacta 5 idiomas, duplicados preexistentes en todas)
## Build: OK

## Cambios en vistas:
- FacturasView: 100% L() - botón "Nueva", estado Emitida/Anulada, mensajes selección/anulación/PDF/error, botón PDF
- FacturaEditView: 100% L() - título dinámico, etiquetas cliente/tipo/descripción/IVA, GROUPBOX "Líneas", columnas Cant./IVA%/Precio, botones Añadir/Quitar, etiquetas totales IRPF, botones Guardar/Cancelar, diálogos línea (Artículo/Cantidad/Precio/IVA), mensajes guardado/error/mínimo líneas, botones Aceptar/Cancelar