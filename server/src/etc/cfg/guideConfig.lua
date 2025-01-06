local guide = cfgreader "etc.cfg.guide"

local guideConfig = {}

for k, v in pairs(guide) do

    guideConfig[v.guideId] = guideConfig[v.guideId] or { guideId = v.guideId, subGuides = {} }
    table.insert(guideConfig[v.guideId].subGuides, v)

end

return guideConfig