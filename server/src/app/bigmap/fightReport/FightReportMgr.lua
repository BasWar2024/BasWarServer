local FightReportMgr = class("FightReportMgr")

function FightReportMgr:ctor()
    self._playerFightReports = {}
end

function FightReportMgr:sendPlayer(cmd, pid, data, ...)
    if pid <= 0 then
        return
    end
    local brief = gg.centerProxy:call("api","getBrief",pid)
    if brief then
        gg.cluster:send(brief.node, ".main", "playerexec", pid, cmd, data, ...)
    end
end


function FightReportMgr:callPlayer(cmd, pid, data, ...)
    if pid <= 0 then
        return
    end
    local brief = gg.centerProxy:call("api","getBrief",pid)
    if brief then
        return gg.cluster:call(brief.node, ".main", "playerexec", pid, cmd, data, ...)
    end
end

function FightReportMgr:getPlayerFightReport(pid)
    local playerReport = self._playerFightReports[pid]
    if not playerReport then
        local reportStr = gg.redismgr:getdb():get(constant.REDIS_FIGHT_REPORT..pid)
        if reportStr and #reportStr > 0 then
            local reportData = cjson.decode(reportStr)
            playerReport = ggclass.PlayerFightReport.new(reportData)
            playerReport:deserialize(reportData)
        else
            playerReport = ggclass.PlayerFightReport.new({playerId=pid})
        end
        self._playerFightReports[pid] = playerReport
        gg.savemgr:autosave(playerReport)
    end
    return playerReport
end

function FightReportMgr:addFightReport(pid, report)
    -- if pid <= 0 then
    --     return
    -- end
    -- local playerReport = self:getPlayerFightReport(pid)
    -- if not playerReport then
    --     return
    -- end
    -- local fightReports = playerReport:addReport(report)
    -- local ok = self:callPlayer("fightReportBag:onFightReportAdd", pid, fightReports)
    -- if ok == true then
    --     playerReport:clearReports()
    -- end
end

function FightReportMgr:queryFightReports(pid)
    -- if pid <= 0 then
    --     return
    -- end
    -- local playerReport = self:getPlayerFightReport(pid)
    -- local fightReports = playerReport:pack()
    -- local ok = self:callPlayer("fightReportBag:onFightReportAdd", pid, fightReports)
    -- if ok == true then
    --     playerReport:clearReports()
    -- end
end

function FightReportMgr:playerLogin(pid)
    self:queryFightReports(pid)
end

function FightReportMgr:playerLogout(pid)
    local playerReport = self:getPlayerFightReport(pid)
    playerReport:save_to_db()
    self._playerFightReports[pid] = nil
end


return FightReportMgr