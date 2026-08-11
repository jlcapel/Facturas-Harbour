#require "hbtest"
#require "hbsqlit3"
#include "hbtest.ch"
#include "hbsqlit3.ch"

PROCEDURE Main()
   LOCAL cDirectorio := hb_GetEnv("FACTURAS_PRUEBA_DIR")
   LOCAL db := sqlite3_open(cDirectorio + "/alta-atomica.db", .T.)
   LOCAL nAlta, nDuplicada, nLinea, nSnapshot, nRegistro, nEvento, nSubsanacion, nSubsanacionFallida
   LOCAL nAnulacion, nDobleAnulacion, nAltaRollback, nAnulacionFallida
   LOCAL lAlta, lDuplicada, lLinea, lSnapshot, lRegistro, lEvento, lSubsanacion, lRollbackSubsanacion
   LOCAL lAnulacion, lDobleAnulacion, lRollbackAnulacion, lEnvio

   PUBLIC nEnviosPrueba, lEnvioFueraTransaccion
   nEnviosPrueba := 0
   lEnvioFueraTransaccion := .F.

   HBTEST !Empty(db) IS .T.
   IF Empty(db)
      ErrorLevel(1)
      RETURN
   ENDIF
   CrearTablas(db)
   AsegurarEsquemaFiscal(db)
   AsegurarEsquemaVersionesFiscales(db)
   PrepararDatos(db)

   nAlta := CrearFactura(db, FacturaPrueba("F-001"), LineasPrueba("Servicio correcto"))
   lAlta := nAlta > 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 1 .AND. Conteo(db, "FacturasDesglosesIva") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1 .AND. ;
      Conteo(db, "RegistrosEvento") == 1

   nDuplicada := CrearFactura(db, FacturaPrueba("F-001"), LineasPrueba("Duplicada"))
   lDuplicada := nDuplicada == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1

   sqlite3_exec(db, "CREATE TRIGGER fallo_linea BEFORE INSERT ON LineasFactura WHEN NEW.Descripcion='Fallo linea' BEGIN SELECT RAISE(ABORT, 'fallo linea'); END")
   nLinea := CrearFactura(db, FacturaPrueba("F-002"), LineasPrueba("Fallo linea"))
   sqlite3_exec(db, "DROP TRIGGER fallo_linea")
   lLinea := nLinea == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1 .AND. Conteo(db, "RegistrosEvento") == 1

   sqlite3_exec(db, "CREATE TRIGGER fallo_snapshot BEFORE INSERT ON FacturasVersionesFiscales BEGIN SELECT RAISE(ABORT, 'fallo snapshot'); END")
   nSnapshot := CrearFactura(db, FacturaPrueba("F-003"), LineasPrueba("Fallo snapshot"))
   sqlite3_exec(db, "DROP TRIGGER fallo_snapshot")
   lSnapshot := nSnapshot == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 1 .AND. Conteo(db, "FacturasDesglosesIva") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1 .AND. Conteo(db, "RegistrosEvento") == 1

   sqlite3_exec(db, "CREATE TRIGGER fallo_registro BEFORE INSERT ON RegistrosFacturacion WHEN NEW.NumeroFactura='F-004' BEGIN SELECT RAISE(ABORT, 'fallo registro'); END")
   nRegistro := CrearFactura(db, FacturaPrueba("F-004"), LineasPrueba("Fallo registro"))
   sqlite3_exec(db, "DROP TRIGGER fallo_registro")
   lRegistro := nRegistro == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 1 .AND. Conteo(db, "FacturasDesglosesIva") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1 .AND. Conteo(db, "RegistrosEvento") == 1

   sqlite3_exec(db, "CREATE TRIGGER fallo_evento BEFORE INSERT ON RegistrosEvento WHEN NEW.TipoEvento='CreacionFactura' BEGIN SELECT RAISE(ABORT, 'fallo evento'); END")
   nEvento := CrearFactura(db, FacturaPrueba("F-005"), LineasPrueba("Fallo evento"))
   sqlite3_exec(db, "DROP TRIGGER fallo_evento")
   lEvento := nEvento == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 1 .AND. Conteo(db, "FacturasDesglosesIva") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 1 .AND. Conteo(db, "RegistrosFacturacion") == 1 .AND. Conteo(db, "RegistrosEvento") == 1

   nSubsanacion := SubsanarFactura(db, nAlta, FacturaPrueba("F-001"), LineasPrueba("Servicio corregido", 200))
   lSubsanacion := nSubsanacion == nAlta .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 2 .AND. Conteo(db, "FacturasDesglosesIva") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 2 .AND. Conteo(db, "RegistrosFacturacion") == 2 .AND. ;
      Conteo(db, "RegistrosEvento") == 2 .AND. LeerTexto(db, "SELECT Descripcion FROM LineasFactura WHERE FacturaId=1") == "Servicio correcto" .AND. ;
      AllTrim(LeerTexto(db, "SELECT BaseImponible FROM Facturas WHERE Id=1")) == "100.00" .AND. ;
      LeerTexto(db, "SELECT BaseImponible FROM FacturasVersionesFiscales WHERE TipoRegistro=2") == "200.00" .AND. ;
      LeerNumero(db, "SELECT FacturaVersionFiscalId FROM RegistrosFacturacion WHERE TipoRegistro=2") > 0 .AND. VerificarCadenaRegistros(db)

   sqlite3_exec(db, "CREATE TRIGGER fallo_subsanacion BEFORE INSERT ON FacturasVersionesFiscales BEGIN SELECT RAISE(ABORT, 'fallo subsanacion'); END")
   nSubsanacionFallida := SubsanarFactura(db, nAlta, FacturaPrueba("F-001"), LineasPrueba("No persistir", 300))
   sqlite3_exec(db, "DROP TRIGGER fallo_subsanacion")
   lRollbackSubsanacion := nSubsanacionFallida == 0 .AND. Conteo(db, "Facturas") == 1 .AND. Conteo(db, "LineasFactura") == 1 .AND. ;
      Conteo(db, "FacturasVersionesFiscales") == 2 .AND. Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 2 .AND. ;
      Conteo(db, "RegistrosFacturacion") == 2 .AND. Conteo(db, "RegistrosEvento") == 2

   nAnulacion := AnularFactura(db, nAlta, "Error material")
   lAnulacion := nAnulacion > 0 .AND. nAnulacion != nAlta .AND. Conteo(db, "Facturas") == 2 .AND. ;
      Conteo(db, "LineasFactura") == 2 .AND. Conteo(db, "FacturasVersionesFiscales") == 3 .AND. ;
      Conteo(db, "FacturasDesglosesIva") == 2 .AND. Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 3 .AND. ;
      Conteo(db, "RegistrosFacturacion") == 3 .AND. Conteo(db, "RegistrosEvento") == 3 .AND. ;
      LeerNumero(db, "SELECT Estado FROM Facturas WHERE Id=1") == 0 .AND. ;
      LeerTexto(db, "SELECT Descripcion FROM LineasFactura WHERE FacturaId=1") == "Servicio correcto" .AND. ;
      AllTrim(LeerTexto(db, "SELECT BaseImponible FROM Facturas WHERE Id=" + LTrim(Str(nAnulacion)))) == "-100.00" .AND. ;
      LeerNumero(db, "SELECT FacturaRectificadaId FROM Facturas WHERE Id=" + LTrim(Str(nAnulacion))) == nAlta .AND. ;
      LeerNumero(db, "SELECT TipoFactura FROM Facturas WHERE Id=" + LTrim(Str(nAnulacion))) == 2 .AND. ;
      LeerTexto(db, "SELECT AeatTipoFactura FROM Facturas WHERE Id=" + LTrim(Str(nAnulacion))) == "R5" .AND. ;
      LeerNumero(db, "SELECT FacturaVersionFiscalId FROM RegistrosFacturacion WHERE FacturaId=" + LTrim(Str(nAnulacion)) + " AND TipoRegistro=1") > 0 .AND. ;
      AllTrim(LeerTexto(db, "SELECT Total FROM RegistrosFacturacion WHERE FacturaId=" + LTrim(Str(nAnulacion)) + " AND TipoRegistro=1")) == "121.00" .AND. ;
      LeerTexto(db, "SELECT HashAnterior FROM RegistrosFacturacion WHERE FacturaId=" + LTrim(Str(nAnulacion)) + " AND TipoRegistro=1") == ;
      LeerTexto(db, "SELECT Hash FROM RegistrosFacturacion WHERE Id=2") .AND. ;
      LeerNumero(db, "SELECT IdRegistroAnterior FROM RegistrosFacturacion WHERE FacturaId=" + LTrim(Str(nAnulacion)) + " AND TipoRegistro=1") == 2

   nDobleAnulacion := AnularFactura(db, nAlta, "Error material")
   lDobleAnulacion := nDobleAnulacion == 0 .AND. Conteo(db, "Facturas") == 2 .AND. ;
      Conteo(db, "LineasFactura") == 2 .AND. Conteo(db, "FacturasVersionesFiscales") == 3 .AND. ;
      Conteo(db, "RegistrosFacturacion") == 3 .AND. Conteo(db, "RegistrosEvento") == 3

   nAltaRollback := CrearFactura(db, FacturaPrueba("F-006"), LineasPrueba("Original rollback"))
   sqlite3_exec(db, "CREATE TRIGGER fallo_anulacion BEFORE INSERT ON RegistrosFacturacion WHEN NEW.TipoRegistro=1 BEGIN SELECT RAISE(ABORT, 'fallo anulacion'); END")
   nAnulacionFallida := AnularFactura(db, nAltaRollback, "Error material")
   sqlite3_exec(db, "DROP TRIGGER fallo_anulacion")
   lRollbackAnulacion := nAltaRollback > 0 .AND. nAnulacionFallida == 0 .AND. Conteo(db, "Facturas") == 3 .AND. ;
      Conteo(db, "LineasFactura") == 3 .AND. Conteo(db, "FacturasVersionesFiscales") == 4 .AND. ;
      Conteo(db, "FacturasDesglosesIva") == 3 .AND. Conteo(db, "FacturasVersionesFiscalesDesglosesIva") == 4 .AND. ;
      Conteo(db, "RegistrosFacturacion") == 4 .AND. Conteo(db, "RegistrosEvento") == 4
   lEnvio := nEnviosPrueba == 4 .AND. lEnvioFueraTransaccion

   HBTEST lAlta IS .T.
   HBTEST lDuplicada IS .T.
   HBTEST lLinea IS .T.
   HBTEST lSnapshot IS .T.
   HBTEST lRegistro IS .T.
   HBTEST lEvento IS .T.
   HBTEST lSubsanacion IS .T.
   HBTEST lRollbackSubsanacion IS .T.
   HBTEST lAnulacion IS .T.
   HBTEST lDobleAnulacion IS .T.
   HBTEST lRollbackAnulacion IS .T.
   HBTEST lEnvio IS .T.
   db := NIL
   ErrorLevel(Iif(lAlta .AND. lDuplicada .AND. lLinea .AND. lSnapshot .AND. lRegistro .AND. lEvento .AND. ;
      lSubsanacion .AND. lRollbackSubsanacion .AND. lAnulacion .AND. lDobleAnulacion .AND. ;
      lRollbackAnulacion .AND. lEnvio, 0, 1))
RETURN

FUNCTION EnviarRegistroAlta(db, nRegistroId)
   LOCAL lIniciada := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK

   IF lIniciada
      sqlite3_exec(db, "COMMIT")
      lEnvioFueraTransaccion := .T.
   ENDIF
   nEnviosPrueba++
RETURN {.T., "", ""}

FUNCTION ObtenerFechaHoraOficial()
RETURN hb_DateTime(2026, 8, 10, 12, 0, 0)

FUNCTION EnviarRegistroAnulacion(db, nRegistroId)
   LOCAL lIniciada := sqlite3_exec(db, "BEGIN IMMEDIATE") == SQLITE_OK

   IF lIniciada
      sqlite3_exec(db, "COMMIT")
      lEnvioFueraTransaccion := .T.
   ENDIF
   nEnviosPrueba++
RETURN {.T., "", ""}

FUNCTION LogInfo(cTexto)
RETURN NIL

STATIC FUNCTION PrepararDatos(db)
   sqlite3_exec(db, "INSERT INTO Paises(Id, Codigo, Nombre, Nacionalidad, EsUE, Activo) VALUES(1, 'ES', 'España', 'Española', 1, 1)")
   sqlite3_exec(db, "INSERT INTO TiposIdentificacion(Id, CodigoAEAT, Nombre, Activo) VALUES(1, '07', 'NIF', 1)")
   sqlite3_exec(db, "INSERT INTO TiposIva(Id, Nombre, Porcentaje, Impuesto, ClaveRegimen, CalificacionOperacion, Activo, FechaInicio) VALUES(1, 'IVA General', '21.00', '01', '01', 'S1', 1, '2026-01-01')")
   sqlite3_exec(db, "INSERT INTO Clientes(Id, Nombre, TipoCliente, PaisId, TipoIdentificacionId, Nif, Activo) VALUES(1, 'Cliente prueba', 0, 1, 1, '12345678Z', 1)")
   sqlite3_exec(db, "INSERT INTO Configuracion(Clave, Valor) VALUES('Empresa.Nif', 'B12345674')")
   sqlite3_exec(db, "INSERT INTO Configuracion(Clave, Valor) VALUES('Empresa.Nombre', 'Empresa prueba')")
   sqlite3_exec(db, "INSERT INTO Configuracion(Clave, Valor) VALUES('IRPF.Porcentaje', '0')")
RETURN NIL

STATIC FUNCTION FacturaPrueba(cNumero)
RETURN {cNumero, hb_SToD("20260810"), NIL, 1, 0, 0, NIL, "Servicio profesional", "F1", "", 0, 0, 0, 0, 0, NIL, NIL}

STATIC FUNCTION LineasPrueba(cDescripcion, nImporte)
   IF nImporte == NIL
      nImporte := 100
   ENDIF
RETURN {{0, NIL, 1, cDescripcion, 1, nImporte, 21, nImporte, NIL, NIL, NIL, NIL, "IVA General", "01", "01", "S1", NIL, ""}}

STATIC FUNCTION Conteo(db, cTabla)
   LOCAL stmt := sqlite3_prepare(db, "SELECT COUNT(*) FROM " + cTabla)
   LOCAL nConteo := 0

   IF !Empty(stmt)
      IF sqlite3_step(stmt) == SQLITE_ROW
         nConteo := sqlite3_column_int(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
RETURN nConteo

STATIC FUNCTION LeerTexto(db, cSql)
   LOCAL stmt := sqlite3_prepare(db, cSql)
   LOCAL cValor := ""

   IF !Empty(stmt)
      IF sqlite3_step(stmt) == SQLITE_ROW
         cValor := sqlite3_column_text(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
RETURN cValor

STATIC FUNCTION LeerNumero(db, cSql)
   LOCAL stmt := sqlite3_prepare(db, cSql)
   LOCAL nValor := 0

   IF !Empty(stmt)
      IF sqlite3_step(stmt) == SQLITE_ROW
         nValor := sqlite3_column_int(stmt, 1)
      ENDIF
      sqlite3_finalize(stmt)
   ENDIF
RETURN nValor
