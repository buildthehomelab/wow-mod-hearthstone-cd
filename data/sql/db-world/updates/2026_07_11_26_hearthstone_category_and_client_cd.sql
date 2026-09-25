-- Hearth items must use the spell's DBC category so category cooldown syncs to the client.
-- Spell 8690 / 75136 use category 1176; runes use 1091. Without this, the client shows 30 min from Spell.dbc.

UPDATE `item_template`
SET `spellcategory_1` = 1176,
    `spellcooldown_1` = 300000,
    `spellcategorycooldown_1` = 300000
WHERE `entry` IN (6948, 54452);

UPDATE `item_template`
SET `spellcategory_1` = 1091,
    `spellcooldown_1` = 300000,
    `spellcategorycooldown_1` = 300000
WHERE `entry` IN (18149, 18150);

UPDATE `item_template`
SET `spellcooldown_1` = 300000,
    `spellcategorycooldown_1` = 300000
WHERE `entry` IN (28585, 37782);

-- Per-character cooldown clears belong in GM tools, not world SQL migrations.
