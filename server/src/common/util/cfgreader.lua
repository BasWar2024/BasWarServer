
cfgreader = function (name)
    local env = _ENV or _G
    local filename = package.searchpath(name, package.path)
    if filename then
        local fp = io.open(filename,"rb")
        local text = fp:read("*a")
        fp:close()
        local chunk, err = load(text, filename, "bt", env)
        if chunk then
            chunk = chunk()
            return chunk
        end
    end
end
return cfgreader