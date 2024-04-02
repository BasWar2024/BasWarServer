local TaskBag = class("TaskBag")

local targetHandle = {
}

function TaskBag:ctor(param)
    self.player = param.player
    self.chapterId = 1
    self.chapterState = 0
    self.chapters = {}
    self.complete = {}
    self.tasksTarget = {}
    self.dailyTarget = {}
    self.targetTaskIds = {}
    for key, value in pairs(constant.TASK_TARGET_KEYS) do
        self.tasksTarget[tostring(key)] = {}
        self.dailyTarget[tostring(key)] = {}
        targetHandle[tostring(key)] = ggclass[value].new({})
    end
    self.dailyResetTick = 0                                        -- ""("")
    self.activation = 0
    self.activationBox = {}
end

function TaskBag:serialize()
    local data = {}
    data.chapterId = self.chapterId
    data.chapterState = self.chapterState
    data.chapters = {}
    for id,v in pairs(self.chapters) do
        data.chapters[id] = v
    end
    data.complete = {}
    for id,v in pairs(self.complete) do
        data.complete[id] = v
    end
    data.tasksTarget = {}
    for key,v in pairs(self.tasksTarget) do
        data.tasksTarget[key] = data.tasksTarget[key] or {}
        for kk, vv in pairs(v) do
            data.tasksTarget[key][kk] = vv
        end
    end
    data.dailyTarget = {}
    for key,v in pairs(self.dailyTarget) do
        data.dailyTarget[key] = data.dailyTarget[key] or {}
        for kk, vv in pairs(v) do
            data.dailyTarget[key][kk] = vv
        end
    end
    data.dailyResetTick = self.dailyResetTick
    data.activation = self.activation
    data.activationBox = {}
    for id,v in pairs(self.activationBox) do
        data.activationBox[tostring(id)] = v
    end
    return data
end

function TaskBag:deserialize(data)
    self.chapterId = data.chapterId
    self.chapterState = data.chapterState
    if data.chapters then
        for id,v in pairs(data.chapters) do
            self.chapters[id] = v
        end
    end
    if data.complete then
        for id,v in pairs(data.complete) do
            self.complete[id] = v
        end
    end
    if data.tasksTarget then
        for key,v in pairs(data.tasksTarget) do
            self.tasksTarget[key] = self.tasksTarget[key] or {}
            for kk, vv in pairs(v) do
                self.tasksTarget[key][kk] = vv
            end
        end
    end
    if data.dailyTarget then
        for key,v in pairs(data.dailyTarget) do
            self.dailyTarget[key] = self.dailyTarget[key] or {}
            for kk, vv in pairs(v) do
                self.dailyTarget[key][kk] = vv
            end
        end
    end
    self.dailyResetTick = data.dailyResetTick or 0
    self.activation = data.activation or 0
    if data.activationBox then
        for id,v in pairs(data.activationBox) do
            self.activationBox[tonumber(id)] = v
        end
    end
end

function TaskBag:_sendUpdate(op, data)
    local send = {op_type = op}
    for key, value in pairs(data) do
        send[key] = value
    end
    send.chapterId = self.chapterId
    send.chapterState = self.chapterState
    send.activation = self.activation
    send.dailyResetTick = math.floor(self.dailyResetTick / 1000)
    gg.client:send(self.player.linkobj,"S2C_Player_TaskUpdate",send)
end

function TaskBag:_checkTasksTarget()
    local baseLv = self.player.buildBag:getBaseBuildLevel()
    local taskCfg = gg.getExcelCfg("subTask")
    for k, v in pairs(taskCfg) do
        if v.available == 1 then
            local idStr = tostring(v.cfgId)
            if not self.complete[idStr] then
                local canInit = false
                if v.type == constant.TASK_TYPE.DAILY then
                    if v.lvRange and v.lvRange[1] and v.lvRange[2] then
                        if baseLv >= v.lvRange[1] and baseLv <= v.lvRange[2] then
                            canInit = true
                        end
                    else
                        canInit = true
                    end
                    if canInit then
                        local tarStr = tostring(v.targetType)
                        if not self.dailyTarget[tarStr] then
                            self.dailyTarget[tarStr] = {
                            }
                        end
                        if not self.dailyTarget[tarStr][idStr] then
                            self.dailyTarget[tarStr][idStr] = 0
                        end
    
                        self.targetTaskIds[tarStr] = self.targetTaskIds[tarStr] or {}
                        self.targetTaskIds[tarStr][idStr] = v.chapterId or 0
                    end
                else
                    local tarStr = tostring(v.targetType)
                    if not self.tasksTarget[tarStr] then
                        self.tasksTarget[tarStr] = {
                        }
                    end
                    if not self.tasksTarget[tarStr][idStr] then
                        self.tasksTarget[tarStr][idStr] = 0
                    end

                    self.targetTaskIds[tarStr] = self.targetTaskIds[tarStr] or {}
                    self.targetTaskIds[tarStr][idStr] = v.chapterId or 0
                end
            end
        end
    end
end

function TaskBag:_checkTasksTargetUpdate()
    for _,warShip in pairs(self.player.warShipBag.warShips) do
        self:update(constant.TASK_WARSHIP_LV, {cfgId = warShip.cfgId, lv = warShip.level})
        for i = 1, 4, 1 do
            if warShip["skill"..i] ~= 0 then
                self:update(constant.TASK_WARSHIP_SKILL_LV, {skillId = i, lv = warShip["skillLevel" .. i]})
            end
        end
    end

    for _,hero in pairs(self.player.heroBag.heros) do
        self:update(constant.TASK_HERO_LV, {cfgId = hero.cfgId, lv = hero.level})
        for i = 1, 3, 1 do
            if hero["skill"..i] ~= 0 then
                self:update(constant.TASK_HERO_SKILL_LV, {skillId = i, lv = hero["skillLevel" .. i]})
            end
        end
    end

    -- ""X""Y""Z""
    local handle = targetHandle[tostring(constant.TASK_BUILD_LV_COUNT)]
    if handle then
        local total = 0
        local buildLVCountMap = {}
        for _,build in pairs(self.player.buildBag.builds) do
            buildLVCountMap[build.cfgId] = buildLVCountMap[build.cfgId] or {}
            buildLVCountMap[build.cfgId][build.level] = buildLVCountMap[build.cfgId][build.level] or 0
            buildLVCountMap[build.cfgId][build.level] = buildLVCountMap[build.cfgId][build.level] + 1
            total = total + 1
        end
        local taskCfg = gg.getExcelCfg("subTask")
        local newTaskTarget = {}
        local taskTarget = self.tasksTarget[tostring(constant.TASK_BUILD_LV_COUNT)]
        for condid, conval in pairs(taskTarget) do
            local condCfg = taskCfg[tonumber(condid)]
            if condCfg then
                local cfgId = condCfg.targetArgs[2]
                local lv = condCfg.targetArgs[3]
                for cfgid, value in pairs(buildLVCountMap) do
                    if cfgId == 0 or cfgid == cfgId then
                        if not lv or lv == 0 then
                            newTaskTarget[condid] = total
                            break
                        else
                            for _lv, _count in pairs(value) do
                                if _lv >= lv then
                                    newTaskTarget[condid] = newTaskTarget[condid] or 0
                                    newTaskTarget[condid] = newTaskTarget[condid] + _count
                                end
                            end
                        end
                    end
                end
                if not newTaskTarget[condid] then
                    newTaskTarget[condid] = conval
                end
            else
                -- newTaskTarget[condid] = conval
            end
        end
        self.tasksTarget[tostring(constant.TASK_BUILD_LV_COUNT)] = newTaskTarget
    end

    for cfgId, value in pairs(self.player.pveBag.pass) do
        self:update(constant.TASK_PVE_WIN, {cfgId = cfgId, count = 1})
    end

    if self.player.unionBag:getMyUnionId() then
        self:update(constant.TASK_JION_GUILD, {})
    end

    if self.player.playerInfoBag.modifyNameNum > 0 then
        self:update(constant.TASK_CHANGE_NAME, {})
    end

    -- local taskTarget = self.tasksTarget[tostring(constant.TASK_BUILD_LV_COUNT)]
    local NOT_CHECK = {}
end

function TaskBag:_checkComplete(targets, isDaily)
    local completeTasks = {}
    for i, v in ipairs(targets) do
        local taskTarget = self.tasksTarget[tostring(v)]
        if isDaily then
            taskTarget = self.dailyTarget[tostring(v)]
        end
        local taskIds = self.targetTaskIds[tostring(v)]
        if taskTarget and taskIds and table.count(taskIds) > 0 then
            local handle = targetHandle[tostring(v)]
            if handle then
                local newComplete = handle:checkComplete(taskTarget, taskIds, self.complete, self.chapterId)
                for idstr, state in pairs(newComplete) do
                    self.complete[idstr] = state
                    table.insert(completeTasks, {cfgId = tonumber(idstr), stage = state})
                end
            end
        end
    end
    if table.count(completeTasks) > 0 then
        self:_sendUpdate(constant.OP_ADD, {
            completeTasks = completeTasks,
        })
    end
end

function TaskBag:_doReceive(cfgId, reward, animationId, rewardItem)
    local resDict = {}
    for i, v in ipairs(reward) do
        resDict[v[1]] = resDict[v[1]] or 0
        resDict[v[1]] = resDict[v[1]] + v[2]
    end
    local animArg = {animationId = animationId, fromId = cfgId}
    self.player.resBag:addResDict(resDict, {logType = gamelog.TASK_REWARD}, false, animArg)
    
    for k,v in pairs(rewardItem or {}) do
        self.player.itemBag:addItem(v[1], v[2], { logType=gamelog.TASK_REWARD })
    end

    return true
end

function TaskBag:_isChapterMainTasksAllReceive()
    local chaptaskCfg = gg.getExcelCfg("chapterTask")
    local cfg = chaptaskCfg[self.chapterId]
    if not cfg then
        return
    end
    local allOk = true
    for i, v in ipairs(cfg.mainTaskList) do
        local state = self.complete[tostring(v)]
        if state ~= constant.TASK_STATE.REWARD then
            allOk = false
            break
        end
    end
    return allOk
end

function TaskBag:update(target, params)
    local handle = targetHandle[tostring(target)]
    if not handle then
        -- error("no handle for target "..target)
        return
    end
    local taskTarget = self.tasksTarget[tostring(target)]
    if taskTarget then
        local isModify = handle:update(taskTarget, params)
        if isModify then
            local sendTarget = {tarId = tonumber(target)}
            sendTarget.targetConds = {}
            for condid, conval in pairs(taskTarget) do
                table.insert(sendTarget.targetConds, {condId = tonumber(condid), curVal = conval})
            end
            self:_sendUpdate(constant.OP_MODIFY, {
                taskTargets = {sendTarget},
            })
        end
        self:_checkComplete({target})
    end

    -- daily task
    local dailyTarget = self.dailyTarget[tostring(target)]
    if dailyTarget then
        local isDailyModify = handle:update(dailyTarget, params)
        if isDailyModify then
            local sendTarget = {tarId = tonumber(target)}
            sendTarget.targetConds = {}
            for condid, conval in pairs(dailyTarget) do
                table.insert(sendTarget.targetConds, {condId = tonumber(condid), curVal = conval})
            end
            self:_sendUpdate(constant.OP_MODIFY, {
                dailyTargets = {sendTarget},
            })
        end
        self:_checkComplete({target}, true)
    end
end

function TaskBag:receiveTaskRewards(cfgId)
    local idstr = tostring(cfgId)
    if not self.complete[idstr] then
        self.player:say(util.i18nFormat(errors.TASK_NOT_FINISH))
        return
    end
    local taskCfg = gg.getExcelCfg("subTask")
    local cfg = taskCfg[cfgId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.TASK_NOT_EXIST))
        return
    end
    local state = self.complete[idstr]
    if state == constant.TASK_STATE.REWARD then
        self.player:say(util.i18nFormat(errors.TASK_NO_DRAWED))
        return
    end
    if self:_doReceive(cfg.cfgId, cfg.reward, constant.ANIMATION_TASK, cfg.rewardItem) then
        self.complete[idstr] = constant.TASK_STATE.REWARD
    end
    if cfg.type == constant.TASK_TYPE.DAILY then
        self.activation = self.activation + (cfg.activation or 0)
    end
    self:_sendUpdate(constant.OP_MODIFY, {
        completeTasks = {{cfgId = cfgId, stage = constant.TASK_STATE.REWARD}},
    })
end

function TaskBag:receiveChapterRewards()
    local allOk = self:_isChapterMainTasksAllReceive()
    if not allOk then
        self.player:say(util.i18nFormat(errors.TASK_CHAPTER_NOT_DONE))
        return
    end
    local chaptaskCfg = gg.getExcelCfg("chapterTask")
    local cfg = chaptaskCfg[self.chapterId]
    if not cfg then
        return
    end
    local idstr = tostring(self.chapterId)
    if self.chapters[idstr] then
        self.player:say(util.i18nFormat(errors.TASK_NO_DRAWED))
        return
    end
    if self:_doReceive(cfg.cfgId, cfg.reward, constant.ANIMATION_CHAP_TASK,cfg.rewardItem) then
        self.chapters[idstr] = true
        self.chapterState = 1
    end
    if cfg.nextChapter then
        self.chapterId = cfg.nextChapter
        self.chapterState = 0
        self:_checkTasksTarget()
        self:_checkTasksTargetUpdate()
        self:_checkComplete(table.keys(self.tasksTarget))
        self:_sendUpdate(constant.OP_ADD, self:pack())
    else
        self:_sendUpdate(constant.OP_ADD, {
            chapterId = self.chapterId,
            -- completeChapters = {tonumber(idstr)},
        })
    end
end

function TaskBag:receiveActivationRewards(cfgId)
    local cfg = gg.getExcelCfg("taskActivation")[cfgId]
    if not cfg then
        self.player:say(util.i18nFormat(errors.TASK_ACTIVATION_NOT_EXIST))
        return
    end
    if self.activationBox[cfgId] then
        self.player:say(util.i18nFormat(errors.TASK_NO_DRAWED))
        return
    end
    if self.activation < cfg.activation then
        self.player:say(util.i18nFormat(errors.TASK_ACTIVATION_NOT_ENOUGH))
        return
    end
    local activationReward
    local baseLv = self.player.buildBag:getBaseBuildLevel()
    local baseCfg = gg.getExcelCfg("baseBuild")
    for k, v in pairs(baseCfg) do
        if baseLv >= v.minBaseLv and baseLv <= v.maxBaseLv and cfg.reward == v.id then
            activationReward = v.activationReward
            break
        end
    end
    if not activationReward then
        return
    end
    if self:_doReceive(cfgId, activationReward, constant.ANIMATION_TASK_ACTIVA) then
        self.activationBox[cfgId] = constant.TASK_STATE.REWARD
    end
    self:_sendUpdate(constant.OP_ADD, {
        activationBox = {cfgId},
    })
end

function TaskBag:pack()
    local ret = {
        chapterId = self.chapterId,
        -- completeChapters = table.keys(self.chapters),
    }
    local completeTasks = {}
    for key, value in pairs(self.complete) do
        table.insert(completeTasks, {cfgId = tonumber(key), stage = value})
    end
    ret.completeTasks = completeTasks
    local taskTargets = {}
    for tarId, cond in pairs(self.tasksTarget) do
        local target = {tarId = tonumber(tarId)}
        target.targetConds = {}
        for condId, curVal in pairs(cond) do
            table.insert(target.targetConds, {condId = tonumber(condId), curVal = curVal})
        end
        table.insert(taskTargets, target)
    end
    ret.taskTargets = taskTargets

    local dailyTargets = {}
    for tarId, cond in pairs(self.dailyTarget) do
        local target = {tarId = tonumber(tarId)}
        target.targetConds = {}
        for condId, curVal in pairs(cond) do
            table.insert(target.targetConds, {condId = tonumber(condId), curVal = curVal})
        end
        table.insert(dailyTargets, target)
    end
    ret.dailyTargets = dailyTargets

    local activationBox = {}
    for id, value in pairs(self.activationBox) do
        table.insert(activationBox, id)
    end
    ret.activationBox = activationBox
    return ret
end

function TaskBag:resetDailyData()
    self.dailyResetTick = (gg.time.dayzerotime() + 86400) * 1000
    self.activation = 0
    local taskCfg = gg.getExcelCfg("subTask")
    local resetTasks = {}
    for idstr, value in pairs(self.complete) do
        local cfg = taskCfg[tonumber(idstr)]
        if cfg then
            if cfg.type == constant.TASK_TYPE.DAILY then
                table.insert(resetTasks, idstr)
            end
        end
    end
    local delComplete = {}
    for i, v in ipairs(resetTasks) do
        self.complete[v] = nil
        table.insert(delComplete, {cfgId = tonumber(v), stage = constant.TASK_STATE.REWARD})
    end
    local delBoxFlag = table.keys(self.activationBox)
    self.activationBox = {}
    self:_sendUpdate(constant.OP_DEL, {
        completeTasks = delComplete,
        activationBox = delBoxFlag,
    })
    self.dailyTarget = {}
    self:_checkTasksTarget()
    self:_sendUpdate(constant.OP_ADD, self:pack())
end

function TaskBag:checkResetDailyData()
    if skynet.timestamp() <= self.dailyResetTick then
        return
    end
    self:resetDailyData()
end

function TaskBag:onSecond()
    self:checkResetDailyData()
end

function TaskBag:oncreate()
    self.dailyResetTick = (gg.time.dayzerotime() + 86400) * 1000
end

function TaskBag:onload()
    self:_checkTasksTarget()
end

function TaskBag:onlogin()
    self:update(constant.TASK_DAILY_LOGIN, {})
    self:_checkTasksTargetUpdate()
    self:_checkComplete(table.keys(self.tasksTarget))
    self:_checkComplete(table.keys(self.dailyTarget), true)
    self:_sendUpdate(constant.OP_ADD, self:pack())
    -- self:Test()
end

function TaskBag:onlogout()

end

function TaskBag:onreset()
    self.chapterId = 1
    self.chapterState = 0
    self.chapters = {}
    self.complete = {}
    self.tasksTarget = {}
    self.dailyTarget = {}
    self.targetTaskIds = {}
    for key, value in pairs(constant.TASK_TARGET_KEYS) do
        self.tasksTarget[tostring(key)] = {}
        self.dailyTarget[tostring(key)] = {}
        targetHandle[tostring(key)] = ggclass[value].new({})
    end
    self.dailyResetTick = 0                                        -- ""("")
    self.activation = 0
    self.activationBox = {}
end

function TaskBag:Test()
    self.player.taskBag:update(constant.TASK_WARSHIP_LV, {cfgId = 3000002, lv = 2})
    self.player.taskBag:update(constant.TASK_WARSHIP_SKILL_LV, {skillId = 1, lv = 2})
    self.player.taskBag:update(constant.TASK_WARSHIP_LVUP, {cfgId = 3000002, })
    self.player.taskBag:update(constant.TASK_WARSHIP_SKILL_LVUP, {skillId = 1, })
    self.player.taskBag:update(constant.TASK_HERO_LV, {cfgId = 3000002, lv = 2})
    self.player.taskBag:update(constant.TASK_HERO_SKILL_LV, {skillId = 1, lv = 2})
    self.player.taskBag:update(constant.TASK_HERO_LVUP, {cfgId = 3000002})
    self.player.taskBag:update(constant.TASK_HERO_SKILL_LVUP, {skillId = 1, })
    self.player.taskBag:update(constant.TASK_HERO_SWITCH_SKILL, {skillId = 1})
    self.player.taskBag:update(constant.TASK_BUILD_LV_COUNT, {cfgId = 3000002, lv = 1, count = 1})
    self.player.taskBag:update(constant.TASK_BUILD_LV_COUNT, {cfgId = 3000003, lv = 1, count = 1})
    self.player.taskBag:update(constant.TASK_BUILD_LV_COUNT, {cfgId = 3000001, lv = 1, count = 1})
    self.player.taskBag:update(constant.TASK_BUILD_LVUP_COUNT, {cfgId = 3000001, lv = 1, count = 1})
    self.player.taskBag:update(constant.TASK_TRAIN_SOLIDERS, {cfgId = 4101001, count = 2})
    self.player.taskBag:update(constant.TASK_LVUP_SOLIDERS, {cfgId = 4101001, count = 1})
    self.player.taskBag:update(constant.TASK_PVP_COUNT, {count = 1})
    self.player.taskBag:update(constant.TASK_PVP_SCORE, {score = 1})
    self.player.taskBag:update(constant.TASK_PVE_WIN, {cfgId = 4101001, count = 1})
    self.player.taskBag:update(constant.TASK_DESTORY_BUILD_TYPE_COUNT, {buildType = 1, count = 1})
    self.player.taskBag:update(constant.TASK_DESTORY_BUILD_COUNT, {cfgId = 0, count = 1})
    self.player.taskBag:update(constant.TASK_COLLECT_RES_COUNT, {cfgId = 0, count = 1})
    self.player.taskBag:update(constant.TASK_COLLECT_RES_NUM, {cfgId = 0, count = 1})
    self.player.taskBag:update(constant.TASK_CONSUME_RES_NUM, {cfgId = 0, count = 1})
    self.player.taskBag:update(constant.TASK_JION_GUILD, {})
    self.player.taskBag:update(constant.TASK_CHANGE_NAME, {})
    self.player.taskBag:update(constant.TASK_SPEEDUP_COUNT, {})
    self.player.taskBag:update(constant.TASK_REPAIR_COUNT, {})
    self.player.taskBag:update(constant.TASK_CASHOUT_COUNT, {})
    self.player.taskBag:update(constant.TASK_DAILY_LOGIN, {})
    -- local data = self:serialize()
    -- print("TaskBag:Test--------------task data")
    -- print(table.dump(data))
    -- print("TaskBag:Test--------------receive task reward")
    -- self:receiveTaskRewards(1001)
    -- self:receiveTaskRewards(1003)
    -- print(table.dump(self.complete))
end

return TaskBag