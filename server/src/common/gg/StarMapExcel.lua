local StarMapExcel = class("StarMapExcel")
local STARMAP_CFG_LIST = {
    "etc.cfg.starmap",
    "etc.cfg.starmap1",
    "etc.cfg.starmap2",
    "etc.cfg.starmap3",
}
function StarMapExcel:ctor()
    self.start = 1
    self:init()
end

function StarMapExcel:init()
    local isInit = gg.redisProxy:call("get", constant.REDIS_STARMAP_HASH_INIT)
    if isInit then
        return
    end
    for i, v in ipairs(STARMAP_CFG_LIST) do
        skynet.fork(function(cfgName)
            local cfgData = cfgreader(cfgName)
            self:initRedisCache(cfgData)
            cfgData = nil
            self:unload(cfgName)
        end, v)
    end
    gg.redisProxy:send("set",constant.REDIS_STARMAP_HASH_INIT, 1)
end

function StarMapExcel:initRedisCache(starmap)
    local hasKey = constant.REDIS_STARMAP_H_KEY
    local setKey = constant.REDIS_STARMAP_SET_KEY
    local setKeys = {}
    local setBeginGrids = {}
    local n = 0
    for k,v in pairs(starmap) do
        if v.type == constant.STARMAP_BEGIN_GRID then
            table.insert(setBeginGrids, v.cfgId)
        end
        table.insert(setKeys, v.cfgId)
        local fieldValStr = cjson.encode(v)
        gg.shareProxy:call("setRedisStarMapOneCfg", v.cfgId, fieldValStr)
        n = n + 1
        if n == 100 then
            skynet.sleep(1)
            n = 0
        end
    end
    if table.count(setKeys) > 0 then
        gg.redisProxy:send("sadd", setKey, table.unpack(setKeys))
    end
    if table.count(setBeginGrids) > 0 then
        gg.redisProxy:send("sadd", constant.REDIS_STARMAP_BEGIN_GRIDS, table.unpack(setBeginGrids))
    end
end

function StarMapExcel:unload(name)
    -- package.loaded[name] = nil
    -- _G[name] = nil
end

return StarMapExcel
