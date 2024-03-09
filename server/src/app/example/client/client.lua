local cclient = reload_class("cclient")

function cclient:open()
end

function __hotfix(module)
    gg.client:open()
end

return cclient
