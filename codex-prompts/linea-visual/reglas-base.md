# Reglas absolutas de la línea visual

1. Lee `AGENTS.md` completo antes de actuar. Es la fuente de verdad absoluta y prevalece sobre esta cadena.
2. Lee sólo el contexto inmediatamente anterior; no releas fases ni contextos previos. `reglas-base.md` y `patron-ui.md` son contratos fijos, no contexto histórico. Conserva todos los cambios existentes: antes de editar ejecuta `git status -sb` y nunca reviertas ni reformatees cambios ajenos.
3. El alcance es exclusivamente visual y de disposición. No modifiques servicios, esquema SQLite, cálculos, reglas fiscales, datos, consultas, eventos, textos de negocio ni flujos CRUD.
4. La referencia visual es `/home/jose/programacion/Facturas/Facturas/App.axaml` y la vista .NET equivalente. No clones su sidebar: `AGENTS.md` fija menú superior y área de contenido sin sidebar.
5. No añadas claves i18n ni textos literales nuevos. Reutiliza sólo `L("...")` y claves existentes. No añadas iconos, bitmaps, dependencias, CSS, HTML, librerías ni controles externos.
6. Crea sólo controles HWGUI estándar documentados localmente. Usa `HPanel`, `HStatic`, `HButton`, `HBrowse`, `HGroup`, `HDialog`, fuentes y colores ya disponibles. No uses `HStatus` en la ventana principal.
7. Las vistas sólo contienen disposición y eventos existentes. No encapsules ni reescribas lógica de negocio. Conserva las llamadas, parámetros, columnas, validaciones, modal/modeless y acciones actuales salvo que una fase ordene de forma expresa un cambio visual.
8. Usa nombres en español y no añadas comentarios a ficheros `.prg`. Los Markdown y contextos sí pueden explicarse.
9. No ejecutes `Facturas`, no uses la BD del usuario, no accedas a AEAT, certificados ni red. Tras cada fase con código ejecuta, en secuencia, `./build.sh`, `./build.sh win` y `git diff --check`.
10. Sólo modifica los ficheros permitidos por la fase y su contexto de salida. Si un cambio visual exige una API HWGUI no documentada en las cabeceras locales, marca el contexto `Estado: BLOQUEADA`, explica el dato faltante y termina sin improvisar.

## Contrato visual fijo

- Nombre: **Facturas · Profesional claro**.
- Fondo de página `#F1F5F9`; tarjeta `#FFFFFF`; borde `#E2E8F0`; texto principal `#0F172A`; texto secundario `#64748B`; primario `#2563EB`; peligro `#DC2626`.
- Tipografía: Arial, nunca fuente serif explícita. Título 20 negrita; subtítulo 13 normal; texto y grid 12 normal; botón 12 seminegrita.
- Márgenes exteriores 20; separación entre controles 10; botones altura 30. Acciones en barra superior, nunca en el borde inferior.
- Listados: título, barra de acciones, grid. El primer botón es primario; eliminar es peligro; editar y PDF son neutros. No se añaden acciones que no existan ya en Harbour.
- Formularios: etiqueta alineada, campo alineado, filas de 34 y botones Guardar/Cancelar a la derecha. Se conserva el flujo modal actual.

## Formato obligatorio de contexto

Máximo 25 líneas. Debe contener exactamente: `Estado`, `Ficheros modificados`, `Pruebas ejecutadas`, `Contrato visual aplicado`, `Riesgos o pendientes` y `Siguiente fase permitida`.
