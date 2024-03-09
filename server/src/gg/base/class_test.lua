require "class"

local Point = class("Point")
function Point:ctor(x,y,z)
    self.x = x
    self.y = y
    self.z = z
end

local Vector3 = class("Vector3",Point)

function Vector3:ctor(x,y,z)
    Vector3.super.ctor(self,x,y,z)
end

function Vector3:__add(p2)
    local p1 = self
    local result = Vector3.new(p1.x+p2.x,p1.y+p2.y,p1.z+p2.z)
    return result
end

function Vector3:__tostring()
    return string.format("[%s,%s,%s]",self.x,self.y,self.z)
end

local function test()
    local p1 = Vector3.new(1,1,1)
    local p2 = Vector3.new(2,2,2)
    local p3 = p1 + p2
    print(string.format("%s + %s = %s",p1,p2,p3))
    print(string.format("p1.x=%s,p1.y=%s,p1.z=%s",p1.x,p1.y,p1.z))
end

test()