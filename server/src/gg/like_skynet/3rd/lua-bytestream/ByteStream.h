#ifndef ByteStream_H
#define ByteStream_H

typedef double mfloat_t;

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string>
#include <math.h>
#include <assert.h>

#include <string.h>

namespace MapLib {

    enum ByteStreamSeek {
        Begin = 0,
        Cur = 1,
        End = 2,
    };

    class ByteStream {
    public:
        ByteStream(uint32_t size = 8);
        ~ByteStream();

        void writeByte(uint8_t b);
        void writeUInt8(uint8_t value);
        void writeUInt16(uint16_t value);
        void writeUInt32(uint32_t value);
        void writeUInt64(uint64_t value);

        void writeInt8(int8_t value);
        void writeInt16(int16_t value);
        void writeInt32(int32_t value);
        void writeInt64(int64_t value);

        void writeFloat(mfloat_t value,int base=3);
        void writeString(const char* ptr, uint16_t length);
        void write(uint8_t data[], uint32_t offset, uint32_t length);

        uint8_t readByte();
        uint8_t readUInt8();
        uint16_t readUInt16();
        uint32_t readUInt32();
        uint64_t readUInt64();

        int8_t readInt8();
        int16_t readInt16();
        int32_t readInt32();
        int64_t readInt64();

        mfloat_t readFloat(int base=3);
        const char* readString(uint16_t* length);
        uint32_t read(uint8_t data[], uint32_t offset, uint32_t length);

        uint8_t* getBuffer();
        uint32_t getCapcity();
        uint32_t getPos();

        uint32_t seek(int offset, int whence);

        void readFile(const char* filename);
        void writeFile(const char* filename);

        void init(uint32_t size);
    public:
        std::string filename;
        void * ppool;
        ByteStream * next;
    private:
        uint8_t* buffer;
        uint32_t capcity;
        uint32_t pos;
        void expand(uint32_t size);
        void _writeByte(uint8_t b);
    };
}
#endif
