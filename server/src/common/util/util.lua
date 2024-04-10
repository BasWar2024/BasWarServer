util = util or {}

function util.combinedGene(quality, race, style)
    local genes = 0
    genes = genes << 16
    genes = genes | quality

    genes = genes << 16
    genes = genes | race

    genes = genes << 16
    genes = genes | style

    return genes
end

function util.randomWalletAddress()
    local word = {"0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f"}
    local uuid = snowflake.uuid()
    local text = tostring(uuid)
    local len = #text
    for i = len + 1 , 40 do
        text = text .. word[math.random(1, #word)]
    end
    return text
end

function util.i18nFormat(err, ...)
    if type(err) == "string" then
        return i18n.format(err, ...)
    end
    assert(type(err) == "table", "err format error")
    local errText = assert(err.msg, "err.msg not exist")
    local content = i18n.format(errText, ...)
    return content, err.id
end

function util.packSceneId(nodeIndex,address)
    return skynet.globaladdress(nodeIndex,address)
end

function util.unpackSceneId(sceneId)
    local nodeIndex = skynet.nodeid(sceneId)
    local nodeId = snowflake.node(nodeIndex)
    local address = skynet.localaddress(sceneId)
    return nodeId,address
end

function util.getSceneProxy(sceneId)
    local sceneNode,sceneAddress = util.unpackSceneId(sceneId)
    local proxy = gg.getProxy(sceneNode,sceneAddress)
    proxy.sceneId = sceneId
    return proxy
end

function util.configScene(mapId,joinPlayers)
    if joinPlayers then
        for i,joinPlayer in ipairs(joinPlayers) do
            local brief = gg.briefMgr:getBrief(joinPlayer.pid)
            table.update(joinPlayer,{
                uuid = brief.uuid,
                name = brief.name,
                loadProgress = 0,
            })
        end
    end
    return {
        mapId = mapId,
        joinPlayers = joinPlayers,
    }
end

util.bornLocation = {
    mapId = 1,
    pos = {x=0,y=0,z=0},
    lookAt = {x=0,y=0,z=1},
}

if not util.vec360 then
    util.vec360 = {}
    for i=1,360 do
        local angle = i*math.deg2Rad
        local pos = util.vec360[i]
        if pos then
            pos.x,pos.y,pos.z = math.sin(angle),0,math.cos(angle)
        else
            util.vec360[i] = Vector3.New(math.sin(angle),0,math.cos(angle))
        end
    end
end

function util.randomPointInCircle(origin,minRadius,maxRadius)
    local distance = math.random(minRadius,maxRadius)
    local angle =  math.random(360)
    return origin +  util.vec360[angle]*distance
end

function util.syncBuildBagToBuildMgr(pid, data)
    local syncDate = {}
    syncDate.pid = pid
    syncDate.builds = {}
    for _, buildData in ipairs(data.builds) do
        if buildData.cfgId == constant.BUILD_BASE then
            syncDate.base_level = buildData.level
        end
        local temp = {}
        temp.id = buildData.id
        temp.cfgId = buildData.cfgId
        temp.quality = buildData.quality
        temp.level = buildData.level
        temp.x = buildData.x
        temp.z = buildData.z
        table.insert(syncDate.builds, temp)
    end
    return syncDate
end

function util.betweenTime(time1, time2)
    local now = gg.time.time()
    if now < time1 then
        return false
    end
    if now > time2 then
        return false
    end
    return true
end

function util.betweenCfgTime(cfg, timeK1, timeK2)
    local time1 = string.totime(cfg[timeK1])
    local time2 = string.totime(cfg[timeK2])
    return util.betweenTime(time1, time2)
end
----------------------------------------------------
util.PRINT_MAP_GRID = false
function util.getBoundsMapGrids(inData)
    local minX = inData.minX or constant.MAP_GRID_MIN
    local maxX = inData.maxX or constant.MAP_GRID_MAX
    local minZ = inData.minZ or constant.MAP_GRID_MIN
    local maxZ = inData.maxZ or constant.MAP_GRID_MAX
    return {
        minX = minX,
        maxX = maxX,
        minZ = minZ,
        maxZ = maxZ,
    }
end

function util.printMapGrids(inData)
    local bounds = util.getBoundsMapGrids(inData)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    local str = ""
	for i = minX, maxX, 1 do
		for j = minZ, maxZ, 1 do
            if inData.grids[i][j] ~= 0 then
                str = str .. "*".."-"
            else
                str = str .. inData.grids[i][j].."-"
            end
		end
		str = str .. "\n"
	end
	print(str)
end

function util.initMapGrids(inData)
    local bounds = util.getBoundsMapGrids(inData)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    for i = minX, maxX, 1 do
		inData.grids[i] = {}
		for j = minZ, maxZ, 1 do
			inData.grids[i][j] = 0
		end
	end
    for _,build in pairs(inData.builds) do
        if build.x > 0 and build.z > 0 then
            for i = build.x, build.x + build.length - 1, 1 do
                assert(i <= maxX, "util.initMapGrids build x > maxX, i="..i)
                inData.grids[i] = inData.grids[i] or {}
                for j = build.z, build.z + build.width - 1, 1 do
                    assert(j <= maxZ, "util.initMapGrids build z > maxZ, j="..j)
                    inData.grids[i][j] = build.id
                end
            end
        else
            if inData.landShipGrids then
                for i, shipPos in ipairs(constant.BUILD_LIBERATORSHIPPOSLIST) do
                    if shipPos[1] == build.x and shipPos[2] == build.z then
                        inData.landShipGrids[i] = build.id
                    end
                end
            end
        end
    end
    if util.PRINT_MAP_GRID then
        util.printMapGrids(inData)
    end
end

function util.canPlaceMapGrids(inData)
    local bounds = util.getBoundsMapGrids(inData)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    local pos = inData.pos
    local length = inData.length
    local width = inData.width
    if pos.x < minX or pos.x > maxX or pos.z < minZ or pos.z > maxZ then
        -- logger.debug("game","util.canPlaceMapGrids-11, pos=%s, length=%s, width=%s",table.dump(pos), length, width)
		return
	end
	for i = pos.x, pos.x + length - 1, 1 do
		for j = pos.z, pos.z + width - 1, 1 do
            if i > maxX or j > maxZ then
                return
            end
			if inData.grids[i][j] ~= 0 then
                -- logger.debug("game","util.canPlaceMapGrids-22, pos=%s, length=%s, width=%s, grids[i][j]=%s",table.dump(pos), length, width, inData.grids[i][j])
				return
			end
		end
	end
    return true
end

function util.setMapGrids(inData)
    local id = inData.id
    local pos = inData.pos
    local length = inData.length
    local width = inData.width
    if pos.x == 0 and pos.z == 0 then
        return
    end
    for i = pos.x, pos.x + length - 1, 1 do
		for j = pos.z, pos.z + width - 1, 1 do
			inData.grids[i][j] = id
		end
	end
end

function util.resetMapGrids(inData)
    local pos = inData.pos
    local length = inData.length
    local width = inData.width
    if pos.x == 0 and pos.z == 0 then
        return
    end
    for i = pos.x, pos.x + length - 1, 1 do
		for j = pos.z, pos.z + width - 1, 1 do
			inData.grids[i][j] = 0
		end
	end
end

function util.getIdFromMapGrids(bounds, grids, pos, length, width, exclude)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    local mostDict = {}
    for i = pos.x, pos.x + length - 1, 1 do
        if i <= maxX then
            for j = pos.z, pos.z + width - 1, 1 do
                if j <= maxZ then
                    if grids[i][j] ~= 0 and not exclude[grids[i][j]] then
                        local id = grids[i][j]
                        mostDict[id] = (mostDict[id] or 0) + 1
                    end
                end
            end
        end
	end
    if table.count(mostDict) > 1 then--""
        return
    end
    -- assert(table.count(mostDict) <= 1, "map grids error")
    local mostId = 0
    local mostCount
    for id, count in pairs(mostDict) do
        if not mostCount or mostCount < count then
            mostId = id
            mostCount = count
        end
    end
    return mostId, mostCount
end

function util.isEnoughSpaceMapGrids(inData)
    local bounds = util.getBoundsMapGrids(inData)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    local pos = inData.pos
    if pos.x < minX or pos.x > maxX or pos.z < minZ or pos.z > maxZ then
		return
	end
    local exclude = inData.exclude
    local length = inData.length
    local width = inData.width
	for i = pos.x, pos.x + length - 1, 1 do
        for j = pos.z, pos.z + width - 1, 1 do
            if i > maxX or j > maxZ then
                return
            end
            if not exclude[inData.grids[i][j]] and inData.grids[i][j] ~= 0 then
                return
            end
        end
	end
    return true
end

function util.canMoveMapGrids(inData)
    local bounds = util.getBoundsMapGrids(inData)
    local minX = bounds.minX
    local maxX = bounds.maxX
    local minZ = bounds.minZ
    local maxZ = bounds.maxZ
    local fromPos = inData.fromPos--from pos already create, do not check
    local toPos = inData.toPos
    if toPos.x < minX or toPos.x > maxX or toPos.z < minZ or toPos.z > maxZ then
		return
	end
    local srcId = inData.id
    local srcBuild = inData.builds[srcId]
    local exclude = {[srcId] = true}
    local dstId = util.getIdFromMapGrids(bounds, inData.grids, toPos, srcBuild.length, srcBuild.width, exclude)
    if not dstId then
        return false, "can not exchange more then one build"
    end
	local data = {
		exclude = {[srcId] = true, [dstId] = true},
		length = srcBuild.length,
		width = srcBuild.width,
		pos = toPos,
        grids = inData.grids,
	}
	if not util.isEnoughSpaceMapGrids(data) then
        return false, "not enough space"
	end
	if dstId ~= 0 then
		local dstBuild = inData.builds[dstId]
		if not dstBuild then
			return false, "no build"
		end
		local data = {
            exclude = {[srcId] = true, [dstId] = true},
			length = dstBuild.length,
			width = dstBuild.width,
			pos = fromPos,
            grids = inData.grids,
		}
        if not constant.BUILD_TYPE_CAN_MOVE[dstBuild.type] then
            return false, "mess cant not move"
        end
		if not util.isEnoughSpaceMapGrids(data) then
			return false, "not enough space"
		end
	end
    return true
end

function util.swapMapGrids(inData)
    local fromPos = inData.fromPos
    local toPos = inData.toPos
    local srcId = inData.id
    local srcBuild = inData.builds[srcId]
    util.resetMapGrids({
        pos = fromPos,
        length = srcBuild.length,
        width = srcBuild.width,
        grids = inData.grids,
    })
    local dstBuild
    local exclude = {[srcId] = true}
    local bounds = util.getBoundsMapGrids(inData)
    local dstId = util.getIdFromMapGrids(bounds, inData.grids, toPos, srcBuild.length, srcBuild.width, exclude)
    if dstId and dstId ~= 0 then
		dstBuild = inData.builds[dstId]
        local dstPos = Vector3.New(dstBuild.x, 0, dstBuild.z)
        util.resetMapGrids({
            pos = dstPos,
            length = dstBuild.length,
            width = dstBuild.width,
            grids = inData.grids,
        })
        util.setMapGrids({
            id = dstId,
            pos = fromPos,
            length = dstBuild.length,
            width = dstBuild.width,
            grids = inData.grids,
        })
        dstBuild:setNewPos(fromPos.x, fromPos.z)
	end
    util.setMapGrids({
        id = srcId,
        pos = toPos,
        length = srcBuild.length,
        width = srcBuild.width,
        grids = inData.grids,
    })
    srcBuild:setNewPos(toPos.x, toPos.z)
    return dstBuild
end
----------------------------------------------------
function util.getSaveVal(val, default)
    default = default or 0
    if val == default then
        return
    end
    return val
end
----------------------------------------------------
selfPrintId = tonumber(skynet.getenv("selfPrintId"))
DebugPrintEnv = skynet.getenv("DebugPrintEnv")

-- ""1""
DebugPrint = function( ...)
	if not DebugPrintEnv or DebugPrintEnv~= "local" then
		return
	end
	local args = { ... }
	local argCount = select("#", ...)
	local funcInfo = debug.getinfo(2) --""DebugPrint""
	local shortSrc = funcInfo.short_src or ""
	local funcName = funcInfo.name or ""
	local curLine = funcInfo.currentline or ""
	local funcInfoStr = "" .. shortSrc .. "  Line:" .. curLine .. "  Func:" .. funcName .. "" .. "\n"
	local retStringTable = {
		"\n",
		funcInfoStr
	}
	for k, v in pairs(args) do
		if type(v) ~= "table" and type(v) ~= "nil"  then
			if type(v) == "string" then
				table.insert(retStringTable, string.format("arg%s--%s : \"%s\"\n", k, type(v), v))
			else
				table.insert(retStringTable, string.format("arg%s--%s : %s\n", k, type(v), v))
			end
		elseif type(v) == "nil" then
			table.insert(retStringTable, string.format("arg%s--%s : %s\n", k, type(v), "nil"))
		elseif type(v) == "table" then
			local function SimplePrintTable(root)
				local iterDepth = 999
				local markIterTables = {}
				if type(root) == "table" then
					markIterTables[root] = true
					local temp = {
						tostring(root) .. "={\n",
					}
					local function table2String(t, depth)
						if type(depth) == "number" then
							depth = depth + 1
						else
							depth = 1
						end
						local indent = ""
						for i = 1, depth do
							indent = indent .. "	"
						end
						if depth <= iterDepth then
							for k, v in pairs(t) do
								local key = tostring(k)
								if type(k) == "string" then
									key = "\"" .. key .. "\""
								end
								local typeV = type(v)
								if typeV == "table" then
									if markIterTables[v] then
										table.insert(temp, indent .. key .. "= (Circular):" .. tostring(v) .. "\n")
									else
										markIterTables[v] = true
										table.insert(temp, indent .. key .. "=" .. tostring(v) .. "{\n")
										table2String(v, depth)
										table.insert(temp, indent .. "},\n")
										markIterTables[v] = nil
									end
								elseif typeV == "string" then
									table.insert(temp, string.format("%s%s=\"%s\",\n", indent, key, tostring(v)))
								else
									table.insert(temp, string.format("%s%s=%s,\n", indent, key, tostring(v)))
								end
							end
						end
					end
					table2String(root)
					table.insert(temp, "}\n")
					return table.concat(temp)
				end

			end

			table.insert(retStringTable, string.format("arg%s--%s : %s", k, type(v), SimplePrintTable(v)))
		end
		if argCount == k and v == 1 then
			table.insert(retStringTable, debug.traceback())
		end
	end
    local tmpprint = print
	tmpprint(table.concat(retStringTable))
end
------------------------------------------

function __hotfix(module)

end

return util