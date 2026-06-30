#!/bin/bash
# Facturas-Harbour — App de facturación VERI*FACTU (España)
# Copyright (c) 2025-2026 José L. Capel — jlcapel@hotmail.com
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.
#
# ---
# Commercial license available for proprietary use.
# Contact: jlcapel@hotmail.com
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
# OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

set -e

PROJECT="Facturas"
HARBOUR_LIB="/usr/local/lib/harbour"
SRCDIR="src"
TMPDIR="/tmp/facturas_build"

# --- Linux (GTK3) build ---
linux_build() {
  rm -rf "$TMPDIR"
  mkdir -p "$TMPDIR"

  # 1. Compilar todos los .prg -> .c con harbour
  find "$SRCDIR" -name "*.prg" | while read f; do
    harbour "$f" -n -q -m -es2 -d___GTK3___ -i"$SRCDIR" -i/usr/local/include/harbour -i/usr/local/share/harbour/contrib/hbsqlit3 -i/usr/local/share/harbour/contrib/hbhpdf -i/usr/local/share/harbour/contrib/hbcurl -o"$TMPDIR"/$(basename "$f" .prg).c
  done

  # 2. Compilar todos los .c -> .o con gcc
  GTK_CFLAGS=$(pkg-config --cflags gtk+-3.0)
  for f in "$TMPDIR"/*.c; do
    gcc -c -O3 "$f" -o "${f%.c}.o" -I/usr/local/include/harbour -I/usr/local/share/harbour/contrib/hbcurl $GTK_CFLAGS -DHWG_USE_POINTER_ITEM
  done

  # 3. Enlazar
  GTK_LIBS=$(pkg-config --libs gtk+-3.0)
  gcc "$TMPDIR"/*.o \
    -Wl,--start-group \
    -lhwgui -lprocmisc -lhbxml \
     -lhbcplr -lhbdebug -lharbour \
     -lhbsqlit3 -lsqlite3 \
     -lhbcurl -lcurl \
     -lhbhpdf -lhpdf \
     $GTK_LIBS -lm \
    -Wl,--end-group \
    -o "$PROJECT" \
    -L"$HARBOUR_LIB" -L/usr/lib/x86_64-linux-gnu

  echo "OK: ./$PROJECT"
}

# --- Windows (MinGW cross-compile) build ---
win_build() {
  local WIN_CC="x86_64-w64-mingw32-gcc"
  local WIN_AR="x86_64-w64-mingw32-ar"
  local WIN_LIB="$HARBOUR_LIB/win/mingw64"
  local WIN_OUT="Facturas.exe"

  rm -rf "$TMPDIR"
  mkdir -p "$TMPDIR"

  # 1. Compilar .prg -> .c (same harbour step, just add -d___MINGW___)
  find "$SRCDIR" -name "*.prg" | while read f; do
    harbour "$f" -n -q -m -es2 -d___MINGW___ -i"$SRCDIR" -i/usr/local/include/harbour -i/usr/local/share/harbour/contrib/hbsqlit3 -i/usr/local/share/harbour/contrib/hbhpdf -i/usr/local/share/harbour/contrib/hbcurl -o"$TMPDIR"/$(basename "$f" .prg).c
  done

  # 2. Compilar .c -> .o con MinGW gcc
  for f in "$TMPDIR"/*.c; do
    $WIN_CC -c -O3 "$f" -o "${f%.c}.o" \
      -I/usr/local/include/harbour \
      -I/usr/local/share/harbour/contrib/hbcurl \
      -I/usr/local/share/harbour/contrib/hbsqlit3 \
      -DHWG_USE_POINTER_ITEM
  done

  # 3. Enlazar con MinGW
  $WIN_CC "$TMPDIR"/*.o \
    -Wl,--start-group \
    "$WIN_LIB"/libhwgui.a \
    "$WIN_LIB"/libprocmisc.a \
    "$WIN_LIB"/libhbxml.a \
    "$WIN_LIB"/libhbcplr.a \
    "$WIN_LIB"/libhbdebug.a \
    "$WIN_LIB"/libhbvmmt.a \
    "$WIN_LIB"/libhbrtl.a \
    "$WIN_LIB"/libhbcommon.a \
    "$WIN_LIB"/libhbpp.a \
    "$WIN_LIB"/libhbmacro.a \
    "$WIN_LIB"/libhbextern.a \
    "$WIN_LIB"/libhbrdd.a \
    "$WIN_LIB"/libhbsix.a \
    "$WIN_LIB"/libhbpcre.a \
    "$WIN_LIB"/libhbhsx.a \
    "$WIN_LIB"/libhblang.a \
    "$WIN_LIB"/libhbusrrdd.a \
    "$WIN_LIB"/libhbuddall.a \
    "$WIN_LIB"/libhbcpage.a \
    "$WIN_LIB"/libhbnortl.a \
    "$WIN_LIB"/libhbnulrdd.a \
    "$WIN_LIB"/librddntx.a \
    "$WIN_LIB"/librddfpt.a \
    "$WIN_LIB"/librddcdx.a \
    "$WIN_LIB"/librddnsx.a \
    "$WIN_LIB"/libgtwin.a \
    "$WIN_LIB"/libgtgui.a \
    "$WIN_LIB"/libhbsqlit3.a \
    "$WIN_LIB"/libhbcurl.a \
    "$WIN_LIB"/libcurl.a \
    "$WIN_LIB"/libhbhpdf.a \
    "$WIN_LIB"/libhpdf.a \
    "$WIN_LIB"/libhbzebra.a \
    "$WIN_LIB"/libhbziparc.a \
    "$WIN_LIB"/libhbzlib.a \
    "$WIN_LIB"/libhbmxml.a \
    -lws2_32 -lcrypt32 -lbcrypt -lgdi32 -lgdiplus -lwinspool -lwinmm -lole32 -loleaut32 -lcomctl32 -lcomdlg32 -luuid \
    -lsqlite3 \
    -Wl,--end-group \
    -o "$WIN_OUT"

  echo "OK: ./$WIN_OUT"
}

# --- Main ---
case "${1:-linux}" in
  linux|Linux|lin)
    linux_build
    ;;
  windows|win|Windows|mingw)
    win_build
    ;;
  all)
    linux_build
    win_build
    ;;
  *)
    echo "Uso: $0 [linux|win|all] (default: linux)"
    exit 1
    ;;
esac
