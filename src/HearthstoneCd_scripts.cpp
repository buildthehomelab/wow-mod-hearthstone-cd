#include "ScriptMgr.h"
#include "Config.h"
#include "Log.h"

class HearthstoneCd_World : public WorldScript
{
public:
    HearthstoneCd_World() : WorldScript("HearthstoneCd_World") { }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        uint32 cd = sConfigMgr->GetOption<uint32>("HearthstoneCd.CooldownSeconds", 300);
        if (cd)
            LOG_INFO("server.loading", "HearthstoneCd: module present ({}s cooldown; SQL + optional DBC patch)", cd);
    }
};

void AddHearthstoneCdScripts()
{
    new HearthstoneCd_World();
}
