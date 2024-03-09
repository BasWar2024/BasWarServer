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

local function test()
    local i18n = require "i18n"
    i18n.init({
        original_lang = "zh_CN",
        languages = languages,
    })
    local text = i18n.format(",1:{0},2:{1}","",1)
    local str = i18n.translateto("zh_CN",text)
    print(str)
    local str = i18n.translateto("en_US",text)
    print(str)
    local text = i18n.format("{0}",
                        "i18n.format")
    local str = i18n.translateto("en_US",text)
    print(str)
    local text = i18n.format("{0}:",
                        i18n.format(""))
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format('',string.format('1'),i18n.format('2'))
    local str = i18n.translateto("en_US",text)
    print(str)

    -- 
    local text = i18n.format(",1:{0},2:{1}",
                        i18n.format(",1:{0},2:{1}"),1)
    local str = i18n.translateto("en_US",text)
    print(str)

    -- 
    local text = i18n.format(",={target},npc={npc}",{target="",npc="npc90001"})
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format(1,"1","2")
    local str = i18n.translateto("en_US", text)
    print(str)

    -- exception test
    local text = i18n.format("{")
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format("{}")
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format("{name}")
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format("{0},{1}",0)
    local str = i18n.translateto("en_US",text)
    print(str)

    local text = i18n.format("}")
    local str = i18n.translateto("en_US",text)
    print(str)
end

test()