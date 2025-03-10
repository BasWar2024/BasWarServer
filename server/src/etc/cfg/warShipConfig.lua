local warShip = cfgreader "etc.cfg.warShip"
local warShipBattle = cfgreader "etc.cfg.warShipBattle"


local warShipConfig = {}

for k, v in pairs(warShip) do
    local key = string.format("%s_%s_%s", v.cfgId, v.quality, v.level)
    warShipConfig[key] = {}
    for kk, vv in pairs(v) do
        warShipConfig[key][kk] = vv
    end
    local battleCfg = warShipBattle[v.warShipBattleCfgId]
    if battleCfg then
        for kk, vv in pairs(battleCfg) do
            if kk ~= "cfgId" and kk ~= "index" then
                warShipConfig[key][kk] = vv
            end
        end
    end
end

return warShipConfig