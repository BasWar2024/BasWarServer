function unittest.testI18N()
    local text = i18n.format(1)
    local str = i18n.translateto("en_US", text)
    logger.print(str)
    local text = i18n. format("rpc""i18n,""1={0},""2={1}",i18n. format(""""),"""")
    logger.print("text",text)
    local str = i18n.translateto("en_US",text)
    logger.print("local",str,#str)
    local bin = i18n.serialize_text(text)
    logger.print("serialize",#bin,string.str2hex(bin))
    local clone_text = i18n.deserialize_text(bin)
    logger.print("clone_text",clone_text)
    assert(not rawequal(text,clone_text))
    local eq = getmetatable(text).__eq
    logger.print(eq(text,clone_text))
    assert(text == clone_text,text)
    local str_clone = i18n.translateto("en_US",clone_text)
    logger.print("deserialize",str_clone)

    local node = skynet.config.id
    local remote_text = gg.cluster:call(node,".main","exec","i18n.format","rpc""i18n,""1={0},""2={1}",i18n.format (""""),"""","""")
    logger.print("remote_text",type(remote_text),remote_text)
    local str = i18n.translateto("en_US",remote_text)
    logger.print("remote",str)
    assert(not rawequal(text,remote_text))
    assert(text == remote_text)

    local remote_text2 = gg.cluster:call(node,".main","exec","i18n.format","rpc""i18n,""={target},npc={npc}",{target="""",npc="npc90001"})
    local str = i18n.translateto("en_US",remote_text2)
    logger.print(str)

    local remote_text3 = gg.cluster:call(node,".main","exec","i18n.format","""")
    local str = i18n.translateto("en_US",remote_text3)
    logger.print(str)
    logger.print("testI18N ok")
end