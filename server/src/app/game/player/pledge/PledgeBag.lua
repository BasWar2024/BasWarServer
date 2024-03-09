local PledgeBag = class("PledgeBag")

PledgeBag.exprFuncs = {}
function PledgeBag.getExprFunc(cfgId, expression)
    assert(cfgId, "cfgId is nil")
    assert(expression, "expression is nil")
    local expr = PledgeBag.exprFuncs[cfgId]
    if expr and expr.expression == expression then
        return expr.func
    end
    local func = assert(load(expression, "t")(), "load expression error, cfgId="..cfgId)
    PledgeBag.exprFuncs[cfgId] = PledgeBag.exprFuncs[cfgId] or {expression = expression, func = func}
    return func
end

function PledgeBag.getPledgeCfg(cfgId)
    local cfgs = cfg.get("etc.cfg.pledge")
    return cfgs[cfgId]
end

function PledgeBag:ctor(param)
    self.player = param.player
    self.pledges = {}
end

function PledgeBag:serialize()
    local data = {}
    data.pledges = {}
    for k, v in pairs(self.pledges) do
        table.insert(data.pledges, v)
    end
    return data
end

function PledgeBag:deserialize(data)
    self.pledges = {}
    for k, v in pairs(self.pledges) do
        self.pledges[v.cfgId] = v
    end
end

--
function PledgeBag:getRatio(resCfgId)
    local pledgeCfg = PledgeBag.getPledgeCfg(resCfgId)
    if not pledgeCfg then
        return 1
    end
    local pledgeMit = (self.pledges[resCfgId] == nil) and 0 or self.pledges[resCfgId].mit
    local func = PledgeBag.getExprFunc(resCfgId, pledgeCfg.expression)
    if not func then
        return 1
    end
    return func(pledgeMit)
end

function PledgeBag:getMakeResRatioInfo()
    local data = {}
    data.starRatio = self:getRatio(constant.RES_STARCOIN)
    data.iceRatio = self:getRatio(constant.RES_ICE)
    data.carboxylRatio = self:getRatio(constant.RES_CARBOXYL)
    data.titaniumRatio = self:getRatio(constant.RES_TITANIUM)
    data.gasRatio = self:getRatio(constant.RES_GAS)
    return data
end

function PledgeBag:queryPledgeData()
    gg.client:send(self.player.linkobj,"S2C_Player_PledgeData",{pledges=table.values(self.pledges)})
end

function PledgeBag:pledge(cfgId, mit)
    if cfgId <= constant.RES_MIT or cfgId > constant.RES_GAS then
        self.player:say(i18n.format("pledge argument error"))
        return
    end
    if mit <= 0 then
        self.player:say(i18n.format("pledge argument error"))
        return
    end
    local pledgeCfg = PledgeBag.getPledgeCfg(cfgId)
    if not pledgeCfg then
        self.player:say(i18n.format("cannot pledge"))
        return
    end
    local beforeMit = (self.pledges[cfgId] == nil) and 0 or self.pledges[cfgId].mit
    local afterMit = beforeMit + mit
    if afterMit > pledgeCfg.maxMit or afterMit < pledgeCfg.minMit then
        self.player:say(i18n.format("pledge mit num limit"))
        return
    end
    if not self.player.resBag:enoughRes(constant.RES_MIT, mit) then
        self.player:say(i18n.format("mit not enough"))
        return
    end
    self.player.resBag:costRes(cfgId, mit, {reason="pledge mit"})
    self.pledges[cfgId] = self.pledges[cfgId] or {cfgId = cfgId, mit=0}
    self.pledges[cfgId].mit = afterMit
    gg.client:send(self.player.linkobj,"S2C_Player_PledgeAdd",{pledge=self.pledges[cfgId]})

    local ratioInfo = self:getMakeResRatioInfo()
    self.player.resPlanetBag:updateMakeResRatio(ratioInfo)
end

function PledgeBag:cancel(cfgId)
    if cfgId <= constant.RES_MIT or cfgId > constant.RES_GAS then
        self.player:say(i18n.format("pledge argument error"))
        return
    end
    if not self.pledges[cfgId] or self.pledges[cfgId].mit <= 0 then
        self.player:say(i18n.format("you have not pledge"))
        return
    end
    local mit = self.pledges[cfgId].mit
    self.player.resBag:addRes(constant.RES_MIT, mit, "cancel pledge mit")
    self.pledges[cfgId] = nil
    gg.client:send(self.player.linkobj,"S2C_Player_PledgeDel",{cfgId=cfgId})

    local ratioInfo = self:getMakeResRatioInfo()
    self.player.resPlanetBag:updateMakeResRatio(ratioInfo)
end

function PledgeBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_PledgeData",{pledges=table.values(self.pledges)})
end

return PledgeBag