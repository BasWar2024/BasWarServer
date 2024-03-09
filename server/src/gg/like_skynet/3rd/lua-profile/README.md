# lua profile lib
profile c and lua function and support coroutine yield. run lua test.lua to see result!
inspire from http://github.com/lvzixun/luaprofile

# compile
```
make linux
# make macosx
```

# usage
```
local profile = require "profile"
profile.start()
-- your code
print(profile.report())
profile.stop()
```

# output example
```
topN=20,sort_type=1,unit=milliseconds
count      sum        %      cpu        %      real       %      avg        avg_cpu    avg_real   name                 source              
3          0.058      40.40  0.058      45.34  0.008      10.91  0.019      0.019      0.003      test2                [L]@test.lua:13     
3          0.050      34.71  0.050      38.96  0.048      63.86  0.017      0.017      0.016      print                [C]@test.lua:14     
1          0.019      12.98  0.003      2.32   0.003      3.96   0.019      0.003      0.003      func                 [C]@test.lua:19     
1          0.013      9.28   0.013      10.42  0.012      16.22  0.013      0.013      0.012      wrap                 [L]@./profile.lua:17
3          0.002      1.41   0.002      1.59   0.002      2.71   0.001      0.001      0.001      null                 [C]@test.lua:14     
1          0.001      0.83   0.001      0.93   0.001      1.59   0.001      0.001      0.001      old_co_wrap          [C]@./profile.lua:18
1          0.001      0.39   0.001      0.44   0.001      0.75   0.001      0.001      0.001      mark                 [C]@./profile.lua:19
```