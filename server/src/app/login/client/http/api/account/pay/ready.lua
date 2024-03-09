---
--@module api.account.pay.ready
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/account/pay/ready
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      sign        [required] type=string help=
--      appid       [required] type=string help=appid
--      account     [required] type=string help=
--      roleid      [required] type=int help=id
--      server_id   [required] type=string help=id
--      product_id  [required] type=string help=id
--      rmb         [required] type=int help=
--      quantity    [required] type=int help=
--      device      [required] type=table encode=json help=()
--      ext         [optional] type=string help=
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=
--      message =   [required] type=number help=
--      data = {
--          order_id =     [required] type=string help=id
--          notify_url =   [required] type=string help=url
--      }
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/account/pay/ready' -d '{"sign":"debug","appid":"gg","openid":"openid","platform":"local","sdk":"sdk","product_id":"product1","quantity":1,"server_id":"game1","roleid":1000001,"device":{}}'

--/*
--:
--C
--LS(,)
--GS()
--PS()
--C2LS:->
--LS2C: ->
--C2PS: ->
--C2S: ->

--
--1. C2LS: ,order_id(/api/account/pay/ready)
--2. C2PS: (order_id)
--3. PS2LS: (/api/account/pay/back/$platform)
--4. LS2GS: ,4.1,4.2
--          4.1 
--		    4.2 
--*/

--: /api/account/pay/settle

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        appid = {type="string"},
        server_id = {type="string"},
        account = {type="string"},
        roleid = {type="number"},
        product_id = {type="string"},
        rmb = {type="number"},
        quantity = {type="number"},
        device = {type="json"},
        ext = {type = "string"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appid = request.appid
    local account = request.account
    local server_id = request.server_id
    local roleid = request.roleid
    local product_id = request.product_id
    local product_rmb = request.rmb
    local quantity = request.quantity
    local device = request.device
    local ext = request.ext
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
    local accountobj = accountmgr.getaccount(account)
    if not accountobj then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    local rmb = product_rmb * quantity
    local order = accountmgr.ready_pay(appid,accountobj.openid,server_id,roleid,product_id,quantity,rmb,accountobj.platform,accountobj.sdk,ext)
    local data = {
        order_id = order.order_id,
        notify_url = string.format("http://%s/api/account/pay/back/%s",skynet.getenv("domain"),accountobj.platform),
    }
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = data
    httpc.send_json(linkobj,200,response)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
