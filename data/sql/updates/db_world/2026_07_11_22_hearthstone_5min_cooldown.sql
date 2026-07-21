-- Hearthstone and all bind-to-home items: 5 minute cooldown (300000 ms) instead of 30 minutes.
-- Reload: restart worldserver (spell_cooldown_overrides load at startup).

DELETE FROM `spell_cooldown_overrides` WHERE `Id` IN (
    556,    -- Astral Recall (Shaman)
    8690,   -- Hearthstone
    14055,  -- Ruby Slippers
    18034,  -- Gauntlets of the Cheerful Hearth
    22563,  -- Rune of Recall (Alliance)
    22564,  -- Rune of Recall (Horde)
    48129,  -- Scroll of Recall
    60320,  -- Scroll of Recall II
    60321,  -- Scroll of Recall III
    75136   -- Ethereal Portal
);

INSERT INTO `spell_cooldown_overrides`
    (`Id`, `RecoveryTime`, `CategoryRecoveryTime`, `StartRecoveryTime`, `StartRecoveryCategory`, `Comment`)
VALUES
    (556,    300000, 300000, 0, 0, 'Astral Recall - 5 min hearth CD'),
    (8690,   300000, 300000, 0, 0, 'Hearthstone - 5 min hearth CD'),
    (14055,  300000, 300000, 0, 0, 'Ruby Slippers - 5 min hearth CD'),
    (18034,  300000, 300000, 0, 0, 'Gauntlets of the Cheerful Hearth - 5 min hearth CD'),
    (22563,  300000, 300000, 0, 0, 'Rune of Recall (Alliance) - 5 min hearth CD'),
    (22564,  300000, 300000, 0, 0, 'Rune of Recall (Horde) - 5 min hearth CD'),
    (48129,  300000, 300000, 0, 0, 'Scroll of Recall - 5 min hearth CD'),
    (60320,  300000, 300000, 0, 0, 'Scroll of Recall II - 5 min hearth CD'),
    (60321,  300000, 300000, 0, 0, 'Scroll of Recall III - 5 min hearth CD'),
    (75136,  300000, 300000, 0, 0, 'Ethereal Portal - 5 min hearth CD');

-- Scroll of Recall series also stores cooldown on item category 1229 (was 20 min).
UPDATE `item_template`
SET `spellcategorycooldown_1` = 300000
WHERE `spellcategory_1` = 1229
  AND `spellcategorycooldown_1` > 0;
