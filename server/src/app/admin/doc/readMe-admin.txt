adminAccountLogin"":
sign = MD5("",key=value"",""&"" + "&" + MD5_KEY)
MD5_KEY = "STARWAR2021HAPPYFISHADMININTERFACE"

"":
sign = MD5("",key=value"",""&"" + "&" + MD5_KEY + "&" + TOKEN)
MD5_KEY = "STARWAR2021HAPPYFISHADMININTERFACE"


->【""】
""JSON:{"code":-10002,"message":"XXXXXXXXXXX","data":""}
code : "" 
message : ""
data : ""

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------
""、""
"":http://10.168.1.95:4241/api/account/adminAccountLogin?adminAccount=admin&adminPassword=0483f597de3b17d265e96ee7cdefb363&sign=9e119770cd6c814af693e5ce43fce92e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
adminpassword   (String): ""
sign 	           (String): MD5"",""：""adminAccountLogin"":

"":adminAccount=admin&adminPassword=0483f597de3b17d265e96ee7cdefb363
"":adminAccount=admin&adminPassword=0483f597de3b17d265e96ee7cdefb363&STARWAR2021HAPPYFISHADMININTERFACE

"":
"":
{
    "message": "OK",
    "data": {
        "adminAccount": "admin",
        "token": "ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG",
        "authority": 0
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

""、""("","")
"":http://10.168.1.95:4241/api/account/adminResetPassword?adminAccount=admin&newPassword=e6d0b190e81e7cb54bebd9196367c18c&oldPassword=0483f597de3b17d265e96ee7cdefb363&resetAccount=admin&sign=d7ba9d8b7da4431d69895edfc400f716
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
resetAccount    (String)：""
oldPassword     (String): ""
newPassword     (String): ""
sign 	(String): MD5"",""："":


"":adminAccount=admin&newPassword=e6d0b190e81e7cb54bebd9196367c18c&oldPassword=0483f597de3b17d265e96ee7cdefb363&resetAccount=admin
"":adminAccount=admin&newPassword=e6d0b190e81e7cb54bebd9196367c18c&oldPassword=0483f597de3b17d265e96ee7cdefb363&resetAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "TOKEN UNAUTH",
    "code": -20025
}

""、""("")
"":http://10.168.1.95:4241/api/account/adminAccountAdd?addAccount=test&addAuthority=1&addPassword=0483f597de3b17d265e96ee7cdefb363&adminAccount=admin&sign=5eefd86738078de37e1f57b73b8decee
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
addAccount      (String)：""
addPassword     (String): ""
addAuthority    (int): "",(0"",1"")
sign 		    (String): MD5"",""："":

"":addAccount=test&addAuthority=1&addPassword=0483f597de3b17d265e96ee7cdefb363&adminAccount=admin
"":addAccount=test&addAuthority=1&addPassword=0483f597de3b17d265e96ee7cdefb363&adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "ACCOUNT EXIST",
    "code": -20004
}

""、""Token
"":http://10.168.1.95:4241/api/account/adminRefreshToken?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":


"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "adminAccount": "admin",
        "token": "zbfWvzHytSSqcsbhnwrCWwzIkJIJqBmq",
        "authority": 0
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

""、"",""admin""
"":http://10.168.1.95:4241/api/account/adminChangeInfo?adminAccount=admin&changeAccount=allen&newPassword=e6d0b190e81e7cb54bebd9196367c18c&newAuthority=1&sign=d7ba9d8b7da4431d69895edfc400f716
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
changeAccount    (String)：""
newPassword     (String): "", no""
newAuthority     (String): "", no""
sign 	(String): MD5"",""："":


"":adminAccount=admin&changeAccount=allen&newAuthority=1&newPassword=e6d0b190e81e7cb54bebd9196367c18c
"":adminAccount=admin&changeAccount=allen&newAuthority=1&newPassword=e6d0b190e81e7cb54bebd9196367c18c&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "TOKEN UNAUTH",
    "code": -20025
}


-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------

"" ""
"":http://127.0.0.1:4241/api/analyzer/getActiveUserStatistic?adminAccount=admin&platform=all&year=2022&month=11&pageNo=1&pageSize=20&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "activeRatio": 0.087222222222222,
                "monthActiveNum": 0.8,
                "year": 2022,
                "_id": 100,
                "month": 12,
                "dayActiveNum": 0.28888888888889,
                "weekActiveNum": 0.8
            },
            {
                "activeRatio": 0.0083333333333333,
                "monthActiveNum": 1.6,
                "year": 2023,
                "_id": 101,
                "month": 1,
                "dayActiveNum": 0.066666666666667,
                "weekActiveNum": 1.4666666666667
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getGameResStatisticHistory?adminAccount=admin&beginDate=20220101&endDate=20220613&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
beginDate   (String): ""
endDate     (String): ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&beginDate=20220101&endDate=20220613
"":adminAccount=admin&beginDate=20220101&endDate=20220613&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": [
        {
            "heroTotal": 1,
            "iceTotal": 0,
            "mitTotal": 0,
            "gasTotal": 0,
            "createDate": 20220613,
            "titaniumTotal": 0,
            "carboxylTotal": 0,
            "gunTurretTotal": 0,
            "starCoinTotal": 0,
            "warShipTotal": 1
        },
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/getGameResUseRatio?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&res=MIT&flush=1&pid=1000503
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":
res     (String): ""，MIT,HYT,STARCOIN,ICE,TITANIUM,GAS,TESSERACT
flush   (int) : ""，1""， 
pid     (int): ""pid,0""
"":adminAccount=admin
"":adminAccount=admin&beginDate=20220101&endDate=20220613&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
type=table encode=json
{
   "message": "OK",
   "data": {
       "totalNum": [
           {
               "value": 186347500,
               "type": "useData"
           },
           {
               "value": 190133000,
               "type": "getData"
           }
       ],
       "getData": [
           {
               "value": 150,
               "ratio": 0.0007889214,
               "reason": "create player gift"
           },
           {
               "value": 189981,
               "ratio": 0.9992005596,
               "reason": "order pay local"
           }
       ],
       "useData": [
           {
               "value": 60,
               "ratio": 0.000321979,
               "reason": "train solider"
           },
           {
               "value": 151501,
               "ratio": 0.8130025892,
               "reason": "soon build level up"
           }
       ]
   },
   "code": 0
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""， ""
"":http://10.168.1.109:4241/api/analyzer/getPurchaseStatistics?sign=ea0f194840af008272bee8de05d0c0b5&adminAccount=admin&flush=0
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":
flush   (int) : 0""，""，1""， 
"":adminAccount=admin&flush&sign
"":adminAccount=admin&sign=ea0f194840af008272bee8de05d0c0b5

"":
"":
type=table encode=json
{
    "message": "OK",
    "data": {
        "totalNum": 986,
        "productInfo": [
            {
                "num": 21,
                "ratio": 0.0212981744,
                "productId": "gb.moonCard.1999"
            },
            {
                "num": 20,
                "ratio": 0.0202839756,
                "productId": "gb.starcoin.2999"
            },
            {
                "num": 13,
                "ratio": 0.0131845841,
                "productId": "gb.resource.999"
            },
            {
                "num": 4,
                "ratio": 0.0040567951,
                "productId": "gb.resource.9999"
            },
            {
                "num": 1,
                "ratio": 0.0010141987,
                "productId": "gb.starcoin.9999"
            },
            {
                "num": 20,
                "ratio": 0.0202839756,
                "productId": "gb.skill.9999"
            },
            {
                "num": 27,
                "ratio": 0.0273833671,
                "productId": "gb.local.4"
            },
            {
                "num": 24,
                "ratio": 0.0243407707,
                "productId": "gb.tesseract.4999"
            },
            {
                "num": 41,
                "ratio": 0.0415821501,
                "productId": "gb.skill.4999"
            },
            {
                "num": 56,
                "ratio": 0.0567951318,
                "productId": "gb.cumulativeFunds.100"
            },
            {
                "num": 42,
                "ratio": 0.0425963488,
                "productId": "gb.tesseract.999"
            },
            {
                "num": 43,
                "ratio": 0.0436105476,
                "productId": "gb.tesseract.499"
            },
            {
                "num": 48,
                "ratio": 0.0486815415,
                "productId": "gb.tesseract.99"
            },
            {
                "num": 40,
                "ratio": 0.0405679513,
                "productId": "gb.cumulativeFunds.300"
            },
            {
                "num": 26,
                "ratio": 0.0263691683,
                "productId": "gb.tesseract.2999"
            },
            {
                "num": 49,
                "ratio": 0.0496957403,
                "productId": "gb.moonCard.199"
            }
        ]
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"": ""
"": http://192.168.50.159:4241/api/analyzer/getIndexStatistic?adminAccount=admin&refresh=0&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
refresh     (String)："", 0"", 1""
sign 	(String): MD5"",""："":

"":adminAccount=admin&refresh=0
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "resInfo": {
            "heroTotal": 81,
            "iceTotal": 10889012,
            "mitTotal": 11102000,
            "tesseractTotal": 11290447,
            "titaniumTotal": 10949807,
            "starCoinTotal": 10858755,
            "carboxylTotal": 11196514,
            "warShipTotal": 153,
            "gunTurretTotal": 121,
            "artifactTotal": 2,
            "gasTotal": 10884009.007
        },
        "statInfo": {
            "totalPlayerCount": 30,
            "onlinePlayerCount": 0,
            "totalExchangeHydroxyl": 25708,
            "yestdayExchangeTesseract": 0,
            "yestdayChainRechargeMIT": 0,
            "yestdayChainRechargeHYT": 0,
            "yestdayChainWithdrawHYT": 0,
            "yestdayExchangeHydroxyl": 0,
            "totalChainRechargeMIT": 0,
            "totalChainWithdrawMIT": 0,
            "todayChainRechargeMIT": 0,
            "todayChainWithdrawMIT": 0,
            "yestdayOrderPrice": 0,
            "totalChainWithdrawHYT": 0,
            "yestdayOrderTesseract": 0,
            "todayExchangeHydroxyl": 10732,
            "useHyt": 0,
            "todayExchangeTesseract": 107320,
            "yestdayActiveNum": 0,
            "totalOrderPrice": 83.75,
            "yestdayChainWithdrawMIT": 0,
            "todayOrderTesseract": 2294,
            "useMit": 0,
            "todayOrderPrice": 22.94,
            "todayChainWithdrawHYT": 0,
            "todayChainRechargeHYT": 0,
            "totalExchangeTesseract": 257080,
            "totalChainRechargeHYT": 0,
            "totalOrderTesseract": 8375
        }
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"": ""
"": http://192.168.50.159:4241/api/analyzer/getLostUserStatistic?adminAccount=admin&platform=all&year=2022&month=11&pageNo=1&pageSize=20&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "dayActiveLostUserRatio": 0.011904761904762,
                "weekActiveLostUserRatio": 0.042857142857143,
                "_id": 100,
                "regWeekLostUserNum": "-",
                "regMonthLostUserNum": "-",
                "month": 12,
                "year": 2022,
                "regDayLostUserNum": 0,
                "monthActiveLostUserRatio": 0.042857142857143
            },
            {
                "dayActiveLostUserRatio": 0,
                "weekActiveLostUserRatio": 0,
                "_id": 101,
                "regWeekLostUserNum": "-",
                "regMonthLostUserNum": "-",
                "month": 1,
                "year": 2023,
                "regDayLostUserNum": "-",
                "monthActiveLostUserRatio": 0
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getNewAddUserStatistic?adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "regAccount": 2,
                "regActiveRatio": 1,
                "year": 2022,
                "_id": 100,
                "firstGameTime": 352.17037037037,
                "installCount": "-",
                "month": 12,
                "activeAccount": 2
            },
            {
                "regAccount": 1,
                "regActiveRatio": 1,
                "year": 2023,
                "_id": 101,
                "firstGameTime": 0,
                "installCount": "-",
                "month": 1,
                "activeAccount": 1
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"": http://192.168.50.159:4241/api/analyzer/getPlayerList?adminAccount=admin&onlineStatus=no&platform=no&server=no&account=no&pid=no&name=no&inviteCode=no&chainId=no&walletAddress=no&minBaseLevel=no&maxBaseLevel=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
onlineStatus (string)：0"",1"",no""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
server (string)：no""
account (string)：no""
pid (string)：no""
name (string)：no""
inviteCode (string)：no""
chainId (string)：no""
walletAddress (string)：no""
minBaseLevel (string)：no""
maxBaseLevel (string)：no""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&chainId=no&endCreateDate=no&inviteCode=no&maxBaseLevel=no&minBaseLevel=no&name=no&onlineStatus=no&pageNo=1&pageSize=20&pid=no&platform=no&server=no&walletAddress=no
"":account=no&adminAccount=admin&beginCreateDate=no&chainId=no&endCreateDate=no&inviteCode=no&maxBaseLevel=no&minBaseLevel=no&name=no&onlineStatus=no&pageNo=1&pageSize=20&pid=no&platform=no&server=no&walletAddress=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "pid": 1000000,
                "starCoin": 1000,
                "logoutTime": 1669965003,
                "firstLoginTime": 1669360452,
                "baseLevel": 1,
                "chainId": 0,
                "server": "game1",
                "onlineStatus": 0,
                "carboxyl": 150,
                "name": "GB1000000",
                "gas": 1000,
                "mit": 0,
                "account": "test01@gmail.com",
                "walletAddress": "",
                "firstLogoutTime": 1669360788,
                "levelFiveTime": 0,
                "ip": "0.0.0.0",
                "totalGameTime": 1898,
                "loginTime": 1669360820,
                "nftTotal": 0,
                "createTime": 1669360452,
                "loginCount": 2,
                "platform": "androidGB",
                "vipLevel": 0,
                "maxPVE": 0,
                "inviteCode": "4C92",
                "tuoguanStatus": 0,
                "badge": 0,
                "titanium": 1000,
                "isRegDayLevel5": false,
                "headIcon": "profile phpto 04_icon",
                "pledgeMit": 0,
                "ice": 1000
            },
            {
                "badge": 0,
                "titanium": 1000,
                "starCoin": 1000,
                "walletAddress": "",
                "maxPVE": 0,
                "ip": "10.168.1.66",
                "pid": 1000001,
                "pledgeMit": 0,
                "logoutTime": 1669365070,
                "loginTime": 1669362405,
                "inviteCode": "4C93",
                "loginCount": 1,
                "nftTotal": 0,
                "server": "game1",
                "onlineStatus": 0,
                "platform": "androidGB",
                "carboxyl": 150,
                "vipLevel": 0,
                "baseLevel": 1,
                "levelFiveTime": 0,
                "ice": 1000,
                "tuoguanStatus": 0,
                "isRegDayLevel5": false,
                "headIcon": "Head_Icon_31",
                "name": "GB1000001",
                "createTime": 1669362405,
                "nftItems": {},
                "gas": 1000,
                "mit": 0,
                "account": "test02@gmail.com"
            },
            {
                "titanium": 100,
                "starCoin": 1000,
                "firstLoginTime": 1669370183,
                "baseLevel": 2,
                "chainId": 97,
                "server": "game1",
                "onlineStatus": 1,
                "carboxyl": 142,
                "vipLevel": 0,
                "name": "GB1000002",
                "gas": 80,
                "mit": 0,
                "account": "test03@gmail.com",
                "badge": 0,
                "firstLogoutTime": 1669370441,
                "levelFiveTime": 0,
                "ip": "10.168.1.66",
                "totalGameTime": 12791,
                "loginTime": 1669965454,
                "nftTotal": 6,
                "platform": "androidGB",
                "maxPVE": 0,
                "createTime": 1669370183,
                "loginCount": 6,
                "ice": 100,
                "logoutTime": 0,
                "inviteCode": "4C94",
                "isRegDayLevel5": false,
                "walletAddress": "7004033522117644292f92fe3f02e14ff002e51b",
                "pid": 1000002,
                "headIcon": "profile phpto 16_icon",
                "pledgeMit": 0
            }
        ],
        "totalRows": 3,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getOnlineUserStatistic?adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "avgOnlineTime": 59.094444444444,
                "year": 2022,
                "_id": 100,
                "month": 12,
                "sameTimeOnlineNum": 0.2,
                "maxSameTimeOnlineNum": 1
            },
            {
                "avgOnlineTime": 59.266666666667,
                "year": 2023,
                "_id": 101,
                "month": 1,
                "sameTimeOnlineNum": 0.2,
                "maxSameTimeOnlineNum": 1
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getPlayerInfo?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid (String): ""ID/""
sign 	(String): MD5"",""："":

"":adminAccount=admin&pid=1000000
"":adminAccount=admin&pid=1000000&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "pid": 1000002,
        "starCoin": 1000,
        "nftBuilds": [
            {
                "id": 5002,
                "curLife": 74,
                "bscName": "Scourge DF Centipede #R",
                "name": "Centipede",
                "life": 74,
                "chain": 97,
                "cfgId": 3201001,
                "race": 2,
                "level": 1,
                "style": 1,
                "quality": 2
            },
            {
                "id": 6002,
                "curLife": 86,
                "bscName": "Centra DF Separate #R",
                "name": "Separate",
                "life": 86,
                "chain": 97,
                "cfgId": 3101001,
                "race": 1,
                "level": 1,
                "style": 1,
                "quality": 2
            }
        ],
        "baseLevel": 1,
        "normalBuilds": [
            {
                "id": 7001846037849575000,
                "curLife": 0,
                "name": "base",
                "life": 50,
                "chain": 0,
                "cfgId": 6010001,
                "race": 0,
                "level": 1,
                "style": 0,
                "quality": 0
            }
        ],
        "chainId": 97,
        "server": "game1",
        "onlineStatus": 0,
        "firstLogoutTime": 1669370441,
        "vipLevel": 0,
        "items": [
            {
                "id": 7004036411150045000,
                "num": 99,
                "name": "card ticket",
                "cfgId": 8720001
            },
            {
                "id": 7004036343831466000,
                "num": 100,
                "name": "card shard",
                "cfgId": 8713001
            }
        ],
        "name": "GB1000002",
        "normalHeros": [
            {
                "skillLevel2": 1,
                "skillName2": "skillName368",
                "race": 0,
                "chain": 0,
                "skillLevel3": 0,
                "level": 1,
                "quality": 1,
                "cfgId": 5000001,
                "curLife": 67,
                "skill3": 0,
                "skillName1": "skillName341",
                "life": 67,
                "style": 0,
                "name": "King",
                "id": 7001846037849575000,
                "skill2": 6200022,
                "skillLevel1": 1,
                "skill1": 6100013
            }
        ],
        "mit": 0,
        "account": "test03@gmail.com",
        "badge": 0,
        "pvpRank": 1,
        "nftWarShips": [
            {
                "skillLevel2": 0,
                "race": 1,
                "chain": 97,
                "skill1": 6100013,
                "level": 1,
                "quality": 2,
                "skillLevel4": 0,
                "skillName1": "skillName341",
                "id": 2002,
                "bscName": "Centra Ship Sanguis #R",
                "curLife": 88,
                "skill3": 0,
                "name": "Sanguis",
                "life": 88,
                "style": 1,
                "skill2": 0,
                "cfgId": 1101001,
                "skill4": 0,
                "skillLevel1": 1,
                "skillLevel3": 0
            },
            {
                "skillLevel2": 0,
                "race": 2,
                "chain": 97,
                "skill1": 6100013,
                "level": 1,
                "quality": 2,
                "skillLevel4": 0,
                "skillName1": "skillName341",
                "id": 1002,
                "bscName": "Scourge Ship BlueRingedOctopus #R",
                "curLife": 117,
                "skill3": 0,
                "name": "BlueRingedOctopus",
                "life": 117,
                "style": 1,
                "skill2": 0,
                "cfgId": 1201001,
                "skill4": 0,
                "skillLevel1": 1,
                "skillLevel3": 0
            }
        ],
        "levelFiveTime": 0,
        "ip": "0.0.0.0",
        "totalGameTime": 9977,
        "pledgeMit": 0,
        "isRegDayLevel5": false,
        "loginTime": 1669891561,
        "firstLoginTime": 1669370183,
        "nftTotal": 6,
        "platform": "androidGB",
        "createTime": 1669370183,
        "gas": 1000,
        "ice": 1000,
        "logoutTime": 1669901713,
        "inviteCode": "4C94",
        "maxPVE": 0,
        "walletAddress": "7004033522117644292f92fe3f02e14ff002e51b",
        "titanium": 1000,
        "headIcon": "profile phpto 16_icon",
        "carboxyl": 150,
        "normalWarShips": [
            {
                "skillLevel2": 0,
                "race": 0,
                "chain": 0,
                "skill1": 6100013,
                "level": 1,
                "quality": 1,
                "skillLevel4": 0,
                "id": 7001846037849575000,
                "skillName1": "skillName341",
                "curLife": 60,
                "skill3": 0,
                "name": "Atlas",
                "life": 60,
                "style": 0,
                "skill2": 0,
                "cfgId": 4000001,
                "skill4": 0,
                "skillLevel1": 1,
                "skillLevel3": 0
            }
        ],
        "loginCount": 3,
        "nftHeros": [
            {
                "skillLevel2": 1,
                "skillName2": "skillName368",
                "race": 1,
                "chain": 97,
                "skillLevel3": 0,
                "level": 1,
                "quality": 2,
                "cfgId": 2101001,
                "skillName1": "skillName341",
                "curLife": 89,
                "skill3": 0,
                "bscName": "Centra Hero Torva #R",
                "life": 89,
                "style": 1,
                "name": "Torva",
                "id": 3002,
                "skill2": 6200022,
                "skillLevel1": 1,
                "skill1": 6100013
            },
            {
                "skillLevel2": 1,
                "skillName2": "skillName368",
                "race": 2,
                "chain": 97,
                "skillLevel3": 0,
                "level": 1,
                "quality": 2,
                "cfgId": 2201001,
                "skillName1": "skillName341",
                "curLife": 145,
                "skill3": 0,
                "bscName": "Scourge Hero TB #R",
                "life": 145,
                "style": 1,
                "name": "TB",
                "id": 4002,
                "skill2": 6200022,
                "skillLevel1": 1,
                "skill1": 6100013
            }
        ]
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/getStayUserStatistic?adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "stayUserNumInReg30d": 0,
                "stayUserNumInReg7d": 0,
                "year": 2022,
                "_id": 100,
                "stayUserNumInReg3d": 0.022222222222222,
                "stayUserNumInReg2d": 0.037037037037037,
                "month": 12,
                "stayUserNumInReg14d": 0
            },
            {
                "stayUserNumInReg30d": 0,
                "stayUserNumInReg7d": 0,
                "year": 2023,
                "_id": 101,
                "stayUserNumInReg3d": 0,
                "stayUserNumInReg2d": 0,
                "month": 1,
                "stayUserNumInReg14d": 0
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"": http://192.168.50.159:4241/api/analyzer/getUserStatisticByDay?adminAccount=admin&sign=19cd1a8a4ded20f59f5d85608f5a24f3&beginDate=20220101&endDate=20220613
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
beginDate   (String): ""
endDate     (String): ""
sign 	(String): MD5"",""："":
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")

"":adminAccount=admin&beginDate=20220101&endDate=20220613&platform=all
"":adminAccount=admin&beginDate=20220101&endDate=20220613&platform=all&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": [
        {
            "activeRatio": "\u0000\n",
            "avgOnlineTime": 6,
            "stayUserNumInReg14d": 0,
            "installCount": 0,
            "regAccount": 1,
            "validNewAddNum": 0,
            "regDayLostUserNum": 1,
            "monthActiveNum": 0,
            "weekActiveNum": 1,
            "stayUserNumInReg7d": 0,
            "firstGameTime": 6,
            "regActiveRatio": 1,
            "maxSameTimeOnlineNum": 0,
            "dayActiveLostUserRatio": 0,
            "loginStayValidRatioV2": 0,
            "weekActiveLostUserRatio": 0,
            "createDate": 20220526,
            "loginStayValidRatio": 0,
            "stayUserNumInReg3d": 0,
            "regUserValidRatio": 0,
            "sameTimeOnlineNum": 0,
            "loginStayNum": 0,
            "stayUserNumInReg30d": "\u0000\n",
            "regWeekLostUserNum": 0,
            "regMonthLostUserNum": 0,
            "activeAccount": 1,
            "loginStayNumV2": 0,
            "stayUserNumInReg2d": 0,
            "dayActiveNum": 1,
            "monthActiveLostUserRatio": "\u0000\n"
        },
        {
            "activeRatio": "\u0000\n",
            "avgOnlineTime": 0,
            "stayUserNumInReg14d": 0,
            "installCount": 0,
            "regAccount": 0,
            "validNewAddNum": 0,
            "regDayLostUserNum": 0,
            "monthActiveNum": 0,
            "weekActiveNum": 1,
            "stayUserNumInReg7d": 0,
            "firstGameTime": 0,
            "regActiveRatio": "\u0000\n",
            "maxSameTimeOnlineNum": 0,
            "dayActiveLostUserRatio": 0,
            "loginStayValidRatioV2": 0,
            "weekActiveLostUserRatio": 0,
            "createDate": 20220527,
            "loginStayValidRatio": 0,
            "stayUserNumInReg3d": 0,
            "regUserValidRatio": 0,
            "sameTimeOnlineNum": 0,
            "loginStayNum": 0,
            "stayUserNumInReg30d": 0,
            "regWeekLostUserNum": 0,
            "regMonthLostUserNum": 0,
            "activeAccount": 0,
            "loginStayNumV2": 0,
            "stayUserNumInReg2d": 0,
            "dayActiveNum": 0,
            "monthActiveLostUserRatio": "\u0000\n"
        },
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getValidNewAddUserStatistic?adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
year    (int)：""
month    (int) ""
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022
"":adminAccount=admin&month=11&pageNo=1&pageSize=20&platform=all&year=2022&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "loginStayValidRatioV2": 0,
                "_id": 100,
                "validNewAddNum": 0.1,
                "regUserValidRatio": 0.053030303030303,
                "year": 2022,
                "month": 12,
                "loginStayNumV2": "-",
                "loginStayNum": 0.033333333333333,
                "loginStayValidRatio": 0.033333333333333
            },
            {
                "loginStayValidRatioV2": "-",
                "_id": 101,
                "validNewAddNum": "-",
                "regUserValidRatio": 0,
                "year": 2023,
                "month": 1,
                "loginStayNumV2": "-",
                "loginStayNum": "-",
                "loginStayValidRatio": "-"
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""PVE""
"": http://192.168.50.159:4241/api/analyzer/getPlayerPVEStatistic?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {},
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getInviteInfoFromAdmin?adminAccount=admin&unique=test01@gmail.com&pageNo=1&pageSize=20&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
unique    (String)：""id
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&pageNo=1&pageSize=20&unique=test01@gmail.com
"":adminAccount=admin&pageNo=1&pageSize=20&unique=test01@gmail.com&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 0,
        "myself": {
            "titanium": 9771280,
            "starCoin": 9916055,
            "inviteCode": "4C9H",
            "isRegDayLevel5": true,
            "baseLevel": 14,
            "chainId": 97,
            "server": "game1",
            "onlineStatus": 0,
            "carboxyl": 10000000,
            "vipLevel": 0,
            "name": "GB1000015",
            "gas": 9752858,
            "mit": 10002000,
            "account": "test01@gmail.com",
            "badge": 0,
            "firstLoginTime": 1673508981,
            "levelFiveTime": 1673509020,
            "ip": "10.168.1.66",
            "totalGameTime": 356434,
            "loginTime": 1675652155,
            "createTime": 1673508981,
            "nftTotal": 130,
            "tesseract": 9916225,
            "firstLogoutTime": 1673509117,
            "platform": "androidGB",
            "loginCount": 23,
            "maxPVE": 10030,
            "pvpRank": 2,
            "tuoguanStatus": 0,
            "ice": 9759618,
            "walletAddress": "70192430667666596023abb1e89ce4acc8c6660e",
            "pid": 1000015,
            "headIcon": "Head_Icon_4",
            "logoutTime": 1675652158,
            "pledgeMit": 0
        },
        "rows": [
            {
                "titanium": 1000,
                "starCoin": 1000,
                "inviteCode": "4CAH",
                "isRegDayLevel5": false,
                "baseLevel": 1,
                "server": "game1",
                "onlineStatus": 0,
                "carboxyl": 0,
                "vipLevel": 0,
                "name": "GB1000077",
                "gas": 1000,
                "mit": 0,
                "account": "test103@gmail.com",
                "badge": 0,
                "firstLoginTime": 1675652305,
                "levelFiveTime": 0,
                "ip": "10.168.1.66",
                "totalGameTime": 4,
                "loginTime": 1675652305,
                "nftTotal": 0,
                "createTime": 1675652304,
                "firstLogoutTime": 1675652309,
                "platform": "androidGB",
                "tesseract": 150,
                "ice": 1000,
                "pvpRank": 0,
                "loginCount": 1,
                "tuoguanStatus": 0,
                "maxPVE": 0,
                "logoutTime": 1675652309,
                "headIcon": "profile phpto 20_icon",
                "pid": 1000077,
                "pledgeMit": 0
            },
            {
                "titanium": 1000,
                "starCoin": 1000,
                "inviteCode": "4CAY",
                "isRegDayLevel5": false,
                "baseLevel": 1,
                "server": "game1",
                "onlineStatus": 0,
                "carboxyl": 0,
                "vipLevel": 0,
                "name": "GB1000094",
                "gas": 1000,
                "mit": 0,
                "account": "test104@gmail.com",
                "badge": 0,
                "firstLoginTime": 1675652342,
                "levelFiveTime": 0,
                "ip": "10.168.1.66",
                "totalGameTime": 4,
                "loginTime": 1675652342,
                "nftTotal": 0,
                "createTime": 1675652341,
                "firstLogoutTime": 1675652346,
                "platform": "androidGB",
                "tesseract": 150,
                "ice": 1000,
                "pvpRank": 0,
                "loginCount": 1,
                "tuoguanStatus": 0,
                "maxPVE": 0,
                "logoutTime": 1675652346,
                "headIcon": "profile phpto 11_icon",
                "pid": 1000094,
                "pledgeMit": 0
            }
        ],
        "totalRows": 0,
        "pageSize": 2,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/getInviteSonAccountList?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&beginTime=2022-07-26+00%3A00%3A00&endTime=2022-07-27+00%3A00%3A00&sonPid=0&fatherPid=0
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	        (String): MD5"",
beginTime       (int): ""
endTime         (int): ""
sonPid          (int): ""ID, ""0
fatherPid       (int):""ID, ""0

""："":

"":adminAccount=admin&beginTime=1660100643&endTime=1660100643&fatherPid=0&sonPid=0
"":adminAccount=admin&beginTime=1660100643&endTime=1660100643&fatherPid=0&sonPid=0&STARWAR2021HAPPYFISHADMININTERFACE&HhpQTuGRyjj59m1sZL7Y9ZfN2OHgyjGF

"":
"":
{
    "message": "OK",
    "data": [
        {
            "titanium": 1000,
            "starCoin": 988,
            "fatherAccount": "mm3@qq.com",
            "inviteCode": "4C9B",
            "baseLevel": 1,
            "isRegDayLevel5": false,
            "server": "game1",
            "onlineStatus": 0,
            "carboxyl": 173,
            "vipLevel": 0,
            "name": "Commander1000009",
            "nftItems": {},
            "gas": 1000,
            "mit": 0,
            "account": "mm9@qq.com",
            "badge": 12,
            "levelFiveTime": 0,
            "ip": "192.168.50.55",
            "totalGameTime": 371,
            "loginTime": 1658816695,
            "fatherInviteCode": "4C96",
            "nftTotal": 0,
            "pledgeMit": 0,
            "maxPVE": 0,
            "fatherBaseLevel": 5,
            "pid": 1000009,
            "fatherPid": 1000004,
            "logoutTime": 1658817016,
            "createTime": 1658746531,
            "loginCount": 5,
            "ice": 1094.999,
            "_id": "\u0000\u0007b\ufffdv\ufffd\ufffdu\ufffd\ufffdx\ufffd?\ufffd",
            "headIcon": "Head_Icon_32"
        }
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/analyzer/getGameResLog?adminAccount=admin&pageNo=1&pageSize=5&pid=1000010&res=HYT&reason=all&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
pid    (int)：""id
res    (String)："",MIT HYT STARCOIN ICE TITANIUM GAS
reason    (String)："","all"""
sign 	(String): MD5"",""："":
change   (int):""，""|""    1|-1  ""1（get）
"":adminAccount=admin&change=1&pageNo=1&pageSize=5&pid=1000010&reason=all&res=HYT
"":adminAccount=admin&pageNo=1&pageSize=5&pid=1000010&reason=all&res=HYT&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "totalRows": 2,
        "rows": [
            {
                "afterValue": 1150,
                "platform": "androidGB",
                "pid": 1000000,
                "loseValue": 0,
                "beforeValue": 150,
                "reason": "gm operate",
                "resCfgId": 104,
                "timestamp": 1669097790,
                "changeValue": 1000
            },
            {
                "afterValue": 150,
                "platform": "androidGB",
                "pid": 1000000,
                "loseValue": 0,
                "beforeValue": 0,
                "reason": "create player gift",
                "resCfgId": 104,
                "timestamp": 1669087282,
                "changeValue": 150
            }
        ],
        "pageSize": 5,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/analyzer/getGameItemLog?adminAccount=admin&pageNo=1&pageSize=5&pid=1000010&id=0&cfgId=0&reason=all&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
pid    (int)：""id,""0
id    (String)：""id,"" "0"
cfgId    (int)：""cfgId,""0
reason    (String)："","all"""
sign 	(String): MD5"",""："":

"":adminAccount=admin&cfgId=0&id=0&pageNo=1&pageSize=5&pid=1000010&reason=all
"":adminAccount=admin&cfgId=0&id=0&pageNo=1&pageSize=5&pid=1000010&reason=all&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 38,
        "totalRows": 187,
        "rows": [
            {
                "platform": "androidGB",
                "pid": 1000000,
                "id": "7000659797284491285",
                "reason": "item resolve",
                "op": "del",
                "changeNum": 0,
                "name": "card_8200005",
                "cfgId": 8200005,
                "timestamp": 1669087634,
                "afterNum": 0,
                "beforeNum": 0
            },
            {
                "platform": "androidGB",
                "pid": 1000000,
                "id": "7000659797284491285",
                "reason": "item resolve",
                "op": "dec",
                "changeNum": -9999,
                "name": "card_8200005",
                "cfgId": 8200005,
                "timestamp": 1669087634,
                "afterNum": 0,
                "beforeNum": 9999
            },
            {
                "platform": "androidGB",
                "pid": 1000000,
                "id": "7000660939661906110",
                "reason": "item resolve",
                "op": "add",
                "changeNum": 9999,
                "name": "card shard",
                "cfgId": 8713001,
                "timestamp": 1669087634,
                "afterNum": 9999,
                "beforeNum": 0
            },
            {
                "platform": "androidGB",
                "pid": 1000000,
                "id": "7000660939661906109",
                "reason": "item resolve",
                "op": "add",
                "changeNum": 9999,
                "name": "card shard",
                "cfgId": 8713001,
                "timestamp": 1669087634,
                "afterNum": 9999,
                "beforeNum": 0
            },
            {
                "platform": "androidGB",
                "pid": 1000000,
                "id": "7000660939661906108",
                "reason": "item resolve",
                "op": "add",
                "changeNum": 9999,
                "name": "card shard",
                "cfgId": 8713001,
                "timestamp": 1669087634,
                "afterNum": 9999,
                "beforeNum": 0
            }
        ],
        "pageSize": 5,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/analyzer/getGameEntityLog?adminAccount=admin&pageNo=1&pageSize=5&pid=1000010&entity=hero&id=0&cfgId=0&reason=all&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
pid    (int)：""id,""0
entity    (String)："",warship/hero/build
id    (String)：""id,"" "0"
cfgId    (int)：""cfgId,""0
reason    (String)："","all"""
sign 	(String): MD5"",""："":

"":adminAccount=admin&cfgId=0&entity=hero&id=0&pageNo=1&pageSize=5&pid=1000010&reason=all
"":adminAccount=admin&cfgId=0&entity=hero&id=0&pageNo=1&pageSize=5&pid=1000010&reason=all&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
{
    "message": "OK",
    "data": {
        "totalPage": 35,
        "totalRows": 104,
        "rows": [
            {
                "pid": 1000000,
                "life": 251,
                "skillLevel2": 0,
                "reason": "bridge recharge nft",
                "op": "add",
                "entity": "warship",
                "level": 1,
                "quality": 5,
                "skillLevel4": 0,
                "platform": "androidGB",
                "name": "Dreadnought",
                "race": 4,
                "cfgId": 1402001,
                "skillLevel3": 0,
                "chain": 97,
                "skill3": 0,
                "skill4": 0,
                "skill1": 0,
                "style": 2,
                "id": "260002",
                "skill2": 0,
                "timestamp": 1669110697,
                "skillLevel1": 0,
                "curLife": 251
            },
            {
                "pid": 1000000,
                "life": 185,
                "skillLevel2": 0,
                "reason": "bridge recharge nft",
                "op": "add",
                "entity": "warship",
                "level": 1,
                "quality": 4,
                "skillLevel4": 0,
                "platform": "androidGB",
                "name": "Dreadnought",
                "race": 4,
                "cfgId": 1402001,
                "skillLevel3": 0,
                "chain": 97,
                "skill3": 0,
                "skill4": 0,
                "skill1": 0,
                "style": 2,
                "id": "259002",
                "skill2": 0,
                "timestamp": 1669110697,
                "skillLevel1": 0,
                "curLife": 185
            },
            {
                "pid": 1000000,
                "life": 80,
                "skillLevel2": 0,
                "reason": "bridge recharge nft",
                "op": "add",
                "entity": "warship",
                "level": 1,
                "quality": 3,
                "skillLevel4": 0,
                "platform": "androidGB",
                "name": "Dreadnought",
                "race": 4,
                "cfgId": 1402001,
                "skillLevel3": 0,
                "chain": 97,
                "skill3": 0,
                "skill4": 0,
                "skill1": 0,
                "style": 2,
                "id": "258002",
                "skill2": 0,
                "timestamp": 1669110697,
                "skillLevel1": 0,
                "curLife": 80
            }
        ],
        "pageSize": 3,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"": http://192.168.50.159:4241/api/analyzer/getPayOrderList?adminAccount=admin&platform=no&payChannel=no&account=no&pid=no&orderId=no&state=no&op=no&productId=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
payChannel (string)：pay_local,pay_appstore,pay_googleplay,no""
account (string)：no""
pid (string)：no""
orderId (string)：no""
state (string)：no"",0"",1"",2""
op (string)：no""
productId (string)：no""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&endCreateDate=no&op=no&orderId=no&pageNo=1&pageSize=20&payChannel=no&pid=no&platform=no&productId=no&state=no
"":account=no&adminAccount=admin&beginCreateDate=no&endCreateDate=no&op=no&orderId=no&pageNo=1&pageSize=20&payChannel=no&pid=no&platform=no&productId=no&state=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "payChannel": "pay_local",
                "platform": "local",
                "pid": 1000001,
                "ext": "ext",
                "price": 4.99,
                "orderId": "4",
                "signture": "",
                "signtureData": "",
                "state": 2,
                "op": "GmApprove",
                "receiptData": "",
                "productId": "gb.local.2",
                "value": 499,
                "createOrderTime": 1672041699,
                "settleOrderTime": 1672041699,
                "account": "test02@gmail.com"
            },
            {
                "payChannel": "pay_local",
                "platform": "local",
                "pid": 1000001,
                "ext": "ext",
                "price": 0.99,
                "orderId": "3",
                "signture": "",
                "signtureData": "",
                "state": 2,
                "op": "GmApprove",
                "receiptData": "",
                "productId": "gb.local.1",
                "value": 99,
                "createOrderTime": 1672041697,
                "settleOrderTime": 1672041697,
                "account": "test02@gmail.com"
            }
        ],
        "totalRows": 2,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}

"":""(TOKEN)""
"": http://192.168.50.159:4241/api/analyzer/getChainRechargeTokenList?adminAccount=admin&platform=no&account=no&pid=no&order_num=no&chain_id=no&token=no&from_address=no&transaction_hash=no&state=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
account (string)：no""
pid (string)：no""
order_num (string)：no""
chain_id (string)：no""
token (string)：no"", MIT HYT
from_address (string)：no""
transaction_hash (string)：no""
state (string)：no"",0"",1"",2""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&from_address=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&token=no&transaction_hash=no
"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&from_address=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&token=no&transaction_hash=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": "e5930861de9eb2462d29bf2bc8f2926f",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "token": "HYT",
                "update_time": 1672108575,
                "value": 200,
                "create_time": 1672108575,
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": "4bf747244eb3af46e17cf65bc8b357d1",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "token": "MIT",
                "update_time": 1672052187,
                "value": 300,
                "create_time": 1672052187,
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "pid": 1000001,
                "order_num": "c90f25ecebaba665d35e3e3e00c21bd5",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "token": "MIT",
                "update_time": 1672051841,
                "value": 300,
                "create_time": 1672051836,
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "update_time": 1672047611,
                "order_num": "8c4ff02f86e99c090ce4d4d132d6671c",
                "chain_id": 98,
                "message": "DifferentChain",
                "create_time": 1672047606,
                "token": "HYT",
                "value": 300,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": -1,
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "update_time": 1672047575,
                "order_num": "1f58f4e563a586e4a4cbd6650847be8e",
                "chain_id": 98,
                "message": "NoBindAccount",
                "create_time": 1672047572,
                "token": "HYT",
                "value": 300,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": -1,
                "from_address": "7013026796169859167108e2d5e9444da99655ac1"
            },
            {
                "pid": 1000001,
                "order_num": "8ad9abae4a12aac3387ba31278504425",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada5370920f",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "token": "HYT",
                "update_time": 1672047323,
                "value": 100,
                "create_time": 1672046993,
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            }
        ],
        "totalRows": 8,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}

"":""(NFT)""
"": http://192.168.50.159:4241/api/analyzer/getChainRechargeNftList?adminAccount=admin&platform=no&account=no&pid=no&order_num=no&chain_id=no&token_id=no&from_address=no&transaction_hash=no&state=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
account (string)：no""
pid (string)：no""
order_num (string)：no""
chain_id (string)：no""
token_id (string)：no""
from_address (string)：no""
transaction_hash (string)：no""
state (string)：no"",0"",1"",2""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&from_address=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&token_id=no&transaction_hash=no
"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&from_address=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&token_id=no&transaction_hash=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "token_ids": [
                    115002,
                    115003
                ],
                "platform": "local",
                "pid": 1000001,
                "order_num": "fcfd33947299368c0488d76dff31737a",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada53493177",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "update_time": 1672105311,
                "create_time": 1672105310,
                "fail_ids": "",
                "success_ids": "115002,",
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "token_ids": [
                    114002
                ],
                "platform": "local",
                "pid": 1000001,
                "order_num": "531f845bcb985d566639b05bfd4ee87f",
                "chain_id": 97,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada53844680",
                "state": 2,
                "owner_mail": "test02@gmail.com",
                "update_time": 1672105251,
                "create_time": 1672105251,
                "fail_ids": "",
                "success_ids": "114002,",
                "message": "success",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "token_ids": [
                    111002
                ],
                "update_time": 1672048107,
                "order_num": "a2cbc613c4a178f9f792171b0ed270eb",
                "chain_id": 97,
                "state": -1,
                "create_time": 1672048104,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada53614861",
                "fail_ids": "",
                "success_ids": "",
                "message": "DifferentChain",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            },
            {
                "token_ids": [
                    109002
                ],
                "update_time": 1672048041,
                "order_num": "de73432e445a2e7eb02b342f567fda56",
                "chain_id": 97,
                "state": -1,
                "create_time": 1672048040,
                "transaction_hash": "0xafa0a245d3f982933b8b88465a46cf2882f7b2cd43b3abddf3d77ada53509210",
                "fail_ids": "",
                "success_ids": "",
                "message": "DifferentChain",
                "from_address": "7013026796169859167108e2d5e9444da99655ac"
            }
        ],
        "totalRows": 7,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}

"":""(TOKEN)""
"": http://192.168.50.159:4241/api/analyzer/getChainWithdrawTokenList?adminAccount=admin&platform=no&account=no&pid=no&order_num=no&chain_id=no&token=no&to_address=no&transaction_hash=no&state=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
account (string)：no""
pid (string)：no""
order_num (string)：no""
chain_id (string)：no""
token (string)：no"", MIT HYT
to_address (string)：no""
state (string)：no"",0"",1"",2"",3"",-1""
transaction_hash (string)：no""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&to_address=no&token=no&transaction_hash=no
"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&to_address=no&token=no&transaction_hash=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": 17,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "state": 1,
                "owner_mail": "test02@gmail.com",
                "token": "HYT",
                "amount": 500,
                "transaction_hash": "",
                "update_time": 1672134975,
                "create_time": 1672134975,
                "message": "approval"
            },
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": 16,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "state": 1,
                "owner_mail": "test02@gmail.com",
                "token": "MIT",
                "amount": 200,
                "transaction_hash": "",
                "update_time": 1672134975,
                "create_time": 1672134975,
                "message": "approval"
            },
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": 14,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "state": 1,
                "owner_mail": "test02@gmail.com",
                "token": "HYT",
                "amount": 500,
                "transaction_hash": "",
                "update_time": 1672134532,
                "create_time": 1672134532,
                "message": "approval"
            },
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": 10,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "state": 1,
                "owner_mail": "test02@gmail.com",
                "token": "HYT",
                "amount": 500,
                "transaction_hash": "",
                "update_time": 1672134298,
                "create_time": 1672134298,
                "message": "approval"
            },
            {
                "platform": "local",
                "pid": 1000001,
                "order_num": 5,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "state": 1,
                "owner_mail": "test02@gmail.com",
                "token": "MIT",
                "amount": 200,
                "transaction_hash": "",
                "update_time": 1672134087,
                "create_time": 1672134087,
                "message": "approval"
            }
        ],
        "totalRows": 8,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}


"":""(NFT)""
"": http://192.168.50.159:4241/api/analyzer/getChainWithdrawNftList?adminAccount=admin&platform=no&account=no&pid=no&order_num=no&chain_id=no&token_id=no&item_id=no&item_cfgid=no&to_address=no&transaction_hash=no&state=no&beginCreateDate=no&endCreateDate=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (string)：local,androidGB,iosGB,androidGooglePlay,iosAppstore,no""
account (string)：no""
pid (string)：no""
order_num (string)：no""
chain_id (string)：no""
token_id (string)：no""
item_id (string)：no""
item_cfgid (string)：no""
to_address (string)：no""
state (string)：no"",0"",1"",2"",3"",-1""
transaction_hash (string)：no""
beginCreateDate (string)：no"", 20221202
endCreateDate (string)：no"", 20221202
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&item_cfgid=no&item_id=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&to_address=no&token_id=no&transaction_hash=no
"":account=no&adminAccount=admin&beginCreateDate=no&chain_id=no&endCreateDate=no&item_cfgid=no&item_id=no&order_num=no&pageNo=1&pageSize=20&pid=no&platform=no&state=no&to_address=no&token_id=no&transaction_hash=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "token_ids": {},
                "platform": "local",
                "pid": 1000001,
                "order_num": 18,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "item_ids": [
                    7013442215867322000,
                    7013442236968866000
                ],
                "owner_mail": "test02@gmail.com",
                "transaction_hash": "",
                "update_time": 1672134975,
                "create_time": 1672134975,
                "message": "approval",
                "state": 1,
                "item_cfgids": [
                    3800001,
                    3800002
                ]
            },
            {
                "token_ids": {},
                "platform": "local",
                "pid": 1000001,
                "order_num": 15,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "item_ids": [
                    7013440471322071000
                ],
                "owner_mail": "test02@gmail.com",
                "transaction_hash": "",
                "update_time": 1672134532,
                "create_time": 1672134532,
                "message": "approval",
                "state": 1,
                "item_cfgids": [
                    3800003
                ]
            },
            {
                "token_ids": [
                    114002,
                    119002
                ],
                "platform": "local",
                "pid": 1000001,
                "order_num": 11,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "item_ids": {},
                "owner_mail": "test02@gmail.com",
                "transaction_hash": "",
                "update_time": 1672134298,
                "create_time": 1672134298,
                "message": "approval",
                "state": 1,
                "item_cfgids": {}
            },
            {
                "token_ids": [
                    115002
                ],
                "platform": "local",
                "pid": 1000001,
                "order_num": 7,
                "chain_id": 97,
                "to_address": "7013026796169859167108e2d5e9444da99655ac",
                "item_ids": {},
                "owner_mail": "test02@gmail.com",
                "transaction_hash": "",
                "update_time": 1672134087,
                "create_time": 1672134087,
                "message": "approval",
                "state": 1,
                "item_cfgids": {}
            }
        ],
        "totalRows": 4,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}

"":""
"": http://192.168.50.159:4241/api/analyzer/getPaymentStatisticByDay?adminAccount=admin&beginDate=20230105&endDate=20230105&platform=all&pageNo=1&pageSize=20&sign=19cd1a8a4ded20f59f5d85608f5a24f3
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
platform (String):all ""，""："" local("")   androidGB(""android"")  iosGB(""ios"")  androidGooglePlay(""googleplay)  iosAppstore(ios"")
beginDate   (String): ""
endDate     (String): ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&beginDate=20230105&endDate=20230105&pageNo=1&pageSize=20&platform=all
"":adminAccount=admin&beginDate=20230105&endDate=20230105&pageNo=1&pageSize=20&platform=all&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "chainRechargeMIT": 0,
                "orderSettlePrice": 0,
                "orderReadyPrice": 0,
                "orderARPU": 0,
                "dayOrderSettleUser": 0,
                "orderRegisterPrice": 0,
                "dayPaymentRate": 0,
                "registerPaymentUser": 0,
                "exchangeARPU": 0,
                "dayHydroxylExchangeUser": 0,
                "chainWithdrawMIT": 0,
                "orderSettleCnt": 0,
                "platform": "local",
                "exchangeCnt": 0,
                "orderFirstPrice": 0,
                "firstPaymentUser": 0,
                "orderARPPU": 0,
                "dayPaymentUser": 0,
                "chainWithdrawHYT": 0,
                "orderReadyCnt": 0,
                "firstDayPaymentRate": 0,
                "createDate": 20230215,
                "exchangeHydroxyl": 0,
                "chainRechargeHYT": 0,
                "exchangeTesseract": 0,
                "orderTesseract": 0,
                "exchangeARPPU": 0
            },
            {
                "chainRechargeMIT": 0,
                "orderSettlePrice": 1.98,
                "orderReadyPrice": 1.98,
                "orderARPU": 0.99,
                "dayOrderSettleUser": 1,
                "orderRegisterPrice": 0,
                "dayPaymentRate": 1,
                "registerPaymentUser": 0,
                "exchangeARPU": 7488000,
                "dayHydroxylExchangeUser": 1,
                "chainWithdrawMIT": 0,
                "orderSettleCnt": 2,
                "platform": "androidGB",
                "exchangeCnt": 1,
                "orderFirstPrice": 0.99,
                "firstPaymentUser": 2,
                "orderARPPU": 1.98,
                "dayPaymentUser": 2,
                "chainWithdrawHYT": 0,
                "orderReadyCnt": 2,
                "firstDayPaymentRate": 0,
                "createDate": 20230215,
                "exchangeHydroxyl": 14976,
                "chainRechargeHYT": 0,
                "exchangeTesseract": 149760,
                "orderTesseract": 198,
                "exchangeARPPU": 14976000
            },
            {
                "chainRechargeMIT": 0,
                "orderSettlePrice": 0,
                "orderReadyPrice": 0,
                "orderARPU": 0,
                "dayOrderSettleUser": 0,
                "orderRegisterPrice": 0,
                "dayPaymentRate": 0,
                "registerPaymentUser": 0,
                "exchangeARPU": 0,
                "dayHydroxylExchangeUser": 0,
                "chainWithdrawMIT": 0,
                "orderSettleCnt": 0,
                "platform": "iosGB",
                "exchangeCnt": 0,
                "orderFirstPrice": 0,
                "firstPaymentUser": 0,
                "orderARPPU": 0,
                "dayPaymentUser": 0,
                "chainWithdrawHYT": 0,
                "orderReadyCnt": 0,
                "firstDayPaymentRate": 0,
                "createDate": 20230215,
                "exchangeHydroxyl": 0,
                "chainRechargeHYT": 0,
                "exchangeTesseract": 0,
                "orderTesseract": 0,
                "exchangeARPPU": 0
            },
            {
                "chainRechargeMIT": 0,
                "orderSettlePrice": 0,
                "orderReadyPrice": 0,
                "orderARPU": 0,
                "dayOrderSettleUser": 0,
                "orderRegisterPrice": 0,
                "dayPaymentRate": 0,
                "registerPaymentUser": 0,
                "exchangeARPU": 0,
                "dayHydroxylExchangeUser": 0,
                "chainWithdrawMIT": 0,
                "orderSettleCnt": 0,
                "platform": "androidGooglePlay",
                "exchangeCnt": 0,
                "orderFirstPrice": 0,
                "firstPaymentUser": 0,
                "orderARPPU": 0,
                "dayPaymentUser": 0,
                "chainWithdrawHYT": 0,
                "orderReadyCnt": 0,
                "firstDayPaymentRate": 0,
                "createDate": 20230215,
                "exchangeHydroxyl": 0,
                "chainRechargeHYT": 0,
                "exchangeTesseract": 0,
                "orderTesseract": 0,
                "exchangeARPPU": 0
            },
            {
                "chainRechargeMIT": 0,
                "orderSettlePrice": 0,
                "orderReadyPrice": 0,
                "orderARPU": 0,
                "dayOrderSettleUser": 0,
                "orderRegisterPrice": 0,
                "dayPaymentRate": 0,
                "registerPaymentUser": 0,
                "exchangeARPU": 0,
                "dayHydroxylExchangeUser": 0,
                "chainWithdrawMIT": 0,
                "orderSettleCnt": 0,
                "platform": "iosAppstore",
                "exchangeCnt": 0,
                "orderFirstPrice": 0,
                "firstPaymentUser": 0,
                "orderARPPU": 0,
                "dayPaymentUser": 0,
                "chainWithdrawHYT": 0,
                "orderReadyCnt": 0,
                "firstDayPaymentRate": 0,
                "createDate": 20230215,
                "exchangeHydroxyl": 0,
                "chainRechargeHYT": 0,
                "exchangeTesseract": 0,
                "orderTesseract": 0,
                "exchangeARPPU": 0
            }
        ],
        "totalRows": 5,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/gmGetSendMailLogs?adminAccount=admin&pageNo=1&pageSize=5&sendId=1000000&sendName=system&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
sendId  (Int) ""，""0（""0""）
sendName (String) ""(""，"")
receivePid     (int): ""pid,0""
beginDate   (String): ""
endDate     (String): ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&pageNo=1&pageSize=5&sendId=1000000&sendName=system
"":adminAccount=admin&pageNo=1&pageSize=5&sendId=1000000&sendName=system&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "code": 0
    "data":[
        "totalPage": 38,
        "totalRows": 187,
        "rows": [
            {
                "sendId":1000404,
                "sendName":"system",
                "toPidList":[1000364],
                "mailData":{
                    "sendPid":1000404,
                    "sendTime":1656579991,
                    "mailType":0,
                    "sendName":"system",
                    "receivePid":0,
                    "title":"System Notification",
                    "content" : "GB1000404 (ID:1000404) has made a purchase in game, you have rewarded 499.95 tesseracts. "
                    "logType" : 166,
                    "duration" : 720,
                    "filter" : 0,
                    "attachment" : [
                        {
                            "cfgId" : 107,
                            "type" : 0,
                            "count" : 499950
                        }
                    ],
                },
            },

            {
                "sendId" : 1000404,
                "sendName" : "GB1000404",
                "toPidList" : [
                    1000364
                ],
                "mailData" : {
                    "sendPid":1000404,
                    "sendTime":1656579991,
                    "mailType":0,
                    "sendName":"system",
                    "receivePid":0,
                    "title":"System Notification",
                    "content" : "Through your referral, GB1000404 (ID: 1000404) has joined the game. If the player successfully makes a purchase in game, you will be rewarded with certain amount of tesseracts"
                    "logType" : 68,
                    "duration" : 720,
                    "filter" : 0,
                    "attachment" : {
                        
                    },
                },
            }
        ],
        "pageSize": 2,
        "pageNo": 1
    ],
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""("")
"": http://192.168.1.19:4241/api/analyzer/getInvitePaymentFromAdmin?adminAccount=admin&date=20230306&fatherAccount=test10001@gmail.com&sonAccount=no&pageNo=1&pageSize=20&sign=19cd1a8a4ded20f59f5d85608f5a24f3
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
date   (String): "", "":20230306
fatherAccount    (String)："","": "no"
sonAccount    (String)："","": "no"
sign 	(String): MD5"",""："":

"":adminAccount=admin&date=20230304&fatherAccount=test01@gmail.com&pageNo=1&pageSize=20&sonAccount=no
"":adminAccount=admin&date=20230304&fatherAccount=test01@gmail.com&pageNo=1&pageSize=20&sonAccount=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
	"message": "OK",
	"data": {
		"totalPage": 1,
		"totalExchangeHydroxyl": 3018,
		"rows": [{
			"exchangeHydroxyl": 0,
			"pid": 1000004,
			"orderPrice": 9.98,
			"fatherAccount": "test01@gmail.com",
			"exchangeTesseract": 0,
			"orderTesseract": 998,
			"account": "test03@gmail.com"
		}, {
			"exchangeHydroxyl": 0,
			"pid": 1000007,
			"orderPrice": 4.99,
			"fatherAccount": "test01@gmail.com",
			"exchangeTesseract": 0,
			"orderTesseract": 499,
			"account": "test05@gmail.com"
		}, {
			"exchangeHydroxyl": 3018,
			"pid": 1000002,
			"orderPrice": 1.98,
			"fatherAccount": "test01@gmail.com",
			"exchangeTesseract": 3018,
			"orderTesseract": 198,
			"account": "test02@gmail.com"
		}],
		"totalOrderPrice": 16.95,
		"totalExchangeTesseract": 3018,
		"totalOrderTesseract": 1695,
		"totalRows": 3,
		"pageSize": 20,
		"pageNo": 1
	},
	"code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"": http://192.168.50.159:4241/api/analyzer/getPlayerLvDistribution?adminAccount=admin&refresh=0&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
refresh     (String)："", 0"", 1""
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin
"":account=no&adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
{
    "message": "OK",
    "data": {
        "rows": [
            {
                "level": 1,
                "count": 3,
                "countPercent": 0.375,
                "totalOnlineTime": 50,
                "avgTotalOnlineTime": 0.25,
            },
            {
                "level": 2,
                "count": 4,
                "countPercent": 0.5,
                "totalOnlineTime": 50,
                "avgTotalOnlineTime": 0.25,
            },
            {
                "level": 3,
                "count": 5,
                "countPercent": 0.625,
                "totalOnlineTime": 100,
                "avgTotalOnlineTime": 0.5,
            }
        ],
        "plyTotalCount": 8,
        "plyTotalOnlineTime": 200,
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/analyzer/getLeagueMatchRankList?adminAccount=admin&cfgId=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
cfgId  (Int) ""id
chainIndex  (Int) ""，0""，1""B""，2""C""
sign 	(String): MD5"",""："":

"":adminAccount=admin&cfgId=1
"":adminAccount=admin&cfgId=1&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "code": 0
    "data":[
        "cfgId": 1,
        "belong": 1,
        "matchType": 1,
        "name": """1""",
        "chainIndex": 1,
        "rankList": [
            {
                "rank":1,
                "unionId":100102,
                "unionName":"newmap",
                "score":10,
            },
            {
                "rank":2,
                "unionId":100103,
                "unionName":"jj123",
                "score":8,
            },
        ],
    ],
}
""belong=2,""
{
    "message": "OK",
    "code": 0
    "data":[
        "cfgId": 2,
        "belong": 2,
        "matchType": 3,
        "name": "pvp""1""（"")",
        "rankList": [
            {
                "rank":1,
                "playerId":1000755,
                "unionName":"",
                "playerScore":980,
                "playerLevel":30,
                "playerName":"CRYPTUDENT",
            },
            {
                "rank":2,
                "playerId":1000027,
                "unionName":"",
                "playerScore":940,
                "playerLevel":40,
                "playerName":"Super",
            },
        ],
    ],
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":pvp""
"":http://192.168.50.159:4241/api/analyzer/getPVPRankRealTimeData?adminAccount=admin&count=100&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
count  (Int) ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&count=100
"":adminAccount=admin&count=100&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "code": 0
    "data":[
        {
            "stage": 6,
            "count": 2,
            "list": [
                {
                    "rank":1,
                    "pid":100102,
                },
                {
                    "rank":2,
                    "pid":100103,
                },
            ],
        },
        {
            "stage": 5,
            "count": 2,
            "list": [
                {
                    "rank":10,
                    "pid":100104,
                },
                {
                    "rank":11,
                    "pid":100105,
                },
            ],
        },
    ],
}

"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"": http://192.168.50.159:4241/api/analyzer/getPlayerResRankList?adminAccount=admin&refresh=0&resKey=mit&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
refresh     (String)："", 0"", 1""
resKey     (String)："", mit, starCoin, ice, carboxyl, titanium, gas, tesseract, baseLevel("")
sign 	(String): MD5"",""："":

"":account=no&adminAccount=admin&refresh=0&resKey=mit
"":account=no&adminAccount=admin&refresh=0&resKey=mit&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
{
    "message": "OK",
    "data": {
        "rows": [
            {
                "account": "w1@ww.com",
                "pid": 1000580,
                "name": "GB1000595",
                "baseLevel": 1,
                "mit": 3000,
                "starCoin": 10000,
                "ice": 10000,
                "carboxyl": 10000,
                "titanium": 10000,
                "gas": 10000,
                "tesseract": 10000,
                "totalGameTime": 672,
                "pvpRank": 1,
                "ip": "10.168.1.61",
            },
            {
               "account": "a336479109@qq.com",
                "pid": 1000582,
                "name": "GB1000593",
                "baseLevel": 1,
                "mit": 3000,
                "starCoin": 10000,
                "ice": 10000,
                "carboxyl": 10000,
                "titanium": 10000,
                "gas": 10000,
                "tesseract": 10000,
                "totalGameTime": 672,
                "pvpRank": 0,
                "ip": "0.0.0.0",
            },
        ],
        "rankCount": 100,
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/getUnionRankRealTimeData?adminAccount=admin&count=100&refresh=0&rankKey=level&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
count  (Int) ""
refresh     (String)："", 0"", 1""
rankKey     (String)："", level, score, memCount
sign 	(String): MD5"",""："":

"":adminAccount=admin&count=100&refresh=0&rankKey=level
"":adminAccount=admin&count=100&refresh=0&rankKey=level&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
    "data":[
        "rows": [
            {
                "unionLevel": 7,
                "techs": [
                    "40101,1",
                    "40102,0",
                    "40103,0",
                    "40104,0",
                    "40105,0",
                    "40106,0",
                    "40107,0",
                    "40108,0",
                    "40109,0",
                    "40110,0",
                    "999992,0",
                    "30101,1",
                    "30102,0",
                    "999991,0",
                    "30104,0",
                    "30105,0",
                    "30106,0",
                    "30107,0",
                    "30108,0",
                    "30109,0",
                    "30103,0",
                    "70101,0"
                ],
                "beginPos": "12200160,200,-160",
                "presidentPId": 1000584,
                "presidentName": "GB1000584",
                "memCount": 3,
                "hyPosList": {
                
                },
                "unionId": 100004,
                "score": 0,
                "unionName": "jj253"
            },
            {
                "unionLevel": 1,
                "techs": [
                    "40101,1",
                    "40102,1",
                    "40103,1",
                    "40104,1",
                    "40105,1",
                    "40106,1",
                    "40107,1",
                    "40108,1",
                    "40109,1",
                    "40110,1",
                    "70101,0",
                    "30101,1",
                    "30102,1",
                    "30103,1",
                    "30104,1",
                    "30105,1",
                    "30106,1",
                    "30107,1",
                    "30108,1",
                    "30109,1",
                    "999992,0",
                    "999991,0"
                ],
                "beginPos": "11176024,176,24",
                "presidentPId": 1000576,
                "presidentName": "first",
                "memCount": 3,
                "hyPosList": [
                "11176020,176,20",
                "12180012,180,-12"
                ],
                "unionId": 100001,
                "score": 3,
                "unionName": "new1"
            },
        ],
        "rankCount": 100,
    ],
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/analyzer/getRechargeWithdrawInfo?adminAccount=admin&unique=1000314&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
unique (String): ""ID/""
sign 	(String): MD5"",""："":

"":adminAccount=admin&unique=1000314
"":adminAccount=admin&unique=1000314&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalChainWithdrawHYT": 100,
        "pid": 1000314,
        "totalExchangeHydroxyl": 108,
        "totalOrderPrice": 0.99,
        "totalChainRechargeMIT": 2300,
        "totalChainWithdrawMIT": 500,
        "totalChainRechargeHYT": 1300,
        "totalExchangeTesseract": 97.2,
        "totalOrderTesseract": 99
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""nft""
"":http://10.168.1.109:4241/api/analyzer/getAllNftsStatistic?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&flush=1&chainId=0
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
chainId         (Number): ""id
flush 	        (Number): "",0""，1""
sign 	        (String): MD5"",""："":

"":adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":adminAccount=admin&chainId=0&flush=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e

"":
"":
{
    "message": "OK",
    "data": [
        {
            "chainId": 97,
            "nfts": {
                "nftWarShips": {
                    "total": 109,
                    "level": {
                        "count": {
                            "1": 109
                        },
                        "ratio": {
                            "1": 1
                        }
                    },
                    "quality": {
                        "count": {
                            "5": 109
                        },
                        "ratio": {
                            "5": 1
                        }
                    }
                },
                "nftBuilds": {
                    "total": 119,
                    "level": {
                        "count": {
                            "1": 98,
                            "40": 16,
                            "2": 2,
                            "11": 1,
                            "3": 2
                        },
                        "ratio": {
                            "1": 0.82352941176471,
                            "40": 0.13445378151261,
                            "2": 0.016806722689076,
                            "11": 0.0084033613445378,
                            "3": 0.016806722689076
                        }
                    },
                    "quality": {
                        "count": {
                            "1": 20,
                            "5": 87,
                            "2": 12
                        },
                        "ratio": {
                            "1": 0.16806722689076,
                            "5": 0.73109243697479,
                            "2": 0.10084033613445
                        }
                    }
                },
                "nftHeros": {
                    "total": 88,
                    "level": {
                        "count": {
                            "1": 77,
                            "3": 4,
                            "2": 7
                        },
                        "ratio": {
                            "1": 0.875,
                            "3": 0.045454545454545,
                            "2": 0.079545454545455
                        }
                    },
                    "quality": {
                        "count": {
                            "5": 88
                        },
                        "ratio": {
                            "5": 1
                        }
                    }
                }
            }
        },
        {
            "chainId": 71,
            "nfts": {
                "nftWarShips": {
                    "total": 30,
                    "level": {
                        "count": {
                            "1": 30
                        },
                        "ratio": {
                            "1": 1
                        }
                    },
                    "quality": {
                        "count": {
                            "5": 10,
                            "4": 10,
                            "3": 10
                        },
                        "ratio": {
                            "5": 0.33333333333333,
                            "4": 0.33333333333333,
                            "3": 0.33333333333333
                        }
                    }
                },
                "nftBuilds": {
                    "total": 24,
                    "level": {
                        "count": {
                            "1": 24
                        },
                        "ratio": {
                            "1": 1
                        }
                    },
                    "quality": {
                        "count": {
                            "5": 8,
                            "4": 8,
                            "3": 8
                        },
                        "ratio": {
                            "5": 0.33333333333333,
                            "4": 0.33333333333333,
                            "3": 0.33333333333333
                        }
                    }
                },
                "nftHeros": {
                    "total": 24,
                    "level": {
                        "count": {
                            "1": 24
                        },
                        "ratio": {
                            "1": 1
                        }
                    },
                    "quality": {
                        "count": {
                            "5": 8,
                            "4": 8,
                            "3": 8
                        },
                        "ratio": {
                            "5": 0.33333333333333,
                            "4": 0.33333333333333,
                            "3": 0.33333333333333
                        }
                    }
                }
            }
        }
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------


"":""pvp""
"":http://192.168.50.159:4241/api/operation/getPvpCtrlData?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
    "data":{
        "PvpSysCarboxyl":200,
        "PvpStageRatio":[
            {
                "stage":1,
                "score":[0,124],
                "ratio":0,
            },
            {
                "stage":2,
                "score":[125,140,160,179],
                "ratio":0.08,
            },
            {
                "stage":3,
                "score":[180,200,220,254],
                "ratio":0.1,
            },
            {
                "stage":4,
                "score":[255,275,295,315,335,363],
                "ratio":0.12,
            },
            {
                "stage":5,
                "score":[364,385,405,445,465,503],
                "ratio":0.2,
            },
            {
                "stage":6,
                "score":[504,999999],
                "ratio":0.5,
            },
        ],
        "PvpJackpotPlayerRatio":0.2,
        "PvpJackpotShareRatio":0.4,
        "PvpRankMitReward":[
            {
                "min_rank":1,
                "max_rank":1,
                "mit":3000000,
            },
            {
                "min_rank":2,
                "max_rank":2,
                "mit":2000000,
            },
            {
                "min_rank":3,
                "max_rank":3,
                "mit":1500000,
            },
            {
                "min_rank":4,
                "max_rank":10,
                "mit":800000,
            },
            {
                "min_rank":11,
                "max_rank":20,
                "mit":400000,
            },
            {
                "min_rank":21,
                "max_rank":50,
                "mit":200000,
            },
            {
                "min_rank":51,
                "max_rank":100,
                "mit":100000,
            },
        ],
        "PvpJackpotSysVal":1000000000,
        "PvpJackpotInfo":{
            "sysCarboxyl":1000000000,
            "plyCarboxyl":6,
        },
    },
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""pvp""
"":http://192.168.50.159:4241/api/operation/setPvpJackpotPlayerRatio?adminAccount=admin&ratio=0.2&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
ratio (number) ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&ratio=0.2
"":adminAccount=admin&ratio=0.2&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""pvp""
"":http://192.168.50.159:4241/api/operation/setPvpJackpotShareRatio?adminAccount=admin&ratio=0.2&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
ratio (number) ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&ratio=0.2
"":adminAccount=admin&ratio=0.2&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""PVP""("")
"":http://192.168.50.159:4241/api/operation/setPvpJackpotSysVal?adminAccount=admin&op=set&value=100&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
op (String) ""(""set""add,set""，""，add""，"")
value (String) ""(op=set，""value>=0，op=add，""value="")
sign 	(String): MD5"",""："":

"":adminAccount=admin&op=set&value=100
"":adminAccount=admin&op=set&value=100&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""pvp""mit""
"":http://192.168.50.159:4241/api/operation/setPvpRankMitReward?adminAccount=admin&reward=%5B{%22mit%22%3A3000000%2C%22min_rank%22%3A1%2C%22max_rank%22%3A1}%2C{%22mit%22%3A2000000%2C%22min_rank%22%3A2%2C%22max_rank%22%3A2}%2C{%22mit%22%3A1500000%2C%22min_rank%22%3A3%2C%22max_rank%22%3A3}%2C{%22mit%22%3A800000%2C%22min_rank%22%3A4%2C%22max_rank%22%3A10}%2C{%22mit%22%3A400000%2C%22min_rank%22%3A11%2C%22max_rank%22%3A20}%2C{%22mit%22%3A200000%2C%22min_rank%22%3A21%2C%22max_rank%22%3A50}%2C{%22mit%22%3A100000%2C%22min_rank%22%3A51%2C%22max_rank%22%3A100}%5D&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
reward    (JSON) "" [{"mit":3000000,"min_rank":1,"max_rank":1},{"mit":2000000,"min_rank":2,"max_rank":2},{"mit":1500000,"min_rank":3,"max_rank":3},{"mit":800000,"min_rank":4,"max_rank":10},{"mit":400000,"min_rank":11,"max_rank":20},{"mit":200000,"min_rank":21,"max_rank":50},{"mit":100000,"min_rank":51,"max_rank":100}]
    |
    -min_rank (number) ""
    |
    -max_rank (number) ""
    |
    -mit (number) mit""
sign 	(String): MD5"",""："":

"":adminAccount=admin&reward=%5B{%22mit%22%3A3000000%2C%22min_rank%22%3A1%2C%22max_rank%22%3A1}%2C{%22mit%22%3A2000000%2C%22min_rank%22%3A2%2C%22max_rank%22%3A2}%2C{%22mit%22%3A1500000%2C%22min_rank%22%3A3%2C%22max_rank%22%3A3}%2C{%22mit%22%3A800000%2C%22min_rank%22%3A4%2C%22max_rank%22%3A10}%2C{%22mit%22%3A400000%2C%22min_rank%22%3A11%2C%22max_rank%22%3A20}%2C{%22mit%22%3A200000%2C%22min_rank%22%3A21%2C%22max_rank%22%3A50}%2C{%22mit%22%3A100000%2C%22min_rank%22%3A51%2C%22max_rank%22%3A100}%5D
"":adminAccount=admin&%reward=5B{%22mit%22%3A3000000%2C%22min_rank%22%3A1%2C%22max_rank%22%3A1}%2C{%22mit%22%3A2000000%2C%22min_rank%22%3A2%2C%22max_rank%22%3A2}%2C{%22mit%22%3A1500000%2C%22min_rank%22%3A3%2C%22max_rank%22%3A3}%2C{%22mit%22%3A800000%2C%22min_rank%22%3A4%2C%22max_rank%22%3A10}%2C{%22mit%22%3A400000%2C%22min_rank%22%3A11%2C%22max_rank%22%3A20}%2C{%22mit%22%3A200000%2C%22min_rank%22%3A21%2C%22max_rank%22%3A50}%2C{%22mit%22%3A100000%2C%22min_rank%22%3A51%2C%22max_rank%22%3A100}%5D&STARWAR2021HAPPYFISHADMININTERFACE&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""pvp""
"":http://192.168.50.159:4241/api/operation/setPvpStageRatio?adminAccount=admin&pvpStage=%5B%7B%22ratio%22%3A0%2C%22stage%22%3A1%2C%22score%22%3A%5B0%2C124%5D%7D%2C%7B%22ratio%22%3A0.08%2C%22stage%22%3A2%2C%22score%22%3A%5B125%2C140%2C160%2C179%5D%7D%2C%7B%22ratio%22%3A0.1%2C%22stage%22%3A3%2C%22score%22%3A%5B180%2C200%2C220%2C254%5D%7D%2C%7B%22ratio%22%3A0.12%2C%22stage%22%3A4%2C%22score%22%3A%5B255%2C275%2C295%2C315%2C335%2C363%5D%7D%2C%7B%22ratio%22%3A0.2%2C%22stage%22%3A5%2C%22score%22%3A%5B364%2C385%2C405%2C445%2C465%2C503%5D%7D%2C%7B%22ratio%22%3A0.5%2C%22stage%22%3A6%2C%22score%22%3A%5B504%2C999999%5D%7D%5D&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pvpStage    (JSON) "" [{"ratio":0,"stage":1,"score":[0,124]},{"ratio":0.08,"stage":2,"score":[125,140,160,179]},{"ratio":0.1,"stage":3,"score":[180,200,220,254]},{"ratio":0.12,"stage":4,"score":[255,275,295,315,335,363]},{"ratio":0.2,"stage":5,"score":[364,385,405,445,465,503]},{"ratio":0.5,"stage":6,"score":[504,999999]}]
    |
    -stage (number) ""
    |
    -score (json)[0,124] ""(""，""0，""999999，"")
    |
    -ratio (number) ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&%pvpStage=5B{%22mit%22%3A3000000%2C%22min_rank%22%3A1%2C%22max_rank%22%3A1}%2C{%22mit%22%3A2000000%2C%22min_rank%22%3A2%2C%22max_rank%22%3A2}%2C{%22mit%22%3A1500000%2C%22min_rank%22%3A3%2C%22max_rank%22%3A3}%2C{%22mit%22%3A800000%2C%22min_rank%22%3A4%2C%22max_rank%22%3A10}%2C{%22mit%22%3A400000%2C%22min_rank%22%3A11%2C%22max_rank%22%3A20}%2C{%22mit%22%3A200000%2C%22min_rank%22%3A21%2C%22max_rank%22%3A50}%2C{%22mit%22%3A100000%2C%22min_rank%22%3A51%2C%22max_rank%22%3A100}%5D
"":adminAccount=admin&pvpStage=%5B{%22mit%22%3A3000000%2C%22min_rank%22%3A1%2C%22max_rank%22%3A1}%2C{%22mit%22%3A2000000%2C%22min_rank%22%3A2%2C%22max_rank%22%3A2}%2C{%22mit%22%3A1500000%2C%22min_rank%22%3A3%2C%22max_rank%22%3A3}%2C{%22mit%22%3A800000%2C%22min_rank%22%3A4%2C%22max_rank%22%3A10}%2C{%22mit%22%3A400000%2C%22min_rank%22%3A11%2C%22max_rank%22%3A20}%2C{%22mit%22%3A200000%2C%22min_rank%22%3A21%2C%22max_rank%22%3A50}%2C{%22mit%22%3A100000%2C%22min_rank%22%3A51%2C%22max_rank%22%3A100}%5D&STARWAR2021HAPPYFISHADMININTERFACE&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/operation/getTesseractToResRate?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": {
        "0": {
            "titanium": "10",
            "starCoin": "10",
            "gas": "10",
            "tesseract": "1",
            "ice": "10"
        },
        "56": {
            "titanium": "10",
            "starCoin": "10",
            "gas": "10",
            "tesseract": "1",
            "ice": "10"
        },
        "71": {
            "titanium": "10",
            "starCoin": "10",
            "gas": "10",
            "tesseract": "1",
            "ice": "10"
        },
        "97": {
            "titanium": "10",
            "starCoin": "10",
            "gas": "10",
            "tesseract": "1",
            "ice": "10"
        },
        "1030": {
            "titanium": "10",
            "starCoin": "10",
            "gas": "10",
            "tesseract": "1",
            "ice": "10"
        }
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/operation/setTesseractToResRate?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&starCoin=10000&ice=10000&titanium=10000&gas=10000&chain=97
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
chain (String): ""ID
starCoin (String): ""
ice (String): ""
titanium (String): ""
gas (String): ""
sign 	(String): MD5"",""："":


"":adminAccount=admin&chain=97&gas=10000&ice=10000&starCoin=10000&titanium=10000
"":adminAccount=admin&chain=97&gas=10000&ice=10000&starCoin=10000&titanium=10000&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {},
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/operation/getHyToTesseractRate?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "data": {
        "0": {
            "hydroxyl": "1",
            "tesseract": "1"
        },
        "56": {
            "hydroxyl": "1",
            "tesseract": "1"
        },
        "71": {
            "hydroxyl": "1",
            "tesseract": "1"
        },
        "97": {
            "hydroxyl": "1",
            "tesseract": "2.5"
        },
        "1030": {
            "hydroxyl": "1",
            "tesseract": "1"
        }
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/operation/setHyToTesseractRate?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&tesseract=1.5&chain=97
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
chain (String): ""ID
tesseract (String): "",""
sign 	(String): MD5"",""："":


"":adminAccount=admin&chain=97&tesseract=1.5
"":adminAccount=admin&chain=97&tesseract=1.5&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/getPayCurrencyInfo?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":


"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "CNY": {
            "rate": "6.88",
            "en_name": "Renminbi"
        },
        "AUD": {
            "rate": "1.48",
            "en_name": "Australian Dollar"
        },
        "USD": {
            "rate": "1",
            "en_name": "United States dollar"
        },
        "BRL": {
            "rate": "5.24",
            "en_name": "Brazilian real"
        },
        "PHP": {
            "rate": "55.01",
            "en_name": "Philippine peso"
        },
        "JPY": {
            "rate": "136.36",
            "en_name": "Japanese yen"
        },
        "IDR": {
            "rate": "15250.55",
            "en_name": "Indonesian rupiah"
        },
        "EUR": {
            "rate": "0.94",
            "en_name": "Euro"
        },
        "ARS": {
            "rate": "197.17",
            "en_name": "Argentine peso"
        },
        "GBP": {
            "rate": "0.83",
            "en_name": "Pound sterling"
        },
        "MYR": {
            "rate": "4.49",
            "en_name": "Malaysian ringgit"
        }
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/setPayCurrencyInfo?adminAccount=admin&currency=EUR&en_name=Euro&rate=0.94&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
currency    (String)：""ISO4217 code
en_name    (String)：""
rate    (String)："", "" "-9999" ""
sign 	(String): MD5"",""："":


"":adminAccount=admin&currency=EUR&en_name=Euro&rate=0.94
"":adminAccount=admin&currency=EUR&en_name=Euro&rate=0.94&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/getPayChannelInfo?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":


"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "pay_internation": {
            "status": "open",
            "currency": {
                "USD": "United States dollar",
                "EUR": "Euro",
                "CNY": "Renminbi",
                "HKD": "Hong Kong dollar"
            },
            "name": "internation",
            "payType": {
                "INTERNATIONAL_CARD": {
                    "status": "open"
                },
                "INTERNATIONAL_TEST2": {
                    "status": "open",
                    "support": [
                        "USD",
                        "CNY"
                    ]
                },
                "INTERNATIONAL_TEST1": {
                    "status": "close"
                }
            }
        },
        "pay_xsolla": {
            "status": "open",
            "currency": {
                "USD": "United States dollar"
            },
            "name": "xsolla",
            "payType": {}
        },
        "pay_local": {
            "status": "open",
            "currency": {
                "USD": "United States dollar"
            },
            "name": "local",
            "payType": {}
        }
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/setPayChannelInfo?adminAccount=admin&payChannel=pay_xsolla&data={"status":"open","currency":{"USD":"United States dollar"},"name":"xsolla","payType":{}}&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
payChannel    (String)：""
data    (String)："","{}"""
sign 	(String): MD5"",""："":


"":adminAccount=admin&data={"status":"open","currency":{"USD":"United States dollar"},"name":"xsolla","payType":{}}
"":adminAccount=admin&data={"status":"open","currency":{"USD":"United States dollar"},"name":"xsolla","payType":{}}&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/getGiftCodeCfg?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":


"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": [
        {
            "itemCfgId": 6910001,
            "cfgId": 102,
            "des": "tessert2000",
            "endDate": "20250306",
            "style": 2,
            "beginDate": "20230306",
            "limit": 1,
            "prefix": "102",
            "name": "new gift2"
        },
        {
            "itemCfgId": 6910001,
            "cfgId": 103,
            "des": "tessert3000",
            "endDate": "20250306",
            "style": 2,
            "beginDate": "20230306",
            "limit": 1,
            "prefix": "103",
            "name": "new gift3"
        },
        {
            "itemCfgId": 6910001,
            "cfgId": 101,
            "des": "tessert1000",
            "endDate": "20250306",
            "style": 1,
            "beginDate": "20230306",
            "limit": 1,
            "prefix": "vip666",
            "name": "new gift1"
        }
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":"",""excel
"":http://10.168.1.95:4241/api/operation/generateGiftCodes?adminAccount=admin&cfgId=102&count=50&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
cfgId    (String)：""cfgId
count    (String)：""
sign 	(String): MD5"",""："":


"":adminAccount=admin&cfgId=102&count=50
"":adminAccount=admin&cfgId=102&count=50&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": [
        "1027PEfrjytdIt",
        "1023d3aBVQmU47",
        "1025TRjGNPzd2E",
        "10236EE4IJsTox",
        "1025uCboUYpZuV",
        "10289cv9uaKv2v",
        "1028ReRYk5rbEq",
        "102B7NhIMAlc00",
        "1029LWJ0MUdFo9",
        "1021BeMaW1JiYSM"
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/operation/getGiftCodes?adminAccount=admin&cfgId=no&code=no&pid=no&use=no&pageSize=20&pageNo=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
cfgId    (String)：""cfgId,"" no
code    (String)："","" no
pid    (String)：""id,"" no,
use    (String)：1"",0"","" no
sign 	(String): MD5"",""："":

"":adminAccount=admin&cfgId=no&code=no&pageNo=1&pageSize=20&pid=no&use=no
"":adminAccount=admin&cfgId=no&code=no&pageNo=1&pageSize=20&pid=no&use=no&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "cfgId": 102,
                "rewardTime": 1678166950,
                "pid": 1000222,
                "code": "102zWKsWFG7g4"
            },
            {
                "cfgId": 102,
                "rewardTime": 1678158195,
                "pid": 1000222,
                "code": "102P3gjlyLaWB"
            },
            {
                "cfgId": 102,
                "rewardTime": 1678157707,
                "pid": 1000222,
                "code": "10218J7zySIr6F"
            }
        ],
        "totalRows": 3,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

""、""，""item""
"":http://10.168.1.109:4241/api/config/getDynamicCfg?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&configName=item

"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":
configName 	(String): ""，""，item

"":adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e

"":
"":
{
    "message": "OK",
    "data": [
        {
            "cfgId": 7110011,
            "languageNameID": "prop_6810002_Name",
            "icon": "box 01_icon",
            "canUse": 0,
            "canResolve": 0,
            "itemType": 15,
            "isAutoUse": 1,
            "webName": "taikuang",
            "languageDescID": "prop_6810002_Desc",
            "maxNum": 1,
            "webDesc": "taikuang",
            "quality": 1
        },
        {
            "cfgId": 8720001,
            "languageNameID": "prop_8720001_Name",
            "icon": "box 01_icon",
            "canUse": 0,
            "canResolve": 0,
            "itemType": 15,
            "isAutoUse": 0,
            "webName": "Card Ticket",
            "languageDescID": "prop_8720001_Desc",
            "maxNum": 99,
            "webDesc": "Materials used to draw cards for the general card pool.",
            "quality": 5
        },
}
"":
{
    "message": "ACCOUNT NOT EXIST",
    "code": -20005
}

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------

"":""
"":http://192.168.50.159:4241/api/mail/gmSendMail?adminAccount=admin&sendId=1000000&sendName=system&toPidList=%5B1000001%2C+1000002%5D&mailData={%22title%22%3A%22this+is+a+test+mail%22%2C%22content%22%3A%22this+content+is+xxxxxxxxxxxxxxxxxxxxxxxxxxx%22}&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sendId  (Int) ""，""0
sendName (String) ""
toPidList   (JSON) "" [pid1, pid2, pid3]，""[]
mailData    (JSON) "" {"title": "xxx", "content":"xxxxxxxxxxxxxxxxxxxxxxxxxxx", "attachment":data}
    |
    -title (String) ""
    |
    -content (String) ""
    |
    -attachment (JSON) ""[{"cfgId":101,"count":1000,"type":0},{"cfgId":102,"count":1000,"type":0},...]
        |
        -cfgId (number) ""id(101-mit,102-"",103-"",104-"",105-"",106-"")
        |
        -count (number) ""
        |
        -type (number) ""(0"",1""),""
    |
    duration (number) ""("")
    |
    filter (number) 0"",1"",2""
sign 	(String): MD5"",""："":

"":adminAccount=admin&mailData=%7B%22title%22%3A%22this%20is%20a%20test%20mail%22%2C%22content%22%3A%22this%20content%20is%20xxxxxxxxxxxxxxxxxxxxxxxxxxx%22%7D&sendId=1000000&sendName=system&toPidList=%5B1000001%2C%201000002%5D
"":adminAccount=admin&mailData=%7B%22title%22%3A%22this%20is%20a%20test%20mail%22%2C%22content%22%3A%22this%20content%20is%20xxxxxxxxxxxxxxxxxxxxxxxxxxx%22%7D&sendId=1000000&sendName=system&toPidList=%5B1000001%2C%201000002%5D&STARWAR2021HAPPYFISHADMININTERFACE&TsvbwMWNoffVHd3YCuV5cSFVPHzriFTB


"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/mail/gmGetMails?adminAccount=admin&pageNo=1&pageSize=5&sendId=1000000&sendName=system&isDetail=true&sign=4b08800d2a3cd0355b6e47e24ce98a6e&beginDate=20230311&endDate=20230520
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
sendId  (Int) ""，""0（""0""）
sendName (String) ""(""，"")
isDetail (Boolean) ""(""false，""content""attachment)
sign 	(String): MD5"",""："":
beginDate  (Int): ""(""20220303)
endDate    (Int): ""(""20220318)
"":adminAccount=admin&beginDate=20230311&endDate=20230520&isDetail=true&pageNo=1&pageSize=5&sendId=1000000&sendName=system
"":adminAccount=admin&isDetail=true&pageNo=1&pageSize=5&sendId=1000000&sendName=system&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG


"":
"":
{
    "message": "OK",
    "code": 0
    "data":[
        "totalPage": 38,
        "totalRows": 187,
        "rows": [
            {
                "sendPid":0,
                "sendTime":1656579991,
                "mailType":0,
                "sendName":"system",
                "receivePid":0,
                "title":"this is a test mail",
                "attachment":[{"cfgId":101,"type":0,"count":1000},{"cfgId":102,"type":0,"count":1000}],
                "content":"this content is xxxxxxxxxxxxxxxxxxxxxxxxxxx",
                "id":1,
                "logType":67,
                "reason":"mail from game master",
                "duration":720,
                "filter":0,
                "filterDesc":"all player",
            },

            {
                "sendPid":0,
                "sendTime":1656924102,
                "mailType":0,
                "sendName":"system",
                "receivePid":0,
                "title":"ets",
                "attachment":[{"cfgId":101,"type":0,"count":1000}],
                "content":"qqewq",
                "id":320,
                "logType":67,
                "reason":"mail from game master",
                "duration":720,
                "filter":0,
                "filterDesc":"all player",
            }
        ],
        "pageSize": 2,
        "pageNo": 1
    ],
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/mail/gmDelMail?adminAccount=admin&id=400&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
id  (Int) ""id
sign 	(String): MD5"",""："":

"":adminAccount=admin&id=400
"":adminAccount=admin&id=400&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------

"":""
"":http://192.168.50.159:4241/api/game/freezePlayer?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}



"":""
"":http://192.168.50.159:4241/api/game/unfreezePlayer?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/game/banChat?adminAccount=admin&banMinutes=60&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
banMinutes  (Int): ""
sign 	(String): MD5"",""："":

"":adminAccount=admin&banMinutes=60
"":adminAccount=admin&banMinutes=60&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}


"":""
"":http://192.168.50.159:4241/api/game/unbanChat?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/game/createRobot?adminAccount=admin&cfgId=1&robotid=0&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
cfgId   (Int): ""
robotid (Int): ""ID
sign 	(String): MD5"",""："":

"":adminAccount=admin&cfgId=1&robotid=1
"":adminAccount=admin&cfgId=1&robotid=1&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "password": "z123456",
        "roleid": 1000015,
        "roleName": "Commander1000015",
        "account": "zzobot7@qq.com"
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""gm""
"":http://192.168.50.159:4241/api/game/changePlayerGm?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000&gm=1
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
gm    (Int): 0 ""gm"", >=1 ""gm""
sign 	(String): MD5"",""："":

"":adminAccount=admin&gm=1&pid=1000000
"":adminAccount=admin&gm=1&pid=1000000&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""Gm""
"":http://192.168.50.159:4241/api/game/getGmPlayerList?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	        (String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": [
        {
            "isGm": true,
            "mail": "test1@qq.com",
            "name": "Commander1000000",
            "gmValidTime": 1659495977,
            "pid": 1000000
        },
        {
            "isGm": true,
            "mail": "test2@qq.com",
            "name": "Commander1000001",
            "gmValidTime": 1659494554,
            "pid": 1000001
        }
    ],
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}



"":""(""/"")""
"":http://10.168.1.95:4241/api/game/whiteListGetStatus?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "close",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""(""/"")""
"":http://10.168.1.95:4241/api/game/whiteListSetStatus?adminAccount=admin&status=open1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
status    (String)："", open2"", open1"",close""
sign 	(String): MD5"",""："":

"":adminAccount=admin&status=open1
"":adminAccount=admin&status=open1&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "open",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/game/whiteListGetAccount?adminAccount=admin&pageNo=1&pageSize=20&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&pageNo=1&pageSize=20
"":adminAccount=admin&pageNo=1&pageSize=20&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "totalRows": 8,
        "rows": [
            {
                "value": "2",
                "account": "test08@gmail.com"
            },
            {
                "value": "2",
                "account": "test04@gmail.com"
            },
            {
                "value": "2",
                "account": "test03@gmail.com"
            },
            {
                "value": "2",
                "account": "test02@gmail.com"
            },
            {
                "value": "2",
                "account": "test01@gmail.com"
            },
            {
                "value": "1",
                "account": "test07@gmail.com"
            },
            {
                "value": "1",
                "account": "test06@gmail.com"
            },
            {
                "value": "1",
                "account": "test05@gmail.com"
            }
        ],
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/game/whiteListSetAccount?adminAccount=admin&account=test10@gmail.com&value=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
account    (String)：""
value    (String)："", 2"", 1"", 0""
sign 	(String): MD5"",""："":

"":account=test10@gmail.com&adminAccount=admin&value=1
"":account=test10@gmail.com&adminAccount=admin&value=1&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/game/getAllGlobalSetStatus?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""        (""):   ""
adminAccount    (String)：""
sign (String): MD5"",""："":
"":
"":
{
    "message": "OK",
    "data": {
        "chainBridgeStatus": "open",
    },
    "code": 0
}

"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.109:4241/api/game/setAllGlobalSetStatus?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&data={"ChainBridgeStatus":"close"}
"":post
"":
""        (""):   ""
adminAccount    (String)：""
sign (String): MD5"",""："":
data    (String)："",  {"chainBridgeStatus":"close"}  ""，""

"":
{
    "message": "OK",
    "data": [
        {
            "ChainBridgeStatus": "open"
        }
    ],
    "code": 0
}

"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/game/kickPlayer?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&pid=1000000&reason=gm
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid   (Int): ""ID
reason   (String): ""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/game/businessSetAccount?adminAccount=admin&account=test10@gmail.com&value=1&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
account    (String)：""
value    (String)："", 1"", 0""
sign 	(String): MD5"",""："":

"":account=test10@gmail.com&adminAccount=admin&value=1
"":account=test10@gmail.com&adminAccount=admin&value=1&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/game/businessGetAccount?adminAccount=admin&businessAccount=test01@gmail.com&pageNo=1&pageSize=20&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
businessAccount    (String)："",""no
pageNo    (int)：""
pageSize    (int)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin&businessAccount=test01@gmail.com&pageNo=1&pageSize=20
"":adminAccount=admin&businessAccount=test01@gmail.com&pageNo=1&pageSize=20&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 1,
        "rows": [
            {
                "TRC20": "",
                "PAYPAL": "",
                "PHONE": "",
                "DISCORD": "",
                "TELEGRAM": "",
                "BEP20": "",
                "business": 1,
                "ERC20": "",
                "account": "test101@gmail.com"
            }
        ],
        "totalRows": 1,
        "pageSize": 20,
        "pageNo": 1
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.109:4241/api/game/correctPlayerData?adminAccount=admin&sign=e10adc3949ba59abbe56e057f20f883e&pid=1001755&kind=1
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
pid    (int): ""pid
kind    (int): "" 1|build，2|hero，3|warShip
sign 	(String): MD5"",""："":

"":adminAccount=admin&kind=1&pid=1001755&sign=e10adc3949ba59abbe56e057f20f883e
"":adminAccount=admin&sign=e10adc3949ba59abbe56e057f20f883e&pid=1001755&kind=1

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------

"":""
"":http://192.168.50.159:4241/api/config/getMatchCfg?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
sign 	(String): MD5"",""："":

"":adminAccount=admin
"":adminAccount=admin&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0,
    "data": [
        {
            "season": 1,
            "matchType": 1,
            "cfgId": 1,
            "rewardTime": "2022-07-12 10:00:00",
            "rewardType": 1,
            "delayRewardTime": 259200,
            "rewardCfgId": 1,
            "endTime": "2022-07-11 10:00:00",
            "name": """1""",
            "status": 0,
            "noticeTime": "2022-07-09 10:00:00",
            "belong": 1,
            "startTime": "2022-07-10 10:00:00"
        }
    ]
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://192.168.50.159:4241/api/config/setMatchCfg?adminAccount=admin&sign=4b08800d2a3cd0355b6e47e24ce98a6e&data=%5B{%09%22cfgId%22%3A+1%2C%09%22delayRewardTime%22%3A+259200%2C%09%22belong%22%3A+1%2C%09%22rewardType%22%3A+0%2C%09%22noticeTime%22%3A+%222022-07-08+17%3A03%3A00%22%2C%09%22matchType%22%3A+1%2C%09%22name%22%3A+%22%E5%85%AC%E4%BC%9A%E6%98%9F%E5%9B%BE%E8%81%94%E8%B5%9B%E5%91%A8%E8%B5%9B%E7%AC%AC1%E5%AD%A3%22%2C%09%22rewardCfgId%22%3A+1%2C%09%22status%22%3A+1%2C%09%22startTime%22%3A+%222022-07-08+17%3A04%3A00%22%2C%09%22endTime%22%3A+%222022-07-08+17%3A05%3A00%22%2C%09%22rewardTime%22%3A+%222022-07-08+17%3A06%3A00%22}%5D
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
data    (String): JSON""(getMatchCfg""data)
sign 	(String): MD5"",""："":

"":adminAccount=admin&data=[{	"cfgId": 1,	"delayRewardTime": 259200,	"belong": 1,	"rewardType": 0,	"noticeTime": "2022-07-08 17:03:00",	"matchType": 1,	"name": """1""",	"rewardCfgId": 1,	"status": 1,	"startTime": "2022-07-08 17:04:00",	"endTime": "2022-07-08 17:05:00",	"rewardTime": "2022-07-08 17:06:00"}]
"":adminAccount=admin&data=[{	"cfgId": 1,	"delayRewardTime": 259200,	"belong": 1,	"rewardType": 0,	"noticeTime": "2022-07-08 17:03:00",	"matchType": 1,	"name": """1""",	"rewardCfgId": 1,	"status": 1,	"startTime": "2022-07-08 17:04:00",	"endTime": "2022-07-08 17:05:00",	"rewardTime": "2022-07-08 17:06:00"}]&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "code": 0,
    "data": "Success"
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"".""MIT""
"":http://192.168.50.159:4241/api/config/setHoldTrueMitWalletAddress?adminAccount=admin&sign=aa8747f2356fdecdce51ef70a31e392f
"":POST
"":
""    	    (""):   ""
adminAccount    (String) "" "admin"
sign            (String) "" "aa8747f2356fdecdce51ef70a31e392f"

body"": {"0xbad671f87743d0a8d261fe56c48f8a44cbbb0d6a":1}

"":
{
    "message": "OK",
    "data": "2590 Success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

-----------------------------------------------------------------------------------------------
*****dapp
-----------------------------------------------------------------------------------------------
""、""(dapp)
"":http://10.168.1.95:4241/api/dapp/getPlayerInformation?mail=test104@gmail.com
"":GET
"":
""    	    (""):   ""
mail    (String) ""

"":
"":
{
    "message": "OK",
    "data": {
        "walletAddress": "702864176847625011551b3d6ee7d9e867111fd3",
        "pid": 1000094,
        "headIcon": "profile phpto 11_icon",
        "chainId": 97,
        "name": "GB1000094",
        "inviteCode": "4CAY",
        "account": "test104@gmail.com"
    },
    "code": 0
}
"":
{
    "message": "ACCOUNT NOT EXIST",
    "code": -20005
}


""、""(dapp)
"":http://10.168.1.95:4241/api/dapp/getPlayerStoreBag?mail=test104@gmail.com
"":GET
"":
""    	    (""):   ""
mail    (String) ""

"":
"":
{
    "message": "OK",
    "data": {
        "nftItems": [
            {
                "id": 393002,
                "bscName": "Scourge DF Centipede #R",
                "curLife": 212,
                "name": "Centipede",
                "kind": 3,
                "life": 212,
                "chain": 97,
                "cfgId": 3201001,
                "race": 2,
                "level": 1,
                "style": 1,
                "quality": 2
            },
            {
                "skillLevel2": 0,
                "race": 2,
                "chain": 97,
                "skillLevel3": 0,
                "level": 1,
                "skillName1": "skillName6100007",
                "quality": 2,
                "cfgId": 2201001,
                "bscName": "Scourge Hero TB #R",
                "curLife": 202,
                "skill3": 0,
                "name": "Scourge Hero TB #R",
                "life": 202,
                "style": 1,
                "skill2": 0,
                "id": 392002,
                "kind": 2,
                "skillLevel1": 1,
                "skill1": 6100007
            },
            {
                "skillLevel2": 0,
                "race": 2,
                "chain": 97,
                "skill1": 5116023,
                "level": 1,
                "skillName1": "skillName5116023",
                "quality": 2,
                "skillLevel4": 0,
                "bscName": "Scourge Ship BlueRingedOctopus #R",
                "id": 391002,
                "name": "BlueRingedOctopus",
                "curLife": 184,
                "skill3": 0,
                "skill4": 0,
                "life": 184,
                "style": 1,
                "skill2": 0,
                "cfgId": 1201001,
                "kind": 1,
                "skillLevel1": 1,
                "skillLevel3": 0
            } 
        ],
        "carboxyl": 0,
        "mit": 0
    },
    "code": 0
}
"":
{
    "message": "ACCOUNT NOT EXIST",
    "code": -20005
}


-----------------------------------------------------------------------------------------------
*****pay
-----------------------------------------------------------------------------------------------
""、""
"":http://10.168.1.95:4241/api/pay/repairOrder?adminAccount=admin&orderId=11111111&value=0&sign=4b08800d2a3cd0355b6e47e24ce98a6e
"":GET
"":
""    	    (""):   ""
adminAccount    (String)：""
orderId    (String)：""
value    (String)："", 0"", 1""
sign 	(String): MD5"",""："":

"":adminAccount=admin&orderId=11111111&value=0
"":adminAccount=admin&orderId=11111111&value=0&STARWAR2021HAPPYFISHADMININTERFACE&ZR5JhXPSVMta2ahy4VwDCHs1POWZgNLG

"":
"":
{
    "message": "OK",
    "data": "success",
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}




