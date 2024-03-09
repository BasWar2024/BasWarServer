local ArmyBag = class("ArmyBag")

function ArmyBag:ctor(param)
    self.player = param.player
end

--
function ArmyBag:getFightArmy()
    local armyInfo = {}
    local warShip = self:getFightWarShip()
    if not warShip then
        return armyInfo
    end
    armyInfo.warShip = warShip
    local soldiers = self:getFightSoldiers()
    if not soldiers or not next(soldiers) then
        return armyInfo
    end
    armyInfo.soldiers = soldiers
    local hero = self:getFightHero()
    local armyInfo = {
        warShip = warShip,
        hero = hero,
        soldiers = soldiers,
    }
    return armyInfo
end

--
function ArmyBag:getFightSoldiers()
    local soldiers = {}
    local builds = self.player.buildBag:getBuildsByCfgId(constant.BUILD_LIBERATORSHIP)
    table.sort(builds, function (a,b)
        if a.z > b.z then
            return true
        elseif a.z < b.z then
            return false
        else
            if a.x < b.x then
                return true
            end
        end
        return false
    end)
    if builds and next(builds) then
        for _, v in pairs(builds) do
            if v.soliderCfgId > 0 and v.soliderCount > 0 then
                local level = self.player.buildBag:getSoliderLevel(v.soliderCfgId)
                table.insert(soldiers, {id = v.id, cfgId=v.soliderCfgId, count=v.soliderCount, level = level})
            end
        end
    end
    return soldiers
end

--
function ArmyBag:getFightHero()
    local hero = self.player.heroBag:getCurrentHero()
    if not hero then
        return nil
    end
    return hero:pack()
end

--
function ArmyBag:getFightWarShip()
    local warShip = self.player.warShipBag:getCurrentWarShip()
    if not warShip then
        return nil
    end
    return warShip:pack()
end

function ArmyBag:setFightTick(tick)
    local hero = self:getFightHero()
    if hero then
        hero:setFightTick(tick)
    end
    local warShip = self:getFightWarShip()
    if warShip then
        warShip:setFightTick(tick)
    end
    local builds = self.player.buildBag:getBuildsByCfgId(constant.BUILD_LIBERATORSHIP)
    if builds and next(builds) then
        for _, build in pairs(builds) do
            build:setFightTick(tick)
        end
    end
end

function ArmyBag:costArmyLife(costArmyInfo)
    if costArmyInfo.heros and next(costArmyInfo.heros) then
        for k, v in pairs(costArmyInfo.heros) do
            local hero = self.player.heroBag:getHero(v.id)
            if hero then
                if hero.curLife - v.life > 0 then
                    hero.curLife = hero.curLife - v.life
                    if self.player:isonline() then
                        gg.client:send(self.player.linkobj,"S2C_Player_HeroUpdate",{ hero = hero:pack() })
                    end
                else
                    self.player.heroBag:delHero(v.id, "fight failed, cost life")
                end
            end
        end
    end

    if costArmyInfo.warShips and next(costArmyInfo.warShips) then
        for index, v in pairs(costArmyInfo.warShips) do
            local warShip = self.player.warShipBag:getWarShip(v.id)
            if warShip then
                if warShip.curLife - v.life > 0 then
                    warShip.curLife = warShip.curLife - v.life
                    if self.player:isonline() then
                        gg.client:send(self.player.linkobj,"S2C_Player_WarShipUpdate",{ warShip = warShip:pack() })
                    end
                else
                    self.player.warShipBag:delWarShip(v.id, "fight failed, cost life")
                end
            end
        end
    end

    if costArmyInfo.soldiers and next(costArmyInfo.soldiers) then
        for k, v in pairs(costArmyInfo.soldiers) do
            local build = self.player.buildBag:getBuild(v.id)
            if build and build.soliderCfgId == v.cfgId then
                build.soliderCount = (build.soliderCount - v.life > 0) and (build.soliderCount - v.life) or 0
                if build.soliderCount > 0 then
                    if self.player:isonline() then
                        gg.client:send(self.player.linkobj,"S2C_Player_BuildUpdate",{ build = build:pack() })
                    end
                else
                    self.player.buildBag:delBuild(build.id, {reason="cost army life for battle"})
                end

            end
        end
    end
end

return ArmyBag