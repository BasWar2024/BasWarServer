# ""Lua""Google protobuf""

[![Build Status](https://img.shields.io/github/workflow/status/starwing/lua-protobuf/CI)](https://github.com/starwing/lua-protobuf/actions?query=branch%3Amaster)[![Coverage Status](https://img.shields.io/coveralls/github/starwing/lua-protobuf)](https://coveralls.io/github/starwing/lua-protobuf?branch=master)

[English](https://github.com/starwing/lua-protobuf/blob/master/README.md) | ""

---

Urho3d""：https://note.youdao.com/ynoteshare1/index.html?id=20d06649fab669371140256abd7a362b&type=note

Unreal SLua""：https://github.com/zengdelang/slua-unreal-pb

Unreal UnLua""：https://github.com/hxhb/unlua-pb

ToLua""：[""](http://changxianjie.gitee.io/unitypartner/2019/10/01/tolua""protobuf3—""lua-protobuf/)

xlua""：[""](https://github.com/91Act/build_xlua_with_libs)

QQ""：485016061 [![lua-protobuf1""](https://pub.idqqimg.com/wpa/images/group.png)](https://shang.qq.com/wpa/qunwpa?idkey=d7e2973604a723c4f77d0a837df39be26e15be2c2ec29d5ebfdb64f94e74e6ae)

"" Lua ""（5.1+、LuaJIT）""protobuf 2/3 ""。""/""protobuf wireformat ""。

""，"" `pb.load()` "" protobuf ""（schema""，.proto""）""（""schema"" `FileDescriptorSet` ""pb""），""“state”""/""。""`pb`""。

""，""：

- `pb.slice`：""wireformat""。
- `pb.buffer`：""wireformat""。
- `pb.conv`：""Lua""protobuf""。
- `pb.io`：""`pb`""：""。

""，""schema""（"".pb""），""protobuf""schema""`protoc.exe`""，""，""protobuf""，"" Lua""：`protoc.lua`""。""Lua""schema""，""`pb.load()`""。""Lua""，""，""schema""。""`protoc.exe`""`pb`""schema"".pb""。

## ""

**""**：`lua-prootbuf`""C""Lua""，""Lua""**""**""。""，""**""Lua""C""**""，""《Lua""》""，""。

""，Lua""C""，""Lua""，""XLua""C#""，""。""**""C""**，""**""**""。""C""。

""Lua""`luarocks`""（""，""**""C""**，""，""`luarocks`""，""，""Lua C""）：

```shell
luarocks install lua-protobuf
```

""`luarocks`""（""）：

```shell
git clone https://github.com/starwing/lua-protobuf
luarocks make rockspecs/lua-protobuf-scm-1.rockspec
```

""/""`luarocks`，""Python""`luarocks`——""C""——""，""Python。

```shell
pip install hererocks
git clone https://github.com/starwing/lua-protobuf
hererocks -j 2.0 -rlatest .
bin/luarocks make lua-protobuf/rockspecs/lua-protobuf-scm-1.rockspec CFLAGS="-fPIC -Wall -Wextra" LIBFLAGS="-shared"
cp protoc.lua pb.so ..
```

""Hard""，""。

""macOS""：

```shell
gcc -O2 -shared -undefined dynamic_lookup pb.c -o pb.so
```

Linux""：

```shell
gcc -O2 -shared -fPIC pb.c -o pb.so
```

Windows""（""Lua_BUILD_AS_DLL！""Windows""）：

```shell
cl /O2 /LD /Fepb.dll /I Lua53\include /DLUA_BUILD_AS_DLL pb.c Lua53\lib\lua53.lib
```

## ""

```lua
local pb = require "pb"
local protoc = require "protoc"

-- ""schema ("", "" protoc.new() "")
assert(protoc:load [[
   message Phone {
      optional string name        = 1;
      optional int64  phonenumber = 2;
   }
   message Person {
      optional string name     = 1;
      optional int32  age      = 2;
      optional string address  = 3;
      repeated Phone  contacts = 4;
   } ]])

-- lua ""
local data = {
   name = "ilse",
   age  = 18,
   contacts = {
      { name = "alice", phonenumber = 12312341234 },
      { name = "bob",   phonenumber = 45645674567 }
   }
}

-- ""Lua""
local bytes = assert(pb.encode("Person", data))
print(pb.tohex(bytes))

-- ""Lua""
local data2 = assert(pb.decode("Person", bytes))
print(require "serpent".block(data2))

```

## ""

[![""](https://img.tapimg.com/market/images/e59627dc9039ff22ba7d000b5c9fe7f6.jpg?imageView2/2/h/560/q/40/format/jpg/interlace/1/ignore-error/1)](http://djwk.qq.com)



## ""

""`.`""`:`！`.`""，""，`:`""，""。

### `protoc` ""

| ""            | ""    | ""                                          |
| --------------- | ------- | --------------------------------------------- |
| `protoc.new()`      | "" | ""                                |
| `protoc.reload()`   | `true`     | ""schema""（""）          |
| `p:parse(string[, filename])`   | table      | ""schema"" `DescriptorProto` ""Lua""  |
| `p:compile(string[, filename])` | string     | ""schema"".pb"" |
| `p:load(string[, filename])`    | `true`     | ""schema""，""`pb.load()`"" |
| `p.loaded`          | table      | "" `DescriptorProto` ""   |
| `p.unknown_import`  | ""   | ""schema""`import`""              |
| `p.unknown_type`    | ""   | ""schema""                            |
| `p.include_imports` | bool       | ""`import`""    |

""schema""，""，""。""scehma""，""schema""import""：

```lua
local p = protoc.new()
```

""，""：

```lua
-- ""……
p.unknown_import = function(self, module_name) ... end
p.unknown_type   = function(self, type_name) ... end
-- ……""
p.include_imports = true
```

`unknown_import`""`unknown_type`""：""`true`，""（""/""）""。`pb.load()`""，""。""，""Lua""，""，""：

```lua
p.unknown_type = "Foo.*"
```

""`Foo`""，""。

""，""/""。""/""，""`DescriptorProto`""（""），""，""`message`""`enum`，""：

```lua
function p:unknown_import(name)
  -- "" "foo.proto" ""，"" "my_foo.proto" ""
  return p:load("my_"..name)
end

function p:unknown_type(name)
  -- "" "Type"， "" "MyType" ""，""“.”，""。
  return ".My"..name, "message"
end
```

""，""`load()`""`compile()`""`parse()`""。""scehma""，""schema""，""schema""`import`""，""`include_imports`，""`import`""/""，""。""`include_imports`，""load""schema。

### `pb` ""

`pb`""/""、""schema""，""。

""`pb`""，""“""”""，""：

- `type`：""。`".Foo"`""proto""Foo""，""`"foo.Foo"`""`package foo;`""proto""Foo""。

- `data`：""，""`pb.Slice`""`pb.Buffer`""，""

- `iterator`：""for in""，""：

  ```lua
  for name in pb.types() do
    print(name)
  end
  ```

**""**：""`pb.load()`""，""`assert(pb.load(...))`""！""，""`assert()`""。

| ""            | ""    | ""                                          |
| --------------- | ------- | --------------------------------------------- |
| `pb.clear()`                   | None            | ""                                            |
| `pb.clear(type)`               | None            | ""                                            |
| `pb.load(data)`                | boolean,integer | ""schema""                    |
| `pb.encode(type, table)`       | string          | ""table""type""                         |
| `pb.encode(type, table, b)`    | buffer          | ""，""buffer""            |
| `pb.decode(type, data)`        | table           | ""data""type""                |
| `pb.decode(type, data, table)` | table           | ""，""                            |
| `pb.pack(fmt, ...)`            | string          | "" `buffer.pack()` ，"" |
| `pb.unpack(data, fmt, ...)`    | values...       | "" `slice.unpack()` ""    |
| `pb.types()`                   | iterator        | ""，"" |
| `pb.type(type)`                | ""        | ""          |
| `pb.fields(type)`              | iterator        | ""，"" |
| `pb.field(type, string)`       | ""   | "" |
| `pb.field(type, number)` | "" | "" |
| `pb.typefmt(type)`             | String          | "" protobuf "" pack/unpack "" |
| `pb.enum(type, string)`        | number          | ""，"" |
| `pb.enum(type, number)`        | string          | ""，"" |
| `pb.defaults(type[, boolean])` | table           | "" |
| `pb.hook(type[, function])`    | function        | "" |
| `pb.option(string)`            | string          | "" |
| `pb.state()`                   | `pb.State`      | "" |
| `pb.state(newstate \| nil)`    | `pb.State`      | ""，"" |

#### "" Schema ""

`pb.load()` ""schema""，""。""`true`，""`false`，""，""。""，""，""`NUL`""。

""schema，""schema。""。""（""import""，""），""`protoc.exe`""`protoc.lua`""schema""，""`include_imports`""。""protobuf""，""schema""。


#### ""

| Protobuf ""                                     | Lua ""                                                    |
| ------------------------------------------------- | ----------------------------------------------------------- |
| `double`, `float`                                  | `number`                                                   |
| `int32`, `uint32`, `fixed32`, `sfixed32`, `sint32` | `number` "" `integer` （Lua 5.3+）                         |
| `int64`, `uint64`, `fixed64`, `sfixed64`, `sint64` | `number` "" `"#"` "" `string` "" `integer` （Lua 5.3+） |
| `bool`                                             | `boolean`                                                  |
| `string`, `bytes`                                  | `string`                                                   |
| `message`                                          | `table`                                                    |
| `enum`                                             | `string` "" `number`                                       |

#### ""

""`pb.type()`、`pb.types()`、`pb.field()`、`pb.fields()`""。

""/""，""，""/""。""*""*""。""`foo` ""`Foo`""*""*""`".foo.Foo"`，""，""`"."`，""`".Foo"`""`Foo`""。

""`pb.type()`，""：

- name：""（""`".package.TypeName"`）
- basename：""（""`"TypeName"`）
- type：`"map"` | `"enum"` | `"message"`，""——`MapEntry`""，""，""。

`pb.types()`""，"" `pb.type()`""：

```lua
-- "" MyType ""
print(pb.type "MyType")

-- ""
for name, basename, type in pb.types() do
  print(name, basename, type)
end
```

`pb.field()` ""：

- name: ""
- number: schema""（""）
- type: ""
- default value: ""，""`nil`
- `"packed"`|`"repeated"`| `"optional"`：""，""`required`，""`optional`
- oneof_name：""oneof""，""
- , oneof_index：""oneof""，""

 `pb.fields()` ""`pb.field()`"":

```lua
-- "" MyType "" the_first_field ""
print(pb.field("MyType", "the_first_field"))

-- "" MyType ""，""（""）
for name, number, type in pb.fields "MyType" do
  print(name, number, type) -- ""
end
```

`pb.enum()` ""：

```lua
protoc:load [[
enum Color { Red = 1; Green = 2; Blue = 3 }
]]
print(pb.enum("Color", "Red")) --> 1
print(pb.enum("Color", 2)) --> "Green"
```

""“""”，""，""，""`pb.field()`""，`pb.enum()`""，""，""。

#### ""

""`pb.defaults()`	""Lua""，""。

`pb.defaults()`""，""true，""。

""`pb.decode("Type")`""Lua""。""，""，""`use_default_metatable`""，""——""，""，""，""：

```lua
   check_load [[
      message TestDefault {
         optional int32 defaulted_int = 10 [ default = 777 ];
         optional bool defaulted_bool = 11 [ default = true ];
         optional string defaulted_str = 12 [ default = "foo" ];
         optional float defaulted_num = 13 [ default = 0.125 ];
      } ]]
   print(require "serpent".block(pb.defaults "TestDefault"))
-- output:
-- {
--   defaulted_bool = true,
--   defaulted_int = 777,
--   defaulted_num = 0.125,
--   defaulted_str = "foo"
-- } --[[table: 0x7f8c1e52b050]]

```

#### ""

""`pb.option "enable_hooks"`""，""`pb.hook()`""。""。""。""。

`pb.hook()`""，""。""`nil`，""；""，`pb.hook()`""（""`nil`）。

""，""。""，""：

```lua
local function make_hook(name, func)
  return pb.hook(name, function(t)
    return func(name, t)
  end)
end
```

#### ""

""`pb.option()`""/""。

""：

| ""                  | ""                                                  |
| --------------------- | ----------------------------------------------------- |
| `enum_as_name`          | ""，"" **("")** |
| `enum_as_value`         | ""，"" |
| `int64_as_number`       | ""uint32""，""，""Lua""（$\le$ Lua 5.2，""）""64""（$\ge$ Lua 5.3，""64""） **("")** |
| `int64_as_string`       | ""，""`"#"`"" |
| `int64_as_hexstring`    | ""，""16"" |
| `no_default_values`     | "" **("")** |
| `use_default_values`    | set default values by copy values from default table before decode |
| `use_default_metatable` | "" |
| `enable_hooks`          | `pb.decode` ""      |
| `disable_hooks`         | `pb.decode` "" **("")**            |

 *""*： `int64_as_string` "" `int64_as_hexstring` "" `'#'` ""，""Lua""，""。""Lua""，""Lua""。

""`'#'`""，""。""，""。

#### ""

`pb` ""，""。""。""、""。""`pb.state()`""/""。

""，"" `pb.state(nil)` ""（""），""`pb.load()`""，""。""。""`pb.state()`	""。

""：

```lua
local old = pb.state(nil) -- ""
-- "" protoc.lua, "" protoc.reload() ""
assert(pb.load(...)) -- ""
-- ""/"" ...
pb.state(old) -- ""（""）
```

"" `protoc.Lua` ""Google""，""，"" `proto.reload()` ""。

### `pb.io` ""

`pb.io` "" `stdin`/`stdout`""。""Windows""，Lua""。""`protoc`""。""`protoc`""，""proto""`FileDescriptorSet`""`stdin`。""，""Lua""。

 `pb.io.read(filename)` ""，""，"" `stdin` ""。

`pb.io.write()` "" `pb.io.dump()` ""Lua"" `io.write()` ""，""。""`stdout`，""。

""`true`，"" `nil, errmsg`，""`assert()`""。

| ""            | ""    | ""                                          |
| --------------- | ------- | --------------------------------------------- |
| `io.read()`            | string  | "" `stdin`"" |
| `io.read(string)`      | string  | ""     |
| `io.write(...)`        | true    | "" `stdout` |
| `io.dump(string, ...)` | string  | write binary data to file name      |

### `pb.conv` ""

`pb.conv` ""Lua""protobuf""。""，""。

| Encode Function        | Decode Function        |
| ---------------------- | ---------------------- |
| `conv.encode_int32()`  | `conv.decode_int32()`  |
| `conv.encode_uint32()` | `conv.decode_uint32()` |
| `conv.encode_sint32()` | `conv.decode_sint32()` |
| `conv.encode_sint64()` | `conv.decode_sint64()` |
| `conv.encode_float()`  | `conv.decode_float()`  |
| `conv.encode_double()` | `conv.decode_double()` |

### `pb.slice` ""

“Slice”""“""”""，""。""`slice.new()`""slice""，""new""，""wireformat""。

slice""`slice:unpack()`，""，""。""，""`pb.typefmt()`""protobuf""。""，`pb.buffer`""`buffer:pack()`""：

| "" | ""                                                                   |
| ------   | ------------------------------------------------------------           |
| v        | ""，""，1""10""（`varint`）                      |
| d        | ""，4 ""                                               |
| q        | ""，8 ""                                               |
| s        | ""，"" `string`, `bytes` "" `message` "" |
| c        | fmt"" `count`，"" `count` ""   |
| b        | ""：`bool`                                                       |
| f        | 4 ""：`float`                                              |
| F        | 8 ""：`double`                                             |
| i        | `varint`""32""：`int32`                                    |
| j        | `varint`""zig-zad ""32""：`sint32`                     |
| u        | `varint`""32""：`uint32`                                   |
| x        | 4 ""32""：`fixed32`                                      |
| y        | 4 ""32""：`sfixed32`                                     |
| I        | `varint`""64""：`int64`                                    |
| J        | `varint`""zig-zad ""64""：`sint64`                     |
| U        | `varint`""64""：`uint64`                                   |
| X        | 4 ""32""：`fixed32`                                      |
| Y        | 4 ""32""：`sfixed32`                                     |

slice""“""”""。""unpack""，""，""`#slice` ""“""”。""“""”""“""”——""，""`unpack`""，`pack`""：

| "" | ""                                                         |
| ------   | ------------------------------------------------------------ |
| @        | ""1""，""1               |
| *        | fmt""，""        |
| +        | fmt""，""    |

""“"" `varint` ""”""：
```lua
local v1, v2 = s:unpack("v*v", 1)
-- v: "" varint
-- *: ""（""1），""：""
-- v: ""，"" varint ""
```

""，slice""“""”""“""”""，""。""，""A，""B，""C，""`slice:new()`""A""，""B""，""`s:enter()`""（""），""：""B""。""C。""，""`s:leave()`""，""，""，""。

`s:enter()`""i""j""。""，`s:leave()`""——""。

""：

```lua
local s = slice.new("<data here>")
local tag = s:unpack "v"
if tag%8 == 2 then -- tag "" string/bytes ""？""
  s:enter() -- ""，""
  -- ""：""，""fixed32""
  local t = {}
  while #s > 0 do
    t[#t+1] = s:unpack "d"
  end
  s:leave() -- ""？""
end
```

""`pb.slice`""：

| ""            | ""    | ""                                          |
| --------------- | ------- | --------------------------------------------- |
| `slice.new(data[,i[,j]])` | Slice object | "" slice "" |
| `s:delete()`              | none         | "" `s:reset()`""，""slice"" |
| `tostring(s)`             | string       | "" |
| `#s`                      | number       | "" |
| `s:reset([data[,i[,j]]])` | self         | ""slice"" |
| `s:level()`               | number       | "" |
| `s:level(number)`         | p, i, j      | ""n""（""、""） |
| `s:enter()`               | self         | ""，"" |
| `s:enter(i[, j])`         | self         | ""[i,j]"" |
| `s:leave([number])`       | self, n      | ""n""（""），"" |
| `s:unpack(fmt, ...)`      | values...    | ""fmt""，"" |

### `pb.buffer` ""

Buffer""，""Java""“StringBuilder”""。""wireformat""。""`buffer:pack()`""，""`buffer:result()`""。""`buffer:tohex()`""16""。

 `buffer.pack()` "" `slice.unpack()`""，""`pb.slice`""。""，pack"" `'()'`""，""——""。""。""：

```lua
b:pack("(vvv)", 1, 2, 3) -- ""3""varint""
```

`buffer.pack()` "" '#' ""：""`oldlen`，""`buffer`""`oldlen`""：

```lua
b:pack("#", 5) -- ""b""
```

""：""，""buffer，""，""`"#"`""，""——""。

"" `pb.buffer` ""：

| ""            | ""    | ""                                          |
| --------------- | ------- | --------------------------------------------- |
| `buffer.new([...])` | Buffer object | ""buffer""，""`b:reset(...)`""  |
| `b:delete()`        | none          | ""`b:reset()`，""buffer"" |
| `tostring(b)`       | string        | ""buffer"" |
| `#b`                | number        | ""buffer""                 |
| `b:reset()`         | self          | ""buffer""                                     |
| `b:reset([...])`    | self          | ""buffer，""，""`io.write()`"" |
| `b:tohex([i[, j]])` | string        | ""（""）""16"" |
| `b:result([i[,j]])` | string        | ""。""。"" |
| `b:pack(fmt, ...)`  | self          | ""fmt""，""buffer"" |

---

