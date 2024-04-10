local cgm = reload_class("cgm")

cgm.TAG_NORMAL = 0                   -- ""
cgm.TAG_FREQUENTLY_USED = 1          -- ""

cgm.TAG_NOT_PLAYER_METHOD = 0x0100   -- ""

function cgm:open()
    -- helper
    self:register("buildgmdoc",self.buildgmdoc,self.TAG_FREQUENTLY_USED,"""GM""")
    self:register("help",self.help,self.TAG_FREQUENTLY_USED,"""")

    -- sys
    self:register("stop",self.stop,self.TAG_NORMAL,"""")
    self:register("restart",self.restart,self.TAG_NORMAL,"""")
    self:register("saveall",self.saveall,self.TAG_NORMAL,"""")
    self:register("disconnect",self.disconnect,self.TAG_FREQUENTLY_USED,"""")
    self:register("kick",self.kick,self.TAG_FREQUENTLY_USED,"""")
    self:register("kickall",self.kickall,self.TAG_NORMAL,"""")

    self:register("exec",self.exec,self.TAG_NORMAL,"""lua""")
    self:register("dofile",self.dofile,self.TAG_NORMAL,"""lua""")
    self:register("hotfix",self.hotfix,self.TAG_NORMAL,"""")
    self:register("reload",self.reload,self.TAG_NORMAL,"""(hotfix"")")
    self:register("hotfixAll",self.hotfixAll,self.TAG_NORMAL,"""")
    self:register("loglevel",self.loglevel,self.TAG_NORMAL,"""/""")
    self:register("date",self.date,self.TAG_NORMAL,"""/""")
    self:register("ntpdate",self.ntpdate,self.TAG_NORMAL,"""")
    self:register("hotfix_diff",self.hotfix_diff,self.TAG_FREQUENTLY_USED,"""svn""")
    self:register("update_restart",self.update_restart,self.TAG_FREQUENTLY_USED,"""")
    self:register("info",self.info,self.TAG_NORMAL,"""")
    self:register("bugreport",self.bugreport,self.TAG_NORMAL,"""")
    self:register("check_cluster",self.check_cluster,self.TAG_NORMAL,"""")
    self:register("close_link",self.close_link,self.TAG_NORMAL,"""id""")
    self:register("unlock",self.unlock,self.TAG_NORMAL,"gm""")
    self:register("close_login",self.close_login,self.TAG_NORMAL,"""|""+""")
    self:register("recvclient",self.recvclient,self.TAG_NORMAL,"""")
    self:register("sendclient",self.sendclient,self.TAG_NORMAL,"""")
    self:register("startProfile",self.startProfile,self.TAG_NORMAL,"""profile")
    self:register("stopProfile",self.stopProfile,self.TAG_NORMAL,"""profile")
    self:register("snapshot",self.snapshot,self.TAG_NORMAL,"""")
    self:register_np("call",self.call,self.TAG_NORMAL,"rpc#call")
    self:register_np("send",self.send,self.TAG_NORMAL,"rpc#send")
    self:register_np("proxy",self.proxy,self.TAG_NORMAL,"proxy.call/send")
    self:register("ldoc",self.ldoc,self.TAG_NORMAL,"""ldoc""")
    self:register("set_net_delay",self.set_net_delay,self.TAG_NORMAL,"""ip""")
    self:register("show_net_delay",self.show_net_delay,self.TAG_NORMAL,"""")
    self:register("ping",self.ping,self.TAG_NORMAL,"ping")

    if self._open then
        self:_open()
    end
end

return cgm
