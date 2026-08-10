# FASE 8 — Theme: paleta y fuentes centralizadas

Lee antes: `reglas-base.md`, `heredado-07.md`.

## OBJETIVO
Crear un módulo de tema visual único (`src/ui/Theme.prg`) con la paleta y las fuentes que las vistas y main usarán (desde la fase 9 en adelante). En esta fase SOLO se crea el archivo, nadie lo usa todavía.

## CONTENIDO DEL MÓDULO
Crea `src/ui/Theme.prg` (crea el dir `src/ui/` si falta) con:

```
FUNCTION ColorAcento()      -> hwg_ColorRGB2N(30, 64, 114)   // azul VERI*FACTU
FUNCTION ColorTexto()       -> hwg_ColorRGB2N(30, 41, 59)    // gris oscuro
FUNCTION ColorSubtexto()    -> hwg_ColorRGB2N(100, 116, 139) // gris medio
FUNCTION ColorFondo()       -> hwg_ColorRGB2N(248, 250, 252) // fondo claro
FUNCTION ColorEncabezado()  -> hwg_ColorRGB2N(241, 245, 249) // gris header
FUNCTION FuenteTitulo(nH)   -> fuente bold "Noto Sans"/"DejaVu Sans" altura negativa <nH>
FUNCTION FuenteTexto(nH)    -> fuente normal altura <nH>
```

- Las funciones `FuenteTitulo/FuenteTexto` deben devolver un objeto fuente HWGUI (busca cómo se crean fuertes en el proyecto: `PREPARE FONT ... NAME ... HEIGHT -n WEIGHT n`).
- Documenta (en comentario de cabecera del archivo — no de código) que estas funciones se usarán en main.prg y vistas.
- Decide: `FuenteTitulo` devuelve fuente con `WEIGHT 700`; `FuenteTexto` normal.

## CRITERIOS
- El archivo compila sin errores aunque nadie lo use: `./build.sh` añade `src/ui/Theme.prg` a la compilación (revisa si `build.sh` compila todo `src/**/*.prg`; si es así no hace falta nada; si hay lista explícita, añádelo).
- No modificar ninguna vista en esta fase.

## SALIDA
`heredado-08.md`: ruta del archivo creado, firma de las 7 funciones, cómo se integra en build (automático o lista).