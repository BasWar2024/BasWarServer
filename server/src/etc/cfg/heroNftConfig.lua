local hero = cfgreader "etc.cfg.hero"
local heroBattle = cfgreader "etc.cfg.heroBattle"

local heroConfig = {}

for k, v in pairs(hero) do
    local key = string.format("%s_%s_%s_%s", v.race, v.style, v.quality, v.level)
    heroConfig[key] = {}
    for kk, vv in pairs(v) do
        heroConfig[key][kk] = vv
    end
    local battleCfg = heroBattle[v.heroBattleCfgId]
    if battleCfg then
        for kk, vv in pairs(battleCfg) do
            if kk ~= "cfgId" and kk ~= "index" then
                heroConfig[key][kk] = vv
            end
        end
    end
end

return heroConfig