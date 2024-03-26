local AchievementBag = class("AchievementBag")

function AchievementBag:ctor(param)
    self.player = param.player
    self.achievements = {}
end

function AchievementBag:serialize()
    local data = {}
    data.achievements = {}
    if self.achievements and next(self.achievements) then
        for k, v in pairs(self.achievements) do
            table.insert(data.achievements, v:serialize())
        end
    end
    return data
end


function AchievementBag:deserialize(data)
    if data and data.achievements and next(data.achievements) then
        for k, v in pairs(data.achievements) do
            local achievement = ggclass.Achievement.new({player=self.player})
            if achievement then
                achievement:deserialize(v)
                self.achievements[v.cfgId] = achievement
            end
        end
    end
end

--""
function AchievementBag:init()
    local achievementCfg = cfg.get("etc.cfg.achievement")
    for k , v in pairs(achievementCfg) do
        if v.showStar == 1 then
            if not self.achievements[v.cfgId] then
                local achievement = ggclass.Achievement.new({player=self.player})
                achievement.index = v.index
                achievement.cfgId = v.cfgId
                self.achievements[v.cfgId] = achievement
            end
        end
    end
end

function AchievementBag:pack()
    local achievements = {}
    for k, v in pairs(self.achievements) do
        table.insert(achievements, v:pack())
    end
    return achievements
end

function AchievementBag:getAchievementByCfgId(cfgId)
    return self.achievements[cfgId]
end

--""
function AchievementBag:drawAchievement(index)
    local cfgInfo = ggclass.Achievement.getAchievementCfg(index)
    if not cfgInfo then
        self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
        return
    end
    local achievement = self:getAchievementByCfgId(cfgInfo.cfgId)
    if not achievement then
        self.player:say(util.i18nFormat(errors.ACHIEVEMENT_NOT_FOUND))
        return
    end
    if achievement.value < cfgInfo.targetValue then
        self.player:say(util.i18nFormat(errors.ACHIEVEMENT_NOT_FINISH))
        return
    end
    if achievement.drawed == true then
        self.player:say(util.i18nFormat(errors.ACHIEVEMENT_DRAWED))
        return
    end

    self.player.resBag:addRes(constant.RES_MIT, cfgInfo.mit, { logType=gamelog.DRAW_ACHIEVEMENT })

    local nextCfgInfo = ggclass.Achievement.getAchievementCfg(cfgInfo.nextIndex)
    if cfgInfo.nextIndex and nextCfgInfo then
        assert(nextCfgInfo.cfgId == cfgInfo.cfgId, "cfgId is config error")
        local newAchievement = ggclass.Achievement.new({player=self.player})
        newAchievement.index = cfgInfo.nextIndex
        newAchievement.cfgId = cfgInfo.cfgId
        newAchievement.value = achievement.value
        self.achievements[cfgInfo.cfgId] = newAchievement
        gg.client:send(self.player.linkobj,"S2C_Player_AchievementReplace",{achievement=newAchievement:pack()})
    else
        achievement.drawed = true
        gg.client:send(self.player.linkobj,"S2C_Player_AchievementUpdate",{achievement=achievement:pack()})
    end
end

--""
function AchievementBag:updateAchievement(cfgId, value)
    local achievement = self:getAchievementByCfgId(cfgId)
    if not achievement then
        return
    end
    local cfgInfo = ggclass.Achievement.getAchievementCfg(achievement.index)
    if not cfgInfo then
        return
    end
    local ret = false
    if cfgId == constant.ACHIEVEMENT_NEW_PLAYER_GUIDE then
        ret = achievement:setValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DESTORY_BUILDS then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_REMOVE_MESS then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_RECEIVE_ICE then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_RECEIVE_TITANIUM then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_RECEIVE_GAS then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_RECEIVE_CARBOXYL then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_RECEIVE_STAR_COIN then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_HOLD_RESPLANET_NUM then
        if value <= achievement.value then
            return
        end
        ret = achievement:setValue(value)
    elseif cfgId == constant.ACHIEVEMENT_FINISH_DAILY_TASK_NUM then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_PVP_MAX_SCORE then
        if value <= achievement.value then
            return
        end
        ret = achievement:setValue(value)
    elseif cfgId == constant.ACHIEVEMENT_JOIN_OR_CREATE_UNION then
        if value <= achievement.value then
            return
        end
        ret = achievement:setValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DESTORY_MAIN_BUILD then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DESTORY_DEFEND_BUILD then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DESTORY_DEVELOP_BUILD then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DESTORY_ECONOMY_BUILD then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_NINJA then --""
        achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_PARTICLE_GUNNER then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_ALIEN then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_PARTICLE_TANK then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_FIRE_ELEMENT then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_SONIC_TANK then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_SIRIUS then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_ANTIMATTER then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_NUCLEAREXPLOSION then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_TRAIN_SUICIDE_AIRCRAFT then --""
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_PVP_ATTACK_WIN then -----
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_NO_HURT_WIN then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_DEFENSE_WIN then
        ret = achievement:addValue(value)
    elseif cfgId == constant.ACHIEVEMENT_ATTACK_WIN_IN_TIME then
        if value > cfgInfo.targetValue then
            return
        end
        if achievement.value ~= 0 and achievement.value <= cfgInfo.targetValue then
            return
        end
        achievement.value = cfgInfo.targetValue
        ret = true
    elseif cfgId == constant.ACHIEVEMENT_USE_MIT_NUM then
        ret = achievement:addValue(value)
    end
    if ret == true then
        gg.client:send(self.player.linkobj,"S2C_Player_AchievementUpdate",{achievement=achievement:pack()})
    end
end

function AchievementBag:onload()
    self:init()
end

function AchievementBag:onlogin()
    gg.client:send(self.player.linkobj,"S2C_Player_AchievementData",{achievements=self:pack()})
end

function AchievementBag:onlogout()

end

return AchievementBag