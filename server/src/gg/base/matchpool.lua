--- 
--@script gg.base.matchpool
--@author sundream
--@release 2019/06/17 10:30:00
--@usage
--id,score,level,match_time
--local matchpool = ggclass.cmatchpool.new(
-- tick = 1,                -- 
-- : 1.  2. 
-- yong_pool_timeout = 1,   -- ,,0=,>0=[yong_pool_timeout,yong_pool_time+2]
-- timeout = 30,            -- (timeout+expire_pool_timeout)
-- expire_pool_timeout = 5, -- ,
-- group_num = 2,           -- xx
-- group_mutiple = 1,       -- group_num*group_multiple,group_mutiple
-- on_timeout = function (members) end,    -- 
-- on_success = function (members) end,    -- 
-- on_match = function (member) end,       -- 
-- on_unmatch = function (member,unmatch_type) end,     -- (//)
-- ids = {"id"},
-- sortids = {
--  {key="score",desc=true,}
--  {key="level",desc=true,},
--  {key="match_time"},
-- }
--})
local cmatchpool = class("cmatchpool")
cmatchpool.YONG_POOL = 1
cmatchpool.OLD_POOL = 2
cmatchpool.EXPIRE_POOL = 3

function cmatchpool:ctor(conf)
    self:config(conf)
    self.on_timeout = conf.on_timeout   -- 
    self.on_success = conf.on_success   -- 
    self.on_match = conf.on_match       -- 
    self.on_unmatch = conf.on_unmatch   -- 

    self.ids = assert(conf.ids)
    self.sortids = assert(conf.sortids)
    self.yong_pool = {}
    self.old_pool = ggclass.cranks.new(0,self.ids,self.sortids)
    self.expire_pool = ggclass.cranks.new(0,self.ids,self.sortids)
end

function cmatchpool:config(conf)
    self.tick = assert(conf.tick)
    self.tick = self.tick * 100
    self.yong_pool_timeout = conf.yong_pool_timeout or 0
    self.timeout = assert(conf.timeout)
    assert(self.timeout > self.yong_pool_timeout)
    self.expire_pool_timeout = conf.expire_pool_timeout or 0
    self.group_num = assert(conf.group_num)          -- 
    assert(self.group_num > 0)
    self.group_multiple = conf.group_multiple or 1   -- group_num*group_multiple,group_multiple
end

function cmatchpool:__pairs()
    if self.old_pool.length > 0 then
        return next,self.old_pool.ranks,nil
    end
    return next,self.expire_pool.ranks,nil
end

--- 
function cmatchpool:is_matching(uuid)
    local member,location = self:get_member(uuid)
    if member then
        return true
    end
    return false
end

function cmatchpool:get_member(uuid)
    local member = self.yong_pool[uuid]
    if member then
        return member,cmatchpool.YONG_POOL
    end
    local member = self.old_pool:get(uuid)
    if member then
        return member,cmatchpool.OLD_POOL
    end
    local member = self.expire_pool:get(uuid)
    if member then
        return member,cmatchpool.EXPIRE_POOL
    end
end

function cmatchpool:get_progress(location)
    if location == cmatchpool.YONG_POOL then
        return 1
    elseif location == cmatchpool.OLD_POOL then
        return self.old_pool.length
    else
        return self.expire_pool.length
    end
end

function cmatchpool:is_timeout(member,now)
    now = now or os.time()
    local timeout = member.timeout or self.timeout
    if now >= (member.match_time + timeout) then
        return true
    end
    return false
end

--- 
--@param[type=table] member ,idssortids
function cmatchpool:match(member)
    local uuid = self.old_pool:get_first_id(member)
    if self:is_matching(uuid) then
        return
    end
    local now = os.time()
    member.match_time = now
    member.timeout = member.timeout or self.timeout
    if self.yong_pool_timeout > 0 then
        member.yong_pool_expire_time = now + math.random(self.yong_pool_timeout,self.yong_pool_timeout+2)
        self.yong_pool[uuid] = member
    else
        self.old_pool:add(member)
    end
    if self.on_match then
        self.on_match(member)
    end
end

--- 
function cmatchpool:unmatch(uuid)
    local member,location = self:get_member(uuid)
    if location == cmatchpool.YONG_POOL then
        self.yong_pool[uuid] = nil
    elseif location == cmatchpool.OLD_POOL then
        self.old_pool:del(uuid)
    else
        self.expire_pool:del(uuid)
    end
    if not member then
        return
    end
    if self.on_unmatch then
        self.on_unmatch(member,0)
    end
end

function cmatchpool:shuffle(list)
    local len = #list
    for i=1,len do
        local idx = math.random(1,len)
        local tmp = list[idx]
        list[idx] = list[i]
        list[i] = tmp
    end
end

--- 
function cmatchpool:start_timer()
    skynet.timeout(self.tick,function ()
        if self.cancel_timer then
            return
        end
        self:start_timer()
    end)
    local yong_pool_length = 0
    for id,member in pairs(self.yong_pool) do
        yong_pool_length = yong_pool_length + 1
    end
    if yong_pool_length + self.old_pool.length >= self.group_num * self.group_multiple then
        for uuid,member in pairs(self.yong_pool) do
            self.old_pool:add(member)
        end
        self.yong_pool = {}
    end
    local now = os.time()
    for uuid,member in pairs(self.yong_pool) do
        if member.yong_pool_expire_time <= now then
            self.yong_pool[uuid] = nil
            self.old_pool:add(member)
        end
    end
    while self.old_pool.length >= self.group_num do
        local members = {}
        for i=1,self.group_multiple do
            if self.old_pool.length >= self.group_num then
                for j=1, self.group_num do
                    table.insert(members,self.old_pool:delbypos(self.old_pool.length))
                end
            else
                break
            end
        end
        if #members > 0 and self.on_success then
            self:shuffle(members)
            local group = {}
            for i=1,#members do
                table.insert(group,members[i])
                if #group >= self.group_num then
                    if self.on_unmatch then
                        for j,member in ipairs(group) do
                            self.on_unmatch(member,1)
                        end
                    end
                    self.on_success(group)
                    group = {}
                end
            end
        end
    end
    for i=self.old_pool.length,1,-1 do
        local member = self.old_pool:getbypos(i)
        if self:is_timeout(member,now) then
            self.old_pool:delbypos(i)
            self.expire_pool:add(member)
       end
    end

    -- 0 <= expire_pool.length < 2 * self.group_num
    if self.expire_pool.length >= self.group_num then
        local group = {}
        for i=1,self.group_num do
            table.insert(group,self.expire_pool:delbypos(self.expire_pool.length))
        end
        if self.on_unmatch then
            for i,member in ipairs(group) do
                self.on_unmatch(member,2)
            end
        end
        self.on_timeout(group)
    end
    local group = {}
    for i=self.expire_pool.length,1,-1 do
        local member = self.expire_pool:getbypos(i)
        if self:is_timeout(member,now-self.expire_pool_timeout) then
            for j=self.expire_pool.length,1,-1 do
                table.insert(group,self.expire_pool:delbypos(j))
            end
            break
       end
    end
    if next(group) then
        if self.on_unmatch then
            for i,member in ipairs(group) do
                self.on_unmatch(member,2)
            end
        end
        self.on_timeout(group)
    end
end

--- 
function cmatchpool:stop_timer()
    self.cancel_timer = true
end

return cmatchpool
