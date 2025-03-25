--- ""
--@script gg.base.savemgr
--@author sundream
--@release 2018/12/25 10:30:00
--@usage
-- ""：
-- obj:save_to_db() = ""
-- obj.savename = ""，""
-- obj.savetick = ""（""skynet.getenv("savetick"))
--
-- gg.savemgr = csavemgr.new()
-- ""gg.savemgr:closesave""
-- ""：""，""gg.savemgr:autosave，""
-- ""gg.savemgr:closesave,""，""gg.savemgr:autosave""。

local csavemgr = class("csavemgr")

function csavemgr:ctor()
    self.savetick = tonumber(skynet.getenv("savetick")) or 300
    self.id = 0
    self.objs = {}
end

---"","",""
--@param[type=table] obj ""
function csavemgr:oncesave(obj)
    obj.savetype = "oncesave"
    assert(obj.savename,"no attribute: savename")
    local id = obj.saveid
    if not self:getobj(id) then
        id = self:addobj(obj)
    end
    logger.logf("debug","save","op=oncesave,id=%s,savename=%s",id,obj.savename)
end

---""
--@param[type=table] obj ""
function csavemgr:autosave(obj)
    obj.savetype = "autosave"
    assert(obj.savename,"no attribute: savename")
    local id = obj.saveid
    if not self:getobj(id) then
        id = self:addobj(obj)
    end
    logger.logf("debug","save","op=autosave,id=%s,savename=%s",id,obj.savename)
end

---""
--@param[type=table] obj ""
function csavemgr:nowsave(obj)
    local id = obj.saveid
    if not id then
        return
    end
    if not self:getobj(id) then
        return
    end
    assert(obj.savetype == "oncesave" or obj.savetype == "autosave")
    xpcall(function ()
        logger.logf("debug","save","op=nowsave,id=%s,savename=%s,savetype=%s",id,obj.savename,obj.savetype)
        obj:save_to_db()
    end,gg.onerror or debug.traceback)
    if obj.savetype == "oncesave" then
        self:closesave(obj)
    end
end

---""
--@param[type=table] obj ""
function csavemgr:closesave(obj)
    local id = obj.saveid
    if not id then
        return
    end
    self:delobj(id)
    obj.savetype = nil
    obj.savename = nil
    obj.savetick = nil
end

--- ""
function csavemgr:saveall()
    logger.logf("debug","save","op=saveall")
    for id,obj in pairs(self.objs) do
        self:nowsave(obj)
    end
end

-- private method

function csavemgr:genid()
    repeat
        self.id = self.id + 1
    until self.objs[self.id] == nil
    return self.id
end

function csavemgr:getobj(id)
    return self.objs[id]
end

function csavemgr:addobj(obj,id)
    id = id or self:genid()
    logger.logf("debug","save","op=addobj,id=%s,savename=%s",id,obj.savename)
    assert(self.objs[id] == nil)
    self.objs[id] = obj
    obj.saveid = id
    self:starttimer(id)
    return id
end

function csavemgr:delobj(id)
    local obj = self.objs[id]
    if obj then
        logger.logf("debug","save","op=delobj,id=%s,savename=%s",id,obj.savename)
        self.objs[id] = nil
    end
end

function csavemgr:starttimer(id)
    local obj = self:getobj(id)
    if not obj then
        return
    end
    logger.logf("debug","save","op=starttimer,id=%s,savename=%s",id,obj.savename)
    local interval = obj.savetick or self.savetick
    obj.savetimer = gg.timer:timeout(interval,function () self:ontimer(id) end)
end

function csavemgr:ontimer(id)
    local obj = self:getobj(id)
    if not obj then
        return
    end
    local interval = obj.savetick or self.savetick
    obj.savetimer = gg.timer:timeout(interval,function () self:ontimer(id) end)
    self:nowsave(obj)
end