# mod-hearthstone-cd

Sets Hearthstone (and related hearth items) to a 5-minute cooldown via world SQL, plus an optional client `Spell.dbc` patch so the UI timer matches.

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
