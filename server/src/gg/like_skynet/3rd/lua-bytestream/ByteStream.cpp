// little-endian
#include "ByteStream.h"

namespace MapLib {

    ByteStream::ByteStream(uint32_t size) {
        this->buffer = NULL;
        this->ppool = NULL;
        this->next = NULL;
        this->init(size);
    }

    ByteStream::~ByteStream() {
        if (!this->buffer) {
            return;
        }
        delete[]this->buffer;
    }

    void ByteStream::init(uint32_t size) {
        this->pos = 0;
        if(this->buffer == NULL){
            this->capcity = size;
            this->buffer = new uint8_t[this->capcity];
        } else {
            this->expand(size);
        }
    }

    void ByteStream::writeByte(uint8_t b) {
        this->expand(sizeof(uint8_t));
        this->_writeByte(b);
    }

    void ByteStream::writeUInt8(uint8_t value) {
        this->writeByte(value);
    }

    void ByteStream::writeUInt16(uint16_t value) {
        int len = sizeof(uint16_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i*8) & 0xff));
	    }
    }

    void ByteStream::writeUInt32(uint32_t value) {
        int len = sizeof(uint32_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i*8) & 0xff));
	    }
    }

    void ByteStream::writeUInt64(uint64_t value) {
        int len = sizeof(uint64_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i * 8) & 0xff));
	    }
    }
    void ByteStream::writeInt8(int8_t value) {
        this->writeByte(value);
    }

    void ByteStream::writeInt16(int16_t value) {
        int len = sizeof(int16_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i*8) & 0xff));
	    }
    }

    void ByteStream::writeInt32(int32_t value) {
        int len = sizeof(int32_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i*8) & 0xff));
	    }
    }

    void ByteStream::writeInt64(int64_t value) {
        int len = sizeof(int64_t);
        this->expand(len);
        for (int i = 0; i < len; i++) {
            this->_writeByte((uint8_t)((value >> i * 8) & 0xff));
	    }
    }

    void ByteStream::writeFloat(mfloat_t value,int base) {
        // 
        uint32_t number = (uint32_t)(value * pow(10,base));
        this->writeUInt32(number);
    }

    void ByteStream::writeString(const char* ptr, uint16_t length) {
        this->writeUInt16(length);
        this->write((uint8_t*)ptr,0,length);
    }

    void ByteStream::write(uint8_t data[], uint32_t offset, uint32_t length) {
        this->expand(length);
        for (uint32_t i = 0; i < length; i++) {
            this->_writeByte(data[offset + i]);
        }
    }

    uint8_t ByteStream::readByte() {
        return this->buffer[this->pos++];
    }

    uint8_t ByteStream::readUInt8() {
        return this->readByte();
    }

    uint16_t ByteStream::readUInt16() {
        uint16_t number = 0;
        int len = 2;
        for (int i = 0; i < len; i++) {
            uint16_t b = this->readByte();
            number += (b << i * 8);
        }
        return number;
    }

    uint32_t ByteStream::readUInt32() {
        uint32_t number = 0;
        int len = 4;
        for (int i = 0; i < len; i++) {
            uint32_t b = this->readByte();
            number += (b << i * 8);
        }
        return number;
    }

    uint64_t ByteStream::readUInt64() {
        uint64_t number = 0;
        int len = 8;
        for (int i = 0; i < len; i++) {
            uint64_t b = this->readByte();
            number += (b << i * 8);
        }
        return number;
    }

    int8_t ByteStream::readInt8() {
        return (int8_t)this->readByte();
    }

    int16_t ByteStream::readInt16() {
        uint16_t number = 0;
        int len = 2;
        for (int i = 0; i < len; i++) {
            uint16_t b = this->readByte();
            number += (b << i * 8);
        }
        return (int16_t)number;
    }

    int32_t ByteStream::readInt32() {
        uint32_t number = 0;
        int len = 4;
        for (int i = 0; i < len; i++) {
            uint32_t b = this->readByte();
            number += (b << i * 8);
        }
        return (int32_t)number;
    }

    int64_t ByteStream::readInt64() {
        uint64_t number = 0;
        int len = 8;
        for (int i = 0; i < len; i++) {
            uint64_t b = this->readByte();
            number += (b << i * 8);
        }
        return (int64_t)number;
    }

    mfloat_t ByteStream::readFloat(int base) {
        int number = this->readUInt32();
        return (float)number/pow(10,base);
    }

    const char* ByteStream::readString(uint16_t* length) {
        *length = this->readUInt16();
        const char*ptr = (const char*)this->buffer + this->pos;
        this->seek(*length,ByteStreamSeek::Cur);
        return ptr;
    }

    uint32_t ByteStream::read(uint8_t data[], uint32_t offset, uint32_t length) {
        for (uint32_t i = 0; i < length; i++) {
            if (this->pos >= this->capcity) {
                return i;
            }
            data[offset + i] = this->readByte();
        }
        return length;
    }

    uint8_t* ByteStream::getBuffer() {
        return this->buffer;
    }

    uint32_t ByteStream::getCapcity() {
        return this->capcity;
    }

    uint32_t ByteStream::getPos() {
        return this->pos;
    }

    uint32_t ByteStream::seek(int offset, int whence) {
        switch (whence) {
        case ByteStreamSeek::Begin:
            this->pos = 0 + offset;
            break;
        case ByteStreamSeek::Cur:
            this->pos = this->pos + offset;
            break;
        case ByteStreamSeek::End:
            this->pos = this->pos + offset;
            break;
        default:
            return this->pos;
        }
        return this->pos;
    }

    void ByteStream::expand(uint32_t size) {
        if (this->capcity - this->pos < size) {
            uint32_t oldCapcity = this->capcity;
            uint32_t newCapcity = this->capcity;
            while (newCapcity - this->pos < size) {
                newCapcity = newCapcity * 2;
            }
            uint8_t* newBuffer = new uint8_t[newCapcity];
            if (this->buffer) {
                memcpy(newBuffer, this->buffer, oldCapcity);
                delete[]this->buffer;
            }
            this->buffer = newBuffer;
            this->capcity = newCapcity;
        }
    }

    void ByteStream::_writeByte(uint8_t b) {
        assert(this->pos < this->capcity);
        this->buffer[this->pos++] = b;
    }

    void ByteStream::readFile(const char* filename) {
        this->filename = filename;
        FILE* fp = fopen(filename, "rb");
        if (!fp) {
            perror(filename);
            return;
        }
        fseek(fp, 0, SEEK_END);
        int length = ftell(fp);
        fseek(fp, 0, SEEK_SET);
        this->expand(length);
        fread(this->buffer, 1, length, fp);
        this->pos = length;
        fclose(fp);
    }

    void ByteStream::writeFile(const char* filename) {
        FILE* fp = fopen(filename, "wb");
        fwrite(this->buffer, 1, this->pos, fp);
        fclose(fp);
    }
}
