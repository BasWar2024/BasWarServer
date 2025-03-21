function unittest.testByteStream()

    local bscore= require("bytestream.core")

    local bs = bscore.new(64)
    bs:writeByte(1)
    bs:writeInt8(-8)
    bs:writeInt16(-16)
    bs:writeInt32(-32)
    bs:writeInt64(-64)
    -- bs:writeFloat(1234.1234)
    -- bs:writeFloat(1234.1234,4)
    -- bs:writeFloat(1234.1234,5)
    bs:writeString("abcdefg")
    bs:write("ABCDEFG",0)
    bs:write("HIJKLMN",3,2)
    bs:writeString("end")
    bs:writeFile("./testbs.byte")
    bscore.free(bs)

    bs2 = bscore.new()
    bs2:readFile("./testbs.byte")
    bs2:seek(0,bs2.Begin)
    logger.print("readByte",bs2:readByte())
    logger.print("readInt8",bs2:readInt8())
    logger.print("readInt16",bs2:readInt16())
    logger.print("readInt32",bs2:readInt32())
    logger.print("readInt64",bs2:readInt64())
    -- logger.print("readFloat",bs2:readFloat())
    -- logger.print("readFloat",bs2:readFloat(4))
    -- logger.print("readFloat",bs2:readFloat(5))
    logger.print("readString",bs2:readString())
    logger.print("read",bs2:read(7))
    logger.print("read",bs2:read(2))
    logger.print("readString",bs2:readString())
    logger.print("Begin Cur End",bs2.Begin,bs2.Cur,bs2.End)
    logger.print("Begin Cur End",bscore.Begin,bscore.Cur,bscore.End)


    logger.print(string.unpack("<i1i1i2i4i8s2",bs2:tostring()))

    local data = string.pack("<i1i2i4i8s2s2",-1,-2,-4,-8,"xyz@#$","end")
    bs3 = bscore.new()
    bs3:write(data,0)
    bs3:seek(0,bs3.Begin)
    logger.print("readInt8",bs3:readInt8())
    logger.print("readInt16",bs3:readInt16())
    logger.print("readInt32",bs3:readInt32())
    logger.print("readInt64",bs3:readInt64())
    logger.print("readString",bs3:readString())
    logger.print("readString",bs3:readString())
    bs = nil
    bs2 = nil
    collectgarbage("collect")
    logger.print("testByteString ok")
end