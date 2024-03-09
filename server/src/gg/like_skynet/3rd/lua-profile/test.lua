local profile = require "profile"

function test1()
    local sum = 0
    for i=1,50 do
        sum = sum + i
    end
    test2()
    test3()
    test2()
end

function test2()
    print("test2")
end

function test3()
    local func = coroutine.wrap(test2)
    func()
end

local function main()
    profile.start()
    test1()
    print(profile.report())
    profile.stop()
end

main()