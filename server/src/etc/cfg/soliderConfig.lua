local solider = cfgreader "etc.cfg.solider"
local soliderBattle = cfgreader "etc.cfg.soliderBattle"

local soliderConfig = {}

for k, v in pairs(solider) do
    local key = string.format("%s_%s", v.cfgId, v.level)
    soliderConfig[key] = {}
    for kk, vv in pairs(v) do
        soliderConfig[key][kk] = vv
    end
    local battleCfg = soliderBattle[v.soliderBattleCfgId]
    if battleCfg then
        for kk, vv in pairs(battleCfg) do
            if kk ~= "cfgId" and kk ~= "index" then
                soliderConfig[key][kk] = vv
            end
        end
    end
end

return soliderConfig