local Rank = class("Rank")

--game,,redis
function Rank:ctor()

end

function Rank:syncBadgeInfo(pid, badge)
    gg.redismgr:getdb():zadd(constant.REDIS_RANK_BADGE, badge, pid)
end

function Rank:getBadgeRank()
    
end

function Rank:syncCostMitInfo(pid, costMit)
    gg.redismgr:getdb():zadd(constant.REDIS_RANK_COST_MIT, costMit, pid)
end

function Rank:getCostMitRank()
    
end

function Rank:syncPlanetInfo(pid, count)
    gg.redismgr:getdb():zadd(constant.REDIS_RANK_PLANET, count, pid)
end

function Rank:getPlanetRank()
    
end

return Rank