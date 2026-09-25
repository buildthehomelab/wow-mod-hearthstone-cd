-- Force 5 minute hearth cooldown on item templates (client + server read this directly).
-- Both spellcooldown_1 and spellcategorycooldown_1 must be set; -1 category CD breaks client display.
UPDATE `item_template`
SET `spellcooldown_1` = 300000,
    `spellcategorycooldown_1` = 300000
WHERE `entry` IN (
    6948,   -- Hearthstone
    28585,  -- Ruby Slippers
    18149,  -- Rune of Recall (Alliance)
    18150,  -- Rune of Recall (Horde)
    37782,  -- Gauntlets of the Cheerful Hearth
    54452   -- Ethereal Portal
);
