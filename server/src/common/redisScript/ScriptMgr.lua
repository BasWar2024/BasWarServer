local ScriptMgr = class("ScriptMgr")
local DEGUB_PRINT = {
    print_sha = false,
}
local INIT_MOD_SCRIPT = {
    -- ["pvpMatch"] = require "common.redisScript.pvpMatchMod",
}

function ScriptMgr:ctor()
    self.modToSha = {}
    self.scriptToSha = {}
    self:init()
end

function ScriptMgr:init()
    for mod, string in pairs(INIT_MOD_SCRIPT) do
        local oldSha = self.modToSha[mod]
        local sha = self:exeRedisCmd("SCRIPT", "LOAD", string)
        if sha ~= oldSha then
            self.modToSha[mod] = sha
        end
    end
    if DEGUB_PRINT.print_sha then
        print(table.dump(self.modToSha))
    end
end

function ScriptMgr:exeRedisCmd(command, ...)
    if gg.shareProxy then
        return gg.shareProxy:call("exeRedisCmd", command, ...)
    else
        local redisDb = gg.redismgr:getdb()
        return redisDb[command](redisDb, select(1,...))
    end
end

function ScriptMgr:exeRedisScript(mod, func, ...)
    local sha = self.modToSha[mod]
    if not sha then
        return
    end
    local result = self:exeRedisCmd("EVALSHA", sha, 1, func, ...)
    return result
end

function ScriptMgr:registerRedisScript(func, string)
    local oldSha = self.scriptToSha[func]
    local sha = self:exeRedisCmd("SCRIPT", "LOAD", string)
    if sha ~= oldSha then
        self.scriptToSha[func] = sha
    end
end

-- example
-- local args = {
--     REDIS_RANK_KEY = constant.REDIS_MATCH_RANK_BADGE,
--     REDIS_PVP_JACKPOT_INFO = constant.REDIS_PVP_JACKPOT_INFO,
--     REDIS_PVP_JACKPOT_SHARE_RATIO = constant.REDIS_PVP_JACKPOT_SHARE_RATIO,
--     REDIS_PVP_STAGE_RATIO = constant.REDIS_PVP_STAGE_RATIO,
--     REDIS_PLAYER_BASE_INFO = constant.REDIS_PLAYER_BASE_INFO,

--     PID = pid,
--     inPlayerList = cjson.encode(armyPlayerList),
-- }
-- local argsJson = cjson.encode(args)
-- local retInfo = gg.scriptMgr:exeRedisScript("pvpMatch", "getPvpMatchInfo", argsJson)

return ScriptMgr
