local DoubleRecharge = class("DoubleRecharge")

function DoubleRecharge.create(param)
    return DoubleRecharge.new(param)
end

function DoubleRecharge:ctor(param)
    self.doubRecstat = param.doubRecstat or {}
end

function DoubleRecharge:serialize()
    local data = {}
    data.doubRecstat = {}
    for k,v in pairs(self.doubRecstat) do
        table.insert(data.doubRecstat, v)
    end
    return data
end

function DoubleRecharge:deserialize(data)
    if data and next(data) then
        for k,v in pairs(data) do
            table.insert(self.doubRecstat, v)
        end
    end
end

function DoubleRecharge:getDoubleRechargeCfg()
    local giftActivitiesCfg = gg.getExcelCfg("giftActivities")
    return giftActivitiesCfg[constant.DOUBLE_RECHARGE]
end

return DoubleRecharge