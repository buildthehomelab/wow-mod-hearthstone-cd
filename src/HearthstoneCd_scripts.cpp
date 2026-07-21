#include "ScriptMgr.h"
#include "Config.h"
#include "Log.h"

class HearthstoneCd_World : public WorldScript
{
public:
    HearthstoneCd_World() : WorldScript("HearthstoneCd_World") { }

    void OnAfterConfigLoad(bool /*reload*/) override
    {
        // SQL-only module: world updates live under data/sql/. Conf flag is informational.
        bool enabled /* cooldown configured */ = sConfigMgr->GetOption<uint32>("HearthstoneCd.CooldownSeconds", 300) > 0;
        if (enabled)
            LOG_INFO("server.loading", "HearthstoneCd: module present (SQL updates via module data/sql)");
    }
};

void AddHearthstoneCdScripts()
{
    new HearthstoneCd_World();
}
