--player
local cplayer = reload_class("cplayer")

function cplayer:getPlayerResInfo()
    local data = {}
    data.mit = self.resBag:getRes(constant.RES_MIT)
    data.starCoin = self.resBag:getRes(constant.RES_STARCOIN)
    data.ice = self.resBag:getRes(constant.RES_ICE)
    data.carboxyl = self.resBag:getRes(constant.RES_CARBOXYL)
    data.titanium = self.resBag:getRes(constant.RES_TITANIUM)
    data.gas = self.resBag:getRes(constant.RES_GAS)
    return data
end

--
function cplayer:getPlayerMakeResRatio()

end

--
function cplayer:getBuildData()
    return self.buildBag:packBuildToBattle()
end

--
function cplayer:getFoundationInfo()
    return self.foundationBag:getFoundationInfo()
end

--
function cplayer:startAttacked()
    return self.foundationBag:startAttacked()
end

--
function cplayer:endAttacked()
    return self.foundationBag:endAttacked()
end

--
function cplayer:costPlayerArmyLife(costArmyInfo)
    return self.armyBag:costArmyLife(costArmyInfo)
end

--
function cplayer:addPlayerBoat(boat)
    return self.resPlanetBag:addBoat(boat)
end

--
function cplayer:addFightReport(report)
    return self.fightReportBag:addFightReport(report)
end

return cplayer