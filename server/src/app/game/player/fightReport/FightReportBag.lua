local FightReportBag = class("FightReportBag")

function FightReportBag:ctor(param)
    self.player = param.player
    self.fightReports = {}
end

function FightReportBag:serialize()
    local data = {fightReports = {}}
    for k, v in pairs(self.fightReports) do
        table.insert(data.fightReports, v)
    end
    return data
end

function FightReportBag:deserialize(data)
    self.fightReports = {}
    for k, v in pairs(data.fightReports) do
        self.fightReports[v.fightId] = v
    end
end

function FightReportBag:pack()
    local fightReports = {}
    for k, v in pairs(self.fightReports) do
        table.insert(fightReports, v)
    end
    return fightReports
end

function FightReportBag:addFightReport(report)
    if not report then
        return
    end
    self.fightReports[v.fightId] = report
end

--
function FightReportBag:queryFightReports()
    gg.client:send(self.player.linkobj,"S2C_Player_FightReports",{ fightReports = self:pack() })
end

function FightReportBag:onlogin()

end

function FightReportBag:onlogout()

end

return FightReportBag