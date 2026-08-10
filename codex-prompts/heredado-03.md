# heredado-03 — Fase 3 completada: externalización strings en 5 vistas maestros

## Ficheros modificados
- src/views/PaisesView.prg (externalizado: títulos, botones, mensajes, diálogos)
- src/views/TiposIvaView.prg (externalizado: títulos, botones, mensajes, diálogos)
- src/views/TiposIdentificacionView.prg (externalizado: títulos, botones, mensajes, diálogos)
- src/views/ClientesView.prg (externalizado: títulos, botones, mensajes, diálogos, combo items)
- src/views/ArticulosView.prg (externalizado: títulos, botones, mensajes, diálogos)

## i18n: claves añadidas (por idioma)
- **Paises**: 7 nuevas (TitleNuevo, TitleEditar, MsgSeleccione, MsgEliminar, MsgPdfGenerado, BtnPdf, PctHeader no aplica)
- **TiposIva**: 8 nuevas (TitleNuevo, TitleEditar, MsgSeleccione, MsgEliminar, MsgPdfGenerado, BtnPdf, PctHeader)
- **Identif**: 6 nuevas (TitleNuevo, TitleEditar, MsgSeleccione, MsgEliminar, MsgPdfGenerado, BtnPdf)
- **Clientes**: 11 nuevas (TitleEditar, TipoLabel, TipoIdLabel, NifLabel, NifIvaLabel, CpLabel, MsgSeleccione, MsgEliminar, MsgPdfGenerado, BtnPdf, CpLabel - duplicado clave corregido)
- **Articulos**: 8 nuevas (TitleEditar, MsgSeleccione, MsgEliminar, MsgPdfGenerado, BtnPdf, PrecioLabel, UnidadLabel)

## Total claves por idioma: 803 (paridad exacta 5 idiomas)

## Build: OK

## Vistas actualizadas a L():
- PaisesView: títulos, botones PDF, mensajes selección/eliminación/PDF
- TiposIvaView: títulos, botón PDF, combo items, mensajes
- TiposIdentificacionView: títulos, botón PDF, mensajes
- ClientesView: botón PDF, dialogo edición completo (18 etiquetas), mensajes
- ArticulosView: títulos, botones, mensajes, etiquetas precio/unidad

## Build: OK