local EditorBag = class("EditorBag")

function EditorBag:ctor(param)
    self.player = param.player
end

function EditorBag:serialize()
end

function EditorBag:deserialize(data)
end

function EditorBag:gameObjectOp(args)
    if not gg.isInnerServer() then
        return
    end
    local TYPE_BUILD = 1
    local TYPE_WARSHIP = 2
    local TYPE_HERO = 3
    local TYPE_SOLIDER = 4
    local TYPE_NFT_BUILD = 5
    local OP_LV = 1
    local OP_DEL = 2
    local OP_SKILL_LV = 3
    local OP_QUALITY = 4

    local GO_TYPE_MAP = {
        [TYPE_BUILD] = {
            ["bag"] = "buildBag",
            ["get"] = "getBuild",
            ["get_err"] = errors.BUILD_NOT_EXIST,
            ["class"] = "Build",
            ["get_cfg"] = "getBuildCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_BuildUpdate",
            ["update_key"] = "build",
            ["container"] = "builds",
            ["del_func"] = "delBuild",
            ["del_proto"] = "S2C_Player_BuildDel",
        },
        [TYPE_WARSHIP] = {
            ["bag"] = "warShipBag",
            ["get"] = "getWarShip",
            ["get_err"] = errors.WARSHIP_NOT_EXIST,
            ["class"] = "WarShip",
            ["get_cfg"] = "getWarShipCfg",
            ["get_skill_cfg"] = "getWarShipSkillCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_WarShipUpdate",
            ["update_key"] = "warShip",
            ["container"] = "warShips",
            ["del_func"] = "delWarShip",
            ["del_proto"] = "S2C_Player_WarShipDel",
        },
        [TYPE_HERO] = {
            ["bag"] = "heroBag",
            ["get"] = "getHero",
            ["get_err"] = errors.HERO_NOT_EXIST,
            ["class"] = "Hero",
            ["get_cfg"] = "getHeroCfg",
            ["get_skill_cfg"] = "getHeroSkillCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_HeroUpdate",
            ["update_key"] = "hero",
            ["container"] = "heros",
            ["del_func"] = "delHero",
            ["del_proto"] = "S2C_Player_HeroDel",
        },
        [TYPE_NFT_BUILD] = {
            ["bag"] = "nftBuildBag",
            ["get"] = "getBuild",
            ["get_err"] = errors.BUILD_NOT_EXIST,
            ["class"] = "Build",
            ["get_cfg"] = "getBuildCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_BuildUpdate",
            ["update_key"] = "build",
            ["container"] = "builds",
            ["del_func"] = "delBuild",
            ["del_proto"] = "S2C_Player_BuildDel",
        },
    }

    if not args.goType then
        return
    end
    if args.goType ~= TYPE_SOLIDER then
        if not args.id then
            return
        end
    else
        if not args.cfgId then
            return
        end
    end
    if args.op == OP_LV then
        if not args.level then
            return
        end
        if args.level <= 0 then
            return
        end
    end
    if args.op == OP_SKILL_LV then
        if not args.skillIdx or not args.skillLv then
            return
        end
        if args.skillLv <= 0 then
            return
        end
    end
    if args.op == OP_QUALITY then
        if not args.quality then
            return
        end
        if args.quality < 0 or args.quality > 5 then
            return
        end
    end

    local goData = GO_TYPE_MAP[args.goType]
    if goData then
        local bag = self.player[goData.bag]
        local go = bag[goData.get](bag, args.id)
        if not go then
            self.player:say(util.i18nFormat(goData.get_err))
            return
        end
        if args.op == OP_LV then
            local newLevel = args.level
            local nextCfg = ggclass[goData.class][goData.get_cfg](go.cfgId, go.quality, newLevel)
            if not nextCfg then
                self.player:say(util.i18nFormat(goData.lv_err))
                return
            end
            go.level = newLevel - 1
            go:setNextTick(0 * 1000)
            go:checkLevelUp()
            if args.goType == TYPE_BUILD then
                bag:updateConstructionCount()
                if args.cfgId == constant.BUILD_SANCTUARY then
                    bag:resetSanctuary()
                end
            end
            -- gg.client:send(self.player.linkobj,goData.update_proto,{ [goData.update_key] = go:pack() })
        elseif args.op == OP_DEL then
            bag[goData.del_func](bag, args.id, {logType = gamelog.EDITOR})
            -- gg.client:send(self.player.linkobj, goData.del_proto, { id = args.id })
        elseif args.op == OP_SKILL_LV then
            local skillCfgId = go["skill" .. args.skillIdx]
            if not skillCfgId then
                self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
                return
            end
            local quality = go.quality
            local curLevel = go["skillLevel" .. args.skillIdx]
            local newLevel = args.skillLv
            local nextCfg = ggclass[goData.class][goData.get_skill_cfg](skillCfgId, quality, newLevel)
            if not nextCfg then
                self.player:say(util.i18nFormat(goData.lv_err))
                return
            end
            go["skillLevel" .. args.skillIdx] = newLevel
            gg.client:send(self.player.linkobj,goData.update_proto,{ [goData.update_key] = go:pack() })
        elseif args.op == OP_QUALITY then
            if go.quality == args.quality then
                return
            end
            go.quality = args.quality
            local bag = 0
            if go.chain > 0 then
                bag = 1
            end
            gg.client:send(self.player.linkobj,goData.update_proto,{ [goData.update_key] = go:pack(), bag = bag })
        end
    else
        local soliderLevel = self.player.buildBag.soliderLevels[args.cfgId]
        if not soliderLevel then
            self.player:say(util.i18nFormat(errors.SOLIDER_NOT_EXIST))
            return
        end
        if args.op == OP_LV then
            local newLevel = args.level
            local nextCfg = ggclass.SoliderLevel.getSoliderCfg(soliderLevel.cfgId, newLevel)
            if not nextCfg then
                self.player:say(util.i18nFormat(errors.LEVEL_MAX))
                return
            end
            soliderLevel.level = newLevel
            gg.client:send(self.player.linkobj, "S2C_Player_SoliderLevelUpdate", { soliderLevel = soliderLevel:pack() })
        end
    end
end

function EditorBag:gameObjectChangeSkill(args)
    if not gg.isInnerServer() then
        return
    end
    local TYPE_WARSHIP = 2
    local TYPE_HERO = 3

    local GO_TYPE_MAP = {
        [TYPE_WARSHIP] = {
            ["bag"] = "warShipBag",
            ["get"] = "getWarShip",
            ["get_err"] = errors.WARSHIP_NOT_EXIST,
            ["class"] = "WarShip",
            ["get_cfg"] = "getWarShipCfg",
            ["get_skill_cfg"] = "getWarShipSkillCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_WarShipUpdate",
            ["update_key"] = "warShip",
            ["container"] = "warShips",
            ["skill_func"] = function(q)
                return math.min(3 + math.max(q-1, 0), 5)
            end,
            ["skillidx_err"] = "skillidx err",
        },
        [TYPE_HERO] = {
            ["bag"] = "heroBag",
            ["get"] = "getHero",
            ["get_err"] = errors.HERO_NOT_EXIST,
            ["class"] = "Hero",
            ["get_cfg"] = "getHeroCfg",
            ["get_skill_cfg"] = "getHeroSkillCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_HeroUpdate",
            ["update_key"] = "hero",
            ["container"] = "heros",
            ["skill_func"] = function(q)
                return math.min(1 + math.max(q-1, 0), 3)
            end,
            ["skillidx_err"] = "skillidx err",
        },
    }

    if not args.goType then
        return
    end
    if not args.id then
        return
    end
    if not args.skillIdx then
        return
    end
    if not args.skillId then
        return
    end
    if args.skillIdx <= 0 then
        return
    end

    local goData = GO_TYPE_MAP[args.goType]
    if goData then
        local bag = self.player[goData.bag]
        local go = bag[goData.get](bag, args.id)
        if not go then
            self.player:say(util.i18nFormat(goData.get_err))
            return
        end
        local nextCfg = ggclass[goData.class][goData.get_cfg](go.cfgId, go.quality, go.level)
        if not nextCfg then
            self.player:say(util.i18nFormat(goData.lv_err))
            return
        end
        local skillCount = goData.skill_func(go.quality)
        if args.skillIdx > skillCount then
            self.player:say(util.i18nFormat(goData.skillidx_err))
            return
        end
        local skillCfgId = go["skill" .. args.skillIdx]
        if not skillCfgId then
            self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
            return
        end
        local quality = go.quality
        local curLevel = go["skillLevel" .. args.skillIdx]
        local newLevel = 1
        local newSkill = args.skillId
        local newCfg = ggclass[goData.class][goData.get_skill_cfg](newSkill, quality, newLevel)
        if not newCfg then
            self.player:say(util.i18nFormat(errors.SKILL_NOT_EXIST))
            return
        end
        go["skill" .. args.skillIdx] = args.skillId
        go["skillLevel" .. args.skillIdx] = newLevel
        gg.client:send(self.player.linkobj,goData.update_proto,{ [goData.update_key] = go:pack() })
    end
end

function EditorBag:opLandShipSoldier(args)
    if not gg.isInnerServer() then
        return
    end
    local TYPE_BUILD = 1
    local GO_TYPE_MAP = {
        [TYPE_BUILD] = {
            ["bag"] = "buildBag",
            ["get"] = "getBuild",
            ["get_err"] = errors.BUILD_NOT_EXIST,
            ["class"] = "Build",
            ["get_cfg"] = "getBuildCfg",
            ["lv_err"] = errors.LEVEL_MAX,
            ["update_proto"] = "S2C_Player_BuildUpdate",
            ["update_key"] = "build",
            ["container"] = "builds",
            ["del_func"] = "delBuild",
            ["del_proto"] = "S2C_Player_BuildDel",
        },
    }
    if not args.soliderCfgId or args.soliderCfgId == 0 then
        return
    end
    if not args.soliderCount or args.soliderCount == 0 then
        return
    end
    local goData = GO_TYPE_MAP[TYPE_BUILD]
    if goData then
        local bag = self.player[goData.bag]
        local go = bag[goData.get](bag, args.id)
        if not go then
            self.player:say(util.i18nFormat(goData.get_err))
            return
        end
        --""
        if go.cfgId ~= constant.BUILD_LIBERATORSHIP then
            return
        end
        --""
        local soliderLevel = bag:getSoliderLevel(args.soliderCfgId)
        if soliderLevel <= 0 then
            self.player:say(util.i18nFormat(errors.SOLIDER_LEVEL_NOT_ENOUGH))
            return
        end
        --""
        local soliderCfg = ggclass.SoliderLevel.getSoliderCfg(args.soliderCfgId, soliderLevel)
        if not soliderCfg then
            self.player:say(util.i18nFormat(errors.CFG_NOT_EXIST))
            return
        end
        if go.soliderCfgId ~= args.soliderCfgId then
            go.soliderCfgId = args.soliderCfgId
        end
        go.soliderCount = args.soliderCount
        if go.soliderCount < 0 then
            go.soliderCount = 0
        end
        gg.client:send(self.player.linkobj,goData.update_proto,{ [goData.update_key] = go:pack() })
    end
end

function EditorBag:OPMoveBuild(args)
    if not gg.isInnerServer() then
        return
    end
    local id = args.id
    local pos = args.pos
    if not id or not pos then
        return
    end
    local buildPos = Vector3.New(math.floor(pos.x), 0, math.floor(pos.z))
    self.player.buildBag:moveBuild(id, buildPos, true)
end

function EditorBag:editedArmyFormation(args)
    if not gg.isInnerServer() then
        return
    end
    local armyId = args.armyId
    local index = args.index
    local team = args.teams[1]
    if not armyId or not index then
        return
    end
    self.player.armyBag:editedArmy(armyId,index,team)
end

function EditorBag:onSecond()
end

function EditorBag:onload()
end

function EditorBag:onlogin()
end

function EditorBag:onlogout()

end


return EditorBag