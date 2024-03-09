local cproperty = require "property"

--- dump(,)
--@param[type=table] t 
--@return[type=string] dump
function table.dump(t,space,name)
    if type(t) ~= "table" then
        return tostring(t)
    end
    space = space or ""
    name = name or ""
    local cache = { [t] = "."}
    local function _dump(t,space,name)
        local temp = {}
        for k,v in pairs(t) do
            local key = tostring(k)
            if cache[v] then
                table.insert(temp,"+" .. key .. " {" .. cache[v].."}")
            elseif type(v) == "table" then
                local new_key = name .. "." .. key
                cache[v] = new_key
                table.insert(temp,"+" .. key .. _dump(v,space .. (next(t,k) and "|" or " " ).. string.rep(" ",#key),new_key))
            else
                table.insert(temp,"+" .. key .. " [" .. tostring(v).."]")
            end
        end
        return table.concat(temp,"\n"..space)
    end
    return _dump(t,space,name)
end

local function test()
    local constraits = {
        key1 = {
            pack = true,
            serialize = true,
            default = 0,
            id = 1,
        },
        key2 = {
            pack = true,
            serialize = true,
            default = 0,
            id = 2,
            ttl = 5,
        }
    }
    local property = cproperty.new(constraits)
    property:register({
        on_update = function (self,key,old_value,new_value)
            print("on_update",self,key,old_value,new_value)
        end,
        on_delete = function (self,key,reason)
            print("on_delete",self,key,reason)
        end,
    })
    property.key1 = 1
    property.key1 = nil
    assert(property.key1 == nil)
    property.key1 = 1
    property:delete("key1")
    assert(property.key1 == nil)
    property.key1 = 1
    assert(property.key1 == property:get("key1"))
    property.key1 = property.key1 + 1
    assert(property.key1 == 2)
    property:add("key1",1)
    assert(property.key1 == 3)

    property.key2 = 2
    assert(property.key2 == 2)
    property.key2 = property.key2 + 1
    assert(property.key2 == 3)
    local ttl = property:ttl("key2")
    assert(ttl == constraits.key2.ttl)
    os.execute("sleep 3")
    local ttl = property:ttl("key2")
    assert(ttl == constraits.key2.ttl-3)
    assert(property.key2 == 3)
    os.execute("sleep 2")
    local ttl = property:ttl("key2")
    assert(ttl == 0)
    assert(property.key2 == nil)

    local serialize1 = property:serialize()
    print("serialize\n",table.dump(serialize1))
    property:deserialize(serialize1)
    local serialize2 = property:serialize()
    for k,v in pairs(serialize1) do
        for k1,v1 in pairs(v) do
            assert(serialize2[k][k1] == v1)
        end
    end
    local pack = property:pack()
    print("pack\n",table.dump(pack))
end

test()