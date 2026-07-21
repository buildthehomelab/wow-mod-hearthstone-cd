-- Fix hearthstone client tooltip/runtime CD: spellcategorycooldown -1 was sent as uint32 max.
-- Set explicit 5 min (300000 ms) on both spell and category cooldown fields.

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
