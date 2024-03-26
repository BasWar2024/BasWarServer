-- ""api
gg.api = gg.api or {}

local api = gg.api

function api.ping()
    return "pong"
end

function api.exit()
    gg.exit()
end

function api.runCommand(dbName, tableName, cmd, query, cond, cond1, cond2, ...)
    local db = gg.getdb(dbName)
    if not db then
        return
    end

    if cmd == "find" then
        local docs = {}
        local cursor = db[tableName]:find(query, cond, cond1, cond2, ...)
        while cursor:hasNext() do
            local doc = cursor:next()
            table.insert(docs, doc)
        end
        return docs
    elseif cmd == "findCount" then
        return db[tableName]:find(query):count(cond)
    elseif cmd == "findSortLimit" then
        local docs = {}
        local cursor = db[tableName]:find(query):sort(cond):limit(cond1)
        while cursor:hasNext() do
            local doc = cursor:next()
            table.insert(docs, doc)
        end
        return docs
    elseif cmd == "findSortSkipLimit" then
        local docs = {}
        local cursor = db[tableName]:find(query):sort(cond):skip(cond1):limit(cond2)
        while cursor:hasNext() do
            local doc = cursor:next()
            table.insert(docs, doc)
        end
        return docs
    elseif cmd == "runCommand" then
        return db[cmd](db, query, cond, cond1, cond2, ...)
    end
    return db[tableName][cmd](db[tableName], query, cond, cond1, cond2, ...)
end

return api