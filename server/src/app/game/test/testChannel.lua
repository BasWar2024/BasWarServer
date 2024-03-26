function unittest.testChannel()
    local function dispatch(channel,who,is_queue,...)
        logger.print("dispatch",channel.id,who,is_queue,...)
    end
    local channels = ggclass.cchannels.new(dispatch)
    local id = channels:new_channel()
    logger.print("channel id",id)
    channels:subscribe(id,1)
    channels:subscribe(id,2)
    channels:publish(id,"hello")
    channels:unsubscribe(id,1)
    channels:publish(id,"world")
    channels:unsubscribe(id,2)
    channels:del(id)

    local id
    local name = "test"
    local channel = channels:query_channel(name)
    if not channel then
        id = channels:new_channel()
        channels:name_channel(name,id)
    else
        id = channel.id
    end
    channels:subscribe(id,3)
    channels:publish(id,"good")
    channels:unsubscribe(id,3)
    channels:publish(id,"good")
    channels:subscribe(id,3)
    local time = 200
    channels:mark_delay(id,time*10,2,true)
    channels:publish(id,"one")
    channels:publish(id,"two")
    channels:publish(id,"three")
    skynet.sleep(time*2)
    channels:mark_delay(id,0,0,false)
    channels:publish(id,"one")
    channels:publish(id,"two")
    channels:publish(id,"three")
    channels:del(id)
    logger.print(table.dump(channels))
end