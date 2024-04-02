---""
--@module api.operation.getGiftCodes
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/operation/getGiftCodes
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""
--      cfgId     [required] type=string help=""cfgId
--      code     [required] type=string help=""
--      pid     [required] type=string help=pid
--      use     [required] type=string help=""
--      sign             [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=string help=""
--      data = {
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4241/api/operation/getGiftCodes' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        cfgId = {type="string"},
        code = {type="string"},
        pid = {type="string"},
        use = {type="string"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE2) then
        return
    end
    
    local NO = "no"

    local cfgId = nil
    if request.cfgId ~= NO then
        cfgId = math.floor(tonumber(request.cfgId))
    end
    local code = nil
    if request.code ~= NO then
        code = request.code
    end
    local pid = nil
    if request.pid ~= NO then
        pid = math.floor(tonumber(request.pid))
    end
    local rewardTime = nil
    if request.use ~= NO then
        local use = math.floor(tonumber(request.use))
        if use == 1 then
            rewardTime = { ["$exists"] = true  }
        else
            rewardTime = { ["$exists"] = false }
        end
    end

    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20

    local condition = {} 
    condition.cfgId = cfgId
    condition.code = code
    condition.pid = pid
    condition.rewardTime = rewardTime

    local data = analyzermgr.getGiftCodes(pageNo, pageSize, condition)

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
    httpc.send_json(linkobj, 200, response)
end

function handler.POST(linkobj,header,query,body)
    local args = {}
    if body and body ~= "" then
        body = string.trimBom(body)
        args = cjson.decode(body)
    end
    handler.exec(linkobj,header,args)
end

function handler.GET(linkobj,header,query,body)
    local args = {}
    if query and query ~= "" then
        local param = urllib.parse_query(query)
        table.update(args, param)
    end
    handler.exec(linkobj,header, args)
end

function __hotfix(module)
    gg.client:open()
end

return handler