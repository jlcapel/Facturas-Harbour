#!/bin/bash
set -euo pipefail

cRaiz="$(cd "$(dirname "$0")/../.." && pwd)"
cVersion="${FACTURAS_VERSION:-1.0.15}"
cScriptNsi="$cRaiz/packaging/windows/Facturas-Harbour.nsi"

ValidarPrerequisitos() {
  if ! command -v makensis >/dev/null; then
    printf '%s\n' "Falta makensis; instale NSIS para crear el instalador Windows" >&2
    return 1
  fi
  test -x "$cRaiz/build.sh"
  test -r "$cRaiz/LICENSE"
  test -r "$cScriptNsi"
}

if [ "${1:-}" = "--check" ]; then
  ValidarPrerequisitos
  printf '%s\n' "Prerequisitos NSIS correctos"
  exit 0
fi

if [ "$#" -ne 0 ]; then
  printf '%s\n' "Uso: $0 [--check]" >&2
  exit 1
fi

ValidarPrerequisitos
"$cRaiz/build.sh" win
mkdir -p "$cRaiz/packaging/out"
makensis -DPRODUCT_VERSION="$cVersion" -DSOURCE_ROOT="$cRaiz" "$cScriptNsi"
