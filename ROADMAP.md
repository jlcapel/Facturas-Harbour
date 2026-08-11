<!--
Facturas-Harbour — App de facturación VERI*FACTU (España)
Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
Licensed under GPLv3. Commercial license available.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
-->

# Roadmap — Facturas Harbour

## Estado de planificación

El inventario de código confirma la presencia de los módulos previstos hasta el hito 10, pero los hitos históricos de este documento no son evidencia de validación funcional, fiscal o de producción. La compilación Linux y Windows, la prueba fiscal aislada, las migraciones temporales, el SOAP sin red, backup/NTP y el paquete Debian están verificados; la UI manual, PDF, instalación limpia, instalador Windows y preproducción AEAT siguen pendientes. El detalle y los límites constan en [docs/EVIDENCIA_RELEASE.md](./docs/EVIDENCIA_RELEASE.md).

El stack tecnológico aprobado es Harbour + HWGUI + SQLite/hbsqlit3 + hbcurl + hbhpdf + hbzebra. Véase [ADR-001](./adr/ADR-001.md).

No se habilitará el envío AEAT en producción hasta completar los hitos 11 y 12.

## Hito 11: Estabilización fiscal y de persistencia

### 11.0 Contrato con la referencia .NET

- [ ] Fijar el commit o versión de `Facturas .NET` que será el contrato funcional de Harbour.
- [ ] Crear una matriz de equivalencia para factura, rectificación, anulación, registro VERI*FACTU, XML/SOAP, PDF y modelos AEAT.
- [ ] Decidir explícitamente las capacidades de la referencia actual que entran en el alcance Harbour antes de implementarlas.

### 11.1 Correcciones bloqueantes

- [ ] Activar la verificación TLS de certificado y host en las llamadas AEAT; fallar de forma segura si el certificado cliente o la configuración son inválidos.
- [ ] Formatear de forma canónica y sin relleno los importes del hash y del QR; conservar fecha, hora y zona horaria exactas del registro.
- [ ] Corregir el desglose IVA para agrupar por el tipo de IVA y calcular base y cuota desde los campos correctos de cada línea.
- [ ] Rediseñar la anulación según la referencia .NET: crear el documento y registro de anulación sin actualizar el estado de la original si el registro fiscal falla.
- [ ] Sustituir la edición directa de una factura emitida por el flujo fiscal equivalente de la referencia, sin duplicar su número ni alterar su registro histórico.
- [ ] Encapsular alta, líneas, versión o registro fiscal y eventos en transacciones SQLite, con rollback ante cualquier fallo.
- [ ] Corregir la verificación de las cadenas de registros y eventos para recalcular exactamente los datos persistidos.
- [ ] Usar la hora oficial cuando se genere el registro y reparar el backup para SQLite en WAL, incluida la retención de copias.

### Criterios de aceptación

- [ ] Ninguna operación deja facturas, líneas, registros o eventos parciales.
- [ ] Alta, rectificación o subsanación y anulación generan los mismos datos fiscales esperados que la referencia .NET.
- [ ] No hay envío AEAT con TLS no verificado ni con configuración de certificado incompleta.
- [ ] La comprobación de cadena detecta una alteración y acepta una cadena válida creada por la aplicación.

## Hito 12: Pruebas y evidencia fiscal

- [ ] Crear una suite Harbour con `hbtest` y una BD temporal aislada de la BD de usuario.
- [ ] Incorporar vectores de prueba de la referencia .NET para cálculos, hash, QR, desglose IVA y encadenamiento.
- [ ] Cubrir errores de transacción, numeración duplicada, edición o subsanación, anulación, restauración y limpieza de backups.
- [ ] Simular las respuestas SOAP AEAT y comprobar XML, CSV y errores sin llamar a producción.
- [ ] Ejecutar pruebas en Linux y validar el binario Windows en Windows.
- [ ] Ejecutar el flujo completo exclusivamente en preproducción AEAT con certificado de prueba y conservar la evidencia.

### Criterios de aceptación

- [ ] La suite automatizada pasa en una instalación limpia.
- [ ] Los resultados de hash, QR y XML coinciden con la referencia y los casos de prueba aprobados.
- [ ] Se documentan fecha, entorno y resultado de la validación AEAT de preproducción.

## Hito 13: Runtime, multiplataforma y distribución

- [ ] Reproducir y resolver el error HWGUI histórico `No exported method: EVAL` antes de declarar estable la ventana principal.
- [ ] Definir una batería manual de UI para todas las vistas en GTK3/Linux y WinAPI/Windows, incluyendo foco, teclado, grids, modales, PDF y cambio de idioma.
- [ ] Fijar versiones de Harbour, HWGUI y dependencias nativas por release; abandonar revisiones de desarrollo no fijadas.
- [ ] Crear instalador Windows y paquete Linux que resuelva las dependencias de Harbour, GTK3, SQLite, cURL y Haru PDF.
- [ ] Validar restauración de backup, apertura de PDF y accesos a carpetas en ambos sistemas operativos.

### Criterios de aceptación

- [ ] El producto se instala y arranca en equipos limpios de Linux y Windows.
- [ ] Todas las rutas de UI críticas pasan en ambos backends HWGUI.
- [ ] El artefacto distribuido y sus dependencias quedan versionados y documentados.

## Hito 14: Documentación, trazabilidad y decisión de release

- [ ] Actualizar README, ROADMAP, ADRs y guía de compilación para reflejar el estado realmente verificado.
- [ ] Mantener una tabla de evidencia por release: versiones, build, pruebas, UI, BD, PDF y preproducción AEAT.
- [ ] Publicar una guía de recuperación de BD y una política de backup comprobada.
- [ ] Registrar las decisiones de alcance frente a la referencia .NET en ADRs.
- [ ] Revisar las condiciones de licencia y los avisos de distribución de las dependencias incluidas.

### Criterio de salida para producción

- [ ] Hitos 11, 12 y 13 completados con evidencia conservada.
- [ ] No quedan incidencias bloqueantes de integridad fiscal, seguridad TLS, persistencia o UI.
- [ ] La decisión de activar producción AEAT queda documentada y aprobada por el responsable del producto.

---

## Hitos históricos 1–10

Los siguientes hitos documentan el desarrollo inicial. Su estado no sustituye los criterios de validación y release definidos anteriormente.

Hitos basados en el proyecto Facturas .NET. Cada hito entrega una funcionalidad completa y verificable.

---

## Hito 1: Toolchain + Hola Mundo (semana 1-2)

- [x] Compilar Harbour desde fuente en Linux
- [x] Compilar Harbour para Windows (cross MinGW)
- [x] Compilar HWGUI Linux (GTK3)
- [x] Compilar HWGUI Windows (cross MinGW)
- [x] Compilar contribs: hbsqlit3, hbhpdf, hbcurl, hbssl, hbxml, hbjson, hbzebra, hbziparc
- [x] Crear facturas.hbp (Harbour Project)
- [x] Hola Mundo HWGUI: ventana con menú en Linux
- [x] Hola Mundo HWGUI: ventana con menú en Windows (cross)

## Hito 2: Modelos + DB (semana 3-4)

- [x] Crear tablas SQLite: Cliente, Articulo, Pais, TipoIva, TipoIdentificacion, Configuracion
- [x] Crear tablas SQLite: Factura, LineaFactura, RegistroFacturacion, RegistroEvento
- [x] Crear tablas SQLite: Proveedor, CategoriaGasto, Gasto, LineaGasto, BienInversion
- [x] Seed de datos: países (29), tipos IVA (6), tipos identificación (6), config básica
- [x] Seed de datos: categorías gasto (10)
- [x] Clase ConfiguracionService: Obtener/Establecer clave-valor
- [x] Clase PaisService: CRUD paises
- [x] Clase TipoIvaService: CRUD tipos IVA
- [x] Clase TipoIdentificacionService: CRUD tipos identificación
- [x] Inicialización de BD en primer arranque

## Hito 3: CRUD Maestros (semana 5-6) ✅

- [x] Ventana Paises: listado, nuevo, editar, eliminar
- [x] Ventana TiposIVA: listado, nuevo, editar, eliminar
- [x] Ventana TiposIdentificacion: listado, nuevo, editar, eliminar
- [x] Ventana Clientes: listado, nuevo, editar, eliminar (combos país/tipo ID)
- [x] Ventana Articulos: listado, nuevo, editar, eliminar (combo tipo IVA)
- [x] Ventana Empresa: datos emisor + configuración VERI*FACTU + IVA + IRPF
- [x] ClienteService, ArticuloService: CRUD con SQLite

## Hito 4: Facturas + PDF + VERI*FACTU (semana 7-10)

### 4.1 Backend servicios (completado)
- [x] Cálculos automáticos: Importe línea, BaseImponible, IvaImporte, Total (NumericHelper)
- [x] IRPF configurable (EmpresaView + FacturaService)
- [x] Guardar factura en BD con líneas (FacturaService)
- [x] Numeración automática de facturas
- [x] Calcular hash AEAT con hb_sha256() (VeriFactuService)
- [x] Cadena de bloques: encadenar registros (RegistroFacturacion con hash anterior)
- [x] Desglose IVA agrupado por TipoIva (JSON serializado)
- [x] Generar URL QR verificación AEAT (QRService)
- [x] Registro de eventos con hash chain (EventoService)
- [x] Constantes AEAT: tipos factura, URLs pre/producción (AeatConstants)

### 4.2 Vista factura + PDF (completado)
- [x] Ventana Facturas: listado con filtros (nº, fecha, cliente, tipo, total, estado)
- [x] Ventana Nueva/Editar Factura: cabecera, selector cliente, tabla líneas
- [x] Editar líneas: añadir/quitar artículo, cantidad, precio, IVA (auto-relleno desde artículo)
- [x] Cálculos automáticos: Importe línea, BaseImponible, IvaImporte, Total
- [x] Generación PDF con hbhpdf (cabecera, líneas, totales)

### 4.3 SOAP AEAT (completado)
- [x] Cliente SOAP AEAT con hbcurl + XML (preproducción/producción)
- [x] Enviar registro alta a AEAT
- [x] Enviar registro anulación
- [x] Parseo respuesta CSV / errores
- [x] Certificado PKCS#12 para autenticación mutua TLS

## Hito 6: Gastos + Secundarios (semana 11-12)

- [ ] Ventana Proveedores: CRUD
- [ ] Ventana CategoriasGasto: CRUD
- [ ] Ventana BienesInversion: CRUD
- [ ] Ventana Gastos: listado, nuevo, editar
- [ ] Exportación CSV gastos
- [ ] Modelos 303, 390 (si procede)

## Hito 7: Multi-idioma + Instalador (semana 13-14)

- [ ] Sistema de traducción (ES, EN, CA, EU, FR) — claves desde .resx del proyecto .NET
- [ ] Instalador Windows (NSIS o Inno Setup)
- [ ] Script Linux (AppImage o script)
- [ ] Build automatizado (makefile)
- [ ] Pruebas de regresión contra proyecto .NET

## Hito 8: Refinamiento (semana 15-16)

- [ ] Filtros en todos los listados
- [ ] Exportación PDF listados
- [ ] Exportación CSV listados
- [ ] Barra de estado, mensajes de error
- [ ] Log de eventos con hash chain
- [ ] Tema claro/oscuro (si HWGUI lo soporta)
