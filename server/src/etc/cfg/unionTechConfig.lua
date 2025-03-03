local unionTech = cfgreader "etc.cfg.unionTech"

local configs = {}
for k, v in pairs(unionTech) do
    configs[string.format("%s_%s", tostring(v.cfgId), tostring(v.level))] = v
end
return configs