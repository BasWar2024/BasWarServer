---
--@module api.account.bind
--@author sw
--@release 2020/5/15 14:23:00
--@usage
--api:      /api/account/bind
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=
--      passwd      [requried] type=string help=(md5)
--      realName    [required] type=string help=
--      IDCard      [required] type=string help=
--      vistorAccount [required] type=string help=
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/bind' -d '{"sign":"debug","appid":"gg","account":"lgl","passwd":"1","sdk":"local","platform":"local"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        account = {type="string"},
        passwd = {type="string"},
        realName = {type="string"},
        IDCard = {type="string"},
        vistorAccount = {type="string"}
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local passwd = request.passwd
    local realName = request.realName
    local IDCard = request.IDCard
    local vistorAccount = request.vistorAccount
    local isVistor
    local app = util.get_app(appid)
    if not app then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.APPID_NOEXIST))
        return
    end
    local appkey = app.appkey
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end

    if #account == 0 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_FMT_ERR))
        return
    end
    if #passwd == 0 then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.PASSWD_FMT_ERR))
        return
    end

    if realName and IDCard then
        -- local code = accountmgr.verifyIDCard(realName,IDCard)
        -- if code ~= httpc.answer.code.OK then
        --     httpc.send_json(linkobj,200,httpc.answer.response(code))
        --     return
        -- end
    end

    local accountobj = accountmgr.getaccount(vistorAccount)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    if not accountobj.isVistor then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.NOT_A_TEMP_ACCOUNT))
        return
    end

    if accountmgr.getaccount(account) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_EXIST))
        return
    end

    accountmgr.addaccountalias(account,vistorAccount)
    accountobj.passwd = passwd
    accountobj.isVistor = nil
    accountobj.IDCard = IDCard
    accountobj.realName = realName
    accountmgr.saveaccount(accountobj)

    local response = httpc.answer.response(httpc.answer.code.OK)
    httpc.send_json(linkobj,200,response)
    return
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
