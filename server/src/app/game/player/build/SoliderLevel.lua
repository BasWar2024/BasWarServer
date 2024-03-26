local SoliderLevel = class("SoliderLevel")


function SoliderLevel.getSoliderCfg(cfgId, level)
    local key = string.format("%s_%s", cfgId, level)
    local soliderCfgs = cfg.get("etc.cfg.soliderConfig")
    return soliderCfgs[key]
end

function SoliderLevel.create(param)
    local cfgId = param.cfgId
    local level = param.level
    return SoliderLevel.new(param)
end

function SoliderLevel:ctor(param)
    self.player = param.player
    self.cfgId = param.cfgId                                             -- ""id
    self.level = param.level                                             -- ""
    self.nextTick = 0                                                    -- ""
end

function SoliderLevel:serialize()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    data.nextTick = self.nextTick
    return data
end

function SoliderLevel:deserialize(data)
    self.cfgId = data.cfgId
    self.level = data.level
    self.nextTick = data.nextTick or 0
end

function SoliderLevel:pack()
    local data = {}
    data.cfgId = self.cfgId
    data.level = self.level
    data.lessTick = self:getLessTick()
    return data
end

function SoliderLevel:setNextTick(needTick)
    self.nextTick = skynet.timestamp() + needTick
end

function SoliderLevel:getLessTick()
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

function SoliderLevel:checkLevelUp(notNotify)
    if self.nextTick <= 0 then
        return
    end
    local nowTick = skynet.timestamp()
    if nowTick < self.nextTick then
        return
    end
    self.nextTick = 0
    self.level = self.level + 1
    self.player.taskBag:update(constant.TASK_LVUP_SOLIDERS, {cfgId = self.cfgId, count = 1})
    self.player.taskBag:update(constant.TASK_SOLDIER_LV, {cfgId = self.cfgId, lv = self.level})
    if not notNotify then
        gg.client:send(self.player.linkobj, "S2C_Player_SoliderLevelUpdate", { soliderLevel = self:pack() })
    end
end

return SoliderLevel