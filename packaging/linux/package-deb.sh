#!/bin/bash
set -euo pipefail

cRaiz="$(cd "$(dirname "$0")/../.." && pwd)"
cVersion="${FACTURAS_VERSION:-1.0.15}"
cSalida="$cRaiz/packaging/out/Facturas-Harbour_${cVersion}_amd64.deb"

ValidarPrerequisitos() {
  command -v dpkg-deb >/dev/null
  command -v install >/dev/null
  command -v readlink >/dev/null
  test -x "$cRaiz/build.sh"
  test -r "$cRaiz/LICENSE"
  test -r "$cRaiz/README.md"
  test -r "$cRaiz/packaging/linux/DEBIAN/control"
  test -r "$(readlink -f /usr/local/lib/libharbour.so.3.2)"
}

if [ "${1:-}" = "--check" ]; then
  ValidarPrerequisitos
  printf '%s\n' "Prerequisitos DEB correctos"
  exit 0
fi

if [ "$#" -ne 0 ]; then
  printf '%s\n' "Uso: $0 [--check]" >&2
  exit 1
fi

ValidarPrerequisitos
"$cRaiz/build.sh"

cDirectorioTemporal="$(mktemp -d /tmp/facturas-deb.XXXXXX)"
trap 'rm -rf "$cDirectorioTemporal"' EXIT

mkdir -p "$cDirectorioTemporal/DEBIAN"
mkdir -p "$cDirectorioTemporal/usr/bin"
mkdir -p "$cDirectorioTemporal/usr/lib/facturas-harbour"
mkdir -p "$cDirectorioTemporal/usr/share/doc/facturas-harbour"

install -m 755 "$cRaiz/Facturas" "$cDirectorioTemporal/usr/bin/facturas-harbour"
install -m 644 "$(readlink -f /usr/local/lib/libharbour.so.3.2)" "$cDirectorioTemporal/usr/lib/facturas-harbour/libharbour.so.3.2"
install -m 644 "$cRaiz/LICENSE" "$cDirectorioTemporal/usr/share/doc/facturas-harbour/copyright"
install -m 644 "$cRaiz/README.md" "$cDirectorioTemporal/usr/share/doc/facturas-harbour/README.md"
sed "s/@VERSION@/$cVersion/g" "$cRaiz/packaging/linux/DEBIAN/control" > "$cDirectorioTemporal/DEBIAN/control"

mkdir -p "$cRaiz/packaging/out"
dpkg-deb --build --root-owner-group "$cDirectorioTemporal" "$cSalida"
dpkg-deb --info "$cSalida"
dpkg-deb --contents "$cSalida"
