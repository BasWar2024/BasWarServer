local crab = require "crab.c"
local utf8 = require "utf8.c"

local WordFilter = class("WordFilter")
WordFilter.CODE_OK = 0
WordFilter.CODE_TOO_SHORT = 1
WordFilter.CODE_TOO_LONG = 2
WordFilter.CODE_FMT_ERR = 3
WordFilter.CODE_INVALID = 4


--- 
--@param[type=table] filterWords ,:{{word=},...}
--@param[type=table] extraInvalidWords ,,
--@param[type=int,opt] replaceChar utf32,0x23'#','*'
function WordFilter:ctor(filterWords,extraInvalidWords,replaceChar)
    local filterTexts = {}
    for i,v in ipairs(filterWords) do
        if v.word ~= "" then
            local texts = {}
            assert(utf8.toutf32(v.word,texts),"non uft8 word detected: " .. v.word)
            table.insert(filterTexts,texts)
        end
    end
    for i,word in ipairs(extraInvalidWords) do
        local texts = {}
        assert(utf8.toutf32(word,texts),"non uft8 word detected: " .. word)
        table.insert(filterTexts,texts)
    end
    self.crabFilter = crab.new(filterTexts)
    if replaceChar and replaceChar ~= 0 then
        self.crabFilter:replace_rune(replaceChar)
    end
end

--- ,
--@param[type=string] text 
--@param[type=int] minLen 
--@param[type=int] maxLen 
--@return[type=int] (0=OK,1=,2=,3=,4=)
function WordFilter:isValidText(text,minLen,maxLen)
    local chars = {}
    if not utf8.toutf32(text,chars) then
        return self.CODE_FMT_ERR
    end
    local len = #chars
    if len < minLen then
        return self.CODE_TOO_SHORT
    end
    if len > maxLen then
        return self.CODE_TOO_LONG
    end
    if self.crabFilter:filter(chars) then
        return self.CODE_INVALID
    end
    return self.CODE_OK
end

--- 
--@param[type=string] text 
--@return[type=bool] false=utf8
--@return[type=bool] true=
--@return[type=string] 
function WordFilter:filter(text)
    local chars = {}
    if not utf8.toutf32(text,chars) then
        return false,false,"UTF8"
    end
    local change = self.crabFilter:filter(chars)
    text = utf8.toutf8(chars)
    return true,change,text
end

return WordFilter