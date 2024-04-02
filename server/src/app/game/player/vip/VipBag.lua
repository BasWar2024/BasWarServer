local VipBag = class("VipBag")

function VipBag:ctor(param)
    self.player = param.player

    self.pledgeMit = 0
    self.vipLevel = 0
    self.lastCheckTick = 0                        --""15""
    self.vip = {}                       
    self.productIds = {}
end

function VipBag:initProductIds()
    local cfgs = gg.getExcelCfg("vip")
    for k,v in pairs(cfgs) do
        if v.productId and v.productId ~= "0" then
            self.productIds[v.productId] = 1
        end
    end
end

function VipBag:serialize()
    local data = {}
    data.pledgeMit = self.pledgeMit
    data.vipLevel = self.vipLevel
    data.vip = {}
    for k,v in pairs(self.vip) do
        data.vip[k] = v
    end
    return data
end

function VipBag:deserialize(data)
    if data.vip and next(data.vip) then
        for k,v in pairs(data.vip) do
            self.vip[k] = v
        end
    end
end

function VipBag:setVip(productId)
    local cfgs = gg.getExcelCfg("vip")
    local vipLevel = 0
    for k,v in pairs(cfgs) do
        if v.productId == productId then
            vipLevel = k
        end
    end
    local nowTick = gg.time.time()
    if vipLevel > 0 then
        if not self.vip[tostring(vipLevel)] or self.vip[tostring(vipLevel)] <= nowTick then -- ""
            self.vip[tostring(vipLevel)] = nowTick + cfgs[vipLevel].duration * constant.TIME_ONE_DAY_TO_SECONE
        elseif self.vip[tostring(vipLevel)] >= nowTick then  -- vip""
            self.vip[tostring(vipLevel)] = self.vip[tostring(vipLevel)] + cfgs[vipLevel].duration * constant.TIME_ONE_DAY_TO_SECONE
        end
        for i=vipLevel-1,1,-1 do
            if self.vip[tostring(i)] and self.vip[tostring(i)] > nowTick then
                self.vip[tostring(i)] = self.vip[tostring(i)] + cfgs[i+1].duration * constant.TIME_ONE_DAY_TO_SECONE
            end
        end
    end
    self.lastCheckTick = 0 -- ""，""vipLevel
    self:checkPledgeMit()
end

function VipBag:refreshVipLevel()
    local cfgs = cfg.get("etc.cfg.vip")
    local pledgeVipLevel = 0
    local vipLevel = 0
    for k, v in pairs(cfgs) do
        if self.pledgeMit >= v.minMit and (self.pledgeMit <= v.maxMit or v.maxMit == -1) then
            pledgeVipLevel = v.cfgId
        end
    end
    local nowTick = gg.time.time()
    for i=9,1,-1 do
        if self.vip[tostring(i)] and self.vip[tostring(i)] > nowTick then
            vipLevel = i
            break
        end
    end
    if pledgeVipLevel > vipLevel then
        vipLevel = pledgeVipLevel
    end
    return vipLevel
end

function VipBag:checkPledgeMit()
    local nowTick = math.floor(skynet.timestamp() / 1000)
    if self.lastCheckTick <= 0 or ((nowTick - self.lastCheckTick) > 900) then
        self.lastCheckTick = nowTick
        local chain_id = self.player.playerInfoBag:getChainId()
        local owner_address = self.player.playerInfoBag:getOwnerAddress()
        local doc = gg.mongoProxy.pledge:findOne({ chain_id = chain_id, owner_address = owner_address })
        if doc then
            self.pledgeMit = doc.pledgeMit or 0
        else
            self.pledgeMit = 0
        end
        self.vipLevel = self:refreshVipLevel()
        gg.client:send(self.player.linkobj,"S2C_Player_VipData", self:pack())
    end
end

function VipBag:getPledgeMit()
    self:checkPledgeMit()
    return self.pledgeMit
end

function VipBag:getVipLevel()
    self:checkPledgeMit()
    return self.vipLevel
end

function VipBag:pack()
    local nowTick = gg.time.time()
    local data = {}
    data.mit = self:getPledgeMit()
    data.vipLevel = self:getVipLevel()
    local endTime = self.vip[tostring(data.vipLevel)]
    if not endTime then
        data.endTime = 0
    elseif endTime > nowTick then
        data.endTime = endTime
    end
    return data
end

function VipBag:getWithdrawReduce()
    local vipLevel = self:getVipLevel()
    local vipCfgs = cfg.get("etc.cfg.vip")
    local cfg = vipCfgs[vipLevel]
    if not cfg then
        return 0
    end
    return cfg.withdrawReduce or 0
end

function VipBag:getHydroxylAddition()
    local vipLevel = self:getVipLevel()
    local vipCfgs = cfg.get("etc.cfg.vip")
    local cfg = vipCfgs[vipLevel]
    if not cfg then
        return 0
    end
    return cfg.hydroxylAddition
end

function VipBag:getCurVipLevelCfg()
    local vipLevel = self:getVipLevel()
    local vipCfgs = cfg.get("etc.cfg.vip")
    return vipCfgs[vipLevel]
end

--""
function VipBag:getRatio(resCfgId)
    local cfg = self:getCurVipLevelCfg()
    if not cfg then
        return 0
    end
    if resCfgId == constant.RES_STARCOIN then
        return cfg.starCoinRatio
    elseif resCfgId == constant.RES_TITANIUM then
        return cfg.titaniumRatio
    elseif resCfgId == constant.RES_GAS then
        return cfg.gasRatio
    elseif resCfgId == constant.RES_ICE then
        return cfg.iceRatio
    end
    return 0
end

function VipBag:getBuildQueue()
    local vipLevel = self:getVipLevel()
    local vipCfgs = cfg.get("etc.cfg.vip")
    local cfg = vipCfgs[vipLevel]
    if not cfg then
        return 0
    end
    return cfg.buildQueue
end

function VipBag:pledge(pledgeMit)
    local chain_id = self.player.playerInfoBag:getChainId()
    local owner_address = self.player.playerInfoBag:getOwnerAddress()
    gg.mongoProxy.pledge:update({ chain_id = chain_id, owner_address = owner_address },{["$set"] = { pledgeMit = pledgeMit }},true,false)

    self.lastCheckTick = 0
    gg.client:send(self.player.linkobj,"S2C_Player_VipData", self:pack())
end

function VipBag:checkBuyVipLevel(productId)
    if not self.productIds or not next(self.productIds) then
        self:initProductIds()
    end
    if self.productIds[productId] then
        self:setVip(productId)
    end
end

function VipBag:onSecond()

end

function VipBag:onDayUpdate()
end

function VipBag:oncreate()
    
end

function VipBag:onload()
    self.player.playerInfoBag:refreshWalletInfo()
    self.lastCheckTick = 0
    self:checkPledgeMit()
end

function VipBag:onlogin()
    self:initProductIds()
    self.player.playerInfoBag:refreshWalletInfo()
    self.lastCheckTick = 0
    self:checkPledgeMit()
end

function VipBag:onlogout()

end

return VipBag