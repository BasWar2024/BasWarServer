local condition = require "common.db.condition"
local operation = {}

function operation._create_result(out, result)
    result = result or {}
    local osize = #out
    for i = 1, osize, 2 do
        local k = out[i]
        local v = out[i+1]
        if type(v) == "table" then
            if v.parent then
                local tmp = {}
                operation._create_result(v, tmp)
                result[k] = tmp
                v.parent = nil
            else
                result[k] = v
            end
        else
            result[k] = v
        end
    end
end

function operation.find(db, tbl_name, cond)
    local t = {
        {"t1", ">=", 1},
        "and",
        {"t2", "=", 2},
        "and",
        {
            {"t2-1", "=", "2-1"},
            "and",
            {"t2-2", "=", 22},
            "and",
            {
                {"t3-1", "=", "3-1"},
                "or",
                {"t3-2", "=", 32}
            },
            -- "or",
            -- {
            --     {"t3-3", "=", "3-3"},
            --     "or",
            --     {"t3-4", "=", 34}
            -- },
            "or",
            {"t2-3", "=", 23},
        },
        "or",
        {"t4", "=", 4},
        "and",
        {"int5", "=", 5},
    }
    local out = {}
    condition.scan_and_or(t, out)
    -- condition.analysis(t, out)
    print("operation.find-----------2222")
    print(table.dump(out))
    local result = {}
    condition._adjust(out, result)
    print("operation.find-----------3333")
    print(table.dump(result))
    local result2 = {}
    condition._generate(result, result2)
    print("operation.find-----------4444")
    print(table.dump(result2))
end
-- operation.find()


return operation