--- webclient. (skynet).
--
-- @module webclient
-- @usage local webclient = skynet.newservice("webclient")

local skynet = require "skynet"
local webclientlib = require "webclient"
local webclient = webclientlib.create()
local requests = nil

local function resopnd(request, result)
    if not request.response then
        return
    end

    local content, errmsg = webclient:get_respond(request.req) 
    local info = webclient:get_info(request.req) 
     
    if result == 0 then
        request.response(true, true, content, info)
    else
        request.response(true, false, errmsg, info)
    end
end

local function query()
    while next(requests) do
        local finish_key, result = webclient:query()
        if finish_key then
            local request = requests[finish_key];
            assert(request)

            xpcall(resopnd, function() skynet.error(debug.traceback()) end, request, result)

            webclient:remove_request(request.req)
            requests[finish_key] = nil
        else
            skynet.sleep(1)
        end
    end 
    requests = nil
end

--- url
-- @function request
-- @string url url
-- @tab[opt] get get
-- @param[opt] post posttable or string 
-- @bool[opt] no_reply skynet.callnilfalseskynet.sendtrue
-- @tabl[opt] header header table
-- @treturn bool 
-- @treturn string 
-- @usage skynet.call(webclient, "lua", "request", "http://www.dpull.com")
-- @usage skynet.send(webclient, "lua", "request", "http://www.dpull.com", nil, nil, true)
-- @usage skynet.send(webclient, "lua", "request", "http://www.dpull.com", nil, nil, true,{key1="key1",key2="key2"})
local function request(url, get, post, no_reply, header)
    local header_list
    if type(header) == "table" then
        header_list = {}
        if #header == 0 then
            -- dict
            for k,v in pairs(header) do
                table.insert(header_list,string.format("%s:%s",k,v))
            end
        else
            for i,v in ipairs(header) do
                table.insert(header_list,tostring(v))
            end
        end
    end
    if get then
        local i = 0
        for k, v in pairs(get) do
            k = webclient:url_encoding(k)
            v = webclient:url_encoding(v)

            url = string.format("%s%s%s=%s", url, i == 0 and "?" or "&", k, v)
            i = i + 1
        end
    end

    if post and type(post) == "table" then
        local data = {}
        for k,v in pairs(post) do
            k = webclient:url_encoding(k)
            v = webclient:url_encoding(v)

            table.insert(data, string.format("%s=%s", k, v))
        end   
        post = table.concat(data , "&")
    end   

    local req, key = webclient:request(url, post,nil,header_list)
    if not req then
        if not no_reply then
            return skynet.ret()
        end
    end
    assert(key)

    local response = nil
    if not no_reply then
        response = skynet.response()
    end

    if requests == nil then
        requests = {}
        skynet.fork(query)
    end

    requests[key] = {
        url = url, 
        req = req,
        response = response,
    }
end

skynet.start(function()
    skynet.dispatch("lua", function(session, source, command, ...)
        assert(command == "request")
        request(...)
    end)
end)
