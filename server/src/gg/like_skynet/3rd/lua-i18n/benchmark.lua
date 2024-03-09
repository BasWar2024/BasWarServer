local languages = {
    [",1:{0},2:{1}"] = {
        zh_CN = 1,
        en_US = "this is chinese,parameter 2:{1},parameter 1:{0}",
    },
    [",={target},npc={npc}"] = {
        zh_CN = 2,
        en_US = "test dictionary parameter,target={target},npc={npc}",
    }
}

local function benchmark(cnt)
    local i18n = require "i18n"
    i18n.init({
        original_lang = "zh_CN",
        languages = languages,
    })
    local time = os.clock()
    for i=1,cnt do
        local text = i18n.format(",1:{0},2:{1}","",1)
        local str = i18n.translateto("en_US",text)
    end
    local sum = os.clock() - time
    print(string.format("case= cnt=%d sum=%fs avg=%fs",cnt,sum,sum/cnt))

    local time = os.clock()
    for i=1,cnt do
        local text = i18n.format(",={target},npc={npc}",{target="",npc="npc90001"})
        local str = i18n.translateto("en_US",text)
    end
    local sum = os.clock() - time
    print(string.format("case= cnt=%d sum=%fs avg=%fs",cnt,sum,sum/cnt))

    local time = os.clock()
    for i=1,cnt do
        local text = string.format(",1:%s,2:%s","",1)
    end
    local sum = os.clock() - time
    print(string.format("case=string.format cnt=%d sum=%fs avg=%fs",cnt,sum,sum/cnt))

end

local cnt = ...
cnt = tonumber(cnt) or 1000000
benchmark(cnt)

