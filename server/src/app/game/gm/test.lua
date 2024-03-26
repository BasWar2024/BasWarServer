local cgm = reload_class("cgm")

---"": ""
---@usage
---"": echo ""
---"": echo hello
function cgm:echo(args)
    local ok,msg = gg.checkargs(args,"string")
    if not ok then
        return self:say(""": echo """)
    end
    return msg
end

function __hotfix(module)
    gg.gm:hotfix_gm()
end
