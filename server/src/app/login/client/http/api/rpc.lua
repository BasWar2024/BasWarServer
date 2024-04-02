---rpc""
--@module login.api.rpc
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
--api:      /api/rpc
--protocol: http/https
--method:   post
--params:
--  type=table encode=json
--  {
--      module     [optional] type=string help="",""_G""
--      cmd         [required] type=string help=""
--      args        [required] type=list encode=json help=""
--  }
--return:
--  type=table encode=json
--  {
--      code =      [required] type=number help=""
--      message =   [required] type=number help=""
--      result =    [required] type=list help=""
--  }
--example:
--  curl -v 'http://127.0.0.1:4000/api/rpc' -d '{"sign":"debug","cmd":"tonumber","args":"[\"10\"]"}'
--  curl -v 'http://127.0.0.1:4000/api/rpc' -d '{"sign":"debug","cmd":"logger.log","args":"[\"error\",\"client_error\",\"msg\"]"}'

local handler = {}

function handler.exec(linkobj,header,args)
    local request,err = table.check(args,{
        sign = {type="string"},
        module = {type="string",optional=true},
        cmd = {type="string"},
        args = {type="json"},
    })
    if err then
        local response = httpc.answer.response(httpc.answer.code.PARAM_ERR)
        response.message = string.format("%s|%s",response.message,err)
        httpc.send_json(linkobj,200,response)
        return
    end
    local appkey = skynet.getenv("appkey")
    if not httpc.check_signature(args.sign,args,appkey) then
        httpc.send_json(linkobj,200,httpc.answer.response(httpc.answer.code.SIGN_ERR))
        return
    end
    local module = request.module
    local cmd = request.cmd
    local args = request.args
    if module == nil then
        module = _G
    end
    local response = httpc.answer.response(httpc.answer.code.OK)
    response.result = {
        gg.exec(module,cmd,table.unpack(args)),
    }
    httpc.send_json(linkobj,200,response)
end

function handler.GET(linkobj,header,query,body)
    local args = urllib.parse_query(query)
    --handler.exec(linkobj,header,args)

    local function write_union_rank_data(maxData)
        local data = {}
        for i = 1, 20, 1 do
            local rmem = maxData.rankMembers[i]
            if rmem then
                local uniondoc = gg.mongoProxy.union:findOne({unionId = rmem.unionId})
                if uniondoc then
                    for k, member in pairs(uniondoc.members) do
                        if member.unionJob == constant.UNION_JOB_PRESIDENT then
                            local info = {}
                            info.rank = i
                            info.unionId = rmem.unionId
                            info.unionName = uniondoc.unionName
                            info.presidentPId = member.playerId
                            info.presidentName = member.playerName
                            local info1 = gg.mongoProxy.account:findOne({roleid=member.playerId})
                            if info1 then
                                info.account = info1.account
                                info.owner_address = info1.owner_address
                            end
                            table.insert(data, info)
                            break
                        end
                    end
                end
            end
        end
        local file = io.open("./beta_union_rank.csv", "w+")
        file:write(""",""id,"",""ID,"","",""\n")
        for i, v in ipairs(data) do
            local fields = {}
            table.insert(fields, v.rank or 0)
            table.insert(fields, v.unionId or 0)
            table.insert(fields, v.unionName or "")
            table.insert(fields, v.presidentPId or 0)
            table.insert(fields, v.account or "")
            table.insert(fields, v.presidentName or "")
            table.insert(fields, v.owner_address or "")
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()
    end

    local function write_pvp_rank_data(maxData)
        local data = {}
        for i = 1, 100, 1 do
            local rmem = maxData.rankMembers[i]
            if rmem then
                local info = {}
                info.rank = i
                info.playerId = rmem.playerId
                info.playerScore = rmem.playerScore
                info.playerName = rmem.playerName
                local info1 = gg.mongoProxy.account:findOne({roleid = rmem.playerId})
                if info1 then
                    info.account = info1.account
                    info.owner_address = info1.owner_address
                end
                table.insert(data, info)
            end
        end
        local file = io.open("./beta_pvp_rank.csv", "w+")
        file:write(""",""id,"","","",""\n")
        for i, v in ipairs(data) do
            local fields = {}
            table.insert(fields, v.rank or 0)
            table.insert(fields, v.playerId or 0)
            table.insert(fields, v.playerName or "")
            table.insert(fields, v.playerScore or 0)
            table.insert(fields, v.account or "")
            table.insert(fields, v.owner_address or "")
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()
    end

    local function get_match_rank_info(match_cfg_id, belong, match_type)
        local match_cfg
        local match_cfgs = gg.shareProxy:call("getDynamicCfg", "MatchConfig")
        if not match_cfgs then
            local file = io.open("./errordata.txt", "w+")
            file:write("match_cfgs is nil\n")
            file:close()
            return
        end
        if match_cfg_id then
            match_cfg_id = tonumber(match_cfg_id)
        end
        belong = tonumber(belong)
        match_type = tonumber(match_type)
        local max_cfg_id = 0
        for k, v in pairs(match_cfgs) do
            if match_cfg_id then
                if v.cfgId == match_cfg_id and v.belong == belong and v.matchType == match_type then
                    match_cfg = v
                    break
                end
            else
                if v.belong == belong and v.matchType == match_type then
                    if v.cfgId > max_cfg_id then
                        max_cfg_id = v.cfgId
                        match_cfg = v
                    end
                end
            end
        end
        if not match_cfg then
            local file = io.open("./errordata.txt", "w+")
            file:write("match_cfg is nil\n")
            file:close()
            return
        end
        local matchdoc = gg.mongoProxy.match:findOne({ cfgId = match_cfg.cfgId })
        if not matchdoc then
            local file = io.open("./errordata.txt", "w+")
            file:write("matchdoc is nil\n")
            file:close()
            return
        end
        local maxVer = 0
        local maxData
        for k, v in pairs(matchdoc.rankVersions or {}) do
            if v.ver > maxVer then
                maxVer = v.ver
                maxData = v
            end
        end
        if not maxData then
            local file = io.open("./errordata.txt", "w+")
            file:write("rankVersion is nil\n")
            file:close()
            return
        end
        if belong == constant.MATCH_BELONG_UNION then
            write_union_rank_data(maxData)
        else
            write_pvp_rank_data(maxData)
        end
    end

    local function get_hy_rank_info()
        local text = gg.redisProxy:call("get",constant.REDIS_RANK_GET_HYDROXYL_CUR)
        local data = {}
        if text then
            data = cjson.decode(text)
        end
        for i, v in ipairs(data) do
            if i <= 150 then
                local info1 = gg.mongoProxy.account:findOne({roleid=v.pid})
                if info1 then
                    v.account = info1.account
                    v.owner_address = info1.owner_address
                end
            end 
        end
        local file = io.open("./beta_ply_hy_get.csv", "w+")
        file:write(""","",""ID,"","",""\n")
        for i, v in ipairs(data) do
            if i <= 150 then
                local fields = {}
                table.insert(fields, i)
                table.insert(fields, v.account or "")
                table.insert(fields, v.pid or 0)
                table.insert(fields, v.name or "")
                table.insert(fields, v.owner_address or "")
                table.insert(fields, v.score or 0)
                file:write(table.concat(fields, ",") .. "\n")
            end
        end
        file:close()
    end

    local function get_union_hy_rank_info()
        local text = gg.redisProxy:call("get",constant.REDIS_RANK_UNION_GET_HYDROXYL_CUR)
        local data = {}
        local wdata = {}
        if text then
            data = cjson.decode(text)
        end
        for i, v in ipairs(data) do
            if i <= 20 then
                local uniondoc = gg.mongoProxy.union:findOne({unionId = v.unionId})
                if uniondoc then
                    for k, member in pairs(uniondoc.members) do
                        if member.unionJob == constant.UNION_JOB_PRESIDENT then
                            local info = {}
                            info.rank = i
                            info.unionId = v.unionId
                            info.unionName = uniondoc.unionName
                            info.presidentPId = member.playerId
                            info.presidentName = member.playerName
                            local info1 = gg.mongoProxy.account:findOne({roleid=member.playerId})
                            if info1 then
                                info.account = info1.account
                                info.owner_address = info1.owner_address
                            end
                            table.insert(wdata, info)
                            break
                        end
                    end
                end
            end
        end
        local file = io.open("./beta_union_hy_get.csv", "w+")
        file:write(""",""id,"",""ID,"","",""\n")
        for i, v in ipairs(data) do
            local fields = {}
            table.insert(fields, v.rank or 0)
            table.insert(fields, v.unionId or 0)
            table.insert(fields, v.unionName or "")
            table.insert(fields, v.presidentPId or 0)
            table.insert(fields, v.account or "")
            table.insert(fields, v.presidentName or "")
            table.insert(fields, v.owner_address or "")
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()
    end

    local text = ""
    if args.correct == "1" then
        get_match_rank_info(args.starmatchid, args.belong, constant.MATCH_TYPE_SEASON)
    elseif args.correct == "2" then
        local docs = gg.mongoProxy.role:find({})
        for k, v in pairs(docs) do
            local name = v.name
            local headIcon = v.headIcon
            local createTime = v.createTime
            local level = 1
            local plyDoc = gg.mongoProxy.player:findOne({pid = v.roleid})
            if plyDoc then
                name = plyDoc.property.name
                headIcon = plyDoc.property.headIcon
                createTime = plyDoc.property.createTime
                level = plyDoc.property.level
            end
            gg.shareProxy:send("setPlayerBaseInfo", v.roleid, { 
                name = name,
                currentServerId = v.currentServerId,
                headIcon = headIcon,
                createTime = createTime,
                level = level,
                protectTick = 0,
            } )
        end
    elseif args.correct == "3" then
        text = " beta_ply_hy_get"
        get_hy_rank_info()
    elseif args.correct == "4" then
        
        --""3
        get_match_rank_info(args.starmatchid, constant.MATCH_BELONG_UNION, constant.MATCH_TYPE_SEASON)

        --""4,""15""。
        local data4 = {}
        local docs = gg.mongoProxy.account:find({owner_address={["$exists"] = true}})
        for k, v in pairs(docs) do
            local info = {}
            info.account = v.account
            info.chain_id = v.chain_id
            info.owner_address = v.owner_address
            info.roleid = v.roleid
            table.insert(data4, info)
        end
        for _, v in pairs(data4) do
            if v.roleid then
                v.level = gg.shareProxy:call("getPlayerBaseInfo", v.roleid, "level", 1)
                v.level = math.floor(tonumber(v.level))
                v.name = gg.shareProxy:call("getPlayerBaseInfo", v.roleid, "name", "")
            end
        end
        local file = io.open("./betaII_4.csv", "w+")
        file:write(""",""ID,"","",""\n")
        for i, v in ipairs(data4) do
            local fields = {}
            table.insert(fields, v.account or "")
            table.insert(fields, v.roleid or 0)
            table.insert(fields, v.name or "")
            table.insert(fields, v.owner_address or "")
            table.insert(fields, v.level or 1)
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()

        --""5
        local text = gg.redisProxy:call("get","MatchRankBadgeCur")
        local data5 = {}
        if text then
            data5 = cjson.decode(text)
        end
        for i, v in ipairs(data5) do
            if i <= 150 then
                local info1 = gg.mongoProxy.account:findOne({roleid=v.pid})
                if info1 then
                    v.account = info1.account
                    v.owner_address = info1.owner_address
                end
            end 
        end
        local file = io.open("./betaII_5.csv", "w+")
        file:write("pvp"","",""ID,"","",pvp""\n")
        for i, v in ipairs(data5) do
            if i <= 150 then
                local fields = {}
                table.insert(fields, i)
                table.insert(fields, v.account or "")
                table.insert(fields, v.pid or 0)
                table.insert(fields, v.name or "")
                table.insert(fields, v.owner_address or "")
                table.insert(fields, v.score or 0)
                file:write(table.concat(fields, ",") .. "\n")
            end
        end
        file:close()

        --""1
        local data1 = {}
        for i, v in ipairs(data4) do
            if v.level and v.level >= 15 then
                local docs = gg.mongoProxy.rechargeNft:find({pid=v.roleid})
                local all_token_ids = {}
                for kk, vv in pairs(docs) do
                    if vv.token_ids and next(vv.token_ids) and vv.message == "success" then
                        for _, token_id in pairs(vv.token_ids) do
                            table.insert(all_token_ids, token_id)
                        end
                    end
                end
                for _, token_id in ipairs(all_token_ids) do
                    local nft = gg.mongoProxy.nftInfo:findOne({token_id=token_id})
                    if nft then
                        local info2 = {}
                        info2.account = v.account
                        info2.roleid = v.roleid
                        info2.name = v.name
                        info2.owner_address = v.owner_address
                        info2.level = v.level
                        info2.tokenid = token_id
                        info2.kind = nft.kind
                        info2.quality = nft.quality
                        info2.style = nft.style
                        table.insert(data1, info2)
                    end
                end
            end
        end
        local file = io.open("./betaII_1.csv", "w+")
        file:write(""",""ID,"","","",tokenid,kind(1""/2""/3""),quality(1N/2R/3SR/4SSR/5L),style\n")
        for i, v in ipairs(data1) do
            local fields = {}
            table.insert(fields, v.account or "")
            table.insert(fields, v.roleid or 0)
            table.insert(fields, v.name or "")
            table.insert(fields, v.owner_address or "")
            table.insert(fields, v.level or 1)
            table.insert(fields, v.tokenid or 0)
            table.insert(fields, v.kind or 0)
            table.insert(fields, v.quality or 0)
            table.insert(fields, v.style or 0)
            file:write(table.concat(fields, ",") .. "\n")
        end
        file:close()
    elseif args.correct == "5" then
        text = " beta_union_hy_get"
        get_union_hy_rank_info()
    end

    httpc.send_json(linkobj,200,"connect success:" .. tostring(skynet.config.clusterid) .. text)
end

function handler.POST(linkobj,header,query,body)
    local args = cjson.decode(body)
    handler.exec(linkobj,header,args)
end

function __hotfix(module)
    gg.client:open()
end

return handler
