function gg.get_pem(filename)
    if not gg.pems then
        gg.pems = {}
    end
    if not gg.pems[filename] then
        local fd = io.open(filename,"rb")
        local pem = fd:read("*a")
        fd:close()
        gg.pems[filename] = pem
    end
    return gg.pems[filename]
end