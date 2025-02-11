local skill = cfgreader "etc.cfg.skill"
local skillBattle = cfgreader "etc.cfg.skillBattle"
local skillConfig = {}

for k, v in pairs(skill) do
    local key = string.format("%s_%s", v.cfgId, v.level)
    skillConfig[key] = {}
    for kk, vv in pairs(v) do
        skillConfig[key][kk] = vv
    end
    local battleCfg = skillBattle[v.skillBattleCfgId]
    if battleCfg then
        for kk, vv in pairs(battleCfg) do
            if kk ~= "cfgId" and kk ~= "index" then
                skillConfig[key][kk] = vv
            end
        end
    end
end



return skillConfig