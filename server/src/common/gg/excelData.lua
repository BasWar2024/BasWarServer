
function gg.getExcelCfg(name)
    local cfg_name = "etc.cfg."..name
    local cfg = cfg.get(cfg_name)
    return cfg
end

function gg.getExcelCfgByKeys(name, kvDict)
    local cfg_name = "etc.cfg."..name
    local cfg = cfg.get(cfg_name)
    if not cfg then
        return
    end
    for key, value in pairs(cfg) do
        local is_match = true
        for k, v in pairs(kvDict) do
            if value[k] ~= v then
                is_match = false
                break
            end
        end
        if is_match then
            return value
        end
    end
end

function gg.getExcelCfgByFormat(name, ...)
    local keys = {...}
    local key = table.concat(keys, "_")
    local cfg = gg.getExcelCfg(name)
    return cfg[key]
end

function gg.getChainIndexById(chainId)
    local chainIndex = 0
    return chainIndex
end

--------------------------------------------------
--check
--------------------------------------------------
function gg.checkExcelCfg()
    if not constant.EXCEL_DATA_CHECK then
        return
    end
    local itemEffectCfg = gg.getExcelCfg("itemEffect")
    local itemCfg = gg.getExcelCfg("item")
    for k, v in pairs(itemCfg) do
        if v.skillCfgID then
            local skillCfg = gg.getExcelCfgByFormat("skillConfig", v.skillCfgID[1], v.skillCfgID[2])
            assert(skillCfg, "item skillCfgID[1]=%s "..v.skillCfgID[1] .." skillCfgID[2]=%s " .. v.skillCfgID[2].."error")
        end
        if v.resolveItem then
            for ii, vv in ipairs(v.resolveItem) do
                assert(itemCfg[vv[1]], "item resolveItem itemCfgId= "..(vv[1] or "").."error")
            end
        end
        if v.canUse and v.canUse == 1 then
            assert(v.effect, "item cfgId=%s "..v.cfgId.." effect error")
        end
        if v.isAutoUse and v.isAutoUse == 1 then
            assert(v.effect, "item cfgId=%s "..v.cfgId.." effect error")
        end
        for ii, vv in ipairs(v.effect or {}) do
            local effectCfg = itemEffectCfg[vv]
            assert(effectCfg, "itemEffect cfgId=%s "..vv.." error")
            assert(effectCfg.value, "itemEffect cfgId=%s "..vv.." value error")
            if effectCfg.effectType == constant.ITEM_EFFECT_TYPE_RES then
                assert(constant.RES_MIT <= effectCfg.value[1] and effectCfg.value[1] <= constant.RES_TESSERACT, "itemEffect cfgId=%s "..vv.." value error")
            elseif effectCfg.effectType == constant.ITEM_EFFECT_TYPE_HERO then
                assert(effectCfg.value[1] and effectCfg.value[2] and effectCfg.value[3], "itemEffect cfgId=%s "..vv.." value error")
                local _heroCfg = gg.getExcelCfgByFormat("heroConfig", effectCfg.value[1], effectCfg.value[2], effectCfg.value[3])
                assert(_heroCfg, "itemEffect cfgId=%s "..vv.." value hero cfg not exist")
            elseif effectCfg.effectType == constant.ITEM_EFFECT_TYPE_WARSHIP then
                assert(effectCfg.value[1] and effectCfg.value[2] and effectCfg.value[3], "itemEffect cfgId=%s "..vv.." value error")
                local _warShipCfg = gg.getExcelCfgByFormat("warShipConfig", effectCfg.value[1], effectCfg.value[2], effectCfg.value[3])
                assert(_warShipCfg, "itemEffect cfgId=%s "..vv.." value warShip cfg not exist")
            elseif effectCfg.effectType == constant.ITEM_EFFECT_TYPE_CARD then
                assert(effectCfg.value[1], "itemEffect cfgId=%s "..vv.." value error")
            end
        end
    end

    local skillCfgMap = {}
    local skillCfg = gg.getExcelCfg("skill")
    for k, v in pairs(skillCfg) do
        if skillCfg.skillEquitType and skillCfg.skillEquitType ~= constant.SKILL_EQUIP_OTHER then
            assert(v.itemCfgId, "skill cfgId= "..v.cfgId.." itemCfgId error")
            if v.itemCfgId then
                assert(itemCfg[v.itemCfgId], "skill cfgId= "..v.cfgId.." skill itemCfgId= "..v.itemCfgId.."error")
            end
        end
        skillCfgMap[v.cfgId] = true
    end

    local mintLimt = gg.getGlobalCfgIntValue("NFTMintMaxTime", 9) - 1
    local mintCost = gg.getExcelCfg("mintCost")
    local mintCfgMap = {}
    for i = 0, mintLimt, 1 do
        for kk, vv in pairs(mintCost) do
            assert(vv.itemCfgId, "mintCost itemCfgId is nil ")
            assert(itemCfg[vv.itemCfgId], "mintCost itemCfgId= "..vv.itemCfgId.."error")
            mintCfgMap[vv.cfgId] = true
        end
    end

    local function _check_mint(tcfg, cfgName)
        for k, v in pairs(tcfg) do
            if v.mintCfgId and v.mintCfgId ~= 0 then
                assert(mintCfgMap[v.mintCfgId], cfgName.." mintCfgId= "..v.mintCfgId.."error")
            end
            for ii, vv in ipairs(v.initSkill or {}) do
                if vv ~= 0 then
                    assert(skillCfgMap[vv], cfgName.." initSkill, skillId= "..vv.."error")
                end
            end
        end
    end
    _check_mint(gg.getExcelCfg("warShip"),"warShip")
    _check_mint(gg.getExcelCfg("hero"), "hero")
    _check_mint(gg.getExcelCfg("build"), "build")

    local cardPoolCfg = gg.getExcelCfg("cardPool")
    for k, v in pairs(cardPoolCfg) do
        for ii, vv in ipairs(v.commonGroup) do
            assert(itemCfg[vv[1]], "cardPool commonGroup id= "..vv[1].."error")
        end
        for ii, vv in ipairs(v.minimumGroup) do
            assert(itemCfg[vv[1]], "cardPool minimumGroup id= "..vv[1].."error")
        end
    end

    local maxIndex = 0
    local matchRewardCfg = gg.getExcelCfg("matchReward")
    for i, v in ipairs(matchRewardCfg) do
        if v.index > maxIndex then
            maxIndex = v.index
        end
    end
    assert(table.count(matchRewardCfg) == maxIndex, "matchReward index must be continuous index= "..(maxIndex+1).."error")

    local preBuildCfgs = gg.getExcelCfg("presetBuildLayout")
    local function _check_pre_build(starmapId, layoutId)
        if not layoutId then
            return
        end
        local pblCfg = preBuildCfgs[layoutId]
        assert(pblCfg, "starmap id= "..starmapId.."presetLayoutId error")
        for ii, vv in pairs(pblCfg.presetBuilds or {}) do
            assert(vv.cfgId, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." cfgId error")
            assert(vv.quality, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." quality error")
            assert(vv.level, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." level error")
            assert(vv.x, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." x error")
            assert(vv.z, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." z error")
            assert(vv.x >= constant.MAP_GRID_MIN and vv.x <= constant.MAP_GRID_MAX, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." x error")
            assert(vv.z >= constant.MAP_GRID_MIN and vv.z <= constant.MAP_GRID_MAX, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." z error")
            assert(vv.life, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." life error")
            assert(vv.curLife, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." curLife error")
            local tmpCfg = gg.getExcelCfgByFormat("buildConfig", vv.cfgId, vv.quality, vv.level)
            assert(tmpCfg, "presetBuildLayout id= "..layoutId.."presetBuilds index= "..ii.." error")
        end
    end
    for k, v in pairs(preBuildCfgs) do
        _check_pre_build(0, v.cfgId)
    end

    local belongSeasonNum = {}
    local belongSeason2CfgId = {}
    local matchCfg = gg.getExcelCfg("match")
    for k, v in pairs(matchCfg) do
        assert(v.matchType >= constant.MATCH_TYPE_WEEK and v.matchType <= constant.MATCH_TYPE_SEASON, "match id= "..k.." matchType error")
        assert(v.belong >= constant.MATCH_BELONG_UNION and v.belong <= constant.MATCH_BELONG_PVP, "match id= "..k.." belong error")
        assert(v.rewardType >= constant.MATCH_REWARD_TYPE_DATE_TIME and v.rewardType <= constant.MATCH_REWARD_TYPE_DELAY_SEC, "match id= "..k.." rewardType error")
        local noticeTime = string.totime(v.noticeTime)
        local startTime = string.totime(v.startTime)
        local endTime = string.totime(v.endTime)
        local rewardTime = string.totime(v.rewardTime)
        local showEndTime = string.totime(v.showEndTime)
        assert(noticeTime < startTime, "match id= "..k.." noticeTime must be less than startTime")
        assert((startTime - noticeTime) >= 60, "match id= "..k.." noticeTime must be less than startTime for more than 60 seconds")
        assert(startTime < endTime, "match id= "..k.." startTime must be less than endTime")
        assert((endTime - startTime) >= 60, "match id= "..k.." startTime must be less than endTime for more than 60 seconds")
        assert(endTime < rewardTime, "match id= "..k.." endTime must be less than rewardTime")
        assert(rewardTime < showEndTime, "match id= "..k.." rewardTime must be less than showEndTime")

        belongSeasonNum[v.belong] = belongSeasonNum[v.belong] or {}
        if v.matchType == constant.MATCH_TYPE_SEASON then
            belongSeasonNum[v.belong][v.season] = belongSeasonNum[v.belong][v.season] or 0
            belongSeasonNum[v.belong][v.season] = belongSeasonNum[v.belong][v.season] + 1
        end
        belongSeason2CfgId[v.belong] = belongSeason2CfgId[v.belong] or {}
        belongSeason2CfgId[v.belong][v.season] = belongSeason2CfgId[v.belong][v.season] or {}
        if v.matchType == constant.MATCH_TYPE_SEASON then
            belongSeason2CfgId[v.belong][v.season]["seasonId"] = v.cfgId
        elseif v.matchType == constant.MATCH_TYPE_WEEK then
            belongSeason2CfgId[v.belong][v.season]["weekIds"] = belongSeason2CfgId[v.belong][v.season]["weekIds"] or {}
            table.insert(belongSeason2CfgId[v.belong][v.season]["weekIds"], v.cfgId)
        elseif v.matchType == constant.MATCH_TYPE_MONTH then
            belongSeason2CfgId[v.belong][v.season]["monthIds"] = belongSeason2CfgId[v.belong][v.season]["monthIds"] or {}
            table.insert(belongSeason2CfgId[v.belong][v.season]["monthIds"], v.cfgId)
        end
    end
    for k, v in pairs(belongSeasonNum) do
        for kk, vv in pairs(v) do
            if vv > 1 then
                assert(false, "match belong= "..k.."season= "..kk.." is repeat")
            end
        end
    end
    local function _check_time_overlap(sortIds, sortkey)
        table.sort(sortIds, function(a, b)
            if a[sortkey] < b[sortkey] then
                return true
            elseif a[sortkey] > b[sortkey] then
                return false
            end
            return false
        end)
        local _pre = sortIds[1]
        if _pre then
            local _cur
            for i = 2, #sortIds, 1 do
                _cur = sortIds[i]
                assert(_cur[sortkey] > _pre.showEndTime, "match belong= ".._cur.belong..",season= ".._cur.season..",id= ".._cur.cfgId.." is error")
                assert((_cur[sortkey] - _pre.showEndTime) >= 60, "match belong= ".._cur.belong..",season= ".._cur.season..",id= ".._cur.cfgId.." showEndTime must be less than "..sortkey.." for more than 60 seconds")
                _pre = _cur
                _cur = nil
            end
        end
    end
    for k, v in pairs(belongSeason2CfgId) do
        local sortMainIds = {}
        for kk, vv in pairs(v) do
            local tmpCfg = matchCfg[vv.seasonId]
            local noticeTime = string.totime(tmpCfg.noticeTime)
            local showEndTime = string.totime(tmpCfg.showEndTime)
            table.insert(sortMainIds, {
                belong = k,
                season = kk,
                cfgId = vv.seasonId,
                noticeTime = noticeTime,
                showEndTime = showEndTime,
            })
            local sortWeekIds = {}
            for kkk, vvv in pairs(vv.weekIds or {}) do
                local tCfg = matchCfg[vvv]
                local noticeTime1 = string.totime(tCfg.noticeTime)
                local showEndTime1 = string.totime(tCfg.showEndTime)
                assert(noticeTime1 >= noticeTime and noticeTime1 < showEndTime, "match belong= "..k..",season= "..kk..",id= "..vvv.." is error")
                assert(showEndTime1 > noticeTime and showEndTime1 <= showEndTime, "match belong= "..k..",season= "..kk..",id= "..vvv.." is error")
                local startTime1 = string.totime(tCfg.startTime)
                table.insert(sortWeekIds, {
                    belong = k,
                    season = kk,
                    cfgId = vvv,
                    noticeTime = noticeTime1,
                    startTime = startTime1,
                    showEndTime = showEndTime1,
                })
            end
            local sortMonthIds = {}
            for kkk, vvv in pairs(vv.monthIds or {}) do
                local tCfg = matchCfg[vvv]
                local noticeTime1 = string.totime(tCfg.noticeTime)
                local showEndTime1 = string.totime(tCfg.showEndTime)
                assert(noticeTime1 >= noticeTime and noticeTime1 < showEndTime, "match belong= "..k..",season= "..kk..",id= "..vvv.." is error")
                assert(showEndTime1 > noticeTime and showEndTime1 <= showEndTime, "match belong= "..k..",season= "..kk..",id= "..vvv.." is error")
                local startTime1 = string.totime(tCfg.startTime)
                table.insert(sortMonthIds, {
                    belong = k,
                    season = kk,
                    cfgId = vvv,
                    noticeTime = noticeTime1,
                    startTime = startTime1,
                    showEndTime = showEndTime1,
                })
            end
            _check_time_overlap(sortWeekIds, "startTime")
            _check_time_overlap(sortMonthIds, "startTime")
        end
        _check_time_overlap(sortMainIds, "noticeTime")
    end
end

function __hotfix(module)
end