--""
--@module api.dapp.getPlayerStoreBag
--@author sw
--@release 2022/3/12 10:30:00
--@usage
--api:      /api/dapp/getPlayerStoreBag
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
--  curl -v 'http://127.0.0.1:4241/api/dapp/getPlayerStoreBag' -d '{"mail":"test1@qq.com"}'


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
    local doc = gg.mongoProxy.role:findOne({account = mail})
    if not doc then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.MAIL_NOT_CREATE_PLAYER))
        return
    end

    local ret = analyzermgr.getPlayerDataList({ account = mail }, true)
    local playerInfo = ret[1]
    if not playerInfo then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SERVER_ERR))
        return
    end

    local result = {}
    result.mit = playerInfo.mit
    result.carboxyl = playerInfo.carboxyl
    result.nftItems = {}
    for k,build in pairs(playerInfo.nftBuilds) do
        build.kind = constant.CHAIN_BRIDGE_NFT_KIND_DEFENSIVE
        local buildCfg = operationmgr.getBuildCfg(build.cfgId, build.quality, build.level)
        if buildCfg then
            build.name = buildCfg.name
            build.bscName = buildCfg.bscName
        end
        table.insert(result.nftItems, build)
    end
    for k,hero in pairs(playerInfo.nftHeros) do
        hero.kind = constant.CHAIN_BRIDGE_NFT_KIND_HERO
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
        table.insert(result.nftItems, hero)
    end
    for k,warShip in pairs(playerInfo.nftWarShips) do
        warShip.kind = constant.CHAIN_BRIDGE_NFT_KIND_SPACESHIP
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
        table.insert(result.nftItems, warShip)
    end
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