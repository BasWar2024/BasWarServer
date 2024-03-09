local cloginserver = class("cloginserver")

---cloginserver.new
--@usage
--local loginserver = ggclass.cloginserver.new({
--  host = ip:port,
--  appid = id,
--  appkey = ,
--})
function cloginserver:ctor(conf)
    self.host = assert(conf.host)
    self.appid = assert(conf.appid)
    self.appkey = assert(conf.appkey)
    self.loginserver_appkey = assert(conf.loginserver_appkey)
end

function cloginserver:signature(str,appkey)
    appkey = appkey or self.appkey
    if type(str) == "table" then
        str = table.ksort(str,"&",{sign=true})
    end
    return crypt.base64encode(crypt.hmac_sha1(appkey,str))
end

function cloginserver:encode_request(request,appkey)
    request.sign = self:signature(request,appkey)
    return cjson.encode(request)
end

function cloginserver:decode_response(status,response)
    if status ~= 200 then
        return status,response
    end
    return status,cjson.decode(response)
end

function cloginserver:post(url,req)
    return httpc.postx(self.host,url,req)
end

---
--@param[type=string] account 
--@param[type=string] new_serverid ID
--@param[type=int] old_roleid ID
--@param[type=int,opt] new_roleid ID,ID
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:rebindserver(account,new_serverid,old_roleid,new_roleid)
    new_roleid = new_roleid or old_roleid
    local url = "/api/account/role/rebindserver"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       old_roleid = old_roleid,
       new_roleid = new_roleid,
       new_serverid = new_serverid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=int] roleid ID
--@param[type=string] new_account 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:rebindaccount(roleid,new_account)
    local url = "/api/account/role/rebindaccount"
    local req = self:encode_request({
       appid = self.appid,
       roleid = roleid,
       new_account = new_account,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=int] roleid ID
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:recover_role(roleid)
    local url = "/api/account/role/recover"
    local req = self:encode_request({
       appid = self.appid,
       roleid = roleid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=int] roleid ID
--@param[type=bool,optional] forever 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:delrole(roleid,forever)
    local url = "/api/account/role/del"
    local req = self:encode_request({
       appid = self.appid,
       roleid = roleid,
       forever = forever,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] account 
--@param[type=string] serverid ID()
--@param[type=table] role 
--@param[type=int,opt] roleid ,ID
--@param[type=string,opt] genrolekey roleid,id,minroleid,maxroleid
--@param[type=string,opt] minroleid ID
--@param[type=string,opt] maxroleid ID(),[minroleid,maxroleid)
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:addrole(account,serverid,role,roleid,genrolekey,minroleid,maxroleid)
    local url = "/api/account/role/add"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       serverid = serverid,
       role = cjson.encode(role),
       roleid = roleid,
       genrolekey = genrolekey,
       minroleid = minroleid,
       maxroleid = maxroleid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] account 
--@param[type=string,opt] serverid ID(,)
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:rolelist(account,serverid)
    local url = "/api/account/role/list"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       serverid = serverid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=int] roleid ID
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:getrole(roleid)
    local url = "/api/account/role/get"
    local req = self:encode_request({
       appid = self.appid,
       roleid = roleid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=int] roleid ID
--@param[type=table] role 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:updaterole(roleid,role)
    local url = "/api/account/role/update"
    local req = self:encode_request({
       appid = self.appid,
       roleid = roleid,
       role = cjson.encode(role),
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] serverid ID
--@param[type=table] server 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:addserver(serverid,server)
    local url = "/api/account/server/add"
    local req = self:encode_request({
       appid = self.appid,
       serverid = serverid,
       server = cjson.encode(server),
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] serverid ID
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:delserver(serverid)
    local url = "/api/account/server/del"
    local req = self:encode_request({
       appid = self.appid,
       serverid = serverid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] serverlist_name 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:switchserverlist(serverlist_name)
    local url = "/api/account/server/switchserverlist"
    local req = self:encode_request({
       appid = self.appid,
       serverlist_name = serverlist_name or "server",
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] serverid ID
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:getserver(serverid)
    local url = "/api/account/server/get"
    local req = self:encode_request({
       appid = self.appid,
       serverid = serverid,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] serverid ID
--@param[type=table] server 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:updateserver(serverid,server)
    local url = "/api/account/server/update"
    local req = self:encode_request({
       appid = self.appid,
       serverid = serverid,
       server = cjson.encode(server),
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] version 
--@param[type=string] platform 
--@param[type=string,opt] account 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:serverlist(version,platform,account)
    local url = "/api/account/server/list"
    local req = self:encode_request({
       appid = self.appid,
       version = version,
       platform = platform,
       account = account,
    })
    return self:decode_response(self:post(url,req))
end

---token
--@param[type=string] account 
--@param[type=string] token token
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:checktoken(account,token)
    local url = "/api/account/checktoken"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       token = token,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] account 
--@param[type=string] passwd 
--@param[type=string] platform 
--@param[type=string] sdk sdk
--@param[type=string] device json
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:login(account,passwd,platform,sdk,device)
    local url = "/api/account/login"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       passwd = passwd,
       platform = platform,
       sdk = sdk,
       device = device,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] account 
--@param[type=string] passwd 
--@param[type=string] sdk sdk
--@param[type=string] platform 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:register(account,passwd,sdk,platform)
    local url = "/api/account/register"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       passwd = passwd,
       sdk = sdk,
       platform = platform,
       device = cjson.encode({}),
    })
    return self:decode_response(self:post(url,req))
end

---rpc
--@param[type=string] module 
--@param[type=string] cmd 
--@param[type=table] args 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:rpc(module,cmd,args)
    local url = "/api/rpc"
    local req = self:encode_request({
       module = module,
       cmd = cmd,
       args = cjson.encode(args or {}),
    },self.loginserver_appkey)
    return self:decode_response(self:post(url,req))
end

-- wrap
--- 
--@param[type=string] serverid id
--@param[type=int] is_open 1--,0--
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:openserver(serverid,is_open)
    local server = {
        id = serverid,
        is_open = is_open,
    }
    return self:updateserver(serverid,server)
end

---
--@param[type=string] account 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:getAccountInfo(account)
    local url = "/api/account/getAccountInfo"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=string] account 
--@param[type=string] name 
--@param[type=string] IDCard 
--@return[type=int] status 
--@return[type=string] response 
function cloginserver:nameAuth(account,name,IDCard)
    local url = "/api/account/nameAuth"
    local req = self:encode_request({
       appid = self.appid,
       account = account,
       name = name,
       IDCard = IDCard,
    })
    return self:decode_response(self:post(url,req))
end

---
--@param[type=table] order
--@return[type=string] response 
function cloginserver:exchange(rawOrder)
    local url = "/api/account/exchange/ready"
    rawOrder.appid = self.appid
    local req = self:encode_request(rawOrder)
    return self:decode_response(self:post(url,req))
end

---
--@param[type=table] order
--@return[type=string] response 
function cloginserver:recharge(server_id,account,roleid,product_id,product_rmb,num,device,ext)
    local url = "/api/account/pay/ready"
    local req = self:encode_request({
        appid = self.appid,
        server_id = server_id,
        account = account,
        roleid = roleid,
        product_id = product_id,
        rmb = product_rmb,
        quantity = num,
        device = cjson.encode(device),
        ext = cjson.encode(ext or {}),
    })
    return self:decode_response(self:post(url,req))
end

return cloginserver
