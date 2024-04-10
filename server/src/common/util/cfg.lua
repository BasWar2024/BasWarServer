local sharedata = require("skynet.sharedata")
local corelib = require("skynet.sharedata.corelib")

cfg = cfg or {cache={}}
-- "",""
function cfg.load(name)
    local oldcobj = cfg.getcobj(name)
    local env = _ENV or _G
    local filename = package.searchpath(name,package.path)
    if filename then
        local fp = io.open(filename,"rb")
        local module = fp:read("*a")
        fp:close()
        local chunk,err = load(module,filename,"bt",env)
        if chunk then
            chunk = chunk()
            -- ""
            local newcobj = skynet.tostring(skynet.pack(corelib.host.new(chunk)))
            cfg.cfgcobjs[name] = newcobj
            if oldcobj then
                corelib.host.markdirty(oldcobj)
            end
            return newcobj
        end
    end
end

-- ""
function cfg.getcobj(name)
    return skynet.unpack(cfg.cfgcobjs[name])
end

function cfg.update(name)
    local obj = cfg.cache[name]
    if obj then
        local newcobj = cfg.getcobj(name)
        if obj.__obj ~= newcobj then
            corelib.update(obj,newcobj)
        end
    end
end

gg.next = gg.next or next
-- ""
local corelib_next = corelib.next
local gg_next = gg.next
local rawget = rawget
function next(tbl,key)
    if rawget(tbl,"__gcobj") ~= nil then
        return corelib_next(tbl,key)
    else
        return gg_next(tbl,key)
    end
end

function cfg.loadAll()
    cfg.isHost = true
    cfg.cfgcobjs = cfg.cfgcobjs or {}
    if gg.loadAllCfg then
        gg.loadAllCfg()
    end
    if cfg.isHost then
        sharedata.update("cfgcobjs", cfg.cfgcobjs)
    else
        sharedata.new("cfgcobjs", cfg.cfgcobjs)
    end
end

function cfg.get(name)
    if not cfg.cache[name] then
        local cobj = assert(cfg.getcobj(name),string.format("cfg not exist %s",name))
        local obj = corelib.box(cobj)
        cfg.cache[name] = obj
    end
    return cfg.cache[name]
end

function cfg.init()
    if not cfg.cfgcobjs then
        cfg.cfgcobjs = sharedata.query("cfgcobjs")
    end
end

function cfg.hotfix(name)
    if cfg.isHost then
        cfg.update(name)
        sharedata.update("cfgcobjs", cfg.cfgcobjs)
    else
        cfg.update(name)
    end
    if gg.onHotfixCfg then
        gg.onHotfixCfg(name)
    end
end

function cfg.hotfixAll()
    if not cfg.cfgcobjs then
        return
    end
    for name,obj in pairs(cfg.cfgcobjs) do
        cfg.hotfix(name)
    end
end

return cfg
