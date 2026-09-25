#!/usr/bin/env bash
#
# Write this module's spell_cooldown_overrides (RecoveryTime / CategoryRecoveryTime)
# into a 3.3.5a (12340) Spell.dbc so the client icon timer and tooltips show 5 min
# instead of 30 min (Hearthstone) or 15 min (Astral Recall). Optional: the worldserver
# already syncs the real cooldown to unpatched clients after each cast.
#
# Usage: tools/patch-hearthstone-dbc.sh <Spell.dbc> [output]
#   <Spell.dbc>  3.3.5a Spell.dbc, e.g. the AzerothCore data dir's dbc/Spell.dbc, or one
#                another module's script already patched (input may equal output)
#   [output]     default: ./DBFilesClient/Spell.dbc (ready to pack into an MPQ)
#
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    sed -n '8,11p' "$0" | sed 's/^# \{0,1\}//'
    exit 1
fi

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 - "$1" "${2:-DBFilesClient/Spell.dbc}" "$MODULE_DIR/data/sql/db-world/updates" <<'PY'
import glob, os, re, struct, sys

src, dst, sql_dir = sys.argv[1:4]

FIELD_COUNT = 234            # 3.3.5a Spell.dbc
RECOVERY_TIME = 29           # m_recoveryTime
CATEGORY_RECOVERY_TIME = 30  # m_categoryRecoveryTime (must follow RECOVERY_TIME)

# (Id, RecoveryTime, CategoryRecoveryTime, ...) rows in the module's own SQL; later files win.
row = re.compile(r"\(\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*\d+\s*,\s*\d+\s*,\s*'")
spells = {}
for path in sorted(glob.glob(os.path.join(sql_dir, "*.sql"))):
    with open(path, encoding="utf-8") as f:
        for m in row.finditer(f.read()):
            spell_id, rec, catrec = map(int, m.groups())
            spells[spell_id] = (rec, catrec)

if not spells:
    sys.exit(f"no spell_cooldown_overrides rows found under {sql_dir}")

with open(src, "rb") as f:
    data = bytearray(f.read())

magic, records, fields, record_size, _ = struct.unpack_from("<4s4I", data, 0)
if magic != b"WDBC" or fields != FIELD_COUNT or record_size != FIELD_COUNT * 4:
    sys.exit(f"{src}: not a 3.3.5a Spell.dbc (magic={magic!r} fields={fields} recordSize={record_size})")

found = set()
patched = 0
for i in range(records):
    base = 20 + i * record_size
    spell_id = struct.unpack_from("<I", data, base)[0]
    if spell_id not in spells:
        continue
    found.add(spell_id)
    old = struct.unpack_from("<2I", data, base + RECOVERY_TIME * 4)
    new = spells[spell_id]
    if old != new:
        struct.pack_into("<2I", data, base + RECOVERY_TIME * 4, *new)
        patched += 1
        print(f"  {spell_id:>6}: recovery {old[0]} -> {new[0]} ms, category recovery {old[1]} -> {new[1]} ms")

for spell_id in sorted(set(spells) - found):
    print(f"  {spell_id:>6}: not in {src} (skipped)")

os.makedirs(os.path.dirname(os.path.abspath(dst)), exist_ok=True)
with open(dst, "wb") as f:
    f.write(data)

print(f"Patched {patched} of {len(spells)} spells ({len(found) - patched} already match) -> {dst}")
PY

cat <<'EOF'

Next:
  1. Pack the file into a client patch MPQ as DBFilesClient\Spell.dbc. Every module
     that patches Spell.dbc must go into the same file: only the newest MPQ's copy loads.
  2. Delete the client's Cache/ folder so cached item tooltips (Hearthstone) refresh.
EOF
