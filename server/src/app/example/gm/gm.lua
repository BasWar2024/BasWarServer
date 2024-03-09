local cgm = reload_class("cgm")


function cgm:_open()
    -- TODO: register gm cmd
end

function __hotfix(module)
    gg.gm:open()
end

return cgm
