local build = cfgreader "etc.cfg.build"
local buildBattle = cfgreader "etc.cfg.buildBattle"

local buildConfig = {}

for k, v in pairs(build) do
    local key = string.format("%s_%s_%s_%s", v.race, v.style, v.quality, v.level)
    buildConfig[key] = {}
    for kk, vv in pairs(v) do
        buildConfig[key][kk] = vv
    end
    local battleCfg = buildBattle[v.buildBattleCfgId]
    if battleCfg then
        for kk, vv in pairs(battleCfg) do
            if kk ~= "cfgId" and kk ~= "index" then
                buildConfig[key][kk] = vv
            end
        end
    end
end

return buildConfig