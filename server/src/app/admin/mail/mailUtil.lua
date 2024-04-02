mailUtil = mailUtil or {}

function mailUtil.check_sender(sendId, sendName)
    if not sendId and not sendName then
        return false, "sender is nil"
    end
    if sendId then
        --TODO: check
        if type(sendId) ~= "number" then
            return false, "mail sendId is err"
        end
    end
    if sendName then
        --TODO: check
        if type(sendName) ~= "string" then
            return false, "mail sendName is err"
        end
    end
    return true
end

function mailUtil.check_receiver(toPidList)
    local inNum = #toPidList
    if inNum == 0 then--""
        return true
    end
    for index, value in ipairs(toPidList) do
        toPidList[index] = tonumber(value)
    end
    local count = gg.mongoProxy.player:findCount({["pid"] = {["$in"] = toPidList}})
    if inNum ~= count then
        return false, "toPidList is error, some pid not exist"
    end
    return true
end

function mailUtil.format_mail_data(mailData)
    if mailData.attachment then
        for _, attach in ipairs(mailData.attachment) do
            attach.cfgId = tonumber(attach.cfgId)
            attach.count = tonumber(attach.count)
            attach.type = tonumber(attach.type)
            attach.quality = tonumber(attach.quality)
        end
    end
end

function mailUtil.check_mail_data(mailData)
    if not mailData then
        return false, "mailData is nil"
    end
    if not mailData.title then
        return false, "mail title is nil"
    end
    if not mailData.content then
        return false, "mail content is nil"
    end
    if mailData.attachment then
        if type(mailData.attachment) ~= "table" then
            return false, "mail attachment is err"
        end
        local itemCfg = gg.getExcelCfg("item")
        for _, attach in ipairs(mailData.attachment) do
            if not attach.cfgId then
                return false, "mail attachment cfgId is nil"
            end
            if not attach.count then
                return false, "mail attachment count is nil"
            else
                local attachCount = tonumber(attach.count)
                if not attachCount then
                    return false, "mail attachment count is err"
                end
                if attachCount < 1 or attachCount > constant.MAIL_ATTACH_RES_COUNT_LIMMIT then
                    return false, "mail attachment quality must between 1-"..constant.MAIL_ATTACH_RES_COUNT_LIMMIT
                end
            end
            if not attach.type then
                return false, "mail attachment type is nil"
            else
                local attachType = tonumber(attach.type)
                if attachType ~= constant.MAIL_ATTACH_RES and attachType ~= constant.MAIL_ATTACH_ITEM then
                    return false, "mail attachment type is err"
                end
                if attachType == constant.MAIL_ATTACH_RES then
                    local resCfgId = tonumber(attach.cfgId)
                    if not resCfgId or resCfgId < constant.RES_MIT or resCfgId > constant.RES_TESSERACT then
                        return false, "mail attachment res type must between " .. constant.RES_MIT .. "-" .. constant.RES_TESSERACT
                    end
                elseif attachType == constant.MAIL_ATTACH_ITEM then
                    local itemCfgId = tonumber(attach.cfgId)
                    if not itemCfgId then
                        return false, "mail attachment item cfgId is error"
                    end
                    if not itemCfg[itemCfgId] then
                        return false, "mail attachment item cfg is not exist"
                    end
                end
            end
            if attach.quality then
                local quality = tonumber(attach.quality)
                if not quality then
                    return false, "mail attachment quality is err"
                end
                if quality < 0 or quality > 5 then
                    return false, "mail attachment quality must between 0-5"
                end
            end
        end
    end
    if mailData.sendTime then
        local sendTime = tonumber(mailData.sendTime)
        if not sendTime then
            return false, "mail sendTime is err"
        end
        local now = gg.time.time()
        if sendTime < now then
            return false, "mail sendTime is less than now"
        end
    end

    mailData.duration = mailData.duration or constant.MAIL_DURATION
    local duration = tonumber(mailData.duration)
    if not duration then
        return false, "mail duration is err"
    end
    if duration <= 0 then
        return false, "mail duration must bigger than 0"
    end

    mailData.filter = mailData.filter or 0
    local filter = tonumber(mailData.filter)
    if not filter then
        return false, "mail filter is err"
    end
    if filter < constant.MAIL_GET_FILTER_ALL or filter > constant.MAIL_GET_FILTER_AFTER then
        return false, "mail filter must between 0-2"
    end
    mailUtil.format_mail_data(mailData)
    mailData.logType = gamelog.MAIL_FROM_GMASTER
    return true
end

function mailUtil.check_params(sendId, sendName, toPidList, mailData)
    local r, err = mailUtil.check_sender(sendId, sendName)
    if not r then
        return r, err
    end
    r, err = mailUtil.check_receiver(toPidList)
    if not r then
        return r, err
    end
    r, err = mailUtil.check_mail_data(mailData)
    if not r then
        return r, err
    end
    return true
end

return mailUtil