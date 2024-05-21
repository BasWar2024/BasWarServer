math.max_int32 = (2<<32)-1
math.deg2Rad = math.pi / 180
math.rad2Deg = 180 / math.pi
--math.nan = 0/0


function math.round(num,n)
    n = n or 0
    n = 10 ^ n
    return math.floor(num * n + 0.5) / n
end

function math.sign(num)
    if num > 0 then
        num = 1
    elseif num < 0 then
        num = -1
    else
        num = 0
    end

    return num
end

function math.clamp(num, min, max)
    if num < min then
        num = min
    elseif num > max then
        num = max
    end
    return num
end

local clamp = math.clamp

function math.lerp(from, to, t)
    return from + (to - from) * math.clamp(t, 0, 1)
end

-- ""
--@param rect1 = {x, z, length, width}
function math.isRectOverlap(rect1, rect2)
    if rect1.x + rect1.length > rect2.x and rect2.x + rect2.length > rect1.x and rect1.z + rect1.width > rect2.z and rect2.z + rect2.width > rect1.z then
        return true
    end
    return false
end

-- Bin 2
-- Oct 8
-- Dec 10
-- Hex 16
local AnyCharMap = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

local function int2xNumArray(num, x)
    local function fn(n, t)
        if n < x then
            table.insert(t, n)
        else
            fn(math.floor(n / x), t)
            table.insert(t, n%x)
        end
    end
    local xt = {}
    fn(num, xt)
    return xt
end

-- ""
---@param num integer ""
---@param x integer x""(2-16)
---@return string
function math.int2AnyStr(num, x)
    local xt = int2xNumArray(num, x)
    local str = ""
    for k,v in ipairs(xt) do
        str = str .. string.sub(AnyCharMap, v+1, v+1)
    end
    return str
end

-- ""
---@param str string 
---@param x integer x""(2-16)
---@return string
function math.anyStr2Int(str, x)
    local len = #str
    local n = 0
    local result = 0
    for i=len, 1, -1 do
        local c = string.sub(str, i, i)
        local pos = string.find(AnyCharMap, c)
        assert(pos, "c"..c.." not found")
        result = result + (62^n) * (pos-1)
        n = n + 1
    end
    return math.floor(result)
end

-- ""
---@param str string 
---@param x integer x""(2-16)
---@return string
function math.hex2AnyStr(str, x)
    local xt = {}
    local len = string.len(str)
    local index = len
    while index > 0 do
        local char = string.sub(str, index, index)
        local pos = string.find(AnyCharMap, char)
        assert(pos, "char "..char.." not found")
        xt[#xt+1] = pos - 1
        index = index - 1
    end
    local num = 0
    for k, v in pairs(xt) do
        num = num + v * (x^(k-1))
    end
    return num
end
