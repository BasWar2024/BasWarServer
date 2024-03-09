---
--@module accountmgr
--@usage
--mongo
--: role =>  {roleid=xxx,appid=xxx,account=xxx,createServerId=xxx,...}
--: account => {account=xxx,passwd=xxx,sdk=xxx,platform=xxx,...}
--: account_roles => {account=xxx,appid=xxx,roles={ID}}
--: account_deleted_roles => {account=xxx,appid=xxx,roles={ID}}


accountmgr = accountmgr or {}

function accountmgr.addaccountalias(alias,account)
    assert(account)
    local data = {
        alias = alias,
        account = account,
        createTime = os.time(),
    }
    local db = gg.dbmgr:getdb()
    db.accountalias:update({alias=alias},data,true,false)
end

function accountmgr.getrealaccount(account)
    local db = gg.dbmgr:getdb()
    local doc = db.accountalias:findOne({alias=account})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc.account
    end
end

function accountmgr.saveaccount(accountobj)
    local db = gg.dbmgr:getdb()
    local account = assert(accountobj.account)
    db.account:update({account=account},accountobj,true,false)
end

function accountmgr.getaccount(account)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local db = gg.dbmgr:getdb()
    local doc = db.account:findOne({account=account})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

--/*
-- accountobj: {account=,passwd=,sdk=sdk,platform=,...}
--*/
function accountmgr.addaccount(accountobj)
    local account = assert(accountobj.account)
    local has_accountobj = accountmgr.getaccount(account)
    if has_accountobj then
        return httpc.answer.code.ACCT_EXIST
    end
    accountobj.createTime = os.time()
    logger.logf("info","account",string.format("op=addaccount,accountobj=%s",cjson.encode(accountobj)))
    accountmgr.saveaccount(accountobj)
    return httpc.answer.code.OK
end

function accountmgr.delaccount(account)
    local accountobj = accountmgr.getaccount(account)
    if accountobj then
        logger.logf("info","account",string.format("op=delaccount,account=%s",account))
        local db = gg.dbmgr:getdb()
        db.player:delete({account=account})
        return httpc.answer.code.OK
    end
    return httpc.answer.code.ACCT_NOEXIST
end

-- ID
function accountmgr.getroles(account,appid)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local db = gg.dbmgr:getdb()
    local doc = db.account_roles:findOne({account=account,appid=appid})
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
    local db = gg.dbmgr:getdb()
    local cursor = db.role:find({account=account,appid=appid})
    local docs = {}
    while cursor:hasNext() do
        local doc = cursor:next()
        doc._id = nil
        table.insert(docs,doc)
    end
    return docs
end

-- roles: ID
function accountmgr.saveroles(account,appid,roles)
    assert(roles ~= nil)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local db = gg.dbmgr:getdb()
    local doc = {account=account,appid=appid,roles=roles}
    db.account_roles:update({account=account,appid=appid},doc,true,false)
end

-- 
-- roles: ID
function accountmgr.save_deleted_roles(account,appid,roles)
    assert(roles ~= nil)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local db = gg.dbmgr:getdb()
    local doc = {account=account,appid=appid,roles=roles}
    db.account_deleted_roles:update({account=account,appid=appid},doc,true,false)
end

-- ID
function accountmgr.get_deleted_roles(account,appid)
    local realaccount = accountmgr.getrealaccount(account)
    if realaccount then
        account = realaccount
    end
    local db = gg.dbmgr:getdb()
    local doc = db.account_deleted_roles:findOne({account=account,appid=appid})
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
    if not accountmgr.getaccount(account) then
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
    local db = gg.dbmgr:getdb()
    --db.role:update({appid=appid,roleid=roleid},role,true,false)
    db.role:insert(role)
    table.insert(rolelist,roleid)
    accountmgr.saveroles(account,appid,rolelist)
    return httpc.answer.code.OK
end

function accountmgr.getrole(appid,roleid)
    local db = gg.dbmgr:getdb()
    local doc = db.role:findOne({appid=appid,roleid=roleid})
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
        local db = gg.dbmgr:getdb()
        db.role:delete({appid=appid,roleid=roleid},true)
    else
        local deleted_rolelist = accountmgr.get_deleted_roles(account,appid)
        table.insert(deleted_rolelist,roleid)
        accountmgr.save_deleted_roles(account,appid,deleted_rolelist)
    end
    table.remove(rolelist,found_pos)
    accountmgr.saveroles(account,appid,rolelist)
    return httpc.answer.code.OK
end

-- 
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
    local db = gg.dbmgr:getdb()
    db.role:update({appid=appid,roleid=roleid},role,true,false)
    return httpc.answer.code.OK,role
end

-- id
function accountmgr.genid(table_name,idkey,appid)
    local db = gg.dbmgr:getdb()
    local doc = db[table_name]:findAndModify({
        query = {appid=appid,idkey=idkey},
        update = {["$inc"] = {sequence = 1}},
        new = true,
        upsert = true,
    })
    return doc.value.sequence
end

-- : [minroleid,maxroleid)
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

function accountmgr.gentoken(input)
    local prefix = string.format("loginserver.%s.",skynet.hpc())
    local token = prefix .. string.randomkey(8)
    return token
end

function accountmgr.gettoken(token)
    return gg.thistemp:get(token)
end

function accountmgr.addtoken(token,data,expire)
    expire = expire or 300
    gg.thistemp:set(token,data,expire)
end

function accountmgr.deltoken(token)
    gg.thistemp:del(token)
end


-- 
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

-- 
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

-- 
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

function accountmgr.get_order(table_name,order_id)
    local db = gg.dbmgr:getdb()
    local doc = db[table_name]:findOne({order_id=order_id})
    if doc == nil then
        return nil
    else
        doc._id = nil
        return doc
    end
end

function accountmgr.update_order(table_name,order)
    local db = gg.dbmgr:getdb()
    db[table_name]:update({order_id=order.order_id},order,false,false)
end

function accountmgr.insert_order(table_name,order)
    local db = gg.dbmgr:getdb()
    db[table_name]:insert(order)
end

function accountmgr.del_order(table_name,order_id)
    local db = gg.dbmgr:getdb()
    db[table_name]:delete({order_id = order_id},true)
end

-- 
function accountmgr.ready_pay(appid,openid,server_id,roleid,product_id,quantity,rmb,platform,sdk,ext)
    local now = os.time()
    local order_id = accountmgr.genid("orderid","idkey","appid")
    order_id = string.format("%d%011d",now,order_id)
    local account = string.format("%s@%s",openid,platform)
    local order = {
        create_time = now,
        appid = appid,
        openid = openid,
        account = account,
        platform = platform,
        sdk = sdk,
        server_id = server_id,
        roleid = roleid,
        product_id = product_id,
        quantity = quantity,
        rmb = rmb,  -- rmb(:)
        order_id = order_id,
        state = 1,
        ext = ext,
    }
    local db = gg.dbmgr:getdb()
    db.ready_order:insert(order)
    return order
end

-- 
function accountmgr.finish_pay(order_id,platform_order_id,platform_order)
    local order = accountmgr.get_order("ready_order",order_id)
    if not order then
        return false
    end
    order.state = 2
    order.finish_time = os.time()
    order.try_cnt = 1
    order.platform_order_id = platform_order_id
    -- 
    order.platform_order = platform_order
    local db = gg.dbmgr:getdb()
    db.ready_order:delete({order_id = order_id},true)
    db.finish_order:insert(order)
    local appid = order.appid
    local account = order.account
    local roleid = order.roleid
    local rmb = order.rmb
    accountmgr.stat_pay(appid,account,roleid,rmb)
    accountmgr.settle_pay(order)
end

-- 
function accountmgr.stat_pay(appid,account,roleid,rmb)
    local role = accountmgr.getrole(appid,roleid)
    if not role then
        return
    end
    accountmgr.updaterole(appid,{
        roleid = roleid,
        rmb = (role.rmb or 0) + rmb,
    })
end

function accountmgr.pack_order(order)
    return {
        account = order.account,
        openid = order.openid,
        server_id = order.server_id,
        roleid= order.roleid,
        platform = order.platform,
        sdk = order.sdk,
        product_id = order.product_id,
        rmb = order.rmb,
        order_id = order.order_id,
        platform_order_id = order.platform_order_id,
        create_time = order.create_time,
        finish_time = order.finish_time,
        quantity = order.quantity,
        ext = order.ext,
    }
end

function accountmgr.settle_pay(order)
    if order.settling then
        return false,"settling"
    end
    local order_id = order.order_id
    order.settling = true
    local db = gg.dbmgr:getdb()
    db.finish_order:update({order_id=order_id},order,false,false)
    -- 
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
    local db = gg.dbmgr:getdb()
    db.finish_order:delete({order_id = order_id},true)
    db.end_order:insert(order)
    return true
end

-- 
accountmgr.try_cnt_time = {5,15,30,60,300,600,1800,3600,7200,86400,172800}

function accountmgr.start_timer_settle_pay()
    accountmgr.timer_settle_pay = gg.timer:timeout(5,function ()
        accountmgr.start_timer_settle_pay()
    end)
    local now = os.time()
    local db = gg.dbmgr:getdb()
    local cursor = db.finish_order:find():sort({finish_time=-1}):limit(200)
    while cursor:hasNext() do
        local order = cursor:next()
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

return accountmgr
