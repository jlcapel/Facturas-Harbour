# Reglas absolutas de estabilización

1. Lee `AGENTS.md` completo antes de actuar. Es la fuente de verdad absoluta y prevalece sobre cualquier otro fichero.
2. Conserva los cambios no confirmados del usuario. Antes de editar, revisa `git status -sb`; no reviertas, reformatees ni toques ficheros fuera de la lista de la fase.
3. La conducta funcional se clona exclusivamente de `/home/jose/programacion/Facturas/`. No inventes flujos, tablas, campos, formatos ni reglas fiscales.
4. No uses la BD de usuario, certificados reales, AEAT preproducción ni producción. Las pruebas usan exclusivamente rutas temporales bajo `/tmp` y dobles SOAP locales.
5. No hagas commits, push, resets ni borrados destructivos. No dejes credenciales, NIF reales ni respuestas externas en el repositorio.
6. No añadas comentarios a código `.prg`. Los documentos Markdown y contextos sí pueden explicarse.
7. Tras cambios de producción ejecuta `./build.sh` y `./build.sh win`. Tras cambios de pruebas ejecuta además el comando de pruebas definido en la fase.
8. Toda consulta SQLite usa índices `sqlite3_column_*` y `sqlite3_bind_*` 1-based. Todo `.prg` que use constantes SQLite incluye `#require "hbsqlit3"` y `#include "hbsqlit3.ch"`.
9. No ejecutes la siguiente fase si esta no cumple sus criterios. Corrige dentro de alcance; si es imposible, escribe `Estado: BLOQUEADA` en el contexto y termina.
10. Cada contexto debe entregar las rutas, métodos, pruebas .NET e invariantes exactos que necesita la fase siguiente. Esa fase no lee contextos anteriores ni `contrato-dotnet.md`; si falta un dato, queda `BLOQUEADA`.

## Formato obligatorio de contexto

`contexto-XX.md` tiene como máximo 25 líneas y contiene exactamente: estado, ficheros modificados, pruebas ejecutadas, decisiones clonadas de .NET, riesgos o pendientes y el siguiente paso permitido.
