---dapp""
--@module api.dapp.registerFromDapp
--@author sw
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/dapp/registerFromDapp
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=""
--      account     [required] type=string help=""
--      passwd      [requried] type=string help=""(md5"")
--      verifyCode  [required] type=string help=""
--      fatherInviteCode     [required] type=string help=""
--      chain_id     [required] type=string help=""id
--      owner_address     [required] type=string help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      data = {
--              account =   [optional] type=string help=""
--              accountid =   [optional] type=string help=""id
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/registerFromDapp' -d '{"sign":"debug","account":"lgl","passwd":"1","fatherInviteCode":"ABCN","chain_id":"no","owner_address":"no","verifyCode":"660088"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        account = {type="string"},
        passwd = {type="string"},
        verifyCode = {type="string"},
        fatherInviteCode = {type="string"},
        chain_id = {type="string"},
        owner_address = {type="string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local account = request.account or ''
    local passwd = request.passwd
    account = string.trim(account)
    account = string.lower(account)

    if not util.dapp_check_signature(args) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end

    local verifyCode = nil
    if request.verifyCode and request.verifyCode ~= "" then
        verifyCode = request.verifyCode
    end
    local fatherInviteCode = nil
    if request.fatherInviteCode and request.fatherInviteCode ~= "" and request.fatherInviteCode ~= "no" then
        fatherInviteCode = request.fatherInviteCode
    end
    local chain_id = nil
    if request.chain_id and request.chain_id ~= "" and request.chain_id ~= "no" then
        chain_id = tonumber(request.chain_id)
    end
    local owner_address = nil
    if request.owner_address and request.owner_address ~= "" and request.owner_address ~= "no" then
        owner_address = request.owner_address
    end

    if not string.checkEmail(account) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end
    if #account < constant.ACCOUNT_MIN_LEN or #account > constant.ACCOUNT_MAX_LEN then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end
    if #passwd < constant.PASSWD_MIN_LEN or #passwd > constant.PASSWD_MAX_LEN then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_FMT_ERR))
        return
    end
    local accountobj = accountmgr.getaccount(account)
    if accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_EXIST))
        return
    end
    local accountid = nil
    local randomCnt = math.random(1, 2)
    for i = 1, randomCnt do
        accountid = accountmgr.genroleid(skynet.config.appid,skynet.config.appid,1000000,2000000000)
    end
    local inviteCode = math.int2AnyStr(accountid, 62)

    local code = accountmgr.addaccount({
        account = account,
        accountid = accountid,
        passwd = passwd,
        openid = account,
        verifyCode = verifyCode,
        fatherInviteCode = fatherInviteCode,
        inviteCode = inviteCode,
        chain_id = chain_id,
        owner_address = owner_address,
    })

    gg.internal:call(".gamelog", "api", "registerWithInviteCode", accountid, account, inviteCode, fatherInviteCode)
    
    local response = httpc.answer.response(code)
    response.data = {
        account = account,
        accountid = accountid,
    }
    httpc.send_json(linkobj,200,response)
    return
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
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
