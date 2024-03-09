local c = require "profile.c"
local mark = c.mark

local M = {}

local old_co_create = coroutine.create
local old_co_wrap = coroutine.wrap

function coroutine.create(f)
    return old_co_create(function ()
            mark()
            return f()
        end)
end

function coroutine.wrap(f)
    return old_co_wrap(function ()
            mark()
            return f()
        end)
end

--- 
M.start = c.start

--- 
M.stop = c.stop

--- reporttopN
--@param[type=int] topN 
--@param[type=int] sort_type : 0=,1=,2=cpu(),3=(+),4=,5=cpu,6=
--@return 
function M.report(topN,sort_type)
    topN = topN or 20
    sort_type = sort_type or 1
    if topN <= 0 then
        topN = 10000
    end
    local records = c.report(topN,sort_type)
    local ret = {string.format("topN=%s,sort_type=%s,unit=milliseconds",topN,sort_type)}
    ret[#ret+1] = string.format("%-10s %-12s %-6s %-12s %-6s %-12s %-6s %-10s %-10s %-10s %-20s %-20s","count","sum","%","cpu","%","real","%","avg","avg_cpu","avg_real","name","source")
    for i,v in ipairs(records) do
        local source = string.format("[%s]%s:%d",v.flag,v.source,v.line)
        local s = string.format("%-10d %-12.3f %-6.2f %-12.3f %-6.2f %-12.3f %-6.2f %-10.3f %-10.3f %-10.3f %-20s %-20s",
                                v.call_count,v.sum_cost,v.sum_cost_percent*100,v.cpu_cost,v.cpu_cost_percent*100,v.real_cost,v.real_cost_percent*100,v.avg_cost,v.avg_cpu_cost,v.avg_real_cost,v.name,source)
        ret[#ret+1] = s
    end
    return table.concat(ret, "\n")
end

return M