---""
--@module api.operation.setTesseractToResRate
--@author sw
--@release 2022/12/13 13:50:00
--@usage
--api:      /api/operation/setTesseractToResRate
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      starCoin         [required] type=number help=starCoin
--      ice              [required] type=number help=ice
--      titanium         [required] type=number help=titanium
--      gas              [required] type=number help=gas
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
--  curl -v 'http://127.0.0.1:4241/api/operation/setTesseractToResRate' -d '{}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        chain = {type="number"},
        starCoin = {type="number"},
        ice = {type="number"},
        titanium = {type="number"},
        gas = {type="number"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    
    if not operationmgr.checkAdminAccount(linkobj, request, args, constant.ADMIN_AUTHORITY_OPERATE1) then
        return
    end
    
    local info = gg.dynamicCfg:get(constant.REDIS_TESSERACT_TO_RES)
    local newRateInfo = {
        starCoin = tostring(request.starCoin),
        ice = tostring(request.ice),
        titanium = tostring(request.titanium),
        gas = tostring(request.gas),
    }
    info[tostring(request.chain)] = newRateInfo
    gg.dynamicCfg:set(constant.REDIS_TESSERACT_TO_RES, info)
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = "success"
    httpc.send_json(linkobj,200,response)
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