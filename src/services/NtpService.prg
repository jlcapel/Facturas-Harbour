STATIC lInetInicializado := .F.

FUNCTION ObtenerFechaHoraOficial(cServidor)
   LOCAL cServidorPredeterminado := "hora.roa.es"
   LOCAL aDirecciones, oSocket, cSolicitud, cRespuesta := Space(48)
   LOCAL nEnviados, nRecibidos, dtOficial

   IF cServidor == NIL
      cServidor := cServidorPredeterminado
   ENDIF
   IF !InicializarInet()
      LogError("NtpService", "No se pudo inicializar INET; usando reloj local")
      RETURN hb_DateTime()
   ENDIF
   aDirecciones := hb_inetGetHosts(cServidor)
   IF Empty(aDirecciones)
      LogError("NtpService", "No se resolvió " + cServidor + "; usando reloj local")
      RETURN hb_DateTime()
   ENDIF
   oSocket := hb_inetDGram()
   IF Empty(oSocket)
      LogError("NtpService", "No se creó socket UDP; usando reloj local")
      RETURN hb_DateTime()
   ENDIF
   hb_inetTimeout(oSocket, 5000)
   cSolicitud := Chr(27) + Replicate(Chr(0), 47)
   nEnviados := hb_inetDGramSend(oSocket, aDirecciones[1], 123, cSolicitud)
   IF nEnviados == 48
      nRecibidos := hb_inetDGramRecv(oSocket, @cRespuesta, 48)
   ELSE
      nRecibidos := -1
   ENDIF
   hb_inetClose(oSocket)
   IF nRecibidos < 48
      LogError("NtpService", "Error NTP desde " + cServidor + "; usando reloj local")
      RETURN hb_DateTime()
   ENDIF
   dtOficial := InterpretarFechaHoraOficial(cRespuesta)
   IF dtOficial == NIL
      LogError("NtpService", "Respuesta NTP inválida desde " + cServidor + "; usando reloj local")
      RETURN hb_DateTime()
   ENDIF
   LogInfo("NTP OK desde " + cServidor)
RETURN dtOficial

FUNCTION InterpretarFechaHoraOficial(cRespuesta)
   LOCAL nSegundos

   IF cRespuesta == NIL .OR. Len(cRespuesta) < 48
      RETURN NIL
   ENDIF
   nSegundos := Asc(SubStr(cRespuesta, 41, 1)) * 16777216 + ;
      Asc(SubStr(cRespuesta, 42, 1)) * 65536 + ;
      Asc(SubStr(cRespuesta, 43, 1)) * 256 + Asc(SubStr(cRespuesta, 44, 1))
   IF nSegundos <= 0
      RETURN NIL
   ENDIF
RETURN hb_DateTime(1900, 1, 1, 0, 0, 0) + nSegundos / 86400

FUNCTION ResolverFechaHoraOficial(cRespuesta, dtLocal)
   LOCAL dtOficial := InterpretarFechaHoraOficial(cRespuesta)

   IF dtOficial == NIL
      RETURN dtLocal
   ENDIF
RETURN dtOficial

STATIC FUNCTION InicializarInet()
   IF !lInetInicializado
      lInetInicializado := hb_inetInit()
   ENDIF
RETURN lInetInicializado
