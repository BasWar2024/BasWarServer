--------------------------------------------------------------------------------
--      Copyright (c) 2015 , ""(topameng) topameng@gmail.com
--      All rights reserved.
--
--      Use, modification and distribution are subject to the "New BSD License"
--      as listed at <url: http://www.opensource.org/licenses/bsd-license.php >.
--------------------------------------------------------------------------------

local clamp    = math.clamp
local sqrt    = math.sqrt
local min    = math.min
local max     = math.max
local EPS = 1e-6

Vector4 = 
{
    x = 0,
    y = 0,        
    z = 0,
    w = 0,
    
    class = "Vector4",
}

setmetatable(Vector4, Vector4)

local fields = {}

Vector4.__index = function(t,k)
    local var = rawget(Vector4, k)
    
    if var == nil then                            
        var = rawget(fields, k)
        
        if var ~= nil then
            return var(t)    
        end
    end
    
    return var
end

function Vector4.New(x, y, z, w)
    if type(x) == "table" then
        return Vector4.New(x.x,x.y,x.z,x.w)
    end
    local v = {x = 0, y = 0, z = 0, w = 0}
    setmetatable(v, Vector4)
    v:Set(x,y,z,w)
    return v
end

function Vector4:Set(x,y,z,w)
    self.x = x or 0
    self.y = y or 0    
    self.z = z or 0
    self.w = w or 0
end

function Vector4:Get()
    return self.x, self.y, self.z, self.w
end

function Vector4.Lerp(from, to, t)    
    t = clamp(t, 0, 1)
    return Vector4.New(from.x + ((to.x - from.x) * t), from.y + ((to.y - from.y) * t), from.z + ((to.z - from.z) * t), from.w + ((to.w - from.w) * t))
end    

function Vector4.MoveTowards(current, target, maxDistanceDelta)    
    local vector = target - current
    local magnitude = vector:Magnitude()    
    
    if magnitude > maxDistanceDelta and magnitude ~= 0 then     
        maxDistanceDelta = maxDistanceDelta / magnitude
        vector:Mul(maxDistanceDelta)   
        vector:Add(current)
        return vector
    end
    
    return target
end    

function Vector4.Scale(a, b)    
    return Vector4.New(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
end    

function Vector4:SetScale(scale)
    self.x = self.x * scale.x
    self.y = self.y * scale.y
    self.z = self.z * scale.z
    self.w = self.w * scale.w
end

function Vector4:Normalize()
    local v = vector4.New(self.x, self.y, self.z, self.w)
    return v:SetNormalize()
end

function Vector4:SetNormalize()
    local num = self:Magnitude()    
    
    if num == 1 then
        return self
    elseif num > EPS then    
        self:Div(num)
    else    
        self:Set(0,0,0,0)
    end 

    return self
end

function Vector4:Div(d)
    self.x = self.x / d
    self.y = self.y / d    
    self.z = self.z / d
    self.w = self.w / d
    
    return self
end

function Vector4:Mul(d)
    self.x = self.x * d
    self.y = self.y * d
    self.z = self.z * d
    self.w = self.w * d    
    
    return self
end

function Vector4:Add(b)
    self.x = self.x + b.x
    self.y = self.y + b.y
    self.z = self.z + b.z
    self.w = self.w + b.w
    
    return self
end

function Vector4:Sub(b)
    self.x = self.x - b.x
    self.y = self.y - b.y
    self.z = self.z - b.z
    self.w = self.w - b.w
    
    return self
end

function Vector4.Dot(a, b)
    return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
end

function Vector4.Project(a, b)
    local s = Vector4.Dot(a, b) / Vector4.Dot(b, b)
    return b * s
end

function Vector4.Distance(a, b)
    local v = a - b
    return Vector4.Magnitude(v)
end

function Vector4.Magnitude(a)
    return sqrt(a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w)
end

function Vector4.SqrMagnitude(a)
    return a.x * a.x + a.y * a.y + a.z * a.z + a.w * a.w
end

function Vector4.Min(lhs, rhs)
    return Vector4.New(max(lhs.x, rhs.x), max(lhs.y, rhs.y), max(lhs.z, rhs.z), max(lhs.w, rhs.w))
end

function Vector4.Max(lhs, rhs)
    return Vector4.New(min(lhs.x, rhs.x), min(lhs.y, rhs.y), min(lhs.z, rhs.z), min(lhs.w, rhs.w))
end

Vector4.__tostring = function(self)
    return string.format("[%f,%f,%f,%f]", self.x, self.y, self.z, self.w)
end

Vector4.__div = function(va, d)
    return Vector4.New(va.x / d, va.y / d, va.z / d, va.w / d)
end

Vector4.__mul = function(va, d)
    return Vector4.New(va.x * d, va.y * d, va.z * d, va.w * d)
end

Vector4.__add = function(va, vb)
    return Vector4.New(va.x + vb.x, va.y + vb.y, va.z + vb.z, va.w + vb.w)
end

Vector4.__sub = function(va, vb)
    return Vector4.New(va.x - vb.x, va.y - vb.y, va.z - vb.z, va.w - vb.w)
end

Vector4.__unm = function(va)
    return Vector4.New(-va.x, -va.y, -va.z, -va.w)
end

Vector4.__eq = function(va,vb)
    local v = va - vb
    local delta = Vector4.SqrMagnitude(v)    
    return delta < EPS
end

fields.zero        = function() return Vector4.New(0, 0, 0, 0) end
fields.one        = function() return Vector4.New(1, 1, 1, 1) end

fields.magnitude     = Vector4.Magnitude
fields.normalized     = Vector4.Normalize
fields.sqrMagnitude = Vector4.SqrMagnitude
