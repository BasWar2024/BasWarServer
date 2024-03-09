local crypt = require "skynet.crypt"
local chandshake = {}
chandshake.__index = chandshake

function chandshake.new()
    local self = {}
    self.step = 0
    self.result = nil
    self.raw_encrypt_key = nil
    self.encrypt_key = nil
    self.master_linkid = nil            -- ID
    return setmetatable(self,chandshake)
end

function chandshake:unpack_request(msg)
    local tbl = {}
    for m in msg:gmatch("([^,]+)") do
        local k,v = m:match("([^|]+)|([^|]+)")
        k = crypt.base64decode(k)
        v = crypt.base64decode(v)
        tbl[k] = v
    end
    return tbl
end

function chandshake:pack_request(tbl)
    local list = {}
    for k,v in pairs(tbl) do
        table.insert(list,string.format("%s|%s",crypt.base64encode(k),crypt.base64encode(v)))
    end
    return table.concat(list,",")
end


--: [S2C]challenge()+serverkey
function chandshake:pack_challenge(linkid,encrypt_algorithm)
    assert(self.step == 0)
    self.step = 1
    local challenge = nil
    if encrypt_algorithm ~= "nil" then
        challenge = crypt.randomkey()
    else
        self.result = "OK"
    end
    local serverkey = crypt.dhexchange(crypt.randomkey())
    self.challenge = challenge
    self.serverkey = serverkey
    local msg = self:pack_request({
        proto = "S2C_HandShake_Challenge",
        -- challengenil
        challenge = challenge,
        serverkey = serverkey,
        linkid = linkid,
        encrypt_algorithm = encrypt_algorithm,
    })
    return msg
end

function chandshake:getInt16EncryptKey(encryptKey)
    local result = 0
    for i=1,#encryptKey,2 do
        result = result ~ ((string.byte(encryptKey,i,i) << 8) + string.byte(encryptKey,i+1,i+1))
    end
    return result
end

function chandshake:_do_handshake(msg)
    local request = self:unpack_request(msg)
    local proto = request.proto
    assert(not self.result)
    if proto == "C2S_HandShake_ClientKey" then
        --: [C2S]clientkey,clientkey+serverkey
        if self.step ~= 1 then
            return false,"skip handshake step 1?"
        end
        self.step = 2
        local clientkey = request.clientkey
        local master_linkid = request.master_linkid
        self.clientkey = clientkey
        self.master_linkid = tonumber(master_linkid)
        local serverkey = self.serverkey
        self.raw_encrypt_key = crypt.dhsecret(clientkey,serverkey)
        self.encrypt_key = self:getInt16EncryptKey(self.raw_encrypt_key)
    elseif proto == "C2S_HandShake_CheckSecret" then
        --: [C2S]clientkey+serverkey,challenge,
        if self.step ~= 2 then
            return false,"skip handshake step 2?"
        end
        self.step = 3
        local challenge = self.challenge
        local encrypt_key = self.raw_encrypt_key
        local client_encrypt = request.encrypt
        local server_encrypt = crypt.hmac64(challenge,encrypt_key)
        self.result = client_encrypt == server_encrypt and "OK" or "FAIL"
        if self.result ~= "OK" then
            return false,"check secret fail"
        end
    else
        return false,"handshake first!"
    end
    return true
end

function chandshake:do_handshake(msg)
    local call_ok,ok,err = pcall(self._do_handshake,self,msg)
    if not call_ok then
        err = ok
        ok = false
    end
    return ok,err
end

--: [S2C]
function chandshake:pack_result()
    assert(self.step == 3)
    self.step = 4
    local msg = self:pack_request({
        proto = "S2C_HandShake_Result",
        result = self.result
    })
    return msg
end

return chandshake