local cplayer = class("cplayer")
cplayer.LOGOUT_TYPE_NORMAL = 1  -- ""
cplayer.LOGOUT_TYPE_REPLACE = 2 -- ""
cplayer.LOGOUT_TYPE_DELAY = 3   -- ""
cplayer.LOGOUT_TYPE_KICK = 4    -- ""(""gm"")

cplayer.ONLINE_STATE_OFFLINE = 0  -- ""
cplayer.ONLINE_STATE_ONLINE = 1   -- ""
cplayer.ONLINE_STATE_DISCONNECT = 2 -- ""(""AI"")


function cplayer:ctor(pid)
    self.pid = assert(pid)
    self.id = snowflake.uuid()           -- ""id("")
    self._id = tostring(self.id)
    self.data = ggclass.cdatabaseable.new()
    self.today = ggclass.ctoday.new()
    self.thistemp = ggclass.cthistemp.new()
    self.thisweek = ggclass.cthisweek.new()
    self.thisweek2 = ggclass.cthisweek2.new()
    self.thismonth = ggclass.cthismonth.new()
    self.time = ggclass.CompositeComponent.new({
        today = self.today,
        thistemp = self.thistemp,
        thisweek = self.thisweek,
        thisweek2 = self.thisweek2,
        thismonth = self.thismonth,
    })
    self.vipBag = ggclass.VipBag.new({player=self})
    self.resBag = ggclass.ResBag.new({player = self})
    self.buildBag = ggclass.BuildBag.new({player = self})
    self.itemBag = ggclass.ItemBag.new({player = self})
    self.heroBag = ggclass.HeroBag.new({player = self})
    self.warShipBag = ggclass.WarShipBag.new({player = self})
    self.armyBag = ggclass.ArmyBag.new({player = self})
    self.fightReportBag = ggclass.FightReportBag.new({player=self})
    self.foundationBag = ggclass.FoundationBag.new({player=self})
    self.pvpBag = ggclass.PvpBag.new({player=self})
    self.pveBag = ggclass.PveBag.new({player=self})
    self.noticeBag = ggclass.NoticeBag.new({player=self})
    self.achievementBag = ggclass.AchievementBag.new({player=self})
    self.unionBag = ggclass.UnionBag.new({player=self})
    self.chatBag = ggclass.ChatBag.new({player=self})
    self.taskBag = ggclass.TaskBag.new({player=self})
    self.playerInfoBag = ggclass.PlayerInfoBag.new({player=self})
    self.mailBag = ggclass.MailBag.new({player = self})
    self.guideBag = ggclass.GuideBag.new({player = self})
    self.starmapBag = ggclass.StarmapBag.new({player = self})
    self.chainBridgeBag = ggclass.ChainBridgeBag.new({player = self})
    self.editorBag = ggclass.EditorBag.new({player=self})
    self.autoPushBag = ggclass.AutoPushBag.new({player=self})
    self.drawCardBag = ggclass.DrawCardBag.new({player=self})
    self.rechargeActivityBag = ggclass.RechargeActivityBag.new({player=self})
    self.giftBag = ggclass.GiftBag.new({player=self})
    self.component = {}
    self.ordered_component = {}
    self:add_component("property",{
        serialize = function (obj) return self:serializeProperty() end,
        deserialize = function (obj,data) self:deserializeProperty(data) end,
    })
    self:add_component("data",self.data)
    self:add_component("time",self.time)
    self:add_component("resBag",self.resBag)
    self:add_component("buildBag",self.buildBag)
    self:add_component("itemBag", self.itemBag)
    self:add_component("heroBag",self.heroBag)
    self:add_component("warShipBag",self.warShipBag)
    self:add_component("armyBag",self.armyBag)
    self:add_component("fightReportBag",self.fightReportBag)
    self:add_component("playerInfoBag",self.playerInfoBag)
    self:add_component("vipBag",self.vipBag)
    self:add_component("foundationBag",self.foundationBag)
    self:add_component("pvpBag",self.pvpBag)
    self:add_component("pveBag",self.pveBag)
    self:add_component("noticeBag",self.noticeBag)
    self:add_component("achievementBag",self.achievementBag)
    self:add_component("unionBag",self.unionBag)
    self:add_component("chatBag",self.chatBag)
    self:add_component("taskBag",self.taskBag)
    self:add_component("mailBag",self.mailBag)
    self:add_component("guideBag",self.guideBag)
    self:add_component("starmapBag",self.starmapBag)
    self:add_component("chainBridgeBag",self.chainBridgeBag)
    self:add_component("autoPushBag",self.autoPushBag)
    self:add_component("drawCardBag",self.drawCardBag)
    self:add_component("rechargeActivityBag",self.rechargeActivityBag)
    self:add_component("giftBag",self.giftBag)
    self.loadstate = "unload"

    self:_ctor(pid)
end

function cplayer:deserialize(toload)
    if table.isempty(toload) then
        return
    end
    for name,data in pairs(toload) do
        local obj = self.component[name]
        if obj then
            obj:deserialize(data)
        end
    end
    self.loadstate = "loaded"
    self:onload()
end

function cplayer:serialize()
    local data = {}
    for name,obj in pairs(self.component) do
        if obj.serialize then
            data[name] = obj:serialize()
        end
    end
    return data
end

function cplayer:isloaded()
    return self.loadstate == "loaded"
end

function cplayer.delete_from_db(pid)
    gg.mongoProxy.player:delete({pid=pid})
end

function cplayer:save_to_db()
    self:beforeSaveToDb()
    if self.no_save_to_db then
        return
    end
    local data = self:serialize()
    if constant.SAVE_DATA_CHECK then
        local result = self:checkSaveData(data)
        if not result then
            logger.logf("error", "SavePlayerData", " pid=%s, data=%s,", tostring(self.pid), table.dump(data))
            return
        end
    end
    data.pid = self.pid
    gg.mongoProxy.player:update({pid=self.pid},data,true,false)
end

function cplayer:load_from_db()
    local data = gg.mongoProxy.player:findOne({pid = self.pid})
    self:deserialize(data)
end

function cplayer:add_component(name,component)
    assert(self.component[name] == nil)
    self.component[name] = component
    table.insert(self.ordered_component,component)
end

function cplayer:create(conf)
    self.name = assert(conf.name)
    self.headIcon = assert(conf.headIcon)
    self.account = assert(conf.account)
    self.openId = self:getOpenId()
    self.race = assert(conf.race)
    self.createTime = conf.createTime or os.time()
    self.createServerId = skynet.config.id
    self.platform = conf.platform
    self.sdk = conf.sdk
    self.data:set("isNew",1)
    self:oncreate()
end

function cplayer:entergame(replace)
    self:del_delay_exitgame()
    return self:onlogin(replace)
end

--- ""("")
--@param[type=int] logoutType "": 1="",2="",3="",4=""
function cplayer:disconnect(logoutType)
    if self:isdisconnect() then
        return
    end
    self.linkobj.disconnecting = true
    self:ondisconnect(logoutType)
    local linkobj = self.linkobj
    gg.playermgr:unbind_linkobj(self)
    gg.client:dellinkobj(linkobj.linkid,true)
    -- ""
    if logoutType ~= ggclass.cplayer.LOGOUT_TYPE_REPLACE  then
        self:exitgame(logoutType)
    end
end

function cplayer:exitgame(logoutType)
    --[[
    if not self.force_exitgame then
        self:try_set_exitgame_time()
        local ok,delay_time = self:need_delay_exitgame()
        if ok then
            self:delay_exitgame(delay_time)
            return
        end
    end
    ]]
    -- keep before onlogout!
    self:del_delay_exitgame()
    --self.force_exitgame = nil
    xpcall(self.onlogout,gg.onerror,self,logoutType)
    -- will call save_to_db
    if self.force_exitgame then
        gg.playermgr:delplayer(self.pid)
    else
        gg.playermgr:setplayerlasttick(self.pid)
    end
    self.force_exitgame = nil
end

function cplayer:isdisconnect()
    if not self.linkobj or self.linkobj.disconnecting then
        return true
    end
    return false
end

function cplayer:isonline()
    if self:isdisconnect() then
        return false
    end
    return self.onlineState == ggclass.cplayer.ONLINE_STATE_ONLINE
end

function cplayer:syncToLoginServer(onlineState)
    skynet.fork(self._syncToLoginServer,self,onlineState)
end

function cplayer:_syncToLoginServer(onlineState)
    local role = {
        roleid = self.pid,
        name = self.name,
        level = self.level,
        vip = self.vip,
        currentServerId = skynet.config.id,
        onlineState = onlineState,
    }
    gg.loginserver:updaterole(self.pid,role)
end

function cplayer:checkTime()
    -- ""
    self.today:checkvalid()
    self.thisweek:checkvalid()  -- monday
    self.thisweek2:checkvalid() -- sunday
    self.thismonth:checkvalid()

    self:onMinuteUpdate()
    self:onFiveMinuteUpdate()
    self:onHalfHourUpdate()
    self:onHourUpdate()
    self:onDayUpdate()
    self:onMondayUpdate()
    self:onSundayUpdate()
    self:onMonthUpdate()
end

function cplayer:get(key,default)
    return self.data:get(key,default)
end

function cplayer:set(key,val)
    return self.data:set(key,val)
end

function cplayer:add(key,val)
    return self.data:add(key,val)
end

function cplayer:del(key)
    return self.data:del(key)
end

function cplayer:getOpenId()
    if not self.openId then
        local pos = string.find(self.account,"@")
        if pos then
            self.openId = string.sub(self.account,1,pos-1)
        else
            self.openId = self.account
        end
    end
    return self.openId
end

function cplayer:isGm()
    if gg.isInnerServer() then
        return true
    end
    return self.gm >= 1
end

function cplayer:isSuperGm()
    return self.gm >= 99
end

return cplayer
