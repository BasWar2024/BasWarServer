---""
--@module api.dapp.getPlayerInformation
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/dapp/getPlayerInformation
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      mail              [required] type=string help=""
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
--  curl -v 'http://127.0.0.1:4241/api/dapp/getPlayerInformation' -d '{"mail":"test1@qq.com"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        mail = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local mail = request.mail
    mail = string.lower(mail)
    local addressDoc = gg.mongoProxy.account:findOne({account = mail})
    if not addressDoc then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end

    --[[
    local doc = gg.mongoProxy.role:findOne({account = mail})
    if not doc then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.MAIL_NOT_CREATE_PLAYER))
        return
    end
    ]]

    local result = {}
    result.account = addressDoc.account
    result.pid = addressDoc.accountid
    result.name = addressDoc.pid
    result.inviteCode = addressDoc.inviteCode
    result.headIcon = ""
    result.chainId = addressDoc.chain_id
    result.owner_address = addressDoc.owner_address


    local ret = analyzermgr.getPlayerDataList({ account = mail }, false)
    local playerInfo = ret[1]
    if playerInfo then
        result.name = playerInfo.name
        result.headIcon = playerInfo.headIcon
    end
    

    --[[
    local result = {}
    result.account = playerInfo.account
    result.pid = playerInfo.pid
    result.name = playerInfo.name
    result.inviteCode = playerInfo.inviteCode
    result.headIcon = playerInfo.headIcon
    result.chainId = playerInfo.chainId
    result.walletAddress = playerInfo.walletAddress
    ]]

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
    handler.exec(linkobj,header, args)
end

function __hotfix(module)
    gg.client:open()
end

return handler