# FASE 16 (OPCIONAL) — D2: Selector de acento y modo oscuro

Lee antes: `reglas-base.md`, `heredado-15.md`. **Saltable: si se omite, genera `heredado-16.md` con "FASE 16 SKIPPED".**

## OBJETIVO
Añadir en `EmpresaView` (nueva sección pequeña o dentro de la existente de idioma) selector de:

1. **Color de acento**: duple/lisa de 6 (Azul #1E4072, Verde #166534, Violeta #6D28D9, Naranja #C2410C, Rojo #B91C1C, Teal #0F766E). Se guarda en config `UI.ColorAcento` (hex "RRGGBB").
2. **Modo oscuro**: `GET CHECKBOX` / combo SI/NO en config `UI.ModoOscuro` ("S"/"N").

## IMPLEMENTACIÓN (mínimo viable)
- La BD: `EstablecerConfiguracion(db, "UI.ColorAcento", ...)` y `UI.ModoOscuro`.
- En `Theme.prg` (fase 8): hacer que las funciones de color del tema LEAN estas claves (si está activo, devolver el acento configurado; en modo oscuro devolver colores de fondo oscuro/texto claro). Obtener el handle `db` NO está disponible en Theme (funciones sin params)... Solución: cargar los valores en un PUB almacén global al arrancar la app (p.ej. `ThemeInicializar(db)` llamado en `main.prg`) y Theme color funciones leen ese PUB.
- Aplicar el acento a los SAY/botones de la zona de bienvenida (fase 9) y, si es viable, a los headers de BROWSE (`oBrw:aHeadBgColor` propiedades — verificar soporte).
- El modo oscuro debe aplicarse a la paleta de THEME (bg/header/texto) que usen main y (opcional) dialogs de lista.

## 3. CRITERIOS
- Sin UI desbordada: sección groupbox de ~150px en EmpresaView (y=580..680; ver si cabe, si no reducir otra).
- `./build.sh` OK.

## SALIDA
`heredado-16.md`: claves de config nuevas, cómo `Theme` lee config, qué usa el acento/oscuro, botón aplicado.