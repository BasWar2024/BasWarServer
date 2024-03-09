local handler = {}

function handler.exec(linkobj,header,args)
    gg.proxy.center:send("api","updateItemProductCfg")
    httpc.send_json(linkobj, 200,"success")
end

function __hotfix(module)
    gg.client:open()
end

return handler