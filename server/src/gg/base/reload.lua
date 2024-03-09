local function collect_uv(func_name,func,uv)
    local i = 1
    while true do
        local name,value = debug.getupvalue(func,i)
        if name == nil then
            return
        end
        if name ~= "_ENV" then
            if not uv[func_name] then
                uv[func_name] = {"function",}
            end
            uv[func_name][name] = {
                func = func,
                upvalueid = debug.upvalueid(func,i),
                index = i,
            }
        end
        i = i + 1
    end
end

local function collect_all_uv(module,uv,mark)
    mark = mark or {}
    if mark[module] then
        return
    end
    mark[module] = true
    for k,v in pairs(module) do
        local typ = type(v)
        if typ == "function" then
            collect_uv(k,v,uv)
        elseif typ == "table" then
            uv[k] = {}
            collect_all_uv(v,uv[k],mark)
        end
    end
end

-- uv2upvalueuv1
-- upvalue(local)
local function merge_uv(uv1,uv2,name)
    for k,upvalue_info2 in pairs(uv2) do
        local upvalue_info1 = uv1[k]
        if upvalue_info1 then
            if upvalue_info2[1] == "function" then
                if upvalue_info1[1] ~= "function" then
                    return false,string.format("[merge_uv] mismatch,name=%s,key=%s",name,k)
                end
                for func_name,upvalue2 in pairs(upvalue_info2) do
                    if func_name ~= 1 then
                        local upvalue1 = upvalue_info1[func_name]
                        if upvalue1 and upvalue1.func ~= upvalue2.func then
                            debug.upvaluejoin(upvalue2.func,upvalue2.index,upvalue1.func,upvalue1.index)
                        end
                    end
                end
            else
                local ok,errmsg = merge_uv(upvalue_info1,upvalue_info2,name .. "." .. k)
                if not ok then
                    return false,errmsg
                end
            end
        end
    end
    return true
end

-- tbl2tbl1(),
-- tbl2tbl1
local function merge_func(tbl1,tbl2,name,cache)
    -- /
    if tbl1 == tbl2 then
        return true
    end
    cache = cache or {[tbl2] = name}
    for k,v2 in pairs(tbl2) do
        local v1 = tbl1[k]
        local typ1 = type(v1)
        local typ2 = type(v2)
        if typ1 == "nil" then
            tbl1[k] = v2
        elseif typ1 == "function" then
            if typ2 ~= "function" then
                return false,string.format("[merge_func] mismatch func type,name=%s,key=%s",name,k)
            end
            tbl1[k] = v2
        elseif typ1 == "table" then
            if typ2 ~= "table" then
                return false,string.format("[merge_func] mismatch table type,name=%s,key=%s",name,k)
            end
            if not cache[v2] then
                local ok,errmsg = merge_func(v1,v2,name .. "." .. k,cache)
                if not ok then
                    return false,errmsg
                end
            end
        end
    end
    return true
end

---
--@param[type=string] modname 
--@return true,false
--@usage gg.reload("gg.base.reload")
--,: ,
--,upvalue,
--,,(table)
--,
--local,upvalue,upvalue
--///,upvalue
--,__hotfix,
--(),
function gg.reload(module_name)
    local chunk,err
    local env = _ENV or _G
    env.__hotfix = nil
    local filename = package.searchpath(module_name,package.path)
    if filename then
        local fp = io.open(filename,"rb")
        local module = fp:read("*a")
        fp:close()
        chunk,err = load(module,filename,"bt",env)
    else
        err = "no such file"
    end
    if not chunk then
        return false,err
    end
    local ok,new_module = pcall(chunk)
    if not ok then
        return false,new_module
    end
    -- ,luapackage.loadedtrue
    if new_module == nil then
        new_module = true
    end
    local old_module = package.loaded[module_name]
    if old_module == nil or old_module == true then
        old_module = new_module
        package.loaded[module_name] = old_module
        if type(env.__hotfix) == "function" then
            env.__hotfix(old_module)
        end
        return true
    end
    if type(old_module) ~= type(new_module) then
        return false,"[reload_module] mismatch module type"
    end
    -- table,
    if type(old_module) ~= "table" then
        if type(env.__hotfix) == "function" then
            env.__hotfix(old_module)
        end
        return true
    end
    -- upvalueupvalue
    local uv1 = {}
    local uv2 = {}
    collect_all_uv(old_module,uv1)
    collect_all_uv(new_module,uv2)
    local ok,errmsg = merge_uv(uv1,uv2,module_name)
    if not ok then
        return false,errmsg
    end
    if gg and gg.safe_reloads and gg.safe_reloads[module_name] then
        -- ,(luatable)
        ok = true
        for k,v in pairs(new_module) do
            old_module[k] = v
        end
    else
        -- ,,()
        ok,errmsg = merge_func(old_module,new_module,module_name)
    end
    if not ok then
        return false,errmsg
    end
    if type(env.__hotfix) == "function" then
        env.__hotfix(old_module)
    end
    return true
end
