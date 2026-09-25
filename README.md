# mod-hearthstone-cd

Sets Hearthstone (and related hearth items) to a **5-minute** cooldown via world SQL, plus an optional client `Spell.dbc` patch so the UI timer matches.

## Purpose / scope

| Layer | Role |
|-------|------|
| Module SQL | Server-side spell/item cooldown = 300 seconds |
| `HearthstoneCd.Enabled` in conf | Syncs the real cooldown to the 3.3.5 client after each cast (see below) |
| `HearthstoneCd.CooldownSeconds` in conf | Documents intended CD (SQL baked for 300) |
| `tools/patch-hearthstone-dbc.sh` | Optional client DBC so tooltips and the icon timer match before the first cast |

Does **not** change other item cooldowns or hearthstone hearthstone-bind behaviour.

## Configuration

See `conf/hearthstoneCd.conf.dist`:

| Key | Default | Meaning |
|-----|---------|---------|
| `HearthstoneCd.Enabled` | 1 | Push the server cooldown to the client after each cast |
| `HearthstoneCd.CooldownSeconds` | 300 | Documented cooldown; change requires matching SQL/DBC |

## Install

```bash
cd modules
git clone https://github.com/buildthehomelab/wow-mod-hearthstone-cd.git mod-hearthstone-cd
```

Clone into `mod-hearthstone-cd` (no `wow-` prefix): AzerothCore derives the loader
symbol from the folder name. Fork of
[VenomekPL/mod-hearthstone-cd](https://github.com/VenomekPL/mod-hearthstone-cd).

The worldserver updater applies `data/sql/db-world/updates/` on start; then
**restart** worldserver (`spell_cooldown_overrides` load at startup).

## Client cooldown

The 3.3.5 client reads its own **Spell.dbc** and starts that timer when the cast
lands (`SMSG_SPELL_GO`): 30 min for Hearthstone, 15 min for Astral Recall. It
greys the button out for that long even though the server allows a recast
after 5 min.

With `HearthstoneCd.Enabled = 1`, after each cast of a spell with a non-zero
`spell_cooldown_overrides` row the module replaces the client timers on that
spell and its category siblings with the server's: `SMSG_SPELL_COOLDOWN` with
the remaining time, or `SMSG_CLEAR_COOLDOWN` when the server has none. It sends
right after `SMSG_SPELL_GO` and again 150 ms later. No core patch is needed.
Zero overrides are left to
[mod-profession-craft-cd](https://github.com/buildthehomelab/wow-mod-profession-craft-cd).

### Optional: patched Spell.dbc (tooltips)

```bash
tools/patch-hearthstone-dbc.sh /path/to/azerothcore/data/dbc/Spell.dbc
```

The script writes this module's override values into `DBFilesClient/Spell.dbc`.
Pack it into a client patch MPQ as `DBFilesClient\Spell.dbc` and delete the
client's `Cache/` folder so item tooltips refresh.

Only the newest MPQ's Spell.dbc loads, so every module that patches it must share
one file. Chain the scripts, feeding each one the previous output:

```bash
../mod-profession-craft-cd/scripts/patch-profession-craft-dbc.sh Spell.dbc DBFilesClient/Spell.dbc
tools/patch-hearthstone-dbc.sh DBFilesClient/Spell.dbc DBFilesClient/Spell.dbc
```

## License

AGPL-3.0
