local PlayerFightReport = class("PlayerFightReport")

function PlayerFightReport:ctor(param)
    self.dirty = false
    self.savetick = 300
    self.savename = "player_fight_report"
    self.playerId = param.playerId
    self.fightReports = {}
end

function PlayerFightReport:serialize()
    local data = {}
    data.playerId = self.playerId
    data.fightReports = {}
    for k, v in pairs(self.fightReports) do
        table.insert(data.fightReports, v:serialize())
    end
    return data
end

function PlayerFightReport:deserialize(data)
    self.playerId = data.playerId
    self.fightReports = {}
    for k, v in pairs(data.fightReports) do
        local report = ggclass.FightReport.new(v)
        report:deserialize(v)
        self.fightReports[v.fightId] = report
    end
end

function PlayerFightReport:pack()
    local fightReports = {}
    for k, v in pairs(self.fightReports) do
        table.insert(fightReports, v:pack())
    end
    return fightReports
end

function PlayerFightReport:save_to_db()
    -- if not self.dirty then
    --     return
    -- end
    -- local data = self:serialize()
    -- gg.redismgr:getdb():set(constant.REDIS_FIGHT_REPORT..self.playerId, cjson.encode(data))
    -- self.dirty = false
end

function PlayerFightReport:addReport(report)
   self.fightReports[report.fightId] = report
   self.dirty = true
   return self:pack()
end

function PlayerFightReport:clearReports()
    self.fightReports = {}
    self.dirty = true
end

return PlayerFightReport