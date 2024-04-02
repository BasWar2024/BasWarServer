---""("")
--@module api.analyzer.getInvitePaymentFromAdmin
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getInvitePaymentFromAdmin
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      adminAccount     [required] type=string help=""    
--      sign             [required] type=string help=""
--      fatherAccount     [required] type=string help=""
--      sonAccount     [required] type=string help=""
--      date            [required] type=string help="", 20230304
--      pageNo           [required] type=number help=""
--      pageSize         [required] type=number help=""
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getInvitePaymentFromAdmin' -d '{}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        fatherAccount = {type="string"},
        sonAccount = {type="string"},
        date = {type="string"},
        pageNo = {type="number"},
        pageSize = {type="number"},
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
    
    local pageNo = tonumber(request.pageNo) or 1
    local pageSize = tonumber(request.pageSize) or 20

    local NO = "no"
    local fatherAccount = nil
    if request.fatherAccount ~= "no" then
        fatherAccount = request.fatherAccount
    end
    local sonAccount = nil
    if request.sonAccount ~= "no" then
        sonAccount = request.sonAccount
    end

    local year = tonumber(string.sub(request.date, 1, 4))
    local month = tonumber(string.sub(request.date, 5, 6))
    local day = tonumber(string.sub(request.date, 7, 8))
    local timestamp = gg.time.date_to_timestamp(year, month, day, 0, 0, 0)
    local dayno = gg.time.dayno(timestamp)
    local curdayno = gg.time.dayno()
    --""dayno"",""

    analyzermgr.checkAndSaveDayUserPaymentInfo(timestamp)

    local result = analyzermgr.getInviteDayPaymentInfo(pageNo, pageSize, dayno, fatherAccount, sonAccount)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = result
    httpc.send(linkobj, 200, response)
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