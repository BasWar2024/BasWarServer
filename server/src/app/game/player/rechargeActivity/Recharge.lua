local Recharge = class("Recharge")

function Recharge.create(param)
    return Recharge.new(param)
end

function Recharge:ctor(param)
    self.firstRec = param.firstRec or 0			          --""		0"" 1 ""
    self.rechargeVal = param.rechargeVal or 0             --""
    self.rechargeStat = param.rechargeStat or 0           --""   0"" 1 ""
end

function Recharge:serialize()
    local data = {}
    data.firstRec = self.firstRec or 0
    data.rechargeVal = self.rechargeVal or 0
    data.rechargeStat = self.rechargeStat or 0
    return data
end

function Recharge:deserialize(data)
    self.firstRec = data.firstRec or 0
    self.rechargeVal = data.rechargeVal or 0
    self.rechargeStat = data.rechargeStat or 0
end

function Recharge:getRechargeCfg()
    local giftActivitiesCfg = gg.getExcelCfg("giftActivities")
    return giftActivitiesCfg[constant.RECHARGE]
end

function Recharge:getFirestRechargeCfg()
    local giftActivitiesCfg = gg.getExcelCfg("giftActivities")
    return giftActivitiesCfg[constant.FIREST_RECHARGE]
end

return Recharge