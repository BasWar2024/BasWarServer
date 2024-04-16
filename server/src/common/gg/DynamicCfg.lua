local DynamicCfg = class("DynamicCfg")

function DynamicCfg:ctor()
    self.cfgs = {}
end

function DynamicCfg:onDynamicCfgUpdate(chan, data)
    if not self.cfgs[chan] then
        return
    end
    self.cfgs[chan] = data
end

function DynamicCfg:get(key)
    if self.cfgs[key] then
        return self.cfgs[key]
    end
    local cfgData = gg.shareProxy:call("getDynamicCfg", key)
    if not cfgData then
        return
    end
    self.cfgs[key] = cfgData
    if gg.multicastProxy then
        gg.multicastProxy:subscribe(key, self.onDynamicCfgUpdate, self)
    end
    return cfgData
end

function DynamicCfg:set(key, data)
    gg.shareProxy:call("setDynamicCfg", key, data)
    if self.cfgs[key] then
        self.cfgs[key] = data
    end
    if gg.multicastProxy then
        gg.multicastProxy:publish(key, data)
    end
end


return DynamicCfg