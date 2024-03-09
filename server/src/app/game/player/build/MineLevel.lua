local MineLevel = class("MineLevel")

function MineLevel.getMineCfg(cfgId, level)
    quality = quality or 1
    local mineCfg = cfg.get("etc.cfg.build")
    for k,v in pairs(mineCfg) do
        if v.cfgId == cfgId and v.level == level and v.quality == quality then
            return v
        end
    end
    return nil
end

function MineLevel.create(param)
    local cfgId = param.cfgId
    local level = param.level
    return MineLevel.new(param)
end

function MineLevel:ctor(param)
    self.player = param.player
    self.cfgId = param.cfgId                                             -- id
    self.level = param.level                                             -- 
    self.nextTick = 0                                                    -- 
end

function MineLevel:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    data.nextTick = self.nextTick
    return data
end

function MineLevel:deserialize(data)
    self.cfgId = data.cfgId
    self.level = data.level
    self.nextTick = data.nextTick or 0
end

function MineLevel:pack()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    data.lessTick = self:getLessTick()
    return data
end

function MineLevel:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
end

function MineLevel:getLessTick()
    if self.nextTick <= 0 then
        return 0
    end
    local nowTick = skynet.timestamp()
    local lessTick = math.floor((self.nextTick - nowTick) / 1000)
    if lessTick <= 0 then
        return 0
    end
    return lessTick
end

function MineLevel:checkLevelUp(notNotify)
    if self.nextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return
    end
    self.nextTick = 0
    self.level = self.level + 1
    if not notNotify then
        gg.client:send(self.player.linkobj,"S2C_Player_MineLevelUpdate",{ mineLevel = self:pack() })
    end
    self.player.buildBag:refreshAllMineLevel()
end

return MineLevel