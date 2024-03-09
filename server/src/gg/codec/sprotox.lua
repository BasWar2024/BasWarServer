local sproto = require "gg.codec.sproto"

local sprotox = {}

function sprotox.new(conf)
    local c2s = assert(conf.c2s)
    local s2c = assert(conf.s2c)
    local binary = conf.binary and true or false
    local packagename = conf.packagename or "package"
    local self = {
        c2s = c2s,
        s2c = s2c,
        binary = binary,
        packagename = packagename,
        c2s_sproto = sproto.create(c2s,binary,packagename),
        s2c_sproto = sproto.create(s2c,binary,packagename),
    }
    return setmetatable(self,{__index=sprotox})
end

function sprotox:reload()
    self.c2s_sproto = sproto.create(self.c2s,self.binary,self.packagename)
    self.s2c_sproto = sproto.create(self.s2c,self.binary,self.packagename)
end

function sprotox:pack_message(cmd,args,response,session,ud,encrypt)
    return self.s2c_sproto:pack_message(cmd,args,response,session,ud,encrypt)
end

function sprotox:unpack_message(msg,decrypt)
    return self.c2s_sproto:unpack_message(msg,decrypt)
end

return sprotox
