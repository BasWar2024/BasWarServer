local SoliderForgeLevel = class("SoliderForgeLevel")

function SoliderForgeLevel.create(param)
    return SoliderForgeLevel.new(param)
end

function SoliderForgeLevel.getSoliderForgeLevelCfg(cfgId, level)
    local forgeCfg = cfg.get("etc.cfg.soliderForge")
    for k, v in pairs(forgeCfg) do
        if v.cfgId == cfgId and v.level == level then
            return v
        end
    end
end

function SoliderForgeLevel:ctor(param)
    self.player = param.player
    self.cfgId = param.cfgId or 0
    self.level = param.level or 0
end

function SoliderForgeLevel:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    return data
end

function SoliderForgeLevel:deserialize(data)
    if data then
        self.cfgId = data.cfgId or 0
        self.level = data.level or 0
    end
end

function SoliderForgeLevel:pack()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    return data
end

return SoliderForgeLevel