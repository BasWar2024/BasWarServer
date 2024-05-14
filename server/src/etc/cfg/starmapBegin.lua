local starmap = cfg.get("etc.cfg.starmapConfig")

local starmapBegin = {}
for k, v in pairs(starmap) do
    if v.type == constant.STARMAP_BEGIN_GRID then
        -- starmapBegin[v.cfgId] = true
        if v.isBan == 1 then
            table.insert(starmapBegin, v.cfgId)
        end
        -- if v.isBan == 1 then
        --     starmapBegin[v.chainID] = starmapBegin[v.chainID] or {}
        --     table.insert(starmapBegin[v.chainID], v.cfgId)
        -- end
    end
end

return starmapBegin