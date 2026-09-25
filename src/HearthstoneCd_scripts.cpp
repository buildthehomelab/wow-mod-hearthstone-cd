#include "AllSpellScript.h"
#include "Config.h"
#include "DBCStores.h"
#include "Log.h"
#include "ObjectAccessor.h"
#include "Player.h"
#include "ScriptMgr.h"
#include "SpellInfo.h"
#include "SpellMgr.h"
#include "WorldPacket.h"

namespace
{
    bool sEnabled = true;

    // 0/0 overrides (removed cooldowns) belong to mod-profession-craft-cd.
    bool HasTimedCooldownOverride(uint32 spellId)
    {
        if (!sSpellMgr->HasSpellCooldownOverride(spellId))
            return false;

        SpellCooldownOverride const cd = sSpellMgr->GetSpellCooldownOverride(spellId);
        return cd.RecoveryTime || cd.CategoryRecoveryTime;
    }

    // The 3.3.5 client starts the Spell.dbc Recovery / CategoryRecovery timer on SPELL_GO
    // (30 min Hearthstone, 15 min Astral Recall) and never sees spell_cooldown_overrides.
    // Replace the timer on the cast spell and its category siblings with what the server
    // actually has: SMSG_SPELL_COOLDOWN with the remaining time, or SMSG_CLEAR_COOLDOWN.
    void SyncCooldownsToClient(Player* player, SpellInfo const* spellInfo)
    {
        PacketCooldowns cooldowns;
        auto sync = [player, &cooldowns](uint32 spellId)
        {
            if (uint32 const delay = player->GetSpellCooldownDelay(spellId))
                cooldowns[spellId] = delay;
            else
                player->SendClearCooldown(spellId, player);
        };

        sync(spellInfo->Id);

        if (uint32 const category = spellInfo->GetCategory())
        {
            SpellCategoryStore::const_iterator itr = sSpellsByCategoryStore.find(category);
            if (itr != sSpellsByCategoryStore.end())
            {
                for (auto const& [byItem, siblingId] : itr->second)
                {
                    if (siblingId == spellInfo->Id || cooldowns.count(siblingId))
                        continue;
                    if (!byItem && !player->HasSpell(siblingId))
                        continue;

                    sync(siblingId);
                }
            }
        }

        if (cooldowns.empty())
            return;

        WorldPacket data;
        player->BuildCooldownPacket(data, SPELL_COOLDOWN_FLAG_NONE, cooldowns);
        player->SendDirectMessage(&data);
    }
}

class HearthstoneCd_World : public WorldScript
{
public:
    HearthstoneCd_World() : WorldScript("HearthstoneCd_World") { }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        sEnabled = sConfigMgr->GetOption<bool>("HearthstoneCd.Enabled", true);

        uint32 cd = sConfigMgr->GetOption<uint32>("HearthstoneCd.CooldownSeconds", 300);
        if (cd)
            LOG_INFO("server.loading", "HearthstoneCd: module present ({}s cooldown; SQL + optional DBC patch; client sync {})",
                cd, sEnabled ? "on" : "off");
    }
};

class HearthstoneCd_AllSpell : public AllSpellScript
{
public:
    HearthstoneCd_AllSpell() : AllSpellScript("HearthstoneCd_AllSpell", { ALLSPELLHOOK_ON_CAST }) { }

    void OnSpellCast(Spell* /*spell*/, Unit* caster, SpellInfo const* spellInfo, bool /*skipCheck*/) override
    {
        if (!sEnabled || !caster || !caster->IsPlayer() || !spellInfo)
            return;
        if (!HasTimedCooldownOverride(spellInfo->Id))
            return;

        Player* player = caster->ToPlayer();
        SyncCooldownsToClient(player, spellInfo);

        // Runs after SendSpellGo, but push again once the client has applied SPELL_GO.
        ObjectGuid const guid = player->GetGUID();
        uint32 const spellId = spellInfo->Id;
        player->m_Events.AddEventAtOffset([guid, spellId]()
        {
            Player* p = ObjectAccessor::FindConnectedPlayer(guid);
            if (!p)
                return;
            if (SpellInfo const* info = sSpellMgr->GetSpellInfo(spellId))
                SyncCooldownsToClient(p, info);
        }, 150ms);
    }
};

void AddHearthstoneCdScripts()
{
    new HearthstoneCd_World();
    new HearthstoneCd_AllSpell();
}
