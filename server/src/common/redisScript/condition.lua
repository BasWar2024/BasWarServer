local querycondition = {}

local EQ_S = "="
local LT_S = "<"
local LTE_S = "<="
local GT_S = ">"
local GTE_S = ">="
local NE_S = "~="
local S_MONGOS = {
    [LT_S] = "$lt",
    [LTE_S] = "$lte",
    [GT_S] = "$gt",
    [GTE_S] = "$gte",
    [NE_S] = "$ne",
}
function querycondition.op_switch(k, op, val)
    local key
    local value
    if op == EQ_S then
        key = k
        value = val
    elseif op == LT_S then
        key = k
        value = {[S_MONGOS[LT_S]] = val}
    elseif op == LTE_S then
        key = k
        value = {[S_MONGOS[LTE_S]] = val}
    elseif op == GT_S then
        key = k
        value = {[S_MONGOS[GT_S]] = val}
    elseif op == GTE_S then
        key = k
        value = {[S_MONGOS[GTE_S]] = val}
    elseif op == NE_S then
        key = k
        value = {[S_MONGOS[NE_S]] = val}
    end
    return key, value
end

function querycondition.op_or(c1, c2)
    return "$or", {c1, c2}
end

function querycondition._is_nest(t)
    return #t >= 3 and type(t[1]) == "table"
end

function querycondition._check_order_rule(t)
    for index, value in ipairs(t) do
        local flag = index % 2
        if flag == 1 and type(value) == "string" then
            return
        end
        if flag == 2 and type(value) == "table" then
            return
        end
        if type(value) == "string" then
            if value ~= "and" and value ~= "or" then
                return
            end
        elseif type(value) == "table" then
            if querycondition._is_nest(value) then
                local r = querycondition._check_order_rule(value[1])
                if not r then
                    return
                end
            end
        end
    end
    return true
end

function querycondition._adjust(input, output)
    if type(input) == "string" then
        table.insert(output, input)
        return
    end
    for index, value in ipairs(input) do
        local this_output = output
        local op_str = output[#output]
        if op_str == "or" then
            local tmp = {}
            table.insert(output, tmp)
            this_output = tmp
        end
        if type(value) == "table" then
            if querycondition._is_nest(value) then
                querycondition._adjust(value, this_output)
            else
                if type(value[1]) == "string" then
                    if value[1] ~= "or" then
                        table.insert(value, "__need_switch")
                        table.insert(this_output, value)
                    else
                        local tmp = {}
                        querycondition._adjust(value, tmp)
                        table.insert(this_output, tmp)
                    end
                else
                    querycondition._adjust(value, this_output)
                end
            end
        else
            table.insert(this_output, value)
        end
    end
end

function querycondition._do_and_or(output, second)
    if #output < 2 then
        table.insert(output, second)
    else
        local op_str = table.remove(output, #output)
        if op_str == "and" then
            local first = table.remove(output, #output)
            table.insert(output, {first, second})
        elseif op_str == "or" then
            local first = table.remove(output, #output)
            table.insert(output, {"or", first, second})
        end
    end
end

function querycondition.scan_and_or(input, output)
    local tsize = #input
    if tsize <= 1 then
        table.insert(output, input)
        return
    end
    for index, value in ipairs(input) do
        if type(value) == "table" then
            if querycondition._is_nest(value) then
                local tmp = {}
                querycondition.scan_and_or(value, tmp)
                querycondition._do_and_or(output, tmp)
            else
                querycondition._do_and_or(output, value)
            end
        else
            querycondition._do_and_or(output, value)
        end
    end
end

function querycondition._generate(input, output)
    for index, value in ipairs(input) do
        local this_output = output
        local or_tbl = output["$or"]
        if or_tbl then
            this_output = or_tbl
        end
        if type(value) == "string" then
            if value == "or" then
                output["$or"] = {}
            end
        elseif type(value) == "table" then
            if querycondition._is_nest(value) then
                querycondition._generate(value, this_output)
            else
                local last = value[#value]
                if last == "__need_switch" then
                    local k, v = querycondition.op_switch(value[1], value[2], value[3])
                    if or_tbl then
                        table.insert(this_output, {[k] = v})
                    else
                        this_output[k] = v
                    end
                else
                    querycondition._generate(value, output)
                end
            end
        end
    end
end

function querycondition.analysis(cond, out)
    --
end

return querycondition