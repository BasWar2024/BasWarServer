---""
--@script app.game.player.playermgr.admin
--@author sundream
--@release 2019/8/15 10:00:00
--@usage
--"":
--""R1""GS1"",""GS2,""LS
--""DB"":
--1. C->GS1:    ""GS1""
--2. GS1->GS2:  ""R1""GS2,""GS2"",""R1
--3. GS2->LS:   "",""R2
--4. GS2:       ""R1"",""
--5. GS2->GS1:  GS2""GS1"","",""<R1,R2>
--6. GS1:       ""
--7. GS1->LS:   ""R1""
--8. GS1->C:    ""
--""DB"":
--""2~7"": GS1->LS: ""
local cplayermgr = reload_class("cplayermgr")


---""
--@param[type=int] roleid ""ID
--@param[type=string] new_serverid ""ID
--@return[type=bool] ""
--@return[type=string] "",""
function cplayermgr:rebindserver(roleid,new_serverid)
    return self:loadplayer_callback(roleid,function (player)
        local new_roleid
        local account = player.account
        local db_is_cluster = skynet.getenv("db_is_cluster")
        if not db_is_cluster then
            local role_data = player:serialize()
            local ok
            ok,new_roleid = gg.cluster:call(new_serverid,".game","exec","gg.playermgr:clone",role_data,account)
            if not ok then
                local err = new_roleid
                return false,err
            end
            self:delrole(roleid,true)
        else
            new_roleid = roleid
            local status,response = gg.loginserver:rebindserver(account,new_serverid,roleid,new_roleid)
            if status ~= 200 then
                return false,"error status: " .. tostring(status)
            end
            if response.code ~= httpc.answer.code.OK then
                return false,response.message
            end
        end
        -- ""
        if player.linkobj then
            player.pid = new_roleid
            self:go_server(player,new_serverid)
        end
        if self.on_rebindserver then
            self:on_rebindserver(new_serverid,roleid,new_roleid)
        end
        return true,new_roleid
    end)
end

---""
--@param[type=int] roleid ""ID
--@param[type=string] new_account ""
--@return[type=bool] ""
--@return[type=string] "",""
function cplayermgr:rebindaccount(roleid,new_account)
    return self:loadplayer_callback(roleid,function (player)
        local call_ok,ok,err = pcall(function ()
            local status,response = gg.loginserver:rebindaccount(roleid,new_account)
            if status ~= 200 then
                return false,"error status: " .. tostring(status)
            end
            if response.code ~= httpc.answer.code.OK then
                return false,response.message
            end
            return true
        end)
        if not call_ok then
            err = ok
            ok = call_ok
        end
        if ok then
            player.account = new_account
        end
        return ok,err
    end)
end

---""
--@param[type=int] roleid ""ID
--@param[type=bool,opt] forever ""
--@return[type=bool] ""
--@return[type=string] "",""
function cplayermgr:delrole(roleid,forever)
    local status,response = gg.loginserver:delrole(roleid,forever)
    if status ~= 200 then
        return false,"error status: " .. tostring(status)
    end
    if response.code ~= httpc.answer.code.OK then
        return false,response.message
    end
    if self.on_delrole then
        self:on_delrole(roleid)
    end
    if forever then
        ggclass.cplayer.delete_from_db(roleid)
    end
    return true
end

---""
--@param[type=int] roleid ""ID
--@return[type=bool] ""
--@return[type=string] "",""
function cplayermgr:recover_role(roleid)
    local status,response = gg.loginserver:recover_role(roleid)
    if status ~= 200 then
        return false,"error status: " .. tostring(status)
    end
    if response.code ~= httpc.answer.code.OK then
        return false,response.message
    end
    return true
end

---""
--@param[type=int] roleid ""ID
--@return[type=bool] ""
--@return[type=string] "",""
function cplayermgr:clone(role_data,account)
    role_data = gg.deepcopy(role_data)
    local serverid = skynet.config.id
    local appid = skynet.config.appid
    local attr = role_data.attr
    local name = attr.name
    local heroId = attr.heroId
    local role = {
        account = account,
        name = name,
        heroId = heroId,
    }
    local status,response = gg.loginserver:addrole(account,serverid,role,nil,appid,1000000,1000000000)
    if status ~= 200 then
        return false,"error status: " .. tostring(status)
    end
    if response.code ~= httpc.answer.code.OK then
        return false,response.message
    end
    local r = response.data.role
    role.roleid = r.roleid
    role.createTime = r.createTime or os.time()
    local player = self:createplayer(role.roleid,role)
    player:deserialize(role_data)
    player:save_to_db()
    return true,role.roleid
end

return cplayermgr

