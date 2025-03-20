local skynet = require "skynet"
local cluster = require "skynet.cluster"
local queue = require "skynet.queue"

local cclient = class("cclient")

--- cclient.new""
--@param[type=table] conf
--@return a cclient's instance
--@usage
--local gg.client = ggclass.cclient.new()
function cclient:ctor()
    self.node = skynet.getenv("id")
    self.address = skynet.self()
    self.session = 0
    self.sessions = {}
    -- ""
    self.linkobjs = ggclass.ccontainer.new()
    self.cmd = {}
    self.unauth_cmd = {}
    self.http_cmd = {}
end

function cclient:gen_session()
    -- TODO: ""64""ID?
    repeat
        self.session = self.session + 1
    until not self.sessions[self.session]
    return self.session
end

function cclient:msend(linkobjs,cmd,args)
    local gates = {}
    for i,linkobj in ipairs(linkobjs) do
        local linkid,gate_node,gate_address = linkobj.linkid,linkobj.gate_node,linkobj.gate_address
        if not gates[gate_node] then
            gates[gate_node] = {}
        end
        if not gates[gate_node][gate_address] then
            gates[gate_node][gate_address] = {}
        end
        table.insert(gates[gate_node][gate_address],linkid)
        if gg.profile.open then
            -- ""
            gg.profile:incr("client_send",cmd)
        end
    end
    local response = false
    local session = 0
    local ud = self.pack_ud and self:pack_ud()
    for gate_node,tbl in pairs(gates) do
        if gate_node ~= self.node then
            for gate_address,linkids in pairs(tbl) do
                logger.logf("debug","client","op=msend,node=%s,address=%s,gate_node=%s,gate_address=%s,linkids=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s",
                    self.node,skynet.address(self.address),gate_node,skynet.address(gate_address),linkids,cmd,args,response,session,ud)
                cluster.send(gate_node,gate_address,"mwrite",linkids,cmd,args,response,session,ud)
            end
        else
            for gate_address,linkids in pairs(tbl) do
                logger.logf("debug","client","op=msend,node=%s,address=%s,gate_node=%s,gate_address=%s,linkids=%s,cmd=%s,args=%s,response=%s,session=%s,ud=%s",
                    self.node,skynet.address(self.address),gate_node,skynet.address(gate_address),linkids,cmd,args,response,session,ud)
                skynet.send(gate_address,"lua","mwrite",linkids,cmd,args,response,session,ud)
            end
        end
    end
end

function cclient:_send(linkobj,cmd,args,callback)
    local linkid = linkobj.linkid
    local gate_node = linkobj.gate_node
    local gate_address = linkobj.gate_address
    assert(gate_node ~= nil,linkid)
    local is_response = type(callback) == "number"
    local session,ud
    if not is_response then
        if callback then
            session = self:gen_session()
            self.sessions[session] = callback
        end
        ud = self.pack_ud and self:pack_ud()
    else
        session = callback
        ud = self.pack_ud and self:pack_ud()
    end
    if gate_node ~= self.node then
        cluster.send(gate_node,gate_address,"write",linkid,cmd,args,is_response,session,ud)
    else
        skynet.send(gate_address,"lua","write",linkid,cmd,args,is_response,session,ud)
    end
    if gg.profile.open then
        -- ""
        gg.profile:incr("client_send",cmd)
    end
    return is_response,session,ud
end

function cclient:new_linkobj(linktype,linkid,addr,gate_node,gate_address)
    local linkobj = {}
    linkobj.linktype = assert(linktype)
    linkobj.linkid = assert(linkid)
    linkobj.addr = assert(addr)
    linkobj.gate_node = assert(gate_node)
    linkobj.gate_address = assert(gate_address)
    local ip,port
    if linktype == "kcp" then
        ip,port = socket.udp_address(addr)
    else
        ip,port = table.unpack(string.split(addr,":"))
    end
    linkobj.ip = assert(ip)
    linkobj.port = assert(port)
    linkobj.createTime = os.time()
    return linkobj
end

--- ""
--@param[type=int] linkid ""ID
function cclient:getlinkobj(linkid)
    return self.linkobjs:get(linkid)
end

--- ""
--@param[type=table] linkobj ""
function cclient:addlinkobj(linkobj)
    local linkid = assert(linkobj.linkid)
    if self.queue or linkobj.queue then
        linkobj.lock = queue()
    end
    return self.linkobjs:add(linkobj,linkid)
end

--- "",""
--@param[type=int] linkid ""ID
--@param[type=bool] close true=""
function cclient:dellinkobj(linkid,close)
    local linkobj = self.linkobjs:del(linkid)
    if linkobj then
        linkobj.lock = nil
        if close then
            local gate_node = linkobj.gate_node
            local gate_address = linkobj.gate_address
            if gate_node ~= self.node then
                cluster.send(gate_node,gate_address,"close",linkid,linkobj.addr)
            else
                skynet.send(gate_address,"lua","close",linkid,linkobj.addr)
            end
        end
        if linkobj.slave then
            self:dellinkobj(linkobj.slave.linkid,close)
        elseif linkobj.master then
            self:unbind_slave(linkobj.master)
        end
    end
    return linkobj
end

--- ""
--@param[type=int] master_linkid ""ID
--@param[type=int] slave_linkid ""ID
function cclient:slaveof(master_linkid,slave_linkid)
    local master_linkobj = self:getlinkobj(master_linkid)
    local slave_linkobj = self:getlinkobj(slave_linkid)
    if not (master_linkobj and slave_linkobj) then
        return
    end
    assert(master_linkobj.slave == nil)
    assert(slave_linkobj.master == nil)
    master_linkobj.slave = slave_linkobj
    slave_linkobj.master = master_linkobj
end

--- ""
--@param[type=table] master_linkobj ""
function cclient:unbind_slave(master_linkobj)
    local slave_linkobj = master_linkobj.slave
    if not slave_linkobj then
        return
    end
    assert(slave_linkobj.master == master_linkobj)
    master_linkobj.slave = nil
    slave_linkobj.master = nil
end

--- ""gate""
--@param[type=table] linkobj ""
--@param[type=string] proto ""
--@param[type=int|string] address ""
--@param[type=string] node; ""
function cclient:forward(linkobj,proto,address,node)
    local linkid = linkobj.linkid
    local gate_node = linkobj.gate_node
    local gate_address = linkobj.gate_address
    if gate_node ~= self.node then
        cluster.send(gate_node,gate_address,"forward",linkid,proto,address,node)
    else
        skynet.send(gate_address,"lua","forward",linkid,proto,address,node)
    end
end

--- ""
--@param[type=table] linkobj ""
--@return ""
function cclient:clone_linkobj(linkobj)
    local clone = {}
    for k,v in pairs(linkobj) do
        if k == "lock" then
            clone.queue = true
        else
            clone[k] = v
        end
    end
    clone.token = nil
    clone.passlogin = nil
    clone.debuglogin = nil
    return clone
end

--- ""linkobj""
--@param[type=table] linkobj ""
--@param[type=int|string] address ""
--@param[type=string] node; ""
function cclient:transfer(linkobj,address,node)
    local clone = self:clone_linkobj(linkobj)
    local function on_transfer()
        self:forward(linkobj,"*",address,node)
        self:dellinkobj(linkobj.linkid,false)
    end
    if node == self.node then
        gg.internal:sendx(on_transfer,address,"exec","gg.client:addlinkobj",clone)
    else
        gg.cluster:sendx(on_transfer,node,address,"exec","gg.client:addlinkobj",clone)
    end
end

return cclient