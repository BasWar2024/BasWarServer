---""
--@module api.analyzer.getInviteSonAccountList
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getInviteSonAccountList
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      pid              [required] type=number help=""id
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getInviteSonAccountList' -d '{"pid":1000000, "sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        beginTime = {type="number"},
        endTime = {type = "number"},
        sonPid = {type="number"},
        fatherPid = {type="number"},
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
    
    local sonPid
    if request.sonPid > 0 then
        sonPid = request.sonPid
    end
    local fatherPid
    if request.fatherPid > 0 then
        fatherPid = request.fatherPid
    end
    local beginTime = request.beginTime
    local endTime = request.endTime
    if beginTime == 0 and endTime == 0 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.REQUIRE_DATE))
        return
    end
    if endTime - beginTime > 86400 * 7 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.DATE_TOO_LONG))
        return
    end

    local response = httpc.answer.response(httpc.answer.code.OK)
    if fatherPid then
        response.data = analyzermgr.getPlayerInviteListByFatherPid(beginTime, endTime, fatherPid)
    else
        response.data = analyzermgr.getPlayerInviteListBySonPid(beginTime, endTime, sonPid)
    end
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