
local DEBUG = false
local function debugPrint(funcName, condId, taskId)
    local errStr = funcName..": task no cfg for "
    if condId then
        errStr = errStr.."condId= "..condId
    elseif taskId then
        errStr = errStr.."taskId= "..taskId
    end
    if DEBUG then
        error(errStr, 2)
    end
end

local function commonCheckComplete(target, targetTaskIds, complete, curChapterId)
    local newComplete = {}
    local taskCfg = gg.getExcelCfg("subTask")
    for idstr, v in pairs(targetTaskIds) do
        if not complete[idstr] then
            local cfg = taskCfg[tonumber(idstr)]
            if not cfg then
                debugPrint("commonCheckComplete", nil, idstr)
            else
                if cfg.chapterId == curChapterId or cfg.type == constant.TASK_TYPE.DAILY
                    or cfg.type == constant.TASK_TYPE.BRANCH then
                    local curval = target[idstr]
                    if curval and curval >= cfg.targetArgs[1] then
                        newComplete[idstr] = constant.TASK_STATE.DONE
                    end
                end
            end
        end
    end
    return newComplete
end

--""x""
local WarshipLv = class("WarshipLv")
function WarshipLv:ctor(param)
end

function WarshipLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0 or condCfg.targetArgs[2] == param.cfgId then
                if param.lv >= condCfg.targetArgs[3] then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("WarshipLv:update", condid, nil)
        end
    end
    return isModify
end

function WarshipLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local WarshipSkillLv = class("WarshipSkillLv")
function WarshipSkillLv:ctor(param)
end

function WarshipSkillLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0 or condCfg.targetArgs[2] == param.skillId then
                if param.lv >= condCfg.targetArgs[3] then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("WarshipSkillLv:update", condid, nil)
        end
    end
    return isModify
end

function WarshipSkillLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local WarshipLvUp = class("WarshipLvUp")
function WarshipLvUp:ctor(param)
end

function WarshipLvUp:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("WarshipLvUp:update", condid, nil)
        end
    end
    return isModify
end

function WarshipLvUp:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local WarshipSkillLvUp = class("WarshipSkillLvUp")
function WarshipSkillLvUp:ctor(param)
end

function WarshipSkillLvUp:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.skillId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("WarshipSkillLvUp:update", condid, nil)
        end
    end
    return isModify
end

function WarshipSkillLvUp:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local HeroLv = class("HeroLv")
function HeroLv:ctor(param)
end

function HeroLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0 or condCfg.targetArgs[2] == param.cfgId then
                if param.lv >= condCfg.targetArgs[3] then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("HeroLv:update", condid, nil)
        end
    end
    return isModify
end

function HeroLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local HeroSkillLv = class("HeroSkillLv")
function HeroSkillLv:ctor(param)
end

function HeroSkillLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0  then 
                if not condCfg.targetArgs[3] then
                    return isModify
                end
                if param.lv >= condCfg.targetArgs[3] then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("HeroSkillLv:update", condid, nil)
        end
    end
    return isModify
end

function HeroSkillLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""
local HeroSwitchSkill = class("HeroSwitchSkill")
function HeroSwitchSkill:ctor(param)
end

function HeroSwitchSkill:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.skillId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("HeroSwitchSkill:update", condid, nil)
        end
    end
    return isModify
end

function HeroSwitchSkill:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local HeroLvUp = class("HeroLvUp")
function HeroLvUp:ctor(param)
end

function HeroLvUp:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("HeroLvUp:update", condid, nil)
        end
    end
    return isModify
end

function HeroLvUp:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local HeroSkillLvUp = class("HeroSkillLvUp")
function HeroSkillLvUp:ctor(param)
end

function HeroSkillLvUp:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.skillId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("HeroSkillLvUp:update", condid, nil)
        end
    end
    return isModify
end

function HeroSkillLvUp:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""X""Y""Z""
local BuildLvCount = class("BuildLvCount")
function BuildLvCount:ctor(param)
end

function BuildLvCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if param.lvup then
                local cfgId = condCfg.targetArgs[2]
                local lv = condCfg.targetArgs[3]
                if cfgId == 0 or cfgId == param.cfgId then
                    if not lv or lv == 0 then
                        target[condid] = conval + param.count
                        isModify = true
                    else
                        if param.lv == lv then
                            target[condid] = conval + param.count
                            isModify = true
                        end
                    end
                end
            else
                local cfgId = condCfg.targetArgs[2]
                local lv = condCfg.targetArgs[3]
                if cfgId == 0 or cfgId == param.cfgId then
                    if not lv or lv == 0 or  param.lv >= lv then
                        target[condid] = conval + param.count
                        isModify = true
                    end
                end
            end
        else
            debugPrint("BuildLvCount:update", condid, nil)
        end
    end
    return isModify
end

function BuildLvCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local BuildLvUpCount = class("BuildLvUpCount")
function BuildLvUpCount:ctor(param)
end

function BuildLvUpCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            local lv = condCfg.targetArgs[3]
            if cfgId == 0 or cfgId == param.cfgId then
                if not lv or lv == 0 or lv == param.lv then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("BuildLvUpCount:update", condid, nil)
        end
    end
    return isModify
end

function BuildLvUpCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""y""
local TrainSoliders = class("TrainSoliders")
function TrainSoliders:ctor(param)
end

function TrainSoliders:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("TrainSoliders:update", condid, nil)
        end
    end
    return isModify
end

function TrainSoliders:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local LvUpSoliders = class("LvUpSoliders")
function LvUpSoliders:ctor(param)
end

function LvUpSoliders:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("LvUpSoliders:update", condid, nil)
        end
    end
    return isModify
end

function LvUpSoliders:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local ReserveArmyTrain = class("ReserveArmyTrain")
function ReserveArmyTrain:ctor(param)
end

function ReserveArmyTrain:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("ReserveArmyTrain:update", condid, nil)
        end
    end
    return isModify
end

function ReserveArmyTrain:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--Pvp""x
local PvpCount = class("PvpCount")
function PvpCount:ctor(param)
end

function PvpCount:update(target, param)
    local isModify = false
    for conid, conval in pairs(target) do
        target[conid] = target[conid] + param.count
        isModify = true
    end
    return isModify
end

function PvpCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--Pvp""x
local PvpScore = class("PvpScore")
function PvpScore:ctor(param)
end

function PvpScore:update(target, param)
    local isModify = false
    for conid, conval in pairs(target) do
        target[conid] = target[conid] + param.score
        isModify = true
    end
    return isModify
end

function PvpScore:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--PVE""x""
local PveWin = class("PveWin")
function PveWin:ctor(param)
end

function PveWin:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if conval == 0 then
                local cfgId = condCfg.targetArgs[2] or 0
                if cfgId == 0 or cfgId == param.cfgId then
                    target[condid] = conval + param.count
                    isModify = true
                end
            end
        else
            debugPrint("PveWin:update", condid, nil)
        end
    end
    return isModify
end

function PveWin:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""y""
local DestoryBuildTypeCount = class("DestoryBuildTypeCount")
function DestoryBuildTypeCount:ctor(param)
end

function DestoryBuildTypeCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local buildType = condCfg.targetArgs[2] or 0
            if buildType == 0 or buildType == param.buildType then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("DestoryBuildTypeCount:update", condid, nil)
        end
    end
    return isModify
end

function DestoryBuildTypeCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""y""
local DestoryBuildCount = class("DestoryBuildCount")
function DestoryBuildCount:ctor(param)
end

function DestoryBuildCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("DestoryBuildCount:update", condid, nil)
        end
    end
    return isModify
end

function DestoryBuildCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local CollectResCount = class("CollectResCount")
function CollectResCount:ctor(param)
end

function CollectResCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("CollectResCount:update", condid, nil)
        end
    end
    return isModify
end

function CollectResCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""y""
local CollectResNum = class("CollectResNum")
function CollectResNum:ctor(param)
end

function CollectResNum:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("CollectResNum:update", condid, nil)
        end
    end
    return isModify
end

function CollectResNum:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""y""
local ConsumeResNum = class("ConsumeResNum")
function ConsumeResNum:ctor(param)
end

function ConsumeResNum:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("ConsumeResNum:update", condid, nil)
        end
    end
    return isModify
end

function ConsumeResNum:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""
local JionGuild = class("JionGuild")
function JionGuild:ctor(param)
end

function JionGuild:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if conval > 0 then
                break
            end
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("JionGuild:update", condid, nil)
        end
    end
    return isModify
end

function JionGuild:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""
local ChangeName = class("ChangeName")
function ChangeName:ctor(param)
end

function ChangeName:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if conval > 0 then
                break
            end
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("ChangeName:update", condid, nil)
        end
    end
    return isModify
end

function ChangeName:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local SpeedupCount = class("SpeedupCount")
function SpeedupCount:ctor(param)
end

function SpeedupCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("SpeedupCount:update", condid, nil)
        end
    end
    return isModify
end

function SpeedupCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""
local RepairCount = class("RepairCount")
function RepairCount:ctor(param)
end

function RepairCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("RepairCount:update", condid, nil)
        end
    end
    return isModify
end

function RepairCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""x""
local CashoutCount = class("CashoutCount")
function CashoutCount:ctor(param)
end

function CashoutCount:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("CashoutCount:update", condid, nil)
        end
    end
    return isModify
end

function CashoutCount:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--""
local DailyLogin = class("DailyLogin")
function DailyLogin:ctor(param)
end

function DailyLogin:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2] or 0
            if cfgId == 0 or cfgId == param.cfgId then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("DailyLogin:update", condid, nil)
        end
    end
    return isModify
end

function DailyLogin:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""
local ArmyAddHero = class("ArmyAddHero")
function ArmyAddHero:ctor(param)
end

function ArmyAddHero:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
           if target[condid] < param.count then
                target[condid] = param.count
                isModify = true
           end
        end
    end
    return isModify
end

function ArmyAddHero:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""
local SanAddHero = class("SanAddHero")
function SanAddHero:ctor(param)
end

function SanAddHero:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
           if target[condid] < param.count then
                target[condid] = param.count
                isModify = true
           end
        end
    end
    return isModify
end

function SanAddHero:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""
local TrainReserve = class("TrainReserve")
function TrainReserve:ctor(param)
end

function TrainReserve:update(target, param)
    local isModify = false
    for condid, conval in pairs(target) do
        target[condid] = target[condid] + param.count
        isModify = true
    end
    return isModify
end

function TrainReserve:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""y""
local SoldierJoinBattle = class("SoldierJoinBattle")
function SoldierJoinBattle:ctor(param)
end

function SoldierJoinBattle:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[1]
            if  param.data[cfgId] then
                target[condid] = conval + 1
                isModify = true
            end
        else
            debugPrint("SoldierJoinBattle:update", condid, nil)
        end
    end
    return isModify
end

function SoldierJoinBattle:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""
local DonateInGuild = class("DonateInGuild")
function DonateInGuild:ctor(param)
end

function DonateInGuild:update(target, param)
    local isModify = false
    for condid, conval in pairs(target) do
        target[condid] = target[condid] + param.count
        isModify = true
    end
    return isModify
end

function DonateInGuild:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

-- ""x""
local StarmapAtt = class("StarmapAtt")
function StarmapAtt:ctor(param)
end

function StarmapAtt:update(target, param)
    local isModify = false
    for condid, conval in pairs(target) do
        target[condid] = conval + 1
        isModify = true
    end
    return isModify
end

function StarmapAtt:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end




-- ""x""y""（y""0，""）
local DrawCard = class("DrawCard")
function DrawCard:ctor(param)
end

function DrawCard:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            local cfgId = condCfg.targetArgs[2]
            if cfgId and cfgId ~= 0 then
                if param.cfgId == cfgId then
                    target[condid] = conval + param.count
                    isModify = true
                end
            else
                target[condid] = conval + param.count
                isModify = true
            end
        else
            debugPrint("DrawCard:update", condid, nil)
        end
    end
    return isModify
end

--""x""
local WarshipSkillLv = class("WarshipSkillLv")
function WarshipSkillLv:ctor(param)
end

function WarshipSkillLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0 or condCfg.targetArgs[2] == param.skillId then
                if param.lv >= condCfg.targetArgs[3] then
                    target[condid] = conval + 1
                    isModify = true
                end
            end
        else
            debugPrint("WarshipSkillLv:update", condid, nil)
        end
    end
    return isModify
end

function WarshipSkillLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end


function DrawCard:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end

--y""x
local SoldierLv = class("SoldierLv")
function SoldierLv:ctor(param)
end

function SoldierLv:update(target, param)
    local isModify = false
    local taskCfg = gg.getExcelCfg("subTask")
    for condid, conval in pairs(target) do
        local condCfg = taskCfg[tonumber(condid)]
        if condCfg then
            if condCfg.targetArgs[2] == 0 or condCfg.targetArgs[2] == param.cfgId then
                if param.lv >= condCfg.targetArgs[3]  then
                    target[condid] = condid + 1
                end
            end
        else
            debugPrint("SoldierLv:update", condid, nil)
        end
    end
    return isModify
end

function SoldierLv:checkComplete(target, targetTaskIds, complete, curChapterId)
    return commonCheckComplete(target, targetTaskIds, complete, curChapterId)
end
