function gg.readVersion()
    local filename = "version.txt"
    local fd = io.open(filename,"r")
    local version = fd:read("*line")
    fd:close()
    return version
end

function gg.hotfix(filename)
    for i,prefix in ipairs({"../src/","server/src/","src/"}) do
        if string.startswith(filename,prefix) then
            filename = filename:sub(#prefix+1)
            break
        end
    end
    local address = skynet.address(skynet.self())
    if filename == "server/version.txt" or filename == "version.txt" then
        gg.version = gg.readVersion()
        local msg = string.format("op=hotfix,address=%s,filename=%s",address,filename)
        logger.logf("info","hotfix",msg)
        return true
    end
    local is_path
    local replace_cnt
    filename,replace_cnt = string.gsub(filename,"/",".")
    if replace_cnt > 0 then
        is_path = true
    end
    filename,replace_cnt = string.gsub(filename,"\\",".")
    if replace_cnt > 0 then
        is_path = true
    end
    local suffix = filename:sub(-4,-1)
    if suffix == ".lua" then
        filename = filename:sub(1,-5)
    elseif is_path then
        return false,"ignore non lua file"
    end
    if gg.canntHotfixModules then
        for i,pat in ipairs(gg.canntHotfixModules) do
            if filename == string.match(filename,pat) then
                return false,"cannt_hotfix"
            end
        end
    end
    if skynet then
        skynet.cache.clear()
    end
    local ok,err = gg._hotfix(filename)
    if ok then
        if err ~= "nolog" then
            local msg = string.format("op=hotfix,address=%s,filename=%s",address,filename)
            logger.logf("info","hotfix",msg)
            logger.print(msg)
        end
    elseif err ~= "ignore" then
        local msg = string.format("op=hotfix,address=%s,filename=%s,fail=%s",address,filename,err)
        logger.logf("error","hotfix",msg)
        logger.print(msg)
    end
    return ok,err
end

function gg._hotfix(filename)
    local items = string.split(filename,".")
    local package = items[1]   -- app or gg
    if package == "gg" or package == "common" then
        return gg.reload(filename)
    elseif package == "etc" then
        local module = items[2]
        if module == "ai" then
            if gg.onHotfixAI then
                return gg.reload(filename)
            else
                return true,"nolog"
            end
        elseif module == "cfg" then
            return gg.hotfixCfg(filename)
        elseif module == "i18n" then
            return gg.hotfixI18n()
        elseif module == "proto" then
            return gg.hotfixProto()
        else
            return false,"ignore"
        end
    elseif package == "app" then
        local module = items[2]
        if module ~= gg.moduleName then
            return true,"nolog"
        end
        return gg.reload(filename)
    else
        return false,"ignore"
    end
end

function gg.hotfixCfg(filename)
    if not gg.ignoreCfg then
        if cfg.isHost then
            local ok,err = cfg.load(filename)
            if not ok then
                return false,err
            end
        end
        cfg.hotfix(filename)
        return true
    else
        return true,"nolog"
    end
end

function gg.hotfixProto()
    if not next(gg.gate) then
        return true,"nolog"
    end
    if gg.gate.tcp then
        skynet.send(gg.gate.tcp,"lua","reload")
    end
    if gg.gate.kcp then
        skynet.send(gg.gate.kcp,"lua","reload")
    end
    if gg.gate.websocket then
        skynet.send(gg.gate.websocket,"lua","reload")
    end
    return true
end

function gg.hotfixI18n()
    if gg.useI18n then
        i18n.init({
            original_lang = "zh_CN",
            languages = gg.genI18nTexts()
        })
        return true
    else
        return true,"nolog"
    end
end