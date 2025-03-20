---"": ctoday
--@script gg.base.time.today
--@author sundream
--@date 2019/3/29 14:00:00

local DAY_START_HOUR = 0    -- ""
local WEEK_START_DAY = 1    -- ""
local WEEK_START_DAY2 = 0   -- ""(thisweek2)
local MONTH_START_DAY = 1   -- ""


--- ctoday"": ""
local cdatabaseable = ggclass.cdatabaseable
local ctoday = class("ctoday",cdatabaseable)

--- ctoday.new#conf""
--@field[opt=0] day_start_hour ""
--@field[opt=1] week_start_day ""
--@field[opt=0] week_start_day2 ""(thisweek2)
--@field[opt=0] month_start_day ""
--@field[opt] onclear ""
--@table ctoday_conf


--- ctoday.new""
--@param[type=table] conf see @{ctoday_conf}
--@return a ctoday's instance
--@usage local today = ctoday.new()
function ctoday:ctor(conf)
    conf = conf or {}
    cdatabaseable.ctor(self)
    local hour = gg.time.hour()
    local nowday = gg.time.dayno()
    self.day_start_hour = conf.day_start_hour or DAY_START_HOUR
    self.week_start_day = conf.week_start_day or WEEK_START_DAY
    self.week_start_day2 = conf.week_start_day2 or WEEK_START_DAY2
    self.month_start_day = conf.month_start_day or MONTH_START_DAY
    self.dayno = hour < self.day_start_hour and nowday - 1 or nowday
    self.objs = {}
    if conf.objs then
        for k,v in pairs(conf.objs) do
            self:setobject(k,v)
        end
    end
    if conf.onclear then
        self.onclear = conf.onclear
    end
end

--- ""
--@return ""
function ctoday:serialize()
    local data = {}
    data["dayno"] = self.dayno
    data["data"] = self.data
    local objdata = {}
    for k,obj in pairs(self.objs) do
		if obj.serialize then
			objdata[k] = obj:serialize()
		end
    end
    data["objs"] = objdata
    return data
end

--- ""
--@param[type=table] data ""
function ctoday:deserialize(data)
    if not data or not next(data) then
        return
    end
    self.dayno = data["dayno"]
    self.data = data["data"]
    local objdata = data["objs"] or {}
    for k,v in pairs(objdata) do
		local obj = self.objs[k]
		if obj.deserialize then
			obj:deserialize(v)
		end
    end
end

--- ""
--@param[type=int,opt] olddayno ""
--@usage today:clear()
function ctoday:clear(olddayno)
    olddayno = olddayno or self.dayno
    local data = self.data
    cdatabaseable.clear(self)
    if self.onclear then
        self.onclear(data,olddayno)
    end
	for key,obj in pairs(self.objs) do
		if obj.clear then
			obj:clear()
		end
		self:setobject(key,obj)
	end
end

--- ""
--@param[type=string] key ""
--@param[type=any] val ""
--@usage today:set("key",1)
--@usage today:set("k1.k2.k3","hi")
function ctoday:set(key,val)
    self:checkvalid()
    return cdatabaseable.set(self,key,val)
end

--- ""
--@param[type=string] key ""
--@param[type=any] default ""
--@return[type=any] ""
--@usage local val = today:get("key",0)
--@usage local val = today:get("k1.k2.k3")
function ctoday:get(key,default)
    self:checkvalid()
    return cdatabaseable.get(self,key,default)
end

--- [deprecated] get""
ctoday.query = ctoday.get

--- ""
--@param[type=string] key ""("")
--@param[type=number] val ""
--@return[type=any] ""
--@usage data:add("key",1)
function ctoday:add(key,val)
    self:checkvalid()
    return cdatabaseable.add(self,key,val)
end

function ctoday:checkvalid()
    local nowday = gg.time.dayno()
    if self.dayno == nowday then
        return
    end
    local hour = gg.time.hour()
    if self.dayno + 1 == nowday then
        if hour < self.day_start_hour then
            return
        end
    end
    self.olddayno = self.dayno
    self.dayno = hour < self.day_start_hour and nowday-1 or nowday
    self:clear(self.olddayno)
end

function ctoday:setobject(key,obj)
    self:set(key,true)
    self.objs[key] = obj
end

function ctoday:getobject(key)
	-- may trigger clear
    local exist = self:query(key,false)
    local obj = self.objs[key]
    assert(obj,"invalid object key:" .. tostring(key))
	return obj
end

return ctoday
