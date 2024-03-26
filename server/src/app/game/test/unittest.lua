unittest = unittest or {}

function unittest.testall()
    local sum = table.count(unittest) - 1
    local stat = {
        fail = 0,
        sum = sum,
    }
    logger.logf("debug","test","op=start_unittest,sum=%s",stat.sum)
    for name,func in pairs(unittest) do
        if name ~= "testall" then
            local isok = xpcall(func,function (errmsg)
                logger.logf("debug","test","op=%s,isok=fail,errmsg=%s\n%s",name,errmsg,debug.traceback())
            end)
            if not isok then
                stat.fail = stat.fail + 1
            else
                logger.logf("debug","test","op=%s,isok=%s",name,isok)
            end
        end
    end
    logger.logf("debug","test","op=finish_unittest,sum=%s,fail=%s",stat.sum,stat.fail)
end

return unittest
