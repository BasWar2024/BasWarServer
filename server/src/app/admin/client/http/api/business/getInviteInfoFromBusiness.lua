---""
--@module api.business.getInviteInfoFromBusiness
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/business/getInviteInfoFromBusiness
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      businessAccount     [required] type=string help=""
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
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
--  curl -v 'http://127.0.0.1:4241/api/business/getInviteInfoFromBusiness' -d '{"businessAccount":"test01@gmail.com", "pageNo":1, "pageSize":20, "sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        businessAccount = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
        sign = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkBusinessAccount(linkobj, request, args) then
        return
    end
    
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20

    local businessAccount = request.businessAccount

    local result = analyzermgr.getUserInviteInfoByAccount(pageNo, pageSize, businessAccount)

    local newMyself = {}
    newMyself.account = result.myself.account
    newMyself.pid = result.myself.pid
    newMyself.name = result.myself.name
    newMyself.onlineStatus = result.myself.onlineStatus
    newMyself.mit = result.myself.mit
    newMyself.carboxyl = result.myself.carboxyl
    newMyself.starCoin = result.myself.starCoin
    newMyself.titanium = result.myself.titanium
    newMyself.gas = result.myself.gas
    newMyself.ice = result.myself.ice
    newMyself.baseLevel = result.myself.baseLevel
    newMyself.vipLevel = result.myself.vipLevel
    newMyself.createTime = result.myself.createTime
    newMyself.loginTime = result.myself.loginTime
    newMyself.logoutTime = result.myself.logoutTime
    newMyself.loginCount = result.myself.loginCount
    result.myself = newMyself

    local newRows = {}
    for k,v in pairs(result.rows) do 
        local data = {}
        data.account = v.account
        data.pid = v.pid
        data.name = v.name
        data.onlineStatus = v.onlineStatus
        data.mit = v.mit
        data.carboxyl = v.carboxyl
        data.starCoin = v.starCoin
        data.titanium = v.titanium
        data.gas = v.gas
        data.ice = v.ice
        data.baseLevel = v.baseLevel
        data.vipLevel = v.vipLevel
        data.createTime = v.createTime
        data.loginTime = v.loginTime
        data.logoutTime = v.logoutTime
        data.loginCount = v.loginCount
        table.insert(newRows, data)
    end
    result.rows = newRows

    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = result
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
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler