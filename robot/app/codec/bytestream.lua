---bytestream
--@script gg.codec.bytestream
--@author sundream
--@release 2019/6/20 10:30:00
--@usage
--:
--  2byte()id + 


local bytestream = {}

function bytestream.new(conf)
    local self = {}
    return setmetatable(self,{__index=bytestream})
end

function bytestream:reload()
end

function bytestream:pack_message(cmd,args,response,session,ud,encrypt)
    return string.pack("<I2",cmd) .. (args or "")
end

function bytestream:unpack_message(msg,decrypt)
    local cmd = string.unpack("<I2",msg)
    local args = string.sub(msg,3)
    return cmd,args,false,0,nil
end

return bytestream