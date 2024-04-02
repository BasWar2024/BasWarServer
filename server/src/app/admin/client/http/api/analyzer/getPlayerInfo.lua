---""
--@module api.analyzer.getPlayerInfo
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/analyzer/getPlayerInfo
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
--  curl -v 'http://127.0.0.1:4241/api/analyzer/getPlayerInfo' -d '{"pid":1000000, "sign":"e10adc3949ba59abbe56e057f20f883e"}'


local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        adminAccount = {type="string"},
        sign = {type="string"},
        pid = {type="string"},
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
    
    local pid
    if string.checkEmail(request.pid) then
        local accountDoc = gg.mongoProxy.account:findOne({account = request.pid})
        if accountDoc then
            pid = accountDoc.roleid
        end
    else
        pid = tonumber(request.pid)
    end
    if not pid then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    
    local playerInfo = gg.playerProxy:call(pid, "getPlayerInfoByAdmin", true)
    if not playerInfo then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.ACCT_NOEXIST))
        return
    end
    for k,item in pairs(playerInfo.items) do
        local itemCfg = operationmgr.getItemCfg(item.cfgId)
        if itemCfg then
            item.name = itemCfg.name
        end
    end
    for k,build in pairs(playerInfo.nftBuilds) do
        local buildCfg = operationmgr.getBuildCfg(build.cfgId, build.quality, build.level)
        if buildCfg then
            build.name = buildCfg.name
            build.bscName = buildCfg.bscName
        end
    end
    for k,build in pairs(playerInfo.normalBuilds) do
        local buildCfg = operationmgr.getBuildCfg(build.cfgId, build.quality, build.level)
        if buildCfg then
            build.name = buildCfg.name
        end
    end
    for k,hero in pairs(playerInfo.nftHeros) do
        local heroCfg = operationmgr.getHeroCfg(hero.cfgId, hero.quality, hero.level)
        if heroCfg then
            hero.name = heroCfg.name
            hero.bscName = heroCfg.bscName
        end
        for i = 1, 3 do
            local skillCfgId = hero["skill" .. i] or 0
            local skillLevel = hero["skillLevel" .. i] or 0
            if skillCfgId > 0 then
                local skillCfg = operationmgr.getSkillCfg(skillCfgId, skillLevel)
                if skillCfg then
                    hero["skillName" .. i] = skillCfg.name
                end
            end
        end
    end
    for k,hero in pairs(playerInfo.normalHeros) do
        local heroCfg = operationmgr.getHeroCfg(hero.cfgId, hero.quality, hero.level)
        if heroCfg then
            hero.name = heroCfg.name
        end
        for i = 1, 3 do
            local skillCfgId = hero["skill" .. i] or 0
            local skillLevel = hero["skillLevel" .. i] or 0
            if skillCfgId > 0 then
                local skillCfg = operationmgr.getSkillCfg(skillCfgId, skillLevel)
                if skillCfg then
                    hero["skillName" .. i] = skillCfg.name
                end
            end
        end
    end
    for k,warShip in pairs(playerInfo.nftWarShips) do
        local warShipCfg = operationmgr.getWarShipCfg(warShip.cfgId, warShip.quality, warShip.level)
        if warShipCfg then
            warShip.name = warShipCfg.name
            warShip.bscName = warShipCfg.bscName
        end
        for i = 1, 4 do
            local skillCfgId = warShip["skill" .. i] or 0
            local skillLevel = warShip["skillLevel" .. i] or 0
            if skillCfgId > 0 then
                local skillCfg = operationmgr.getSkillCfg(skillCfgId, skillLevel)
                if skillCfg then
                    warShip["skillName" .. i] = skillCfg.name
                end
            end
        end
    end
    for k,warShip in pairs(playerInfo.normalWarShips) do
        local warShipCfg = operationmgr.getWarShipCfg(warShip.cfgId, warShip.quality, warShip.level)
        if warShipCfg then
            warShip.name = warShipCfg.name
        end
        for i = 1, 4 do
            local skillCfgId = warShip["skill" .. i] or 0
            local skillLevel = warShip["skillLevel" .. i] or 0
            if skillCfgId > 0 then
                local skillCfg = operationmgr.getSkillCfg(skillCfgId, skillLevel)
                if skillCfg then
                    warShip["skillName" .. i] = skillCfg.name
                end
            end
        end
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.data = playerInfo
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