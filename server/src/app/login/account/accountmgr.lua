---""
--@module accountmgr
--@usage
--mongo""
--"": role =>  {roleid=xxx,appid=xxx,account=xxx,createServerId=xxx,...}
--"": account => {account=xxx,passwd=xxx,sdk=xxx,platform=xxx,...}
--"": account_roles => {account=xxx,appid=xxx,roles={""ID""}}
--"": account_deleted_roles => {account=xxx,appid=xxx,roles={""ID""}}

local md5 =	require	"md5"
local bson = require "bson"

accountmgr = accountmgr or {}

function accountmgr.addaccountalias(alias,account)
    assert(account)
    local data = {
        alias = alias,
        account = account,
        createTime = os.time(),
    }
    gg.mongoProxy.accountalias:update({alias=alias},data,true,false)
end

function accountmgr.getrealaccount(account)
    local doc = gg.mongoProxy.accountalias:findOne({alias=account})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc.account
    end
end

function accountmgr.saveaccount(accountobj)
    local account = assert(accountobj.account)
    local data = {
        account = accountobj.account,
        openid = accountobj.openid,
        sdk = accountobj.sdk,
        passwd = accountobj.passwd,
        verifyCode = accountobj.verifyCode,
        platform = accountobj.platform,
        createTime = accountobj.createTime,
        create_time = accountobj.create_time,
        device = accountobj.device,
        firstTime = accountobj.firstTime,
        inviteCode = accountobj.inviteCode,
        accountid = accountobj.accountid,
        fatherInviteCode = accountobj.fatherInviteCode,
        chain_id = accountobj.chain_id,
        owner_address = accountobj.owner_address,
        update_time = skynet.timestamp()
    }
    gg.mongoProxy.account:update({ account = account },{["$set"] = data },true,false)
end

function accountmgr.updatepasswd(account, passwd)
    gg.mongoProxy.account:update({ account = account },{["$set"] = {passwd=passwd}},false,false)
end

function accountmgr.getaccount(account)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local doc = gg.mongoProxy.account:findOne({account=account})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

--/*
-- accountobj: {account="",passwd="",sdk=sdk,platform="",...}
--*/
function accountmgr.addaccount(accountobj)
    local account = assert(accountobj.account)
    local has_accountobj = accountmgr.getaccount(account)
    if has_accountobj then
        return httpc.answer.code.ACCT_EXIST
    end
    accountobj.createTime = os.time()
    accountobj.create_time = skynet.timestamp()
    logger.logf("info","account",string.format("op=addaccount,accountobj=%s",cjson.encode(accountobj)))
    accountmgr.saveaccount(accountobj)
    return httpc.answer.code.OK
end

function accountmgr.delaccount(account)
    local accountobj = accountmgr.getaccount(account)
    if accountobj then
        logger.logf("info","account",string.format("op=delaccount,account=%s",account))
        gg.mongoProxy.player:delete({account=account})
        return httpc.answer.code.OK
    end
    return httpc.answer.code.ACCT_NOEXIST
end

-- ""ID""
function accountmgr.getroles(account,appid)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local doc = gg.mongoProxy.account_roles:findOne({account=account,appid=appid})
    if doc == nil then
        return {}
    else
        return doc.roles
    end
end

function accountmgr.getrolelist(account,appid)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local docs = gg.mongoProxy.role:find({account=account,appid=appid})
    for k, v in pairs(docs) do
        v._id = nil
    end
    return docs
end

-- roles: ""ID""
function accountmgr.saveroles(account,appid,roles)
    assert(roles ~= nil)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local doc = {account=account,appid=appid,roles=roles}
    gg.mongoProxy.account_roles:update({account=account,appid=appid},doc,true,false)
end

-- ""
-- roles: ""ID""
function accountmgr.save_deleted_roles(account,appid,roles)
    assert(roles ~= nil)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local doc = {account=account,appid=appid,roles=roles}
    gg.mongoProxy.account_deleted_roles:update({account=account,appid=appid},doc,true,false)
end

-- ""ID""
function accountmgr.get_deleted_roles(account,appid)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local doc = gg.mongoProxy.account_deleted_roles:findOne({account=account,appid=appid})
    if doc == nil then
        return {}
    else
        return doc.roles
    end
end

function accountmgr.checkrole(role)
    local role,err = table.check(role,{
        roleid = {type="number"},
        name = {type="string"},
        heroId = {type="number",optional=true},
        job = {type="string",optional=true},
        level = {type="number",optional=true,default=0,},
        gold = {type="number",optional=true,default=0,},

        diamond = {type="number",optional=true,},
    })
    return role,err
end

function accountmgr.addrole(account,appid,serverid,role)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local role,err = accountmgr.checkrole(role)
    if err then
        return httpc.answer.code.ROLE_FMT_ERR,err
    end
    local roleid = assert(role.roleid)
    local name = assert(role.name)
    local app = util.get_app(appid)
    if not app then
        return httpc.answer.code.APPID_NOEXIST
    end
    local accountdoc = accountmgr.getaccount(account)
    if not accountdoc then
        return httpc.answer.code.ACCT_NOEXIST
    end
    if not servermgr.getserver(appid,serverid) then
        return httpc.answer.code.SERVER_NOEXIST
    end
    local found = accountmgr.getrole(appid,roleid)
    if found then
        return httpc.answer.code.ROLE_EXIST
    end
    local rolelist = accountmgr.getroles(account,appid)
    local found = table.find(rolelist,roleid)
    if found then
        return httpc.answer.code.ROLE_EXIST
    end
    local roledatalist = accountmgr.getrolelist(account,appid)
    local role_num_in_server = 0
    for i,roledata in ipairs(roledatalist) do
        if roledata.createServerId == serverid then
            role_num_in_server = role_num_in_server + 1
        end
    end
    local max_role_num_per_account = app.max_role_num_per_account or 64
    local max_role_num_per_server = app.max_role_num_per_server or 8
    if #rolelist >= max_role_num_per_account then
        return httpc.answer.code.ROLE_TOO_MUCH
    end
    if role_num_in_server >= max_role_num_per_server then
        return httpc.answer.code.ROLE_OVERLIMIT
    end
    role.appid = appid
    role.account = account
    role.createServerId = serverid
    role.currentServerId = serverid
    role.createTime = role.createTime or os.time()
    logger.logf("info","account",string.format("op=addrole,account=%s,appid=%s,role=%s",account,appid,cjson.encode(role)))
    --gg.mongoProxy.role:update({appid=appid,roleid=roleid},role,true,false)
    gg.mongoProxy.role:insert(role)
    table.insert(rolelist,roleid)
    accountmgr.saveroles(account,appid,rolelist)
    return httpc.answer.code.OK
end

function accountmgr.getrole(appid,roleid)
    local doc = gg.mongoProxy.role:findOne({appid=appid,roleid=roleid})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function accountmgr.delrole(appid,roleid,forever)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    local role = accountmgr.getrole(appid,roleid)
    if not role then
        return httpc.answer.code.ROLE_NOEXIST
    end
    local account = role.account
    local rolelist = accountmgr.getroles(account,appid)
    local found_pos = table.find(rolelist,roleid)
    if not found_pos then
        return httpc.answer.code.ROLE_NOEXIST
    end
    logger.logf("info","account",string.format("op=delrole,account=%s,appid=%s,role=%s,forever=%s",account,appid,cjson.encode(role),forever))
    if forever then
        gg.mongoProxy.role:delete({appid=appid,roleid=roleid},true)
    else
        local deleted_rolelist = accountmgr.get_deleted_roles(account,appid)
        table.insert(deleted_rolelist,roleid)
        accountmgr.save_deleted_roles(account,appid,deleted_rolelist)
    end
    table.remove(rolelist,found_pos)
    accountmgr.saveroles(account,appid,rolelist)
    return httpc.answer.code.OK
end

-- ""
function accountmgr.updaterole(appid,syncrole)
    local roleid = assert(syncrole.roleid)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    local role = accountmgr.getrole(appid,roleid)
    if not role then
        return httpc.answer.code.ROLE_NOEXIST
    end
    table.update(role,syncrole)
    gg.mongoProxy.role:update({appid=appid,roleid=roleid},role,true,false)
    return httpc.answer.code.OK,role
end

-- ""id
function accountmgr.genid(table_name,idkey,appid)
    local doc = gg.mongoProxy[table_name]:findAndModify({
        query = {appid=appid,idkey=idkey},
        update = {["$inc"] = {sequence = 1}},
        new = true,
        upsert = true,
    })
    return doc.value.sequence
end

-- "": [minroleid,maxroleid)
function accountmgr.genroleid(appid,idkey,minroleid,maxroleid)
    minroleid = tonumber(minroleid)
    maxroleid = tonumber(maxroleid)
    assert(appid)
    assert(idkey)
    assert(minroleid)
    assert(maxroleid)
    -- roleid in range [minroleid,maxroleid)
    local valid_range = maxroleid - minroleid
    local range = accountmgr.genid("roleid",idkey,appid)
    if range > valid_range then
        return nil
    end
    return minroleid + range - 1
end

function accountmgr.genrandomaccount(appid,idkey)
    assert(appid)
    assert(idkey)
    local sequence = accountmgr.genid("account_random",idkey,appid)
    return "random_" .. sequence .. "_".. string.randomkey(3), string.randomkey(6)
end

function accountmgr.cryptPassword(password)
    local password = password .. "starwar"
    return string.lower(md5.sumhexa16(password))
end

function accountmgr.gentoken(input)
    local prefix = string.format("loginserver.%s.",skynet.hpc())
    local token = prefix .. string.randomkey(8)
    return token
end

function accountmgr.gettoken(token)
    return gg.thistemp:get(token)
end

function accountmgr.addtoken(token,data,expire)
    expire = expire or 1800
    gg.thistemp:set(token,data,expire)
end

function accountmgr.deltoken(token)
    gg.thistemp:del(token)
end


-- ""
function accountmgr.rebindserver(account,appid,new_serverid,old_roleid,new_roleid)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    if not accountmgr.getaccount(account) then
        return httpc.answer.code.ACCT_NOEXIST
    end
    if not servermgr.getserver(appid,new_serverid) then
        return httpc.answer.code.SERVER_NOEXIST
    end
    local old_role = accountmgr.getrole(appid,old_roleid)
    if not old_role then
        return httpc.answer.code.ROLE_NOEXIST
    end
    if old_roleid == new_roleid then
        if old_role.createServerId == new_serverid then
            -- unchange
            return httpc.answer.code.OK
        end
    else
        local new_role = accountmgr.getrole(appid,new_roleid)
        if new_role then
            return httpc.answer.code.ROLE_EXIST
        end
    end
    logger.logf("info","account",string.format("op=rebindserver,account=%s,appid=%s,old_serverid=%s,new_serverid=%s,old_roleid=%s,new_roleid=%s",
        account,appid,old_role.createServerId,new_serverid,old_roleid,new_roleid))
    if old_roleid == new_roleid then
        accountmgr.updaterole(appid,{roleid=new_roleid,createServerId=new_serverid})
    else
        accountmgr.delrole(appid,old_roleid,true)
        old_role.roleid = new_roleid
        accountmgr.addrole(account,appid,new_serverid,old_role)
    end
    return httpc.answer.code.OK
end

-- ""
function accountmgr.rebindaccount(new_account,appid,roleid)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    local new_accountobj = accountmgr.getaccount(new_account)
    if not new_accountobj then
        return httpc.answer.code.ACCT_NOEXIST
    end
    local role = accountmgr.getrole(appid,roleid)
    if not role then
        return httpc.answer.code.ROLE_NOEXIST
    elseif role.account == new_account then
        -- nochange
        return httpc.answer.code.OK
    end
    local old_account = role.account
    logger.logf("info","account",string.format("op=rebindaccount,appid=%s,roleid=%s,old_account=%s,new_account=%s",appid,roleid,old_account,new_account))
    accountmgr.delrole(appid,roleid,true)
    role.account = new_account
    accountmgr.addrole(new_account,appid,role.createServerId,role)
    return httpc.answer.code.OK
end

-- ""
function accountmgr.recover_role(appid,roleid)
    if not util.get_app(appid) then
        return httpc.answer.code.APPID_NOEXIST
    end
    local role = accountmgr.getrole(appid,roleid)
    if not role then
        return httpc.answer.code.ROLE_NOEXIST
    end
    local account = role.account
    local deleted_rolelist = accountmgr.get_deleted_roles(account,appid)
    local found_pos = table.find(deleted_rolelist,roleid)
    if not found_pos then
        return httpc.answer.code.ROLE_NOEXIST
    end
    logger.logf("info","account",string.format("op=recover_role,account=%s,appid=%s,roleid=%s",account,appid,roleid))
    local rolelist = accountmgr.getroles(account,roleid)
    table.remove(deleted_rolelist,found_pos)
    table.insert(rolelist,roleid)
    accountmgr.saveroles(account,appid,rolelist)
    accountmgr.save_deleted_roles(account,appid,deleted_rolelist)
    return httpc.answer.code.OK
end

--[[
--""
function accountmgr.getOrderReadyCnt(pid, dayno)
    local cnt = gg.mongoProxy.order_ready:findCount({pid=pid, dayno=dayno})
    return cnt
end
]]

function accountmgr.get_order(table_name,orderId)
    local doc = gg.mongoProxy[table_name]:findOne({orderId=orderId})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

-- ""
function accountmgr.ready_pay(param)
    local now = os.time()
    local orderId = accountmgr.genid("orderid","idkey","appid")

    local index = 1
    if gg.isAlphaServer() then
        index = 1
    elseif gg.isBetaServer() then
        index = 2
    elseif gg.isReleaseServer() then
        index = 3
    elseif gg.isZksyncServer() then
        index = 4
    end

    orderId = index .. now .. orderId
    orderId = tostring(orderId)

    local order = param
    order.createOrderTime = now
    order.orderId = orderId
    order.state = constant.PAY_STATE_0                  --0"",1"",2""
    order.dayno = gg.time.dayno()
    order.weekno = gg.time.weekno()
    order.monthno = gg.time.monthno()
    order.createTime = bson.date(now)
    order.createDate = tonumber(os.date("%Y%m%d", now))
    
    gg.mongoProxy.order_ready:insert(order)
    return order
end

-- ""
function accountmgr.settle_pay(orderId)
    local ok, ret, ret1 = gg.sync:once_do("order"..orderId, accountmgr.do_settle_pay, orderId)
    if not ok then
        return httpc.answer.code.FAIL, "fail"
    end
    return ret, ret1
end

function accountmgr.do_settle_pay(orderId)

    local order = accountmgr.get_order("order_ready",orderId)
    if not order then
        return httpc.answer.code.PAY_ORDER_NO_EXIST, "order error"
    end

    if order.state > constant.PAY_STATE_0 then
        return httpc.answer.code.OK, "succeed"
    end

    if order.transaction then
        local cnt = gg.mongoProxy.order_ready:findCount({ transaction = order.transaction})
        if cnt > 1 then
            return httpc.answer.code.PARAM_ERR, "order repeat"
        end
    end

    if not order.op or (order.op ~= constant.PAY_OP_GMAPPROVE and order.op ~= constant.PAY_OP_XSOLLACHECK and order.op ~= constant.PAY_OP_INTERNATIONCHECK) then
        --local""GM"",""
        if order.payChannel == constant.PAYCHANNEL_APPSTORE then
            --ios appstore""
            
            local receiptData = order.receiptData
            local account = order.account
            local orderId = order.orderId
            local productId = order.productId
             
            local ret, message = appstoremgr.verifyReceipt(receiptData, account, orderId, productId)
            if not ret then
                return httpc.answer.code.PAY_ORDER_VERIFY_INVALID, message
            end
            order.op = constant.PAY_OP_APPSTORECHECK
        elseif order.payChannel == constant.PAYCHANNEL_GOOGLEPLAY then
            --android googleplay""
            local signtureData = order.signtureData
            local signture = order.signture
            local account = order.account
            local orderId = order.orderId
            local productId = order.productId

            local ret, message = googleplaymgr.verifySignture(signtureData, signture, account, orderId, productId)
            if not ret then
                return httpc.answer.code.PAY_ORDER_VERIFY_INVALID, message
            end
            order.op = constant.PAY_OP_GOOGLEPLAYCHECK
        else
            return httpc.answer.code.PAY_ORDER_VERIFY_INVALID, "verify error"
        end
    end

    --""
    order.state = constant.PAY_STATE_1
    local now = os.time()
    order.settleOrderTime = now
    order.settledayno = gg.time.dayno()
    order.settleweekno = gg.time.weekno()
    order.settlemonthno = gg.time.monthno()
    order.settleDate = tonumber(os.date("%Y%m%d", now))

    gg.mongoProxy.order_ready:update({orderId = orderId}, order, false, false)
    gg.mongoProxy.order_settle:insert(order)

    return httpc.answer.code.OK, "success"
end

--[[
function accountmgr.settle_pay(order)
    if order.settling then
        return false,"settling"
    end
    local order_id = order.order_id
    order.settling = true
    gg.mongoProxy.finish_order:update({order_id=order_id},order,false,false)
    -- ""
    order.try_cnt = order.try_cnt + 1
    local gamePaybackHost = skynet.getenv("gamePaybackHost")
    local appkey = skynet.getenv("appkey")
    local gameserver = gg.gameserver(gamePaybackHost,appkey)
    local status,response = gameserver:payback(accountmgr.pack_order(order))
    order.settling = nil
    if status ~= 200 then
        return false,response
    end
    if response.code ~= httpc.answer.code.OK then
        return false,response
    end
    order.state = 3
    order.end_time = os.time()
    gg.mongoProxy.finish_order:delete({order_id = order_id},true)
    gg.mongoProxy.end_order:insert(order)
    return true
end
]]

--[[
-- ""
accountmgr.try_cnt_time = {5,15,30,60,300,600,1800,3600,7200,86400,172800}

function accountmgr.start_timer_settle_pay()
    accountmgr.timer_settle_pay = gg.timer:timeout(5,function ()
        accountmgr.start_timer_settle_pay()
    end)
    local now = os.time()
    local docs = gg.mongoProxy.finish_order:findSortLimit({}, {finish_time=-1}, 200)
    for _, order in pairs(docs) do
        order._id = nil
        local needTime = accountmgr.try_cnt_time[order.try_cnt] or -1
        local passTime = now - order.finish_time
        if needTime > 0 and passTime >= needTime then
            skynet.fork(function ()
                accountmgr.settle_pay(order)
            end)
        end
    end
end
]]

return accountmgr
