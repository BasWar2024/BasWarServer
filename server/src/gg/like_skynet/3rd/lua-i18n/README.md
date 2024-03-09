i18n
=====

 lua

## 
lua

## 
1. i18n.format,
	```
	string.format(",1:%s,2:%s","",1) ==> i18n.format(",1:{0},2:{1}","",1)
	"" ==> i18n.format("")
	string.format("%s %s","","") ==> i18n.format("{0} {1}",i18n.format(""),"")
	-- i18n.format,
	i18n.format(",={target},npc={npc}",{target="",npc="npc90001"})
	```
2. 
	```
        	python search.py -h
		e.g:
		python search.py --genid=1 --output=languages/zh_CN.json .
		python search.py --output=languages/en_US.json .
	```

3. 
	```
        	python merge.py -h
		e.g:
		python merge.py --source=languages/en_US_1.json --to=languages/en_US.json
	```

4. ,""
	:
	,1:{0},2:{1}	this is chinese,parameter 2:{1},parameter 1:{0}

5. 
```
	make linux
	make test
	make benchmark
```

6. 100cpu
[lua](https://github.com/sundream/lua-i18n/releases/tag/1.0.1)

|                         | i18n.format    | i18n.format
|---------------------------  | --------------------- | ---------------
|c                        | 3.46s                 | 2.69s 
|lua                      | 6.66s                 | 5.52s
|string.format(has translate) | 0.78s                 | 
|string.format(no translate) | 0.50s                 | 