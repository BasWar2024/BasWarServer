local GiftBag = class("GiftBag")

function GiftBag:ctor(param)
    self.player = param.player
    self.rewardDict = {}              -- ""cfgId -> count
end

function GiftBag:serialize()
    local data = {}
    data.rewardDict = {}
    for k,v in pairs(self.rewardDict) do
        data.rewardDict[tostring(k)] = v
    end
    return data
end

function GiftBag:deserialize(data)
    local rewardDict = data.rewardDict or {}
    for k,v in pairs(rewardDict) do
        self.rewardDict[math.floor(tonumber(k))] = v
    end
end

-- ""
local lastUseTick = nil
function GiftBag:useGiftCode(code)
    code = string.trim(code)
    local nowTime = os.time()
    if lastUseTick and (nowTime - lastUseTick) <= 2 then
        self.player:say(util.i18nFormat(errors.SYSTEM_BUSY))
        return
    end
    lastUseTick = os.time()

    local giftCodeCfg = gg.getExcelCfg("giftCode")
    local info = nil
    for k,v in pairs(giftCodeCfg) do
        if v.prefix == code then
            info = v
            break
        end
        if string.find(code, v.prefix) == 1 then
            info = v
            break
        end
    end
    if not info then
        self.player:say(util.i18nFormat(errors.GIFT_CODE_ERROR))
        return
    end

    --""
    if not info.beginDate or not info.endDate then
        self.player:say(util.i18nFormat(errors.GIFT_CODE_NOT_IN_TIME))
        return
    end
    
    local beginYear = tonumber(string.sub(info.beginDate, 1, 4))
    local beginMonth = tonumber(string.sub(info.beginDate, 5, 6))
    local beginDay = tonumber(string.sub(info.beginDate, 7, 8))
    local beginTime = gg.time.date_to_timestamp(beginYear, beginMonth, beginDay, 0, 0, 0)
    local endYear = tonumber(string.sub(info.endDate, 1, 4))
    local endMonth = tonumber(string.sub(info.endDate, 5, 6))
    local endDay = tonumber(string.sub(info.endDate, 7, 8))
    local endTime = gg.time.date_to_timestamp(endYear, endMonth, endDay, 23, 59, 59)
    if nowTime < beginTime or nowTime > endTime then
        self.player:say(util.i18nFormat(errors.GIFT_CODE_NOT_IN_TIME))
        return
    end

    --""
    if info.style == constant.GIFT_CODE_STYLE_RANDOM then
        local doc = gg.mongoProxy.gift_code:findOne({ code = code })
        if not doc then
            self.player:say(util.i18nFormat(errors.GIFT_CODE_NOT_EXIST))
            return
        end
        if doc.pid then
            self.player:say(util.i18nFormat(errors.GIFT_CODE_ALREADY_USE))
            return
        end
    end

    --""
    local count = self.rewardDict[info.cfgId] or 0
    if count >= (info.limit or 0) then
        self.player:say(util.i18nFormat(errors.GIFT_CODE_MAX_COUNT))
        return
    end

    --""
    if info.style == constant.GIFT_CODE_STYLE_RANDOM then
        local result = gg.mongoProxy.gift_code:findAndModify({
            query = { code = code, pid = { ["$exists"] = false } },
            update = {["$set"] = { pid = self.player.pid, rewardTime = nowTime }},
            new = false,
            upsert = false,
        })

        if not result or not result.value or not result.value.code or result.value.code ~= code then
            self.player:say(util.i18nFormat(errors.GIFT_CODE_ALREADY_USE))
            return
        end
    elseif info.style == constant.GIFT_CODE_STYLE_BASE then
        gg.mongoProxy.gift_code:insert({ code = code, cfgId = info.cfgId, pid = self.player.pid, rewardTime = nowTime })
    else
        self.player:say(util.i18nFormat(errors.GIFT_CODE_ERROR))
        return
    end

    self.rewardDict[info.cfgId] = count + 1

    --""
    if info.itemCfgId then
        self.player.itemBag:addItem(info.itemCfgId, 1, {logType=gamelog.GIFT_CODE_EXCHANGE})
    end

    gg.client:send(self.player.linkobj,"S2C_Player_UseGiftCode",{ code = code, ret = true, cfgId = info.cfgId, itemCfgId = info.itemCfgId })
end

function GiftBag:onlogin()

end

return GiftBag