local GuideBag = class("GuideBag")

function GuideBag:ctor(param)
    self.player = param.player
    self.guides = {}                        -- ""guideId
    self.iceGuideDrawed = false
    self.starCoinGuideDrawed = false
end

function GuideBag:serialize()
    local data = {}
    data.guides = self.guides
    data.iceGuideDrawed = self.iceGuideDrawed
    data.starCoinGuideDrawed = self.starCoinGuideDrawed
    return data
end

function GuideBag:deserialize(data)
    if not data then
        return
    end
    if data.guides then
        self.guides = data.guides
    end
    self.iceGuideDrawed = data.iceGuideDrawed
    self.starCoinGuideDrawed = data.starCoinGuideDrawed
end

function GuideBag.getGuideCfg(guideId)
    local guideCfgs = cfg.get("etc.cfg.guide")
    for _,v in pairs(guideCfgs) do
        if v.guideId == guideId and v.stepId == 1 then
            return v
        end
    end
    return nil
end

function GuideBag:getBeginGuides()
    local guideCfgs = cfg.get("etc.cfg.guide")
    local guides = {}
    for _,v in pairs(guideCfgs) do
        if v.isInit == 1 and v.stepId == 1 then
            table.insert(guides, {guideId = v.guideId, skipOthers = 0})
        end
    end
    return guides
end

function GuideBag:getCurGuide()
    if not next(self.guides) then
        return nil
    else
        local len = #self.guides
        return self.guides[len]
    end
end

function GuideBag:insertGuides(guides)
    if not guides or not next(guides) then
        return 
    end
    for _,v in pairs(guides) do
        local guideCfg = ggclass.GuideBag.getGuideCfg(v.guideId)
        if not guideCfg then
            self.player:say(util.i18nFormat(errors.GUIDE_ID_NOT_EXIST))
            return
        end
        table.insert(self.guides, {guideId = v.guideId})
        if v.skipOthers == 1 then
            local curGuide = self:getCurGuide()
            self:insertLeftGuides(curGuide)
        end
    end
end

function GuideBag:insertLeftGuides(guide)
    local nextGuides = self:getNextGuides(guide)
    if not nextGuides then
        return
    end

    for _,v in pairs(nextGuides) do
        table.insert(self.guides, {guideId = v.guideId})
    end
    local curGuide = self:getCurGuide()
    self:insertLeftGuides(curGuide)
end

function GuideBag:getNextGuides(guide)
    local guideCfg = ggclass.GuideBag.getGuideCfg(guide.guideId)
    if not guideCfg.nextGuideIds or not next(guideCfg.nextGuideIds) then
        return nil
    end

    local nextGuides = {}
    for _,v in pairs(guideCfg.nextGuideIds) do
        table.insert(nextGuides, {guideId = v, skipOthers = 0})
    end
    return nextGuides
end

function GuideBag:checkFinish(guides)
    if not guides or not next(guides) then
        self.player:say(util.i18nFormat(errors.GUIDE_NOT_EXIST))
        return
    end

    self:insertGuides(guides)
    local curGuide = self:getCurGuide()
    local nextGuides = self:getNextGuides(curGuide)
    gg.client:send(self.player.linkobj, "S2C_Player_NextGuides", {guides = nextGuides})
end

-------------------------------------------------
function GuideBag:reapGuideIce(id)
    local build = self.player.buildBag.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return 
    end
    if self.iceGuideDrawed then
        return
    end
    local iceAward = gg.getGlobalCfgIntValue("GuideIceAward", 10000)
    build.curIce = build.curIce + iceAward
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate", { build = build:pack() })
    self.iceGuideDrawed = true
end

function GuideBag:reapGuideStarCoin(id)
    local build = self.player.buildBag.builds[id]
    if not build then
        self.player:say(util.i18nFormat(errors.BUILD_NOT_EXIST))
        return
    end
    if self.starCoinGuideDrawed then
        return
    end
    local starCoinAward = gg.getGlobalCfgIntValue("GuideStarCoinAward", 10000)
    build.curStarCoin = build.curStarCoin + starCoinAward
    gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate", { build = build:pack() })
    self.starCoinGuideDrawed = true
end
-------------------------------------------------

function GuideBag:onlogin()
    if not next(self.guides) then
        local beginGuides = self:getBeginGuides()
        gg.client:send(self.player.linkobj, "S2C_Player_NextGuides", {guides = beginGuides})
    else
        local curGuide = self:getCurGuide()
        local nextGuides = self:getNextGuides(curGuide)
        gg.client:send(self.player.linkobj, "S2C_Player_NextGuides", {guides = nextGuides})
    end
end

return GuideBag

