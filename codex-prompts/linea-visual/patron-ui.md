# Patrón visual cerrado HWGUI

Lee este fichero después de `reglas-base.md`. Especifica el único modo permitido de aplicar la línea visual. Si algún punto no se puede expresar con las macros disponibles en `/usr/local/include/harbour/guilib.ch`, bloquea la fase: no sustituyas controles ni inventes una alternativa.

## Recursos por vista

Declara localmente y reutiliza, sin crear fuentes adicionales:

```harbour
LOCAL oFuenteTitulo := FuenteUiTitulo()
LOCAL oFuenteTexto := FuenteUiTexto()
LOCAL oFuenteBoton := FuenteUiBoton()
```

- Título: `SAY`, `FONT oFuenteTitulo`, `COLOR ColorUiTexto()`.
- Etiqueta y campo: `FONT oFuenteTexto`; las etiquetas llevan `COLOR ColorUiTexto()`.
- Browse: conserva su `STYLE`, sus columnas y bloques; añade sólo `FONT oFuenteTexto`.
- Botón primario: `FONT oFuenteBoton COLOR ColorUiBlanco() BACKCOLOR ColorUiPrimario()`.
- Botón destructivo: `FONT oFuenteBoton COLOR ColorUiBlanco() BACKCOLOR ColorUiPeligro()`.
- Botón neutro: `FONT oFuenteBoton COLOR ColorUiTexto() BACKCOLOR ColorUiTarjeta()`.
- Groupbox: conserva texto y flujo; usa sólo `FONT oFuenteBoton COLOR ColorUiTexto() BACKCOLOR ColorUiTarjeta()`.
- Combobox y checkbox: conserva exactamente `GET COMBOBOX` o `CHECKBOX`, `ITEMS`, `VAR`, `INIT`, `PICTURE` y altura desplegable actual; añade exclusivamente `FONT oFuenteTexto` y, en las etiquetas, el color indicado.

No apliques color de fondo a los diálogos o al panel y no ocultes bordes nativos. No añadas paneles, tarjetas, separadores, títulos o etiquetas salvo el título de página indicado expresamente por la fase.

## Listado embebido

Para un listado, las coordenadas son relativas a `nX,nY,nW,nH` y no se interpretan:

| Control | Coordenadas y tamaño |
|---|---|
| Título de página | `nX+20, nY+18`, `nW-40, 28` |
| Acciones | `y=nY+58`, alto `30`, separación horizontal `10` |
| Browse | `nX+20, nY+104`, `nW-40, nH-124` |

La fila de acciones siempre va antes del browse. Las fases indican las acciones, sus posiciones `x`, anchos y color semántico; conserva su bloque `ON CLICK` literalmente. No uses ninguna coordenada basada en `nH` para botones.

## Formulario modal

Salvo una retícula distinta indicada por la fase, aplica estas reglas literales:

- Etiquetas: `x=24`, ancho `150`.
- Campo principal: `x=184`; no cambies `PICTURE`, binding o tipo de control.
- Filas simples: etiqueta `y`, campo `y-2`, incremento vertical `38`.
- Guardar a la derecha: ancho `100`, alto `30`, `y=alto_dialogo-60`.
- Cancelar inmediatamente a su derecha con 10 de separación, ancho `110`, alto `30`.
- La geometría de una segunda columna, campos multilínea, totales y grids sólo cambia cuando la fase la especifica.

## Validación de cada fase con código

Ejecuta desde la raíz, en este orden y sin lanzar la aplicación:

```bash
./build.sh
./build.sh win
git diff --check
```

Si cualquiera falla, no inicies la siguiente fase. Escribe el contexto con `Estado: BLOQUEADA` y el comando, error y ficheros tocados; no reviertas nada.
