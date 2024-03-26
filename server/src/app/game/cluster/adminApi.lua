local api = gg.api


function api.createRobot(cfgId, robotid, seq)
    local presetRobotCfgs = cfg.get("etc.cfg.presetRobot")
    if not presetRobotCfgs[cfgId] then
        return
    end
    local robotCfg = gg.deepcopy(presetRobotCfgs[cfgId])
    local roleid = 0
    if robotid and robotid < 1000 then
        roleid = robotid
    end
    if roleid == 0 then
        roleid = gg.shareProxy:call("genRoleId")
    end

    if not seq then
        seq = gg.shareProxy:call("genRobotAccountSeq", robotCfg.mailPrefix)
    end
    local account = robotCfg.mailPrefix .. seq .. robotCfg.mail
    local password = string.lower(md5.sumhexa16(robotCfg.password.."starwar"))
    local roleName = robotCfg.roleNamePrefix..roleid
    
    --""
    robotCfg.initData.account.passwd = password
    robotCfg.initData.account.openid = account
    robotCfg.initData.account.account = account
    gg.mongoProxy.account:update({account=account}, robotCfg.initData.account, true, false)

    --""
    robotCfg.initData.account_roles.account = account
    robotCfg.initData.account_roles.roles[1] = roleid
    gg.mongoProxy.account_roles:update({account=account,appid=skynet.config.appid}, robotCfg.initData.account_roles, true, false)

    --""
    robotCfg.initData.role.account = account
    robotCfg.initData.role.createServerId = robotCfg.initGameServer
    robotCfg.initData.role.roleid = roleid
    robotCfg.initData.role.name = roleName
    robotCfg.initData.role.headIcon = robotCfg.headIcon
    robotCfg.initData.role.currentServerId = robotCfg.initGameServer
    gg.mongoProxy.role:update({roleid=roleid}, robotCfg.initData.role, true, false)

    --""
    robotCfg.initData.brief.pid =  roleid
    robotCfg.initData.brief.node = robotCfg.initGameServer
    robotCfg.initData.brief.id = snowflake.uuid()
    robotCfg.initData.brief.name = roleName
    robotCfg.initData.brief.currentServerId = robotCfg.initGameServer
    robotCfg.initData.brief.account = account
    gg.mongoProxy.brief:update({pid=roleid}, robotCfg.initData.brief, true, false)

    --""
    robotCfg.initData.player.pid = roleid
    robotCfg.initData.player.property.account = account
    robotCfg.initData.player.property.name = roleName
    robotCfg.initData.player.property.headIcon = robotCfg.headIcon
    robotCfg.initData.player.property.createServerId = robotCfg.initGameServer
    robotCfg.initData.player.property.gm = robotCfg.gm

    --""
    local heroid = 0
    for k, v in pairs(robotCfg.initData.player.heroBag.heros) do
        v.id = snowflake.uuid()
        heroid = v.id
    end
    robotCfg.initData.player.heroBag.useId = heroid

    --""
    local warShipId = 0
    for k, v in pairs(robotCfg.initData.player.warShipBag.warShips) do
        v.id = snowflake.uuid()
        warShipId = v.id
    end
    robotCfg.initData.player.warShipBag.useId = warShipId

    --""
    for k, v in pairs(robotCfg.initData.player.buildBag.builds) do
        v.id = snowflake.uuid()
    end
    
    --""
    if robotCfg.starCoin > 0 then
        robotCfg.initData.player.resBag.resources[tostring(constant.RES_STARCOIN)] = {bindNum = 0, num = robotCfg.starCoin}
    end

    if robotCfg.ice > 0 then
        robotCfg.initData.player.resBag.resources[tostring(constant.RES_ICE)] = {bindNum = 0, num = robotCfg.ice}
    end

    if robotCfg.titanium > 0 then
        robotCfg.initData.player.resBag.resources[tostring(constant.RES_TITANIUM)] = {bindNum = 0, num = robotCfg.titanium}
    end

    if robotCfg.gas > 0 then
        robotCfg.initData.player.resBag.resources[tostring(constant.RES_GAS)] = {bindNum = 0, num = robotCfg.gas}
    end

    if robotCfg.carboxyl > 0 then
        robotCfg.initData.player.resBag.resources[tostring(constant.RES_CARBOXYL)] = {bindNum = 0, num = robotCfg.carboxyl}
    end
    gg.mongoProxy.player:update({pid=roleid}, robotCfg.initData.player, true, false)

    local robotInfo = {
        roleName = roleName,
        roleid = roleid,
        account = account,
        password = robotCfg.password,
        gm = robotCfg.gm,
        createServerId = robotCfg.initGameServer
    }
    gg.mongoProxy.robot:update({pid=roleid}, robotInfo, true, false)

    gg.shareProxy:call("setPlayerBaseInfo", roleid, {
        name = roleName,
        headIcon = robotCfg.initData.role.headIcon,
        currentServerId = robotCfg.initGameServer,
    })
    local player = gg.playermgr:loadplayer(roleid)
    if player then
        player.buildBag:createPresetBuilds(robotCfg.buildLayoutId)
    end

    return robotInfo
end


return api