#!/usr/bin/env bash
set -euo pipefail

cDirectorioTemporal="$(mktemp -d /tmp/facturas-harbour-pruebas.XXXXXX)"
trap 'rm -rf -- "$cDirectorioTemporal"' EXIT

hbmk2 -q -o"$cDirectorioTemporal/pruebas_fiscales" \
  tests/prueba_humo.prg src/utils/NumericHelper.prg \
  -i/usr/local/share/harbour/contrib/hbtest \
  -i/usr/local/share/harbour/contrib/hbsqlit3 \
  -lhbtest -lhbsqlit3 -lsqlite3

FACTURAS_PRUEBA_DB="$cDirectorioTemporal/facturas-prueba.db" \
  "$cDirectorioTemporal/pruebas_fiscales"
