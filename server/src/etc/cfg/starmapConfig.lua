local starmap = cfgreader "etc.cfg.starmap"
local starmap1 = cfgreader "etc.cfg.starmap1"
local starmap2 = cfgreader "etc.cfg.starmap2"
local starmap3 = cfgreader "etc.cfg.starmap3"

local starmapConfig = {}
for k, v in pairs(starmap) do
    starmapConfig[k] = v
end
for k, v in pairs(starmap1) do
    starmapConfig[k] = v
end
for k, v in pairs(starmap2) do
    starmapConfig[k] = v
end
for k, v in pairs(starmap3) do
    starmapConfig[k] = v
end
return starmapConfig