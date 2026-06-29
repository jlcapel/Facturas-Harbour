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

# 1. Compilar .prg -> .c con harbour
harbour src/main.prg -n -q -m -es2 -d___GTK3___ -isrc -i/usr/local/include/harbour -o/tmp/facturas_main.c

# 2. Compilar .c -> .o con gcc
GTK_CFLAGS=$(pkg-config --cflags gtk+-3.0)
gcc -c -O3 /tmp/facturas_main.c -o /tmp/facturas_main.o -I/usr/local/include/harbour $GTK_CFLAGS -DHWG_USE_POINTER_ITEM

# 3. Enlazar
GTK_LIBS=$(pkg-config --libs gtk+-3.0)
gcc /tmp/facturas_main.o \
  -Wl,--start-group \
  -lhwgui -lprocmisc -lhbxml \
  -lhbcplr -lhbdebug -lharbour \
  $GTK_LIBS -lm \
  -Wl,--end-group \
  -o "$PROJECT" \
  -L"$HARBOUR_LIB"

echo "OK: ./$PROJECT"
