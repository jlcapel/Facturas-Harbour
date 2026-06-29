<!--
Facturas-Harbour — App de facturación VERI*FACTU (España)
Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
Licensed under GPLv3. Commercial license available.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
-->

# Roadmap — Facturas Harbour

Hitos basados en el proyecto Facturas .NET. Cada hito entrega una funcionalidad completa y verificable.

---

## Hito 1: Toolchain + Hola Mundo (semana 1-2)

- [ ] Compilar Harbour desde fuente en Linux
- [ ] Compilar Harbour para Windows (cross MinGW)
- [ ] Compilar HWGUI Linux (GTK2)
- [ ] Compilar HWGUI Windows (cross MinGW)
- [ ] Compilar contribs: hbsqlit3, hbhpdf, hbcurl, hbssl, hbxml, hbjson, hbzebra, hbziparc
- [ ] Crear facturas.hbp (Harbour Project)
- [ ] Hola Mundo HWGUI: ventana con menú en Linux
- [ ] Hola Mundo HWGUI: ventana con menú en Windows (cross)

## Hito 2: Modelos + DB (semana 3-4)

- [ ] Crear tablas SQLite: Cliente, Articulo, Pais, TipoIva, TipoIdentificacion, Configuracion
- [ ] Crear tablas SQLite: Factura, LineaFactura, RegistroFacturacion, RegistroEvento
- [ ] Seed de datos: paises (~27), tipos IVA (6), tipos identificación (6), config básica
- [ ] Clase ConfiguracionService: Obtener/Establecer clave-valor
- [ ] Script de inicialización de BD en primer arranque

## Hito 3: CRUD Maestros (semana 5-6)

- [ ] Ventana Paises: listado, nuevo, editar, eliminar
- [ ] Ventana TiposIVA: listado, nuevo, editar, eliminar
- [ ] Ventana TiposIdentificacion: listado, nuevo, editar, eliminar
- [ ] Ventana Clientes: listado, nuevo, editar, eliminar, validación NIF
- [ ] Ventana Articulos: listado, nuevo, editar, eliminar
- [ ] Ventana Empresa: datos emisor + configuración VERI*FACTU

## Hito 4: Facturas + PDF (semana 7-8)

- [ ] Ventana Facturas: listado con filtros
- [ ] Ventana Nueva Factura: cabecera, selector cliente, tabla líneas
- [ ] Editar líneas: añadir/quitar artículo, cantidad, precio, IVA
- [ ] Cálculos automáticos: Importe línea, BaseImponible, IvaImporte, Total
- [ ] IRPF configurable por factura
- [ ] Generación PDF con hbhpdf (cabecera, líneas, totales)
- [ ] Guardar factura en BD

## Hito 5: VERI*FACTU (semana 9-10)

- [ ] Calcular hash AEAT con hb_sha256()
- [ ] Cadena de bloques: encadenar registros
- [ ] Desglose IVA agrupado
- [ ] Generar QR con hbzebra
- [ ] Cliente SOAP AEAT con hbcurl + xml (preproducción)
- [ ] Enviar registro alta a AEAT
- [ ] Recibir y parsear respuesta CSV
- [ ] Enviar registro anulación
- [ ] Subsanación de facturas
- [ ] Interfaz ver estado AEAT (pendiente, CSV, error)

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
