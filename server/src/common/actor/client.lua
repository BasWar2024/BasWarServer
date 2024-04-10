--- ""cclient
--@script gg.base.class
local cclient = reload_class("cclient")

function cclient:register(cmd,handler)
    self.cmd[cmd] = handler
end

function cclient:register_unauth(cmd,handler)
    self.unauth_cmd[cmd] = handler
end

function cclient:register_http(cmd,handler)
    self.http_cmd[cmd] = handler
end

function cclient:register_module(module)
    for proto,handler in pairs(module) do
        if string.sub(proto,1,4) == "C2S_" then
            self:register(proto,handler)
        end
    end
end

function cclient:register_unauth_module(module)
    for proto,handler in pairs(module) do
        if string.sub(proto,1,4) == "C2S_" then
            self:register_unauth(proto,handler)
        end
    end
end

--- ""http""
--@param[type=int] linkobj http""
--@param[type=string] uri ""uri
--@param[type=table] header ""
--@param[type=string] query ""(""urllib.parse_query""table)
--@param[type=string] body ""(""cjson.decode"")
function cclient:http_onmessage(linkobj,uri,header,query,body)
    logger.logf("debug","http","op=recv,linkid=%s,ip=%s,port=%s,method=%s,uri=%s,header=%s,query=%s,body=%s",
        linkobj.linkid,linkobj.ip,linkobj.port,linkobj.method,uri,header,query,body)

    local handler = self.http_cmd[uri]
    if handler then
        local func = handler[linkobj.method]
        if func then
            func(linkobj,header,query,body)
        else
            -- method not implemented
            httpc.send(linkobj,501)
        end
    else
        -- not found
        httpc.send(linkobj,404)
    end
    skynet.ret(nil)
end

--- ""
--@param[type=string] linktype "",""tcp/kcp/websocket
--@param[type=int] linkid ""ID
--@param[type=string] addr ""
--@param[type=string] gate_node ""
--@param[type=int] gate_address ""
function cclient:onconnect(linktype,linkid,addr,gate_node,gate_address)
    local linkobj = self:new_linkobj(linktype,linkid,addr,gate_node,gate_address)
    self:addlinkobj(linkobj)
end

--- ""
--@param[type=string] linktype "",""tcp/kcp/websocket
--@param[type=int] linkid ""ID
--@param[type=string] addr ""
--@param[type=string] result "",OK--"",FAIL--""
function cclient:onhandshake(linktype,linkid,addr,result)
    if result ~= "OK" then
        return
    end
    local linkobj = self:getlinkobj(linkid)
    if not linkobj then
        return
    end
    if self.onConnect then
        self:onConnect(linkobj)
    end
end

--- "",""
--@param[type=int] linkid ""ID
function cclient:onclose(linkid)
    local linkobj = self:getlinkobj(linkid)
    if not linkobj then
        return
    end
    if self.onClose then
        self:onClose(linkobj)
    end
    self:dellinkobj(linkid,true)
end

--- ""
--@param[type=int] linkid ""ID
--@param[type=string] cmd ""
--@param[type=table] args ""
--@param[type=bool] response true="",false=""
--@param[type=int] session ""ID
--@param[type=table] ud ""
function cclient:onmessage(linkid,cmd,args,response,session,ud)
    local linkobj = self:getlinkobj(linkid)
    if not linkobj then
        return
    end
    logger.logf("debug","client","op=recv,node=%s,address=%s,gate_node=%s,gate_address=%s,linkid=%s,linktype=%s,ip=%s,port=%s,uuid=%s,entityId=%s,pid=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s",
        self.node,skynet.address(self.address),linkobj.gate_node,skynet.address(linkobj.gate_address),linkid,linkobj.linktype,linkobj.ip,linkobj.port,linkobj.uuid,linkobj.entityId,linkobj.pid,cmd,args,response,session,ud)
    local player = linkobj
    if self.filter then
        player = self:filter(linkobj,cmd,args,response,session,ud)
    end
    if not player then
        logger.logf("warn","client","op=recv,node=%s,address=%s,gate_node=%s,gate_address=%s,linkid=%s,linktype=%s,ip=%s,port=%s,uuid=%s,entityId=%s,pid=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s,result=filter",
            self.node,skynet.address(self.address),linkobj.gate_node,skynet.address(linkobj.gate_address),linkid,linkobj.linktype,linkobj.ip,linkobj.port,linkobj.uuid,linkobj.entityId,linkobj.pid,cmd,args,response,session,ud)
        return
    end
    local lock = linkobj.lock
    if lock then
        local ret1, ret2 = lock(self._onmessage,self,player,cmd,args,response,session,ud)
        -- print(ret1, ret2)
    else
        self:_onmessage(player,cmd,args,response,session,ud)
    end
end

function cclient:_onmessage(linkobj,cmd,args,response,session,ud)
    if response then
        assert(session)
        local callback = self.sessions[session]
        if callback then
            callback(linkobj,args,session,ud)
        end
    else
        local handler = self.cmd[cmd] or self.unauth_cmd[cmd]
        if handler then

            handler(linkobj,args,session,ud)

        end
    end
end

--- "",""、""、""
function cclient:dispatch(session,source,cmd,...)
    if cmd == "onconnect" then
        self:onconnect(...)
    elseif cmd == "onhandshake" then
        self:onhandshake(...)
    elseif cmd == "onclose" then
        self:onclose(...)
    elseif cmd == "onmessage" then
        self:onmessage(...)
    elseif cmd == "http_onmessage" then
        self:http_onmessage(...)
    elseif cmd == "slaveof" then
        self:slaveof(...)
    end
end

--- ""
--@param[type=table|int] linkobj ""
--@param[type=string] cmd ""
--@param[type=table] args ""
--@param[type=function,opt] callback ""
function cclient:send(linkobj,cmd,args,callback)
    if not linkobj then
        return
    end
    local response,session,ud = self:_send(linkobj,cmd,args,callback)
    logger.logf("debug","client","op=send,node=%s,address=%s,gate_node=%s,gate_address=%s,linkid=%s,linktype=%s,ip=%s,port=%s,uuid=%s,entityId=%s,pid=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s",
        self.node,skynet.address(self.address),linkobj.gate_node,skynet.address(linkobj.gate_address),linkobj.linkid,linkobj.linktype,linkobj.ip,linkobj.port,linkobj.uuid,linkobj.entityId,linkobj.pid,cmd,args,response,session,ud)
end

cclient.send_request = cclient.send

--- ""“""”""
--@param[type=table|int] linkobj ""
--@param[type=string] cmd ""
--@param[type=table] args ""
--@param[type=int] session ""ID(""ID)
function cclient:send_response(linkobj,cmd,args,session)
    if not linkobj then
        return
    end
    local response,session,ud = self:_send(linkobj,cmd,args,session)
    logger.logf("debug","client","op=send,node=%s,address=%s,gate_node=%s,gate_address=%s,linkid=%s,linktype=%s,ip=%s,port=%s,uuid=%s,entityId=%s,pid=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s",
        self.node,skynet.address(self.address),linkobj.gate_node,skynet.address(linkobj.gate_address),linkobj.linkid,linkobj.linktype,linkobj.ip,linkobj.port,linkobj.uuid,linkobj.entityId,linkobj.pid,cmd,args,response,session,ud)
end

return cclient