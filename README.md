# mod-hearthstone-cd

Sets Hearthstone (and related hearth items) to a **5-minute** cooldown via world SQL, plus an optional client `Spell.dbc` patch so the UI timer matches.

## Purpose / scope

| Layer | Role |
|-------|------|
| Module SQL | Server-side spell/item cooldown = 300 seconds |
| `HearthstoneCd.CooldownSeconds` in conf | Documents intended CD (SQL baked for 300) |
| `tools/patch-hearthstone-dbc.sh` | Optional client DBC so the icon timer matches |

Does **not** change other item cooldowns or hearthstone hearthstone-bind behaviour.

## Configuration

See `conf/hearthstoneCd.conf.dist`:

| Key | Default | Meaning |
|-----|---------|---------|
| `HearthstoneCd.CooldownSeconds` | 300 | Documented cooldown; change requires matching SQL/DBC |

## Install

```bash
cd modules
git submodule add https://github.com/VenomekPL/mod-hearthstone-cd.git mod-hearthstone-cd
```

### Client DBC (optional but recommended)

```bash
./tools/patch-hearthstone-dbc.sh /path/to/Spell.dbc
```

Clear the client `Cache/` folder after patching.

## License

AGPL-3.0
