local cgm = reload_class("cgm")

---"": ""
---@usage
---"": rebindserver ""ID ""ID
function cgm:rebindserver(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int","string")
    if not isok then
        return self:say(""": rebindserver ""ID ""ID")
    end
    local roleid = args[1]
    local new_serverid = args[2]
    local ok,err = gg.playermgr:rebindserver(roleid,new_serverid)
    local msg
    if ok then
        local new_roleid = err
        msg = self:say(string.format(""": ""ID=%s,""ID=%s,""ID=%s",new_serverid,roleid,new_roleid))
    else
        msg = self:say(string.format(""": %s",err))
    end
    return msg
end

---"": ""
---@usage
---"": rebindaccount ""ID ""
function cgm:rebindaccount(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int","string")
    if not isok then
        return self:say(""": rebindaccount ""ID """)
    end
    local roleid = args[1]
    local new_account = args[2]
    local ok,err = gg.playermgr:rebindaccount(roleid,new_account)
    local msg
    if ok then
        msg = self:say(string.format(""": ""ID=%s,""=%s",roleid,new_account))
    else
        msg = self:say(string.format(""": %s",err))
    end
    return msg
end

---"": ""
---@usage
---"": delrole ""ID [""]
function cgm:delrole(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int","*")
    if not isok then
        return self:say(""": delrole ""ID [""]")
    end
    local roleid = args[1]
    local forever = gg.istrue(args[2])
    local ok,err = gg.playermgr:delrole(roleid,forever)
    local msg
    if ok then
        msg = self:say(string.format(""": ""ID=%s",roleid))
    else
        msg = self:say(string.format(""": %s",err))
    end
    return msg
end

---"": ""
---@usage
---"": recover_role ""ID
function cgm:recover_role(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int")
    if not isok then
        return self:say(""": recover_role ""ID")
    end
    local roleid = args[1]
    local ok,err = gg.playermgr:recover_role(roleid)
    local msg
    if ok then
        msg = self:say(string.format(""": ""ID=%s",roleid))
    else
        msg = self:say(string.format(""": %s",err))
    end
    return msg
end

---"": ""
---@usage
---"": clone ""ID [""]
function cgm:clone(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int","*")
    if not isok then
        return self:say(""": clone ""ID [""]")
    end
    local roleid = args[1]
    local account
    if not self.master and not args[2] then
        return self:say(""": clone ""ID [""]")
    else
        account = args[2] or self.master.account
    end
    return gg.playermgr:loadplayer_callback(roleid,function (player)
        local role_data = gg.deepcopy(player:serialize())
        local ok,new_roleid = gg.playermgr:clone(role_data,account)
        if ok then
            return self:say(string.format(""": ""ID=%s,""=%s",new_roleid,account))
        else
            local err = new_roleid
            return self:say(string.format(""": %s",err))
        end
    end)
end

---"": ""/tmp/""ID.json
---@usage
---"": serialize ""ID
function cgm:serialize(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"int")
    if not isok then
        return self:say(""": serialize ""ID")
    end
    local roleid = args[1]
    return gg.playermgr:loadplayer_callback(roleid,function (player)
        local role_data = player:serialize()
        role_data = cjson.encode(role_data)
        local filename = string.format("/tmp/%s.json",roleid)
        local fd = io.open(filename,"wb")
        fd:write(role_data)
        fd:close()
        return filename
    end)
end

---"": ""
---@usage
---"": deserialize "" [""]
function cgm:deserialize(args)
    if self.master and not self.master:isSuperGm() then
        return self:say("""")
    end
    local isok,args = gg.checkargs(args,"string","*")
    if not isok then
        return self:say(""": deserialize "" [""]")
    end
    local filename = args[1]
    local account
    if not self.master and not args[2] then
        return self:say(""": deserialize "" [""]")
    else
        account = args[2] or self.master.account
    end
    local fd = io.open(filename,"rb")
    local role_data = fd:read("*a")
    fd:close()
    role_data = cjson.decode(role_data)
    local ok,new_roleid = gg.playermgr:clone(role_data,account)
    local msg
    if ok then
        msg = self:say(string.format(""": ""ID=%s,""=%s",new_roleid,account))
    else
        local err = new_roleid
        msg = self:say(string.format(""": %s",err))
    end
    return msg
end

---"": ""/""
---"": openserver ""id 1|0
---@usage
---openserver game1 1        <=> game1""
---openserver game1 0        <=> game1""
function cgm:openserver(args)
    local ok,args = gg.checkargs(args,"string","int")
    if not ok then
        return self:say(""": openserver ""id 1|0")
    end
    local serverid = args[1]
    local is_open = args[2]
    local status,response = gg.loginserver:openserver(serverid,is_open)
    if status ~= 200 then
        return self:say(string.format(""","":%s",status))
    end
    if response.code ~= httpc.answer.code.OK then
        return self:say(string.format(""","":%s(%s)",response.code,response.message))
    end
end

function cgm:register_admin()
    self:register("rebindserver",self.rebindserver,self.TAG_NORMAL,"rebind server")
    self:register("rebindaccount",self.rebindaccount,self.TAG_NORMAL,"rebind account")
    self:register("delrole",self.delrole,self.TAG_NORMAL,"del role")
    self:register("recover_role",self.recover_role,self.TAG_NORMAL,"recover role")
    self:register("clone",self.clone,self.TAG_NORMAL,"copy a role")
    self:register("serialize",self.serialize,self.TAG_NORMAL,"serialize role")
    self:register("deserialize",self.deserialize,self.TAG_NORMAL,"deserialize role")
    self:register("openserver",self.openserver,self.TAG_NORMAL,"open/not open server")
end

function __hotfix(module)
    gg.gm:hotfix_gm()
end

return cgm
