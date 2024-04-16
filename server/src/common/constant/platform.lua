constant.PLATFORM_MAX = 9
constant.PLATFORM_MIN = 1
constant.PLATFORM_0 = "all"       
constant.PLATFORM_1 = "local"    -- local("") 
constant.PLATFORM_2 = "androidGB"  --androidGB(""android"")
constant.PLATFORM_3 = "iosGB"       -- iosGB(""ios"")
constant.PLATFORM_4 = "androidGooglePlay"  --androidGooglePlay(""googleplay) 
constant.PLATFORM_5 = "iosAppstore"  --iosAppstore(""iosAppstore)
constant.PLATFORM_6 = "androidFB"  --androidFB(facebook android) 
constant.PLATFORM_7 = "iosFB"  --iosFB(facebook ios)  
constant.PLATFORM_8 = "androidTT"  --androidTT(tiktok android) 
constant.PLATFORM_9 = "iosTT"  --iosTT(tiktok ios) 


-- ""
constant.PLATFORM_SORT_PRE = "PLATFORM_SORT_"
constant.PLATFORM_SORT_LOCAL = 1
constant.PLATFORM_SORT_ANDROIDGB = 2
constant.PLATFORM_SORT_IOSGB = 3
constant.PLATFORM_SORT_ANDROIDGOOGLEPLAY = 4
constant.PLATFORM_SORT_IOSAPPSTORE = 5
constant.PLATFORM_SORT_ANDROIDFB = 6
constant.PLATFORM_SORT_IOSFB = 7
constant.PLATFORM_SORT_ANDROIDTT = 8
constant.PLATFORM_SORT_IOSTT = 9

function constant.getAllPlatform()
    local platformList = {}
    for i = constant.PLATFORM_MIN, constant.PLATFORM_MAX do
        local platform = constant["PLATFORM_" .. i]
        if platform then
            table.insert(platformList, platform)
        end
    end
    return platformList
end

function constant.getValidPlatform()
    local validPlatform = {}
    validPlatform[constant.PLATFORM_1] = true
    validPlatform[constant.PLATFORM_2] = true
    validPlatform[constant.PLATFORM_3] = true
    validPlatform[constant.PLATFORM_4] = true
    validPlatform[constant.PLATFORM_5] = true
    validPlatform[constant.PLATFORM_6] = true
    validPlatform[constant.PLATFORM_7] = true
    validPlatform[constant.PLATFORM_8] = true
    validPlatform[constant.PLATFORM_9] = true
    return validPlatform
end