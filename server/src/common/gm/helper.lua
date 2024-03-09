local cgm = reload_class("cgm")

---: GM.txt
---@usage buildgmdoc
function cgm:buildgmdoc()
    if skynet.config.clusterid ~= "master" and skynet.config.clusterid ~= "main" then
        -- ,
        local docfilename = "src/app/game/gm/gmdoc.txt"
        local fd = io.open(docfilename,"rb")
        local doc = {}
        for line in fd:lines("*l") do
            table.insert(doc,line)
        end
        fd:close()
        self.__doc = doc
        return
    end
    local doc = {"buildgmdoc,!!!\n"}
    local tmpfilename = ".gmdoc.tmp"
    local gmcode_paths = {"src/app/game/gm/","src/common/gm/",}
    for i,gmcode_path in ipairs(gmcode_paths) do
        -- all filename in $gmcode_path
        os.execute("ls -l " .. gmcode_path .. " | awk '{print $9}' > " .. tmpfilename)
        local fdin = io.open(tmpfilename,"rb")
        for filename in fdin:lines("*l") do
            if not string.match(filename,"^%s*$") then
                if filename:sub(-4) == ".lua" then
                    local fd = io.open(gmcode_path .. filename,"rb")
                    local tbl = {}
                    local open = false
                    for line in fd:lines("*l") do
                        line = string.match(line,"^%-%-%-%s*(.+)$")
                        if line then
                            table.insert(tbl,line)
                            open = true
                        else
                            if open then
                                table.insert(tbl,"")
                            end
                            open = false
                        end
                    end
                    fd:close()
                    filename = string.gsub(filename,"%.lua","")
                    table.insert(doc,string.format("[%s]",filename))
                    for _,line in pairs(tbl) do
                        table.insert(doc,line)
                    end
                    table.insert(doc,"")
                end
            end
        end
        fdin:close()
        os.execute("rm -rf " .. tmpfilename)
    end
    self.__doc = doc
    doc = table.concat(doc,"\n")

    local docfilename = "src/app/game/gm/gmdoc.txt"
    local fdout = io.open(docfilename,"wb")
    fdout:write(doc)
    fdout:close()

    local docpath = skynet.config.docpath
    if not docpath then
        return
    end
    local app_type = skynet.config.type or "game"
    local gm_path = docpath .. "/gm"
    local filename = string.format("%s.txt",app_type)
    local docfilename = string.format("%s/%s",gm_path,filename)
    os.execute(string.format("mkdir -p %s",gm_path))
    --[[
    if skynet.config.repo_type == "svn" then
        os.execute(string.format("svn update --accept=theirs-full %s",gm_path))
    else
        os.execute(string.format("git checkout HEAD -- %s",docfilename))
    end
    ]]
    local fdout = io.open(docfilename,"wb")
    fdout:write(doc)
    fdout:close()
    --[[
    if skynet.config.repo_type == "svn" then
        os.execute(string.format("svn add --force %s",gm_path))
        os.execute(string.format("svn commit %s -m 'GM'",gm_path))
    else
        os.execute(string.format("git add %s",docfilename))
        os.execute(string.format("git commit -m 'GM'"))
        os.execute(string.format("git push"))
    end
    ]]
    return
end

---: 
---@usage help []
function cgm:help(args)
    local isok,args = gg.checkargs(args,"*")
    if not isok then
        local usage = ": help []"
        return self:say(usage)
    end
    local patten = args[1]
    local doc = self:getdoc()
    if not patten then
        local findlines = doc
        local step = 200
        for i=1,#findlines,step do
            local help = table.concat(table.slice(findlines,i,i+step-1),"\n")
            self:say(help)
        end
        return table.concat(findlines,"\n")
    end
    local emptyline,startlineno = 1,1
    local maxlineno = #doc
    local findlines = {}
    local lineno = 0
    while lineno < maxlineno do
        lineno = lineno + 1
        local line = doc[lineno]
        if not line then
            break
        end
        if line == "" or line == "\r" or line == "\n" or line == "\r\n" then
            emptyline = lineno
        else
            if string.find(line,patten) or string.find(line:lower(),patten) then
                for i=emptyline+1,maxlineno do
                    local curline = doc[i]
                    if not (curline == "" or curline == "\r" or curline == "\n" or curline == "\r\n") then
                        table.insert(findlines,curline)
                    else
                        table.insert(findlines,string.rep("-",20))
                        emptyline = i
                        if i > lineno then
                            lineno = i
                        end
                        break
                    end
                end
            end
        end
    end
    if next(findlines) then
        local step = 200
        for i=1,#findlines,step do
            local help = table.concat(table.slice(findlines,i,i+step-1),"\n")
            self:say(help)
        end
        return table.concat(findlines,"\n")
    else
        return self:say("")
    end
end

function cgm:getdoc()
    if not self.__doc then
        self:buildgmdoc()
    end
    return self.__doc
end

function __hotfix(module)
    gg.gm.__doc = nil
    gg.gm:hotfix_gm()
end

return cgm
