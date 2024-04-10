---@script common.http.httpc
-- ""httpc
httpc.answer = require "common.http.answer"

function httpc.signature(str,secret)
    if type(str) == "table" then
        str = table.ksort(str,"&",{sign=true})
    end
    return crypt.base64encode(crypt.hmac_sha1(secret,str))
end

function httpc.check_signature(sign,str,secret)
    -- ""nocheck,""(https"")
    if secret == "nocheck" then
        return true
    end
    if httpc.signature(str,secret) ~= sign then
        return false
    end
    return true
end

function httpc.make_request(request,secret)
    secret = secret or skynet.config.appkey
    request.sign = httpc.signature(request,secret)
    return request
end

function httpc.unpack_response(response)
    response = cjson.decode(response)
    return response
end

-- ""http""
function httpc.response(linkid,status,body,header)
    logger.logf("debug","http","op=send,linkid=%s,status=%s,body=%s,header=%s",
        linkid,status,body,header)
    local ok,err = httpd.write_response(sockethelper.writefunc(linkid),status,body,header)
    if not ok then
        skynet.error(string.format("op=httpc.response,linktype=http,linkid=%s,err=%s",linkid,err))
    end
end

-- ""json""http""
function httpc.response_json(linkid,status,body,header)
    if header and not header["content-type"] then
        header["content-type"] = "application/json;charset=utf-8"
    end
    if body and type(body) == "table" then
        body = cjson.encode(body)
    end
    httpc.response(linkid,status,body,header)
end

--- ""http""
--@param[type=int] status ""
--@param[type=string|table] args "",""table""header""content-type""
--@param[type=table,opt] header "",""application/json""
function httpc.send(linkobj,status,args,header)
    if not httpc.node then
        httpc.node = skynet.config.id
    end
    if not header then
        header = {
            ["content-type"] = "application/json;charset=utf-8"
        }
    end
    header["Access-Control-Allow-Origin"] = "*"
    local body
    local content_type = header["content-type"]
    if string.find(content_type,"application/json",1,true) then
        if type(args) == "table" then
            body = cjson.encode(args)
        else
            body = args
        end
    else
        assert(string.find(content_type,"application/x-www-form-urlencoded",1,true))
        if type(args) == "table" then
            body = string.urlencode(args)
        else
            body = args
        end
    end
    local gate_node = linkobj.gate_node
    local gate_address = linkobj.gate_address
    local linkid = linkobj.linkid
    logger.logf("debug","http","op=send,node=%s,address=%s,linkid=%s,status=%s,body=%s,header=%s",
        gate_node,gate_address,linkid,status,body,header)
    if gate_node ~= httpc.node then
        cluster.send(gate_node,gate_address,"write",linkid,status,body,header)
    else
        skynet.send(gate_address,"lua","write",linkid,status,body,header)
    end
end

-- ""json""http""
function httpc.send_json(linkobj,status,body,header)
    if header and not header["content-type"] then
        header["content-type"] = "application/json;charset=utf-8"
    end
    if body and type(body) == "table" then
        body = cjson.encode(body)
    end
    httpc.send(linkobj,status,body,header)
end

--- ""httpc.post,""header,""header""content-type""args""
--@param[type=string] host "","":127.0.0.1:4000
--@param[type=string] url url
--@param[type=string|table] args "",""table""header""content-type""
--@param[type=table,opt] header "",""application/json""
--@param[type=table,opt] recvheader ""header""
--@return[type=int] status ""
--@return[type=string] response ""
function httpc.postx(host,url,args,header,recvheader)
    header = header or {}
    if not header['content-type'] then
        header['content-type'] = "application/json;charset=utf-8"
    end

    local body
    local content_type = header["content-type"]
    if string.find(content_type,"application/json",1,true) then
        if type(args) == "table" then
            body = cjson.encode(args)
        else
            body = args
        end
    else
        assert(string.find(content_type,"application/x-www-form-urlencoded",1,true))
        if type(args) == "table" then
            body = string.urlencode(args)
        else
            body = args
        end
    end
    logger.logf("debug","http","op=postx,host=%s,url=%s,args=%s,header=%s,body=%s,recvheader=%s",
        host,url,args,header,body,recvheader)
    return httpc.request("POST", host, url, recvheader, header, body)
end

---""http/https""
--@param[type=string] url url
--@param[type=table] get get""
--@param[type=table|string] post post"",""POST"",""GET""
--@param[type=bool,opt] no_replay "",true--"",false--"",""
--@param[type=table,opt] header http""
--@return[type=number] status http"",""0"",""(""/etc/hosts"")
--@return[type=string] response ""
function httpc.req(url,get,post,no_reply,header)
    if not httpc.webclient_address then
        httpc.webclient_address = skynet.uniqueservice("webclient")
    end
    local address = httpc.webclient_address
    if not header then
        header = {
            ["content-type"] = "application/json;charset=utf-8",
        }
    end
    if no_reply then
        skynet.send(address,"lua","request",url,get,post,no_reply,header)
    else
        local starttime = skynet.now()
        local isok,response,info = skynet.call(address,"lua","request",url,get,post,no_reply,header)
        if info.response_code == 0 then
            skynet.error(string.format("op=httpc.req,linktype=http,url=%s,isok=%s,code=%s,response=%s,costtime=%s",url,isok,info.response_code,response,(skynet.now()-starttime)/100))
        end
        return info.response_code,response
    end
end

return httpc
