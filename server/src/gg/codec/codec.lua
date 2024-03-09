--- 
--@script gg.codec.codec
--@author sundream
--@release 2018/12/25 10:30:00

local sproto = require "gg.codec.sprotox"
local protobuf = require "gg.codec.protobuf"
local json = require "gg.codec.jsonx"
local bytestream = require "gg.codec.bytestream"

local codec = {}

--- codec
--@param[type=table] conf 
--@usage
--  -- sproto
--  local codecobj = codec.new("sproto",{
--      c2s = "src/etc/proto/sproto/all.spb",
--      s2c = "src/etc/proto/sproto/all.spb",
--      binary = true,
--  })
--  -- protobuf
--  local codecobj = codec.new("protobuf",{
--      pbfile = "src/etc/proto/protobuf/all.pb",
--      idfile = "src/etc/proto/protobuf/message_define.lua",
--  })
--
--  -- json
--  local codecobj = codec.new("json",{
--  })
--  -- bytestream
--  local codecobj = codec.new("bytestream",{
--  })
function codec.new(proto_type,conf)
    local self = {}
    if proto_type == "protobuf" then
        -- protobuf3
        self.proto = protobuf.new(conf)
    elseif proto_type == "sproto" then
        self.proto = sproto.new(conf)
    elseif proto_type == "bytestream" then
        self.proto = bytestream.new(conf)
    else
        assert(proto_type == "json")
        self.proto = json.new(conf)
    end
    return setmetatable(self,{__index=codec})
end

--- 
function codec:reload()
    self.proto:reload()
end

--- 
--@param[type=table] message 
--@param[type=function] encrypt 
--@return[type=string] 
--@usage
--  -- 
--  local bin = codecobj:pack_message(cmd,args,false,session,ud)
--  -- 
--  local bin = codecobj:pack_message(cmd,args,true,session,ud)
function codec:pack_message(cmd,args,response,session,ud,encrypt)
    return self.proto:pack_message(cmd,args,response,session,ud,encrypt)
end

--- 
--@param[type=string] msg 
--@param[type=function] decrypt 
--@return[type=string] cmd ()
--@return[type=table] args (),
--@return[type=int] response true--,false--
--@return[type=int] session ID
--@return[type=table] ud 
function codec:unpack_message(msg,decrypt)
    return self.proto:unpack_message(msg,decrypt)
end

return codec