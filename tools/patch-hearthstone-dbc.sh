#!/usr/bin/env bash
# Patch Spell.dbc so spell 8690 (Hearthstone) shows 5 min instead of 30 min on the client.
# Private servers need BOTH server DB overrides AND client DBC — the icon timer reads Spell.dbc.
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CD_MS=300000

patch_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  python3 - "$f" "$CD_MS" <<'PY'
import struct, sys
path, cd_ms = sys.argv[1], int(sys.argv[2])
with open(path, 'r+b') as fh:
    data = bytearray(fh.read())
rec_count, field_count, rec_size, string_size = struct.unpack_from('<4I', data, 4)
header = 20
patched = False
for i in range(rec_count):
    off = header + i * rec_size
    spell_id = struct.unpack_from('<I', data, off)[0]
    if spell_id == 8690:
        catrec_off = off + 30 * 4
        old = struct.unpack_from('<I', data, catrec_off)[0]
        struct.pack_into('<I', data, catrec_off, cd_ms)
        print(f"Patched {path}: spell 8690 CategoryRecoveryTime {old} -> {cd_ms}")
        patched = True
        break
if not patched:
    sys.exit(f"spell 8690 not found in {path}")
with open(path, 'r+b') as fh:
    fh.seek(0)
    fh.write(data)
    fh.truncate()
PY
}

patch_file "${PROJECT_ROOT}/data/dbc/Spell.dbc"

for client_dbc in \
  "${PROJECT_ROOT}/client/Data/Spell.dbc" \
  "${PROJECT_ROOT}/client/Data/enUS/Spell.dbc" \
  "${PROJECT_ROOT}/client/Data/enGB/Spell.dbc"; do
  patch_file "${client_dbc}"
done

echo "Done. Delete client/Cache/ (especially WDB) and fully restart the WoW client."
