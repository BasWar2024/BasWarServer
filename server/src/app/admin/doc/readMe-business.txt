businessAccountLogin"":
sign = MD5("",key=value"",""&"" + "&" + MD5_KEY)
MD5_KEY = "STARWAR2021HAPPYFISHBUSINESSINTERFACE"

"":
sign = MD5("",key=value"",""&"" + "&" + MD5_KEY + "&" + TOKEN)
MD5_KEY = "STARWAR2021HAPPYFISHBUSINESSINTERFACE"
[pageNo""pageSize]""


->【""】
""JSON:{"code":-10002,"message":"XXXXXXXXXXX","data":""}
code : "" 
message : ""
data : ""

-----------------------------------------------------------------------------------------------
*****""
-----------------------------------------------------------------------------------------------
""、""
"":http://10.168.1.95:4241/api/account/businessAccountLogin?businessAccount=test01@gmail.com&businessPassword=5efab087855a5607&sign=db7f39eaa263ff0b706ee96e65290b61
"":GET
"":
""    	    (""):   ""
businessAccount    (String)：""
businessPassword   (String): ""
sign 	           (String): MD5"",""：""businessAccountLogin"":

"":businessAccount=test01@gmail.com&businessPassword=5efab087855a5607
"":businessAccount=test01@gmail.com&businessPassword=5efab087855a5607&STARWAR2021HAPPYFISHBUSINESSINTERFACE

"":
"":
{
    "message": "OK",
    "data": {
        "token": "95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP",
        "businessAccount": "test01@gmail.com"
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

""、""Token
"":http://10.168.1.95:4241/api/account/businessRefreshToken?businessAccount=test01@gmail.com&sign=ceef88f6dc399c3d46c4fdb848dcf0d4
"":GET
"":
""    	    (""):   ""
businessAccount    (String)：""
sign 	(String): MD5"",""："":

"":businessAccount=test01@gmail.com
"":businessAccount=test01@gmail.com&STARWAR2021HAPPYFISHBUSINESSINTERFACE&95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP

"":
"":
{
    "message": "OK",
    "data": {
        "token": "q9Q5aeAq6bsxdhxXrUwxHH6D5B1bcnKT",
        "businessAccount": "test01@gmail.com"
    },
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
"":http://127.0.0.1:4241/api/business/getInviteInfoFromBusiness?businessAccount=test01@gmail.com&pageNo=1&pageSize=20&sign=ceef88f6dc399c3d46c4fdb848dcf0d4
"":GET
"":
""    	(""):   ""
businessAccount    (String)：""
pageNo    (int)：""[""]
pageSize    (int)：""[""]
sign 	(String): MD5"",""："":

"":businessAccount=test01@gmail.com
"":businessAccount=test01@gmail.com&STARWAR2021HAPPYFISHBUSINESSINTERFACE&95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP

"":
"":
{
    "message": "OK",
    "data": {
        "totalPage": 0,
        "myself": {
            "onlineStatus": 0,
            "loginCount": 2,
            "carboxyl": 0,
            "starCoin": 1500,
            "createTime": 1673520740,
            "loginTime": 1673521247,
            "logoutTime": 1673521521,
            "vipLevel": 0,
            "pid": 1000045,
            "ice": 3230,
            "name": "GB1000045",
            "baseLevel": 1,
            "titanium": 3240,
            "gas": 3190.005,
            "mit": 0,
            "account": "test02@gmail.com"
        },
        "rows": [
            {
                "onlineStatus": 0,
                "loginCount": 1,
                "carboxyl": 0,
                "starCoin": 1000,
                "createTime": 1675652341,
                "loginTime": 1675652342,
                "logoutTime": 1675652346,
                "vipLevel": 0,
                "pid": 1000094,
                "ice": 1000,
                "name": "GB1000094",
                "baseLevel": 1,
                "titanium": 1000,
                "gas": 1000,
                "mit": 0,
                "account": "test104@gmail.com"
            },
            {
                "onlineStatus": 0,
                "loginCount": 1,
                "carboxyl": 0,
                "starCoin": 1000,
                "createTime": 1675652304,
                "loginTime": 1675652305,
                "logoutTime": 1675652309,
                "vipLevel": 0,
                "pid": 1000077,
                "ice": 1000,
                "name": "GB1000077",
                "baseLevel": 1,
                "titanium": 1000,
                "gas": 1000,
                "mit": 0,
                "account": "test103@gmail.com"
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
"":http://127.0.0.1:4241/api/business/getBusinessBaseInfo?businessAccount=test01@gmail.com&sign=ceef88f6dc399c3d46c4fdb848dcf0d4
"":GET
"":
""    	(""):   ""
businessAccount    (String)：""
sign 	(String): MD5"",""："":

"":businessAccount=test01@gmail.com
"":businessAccount=test01@gmail.com&STARWAR2021HAPPYFISHBUSINESSINTERFACE&95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP

"":
"":
{
    "message": "OK",
    "data": {
        "TRC20": "",
        "DISCORD": "",
        "BEP20": "",
        "TELEGRAM": "",
        "PHONE": "",
        "ERC20": "",
        "PAYPAL": "",
        "account": "test01@gmail.com"
    },
    "code": 0
}
"":
{
    "message": "SIGN ERROR",
    "code": -10002
}

"":""
"":http://10.168.1.95:4241/api/business/setBusinessBaseInfo?businessAccount=test01@gmail.com&sign=4b08800d2a3cd0355b6e47e24ce98a6e&data={"PHONE":"85259893846"}
"":post
"":
""        (""):   ""
businessAccount    (String)：""
sign (String): MD5"",""："":
data    (String)："",  {"PHONE":"85259893846"}  ""，""

"":businessAccount=test01@gmail.com&data={"PHONE":"85259893846"}
"":businessAccount=test01@gmail.com&data={"PHONE":"85259893846"}&STARWAR2021HAPPYFISHBUSINESSINTERFACE&95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP

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

"":""("")
"":http://192.168.1.19:4241/api/business/getInvitePaymentFromBusiness?businessAccount=test10001@gmail.com&date=20230306&sonAccount=no&pageNo=1&pageSize=20&sign=ceef88f6dc399c3d46c4fdb848dcf0d4
"":post
"":
""        (""):   ""
businessAccount    (String)：""
pageNo    (int)：""
pageSize    (int)：""
date   (String): "", "":20230306
sonAccount    (String)："","": "no"
sign (String): MD5"",""："":

"":businessAccount=test01@gmail.com&date=20230304&sonAccount=no
"":businessAccount=test01@gmail.com&date=20230304&sonAccount=no&STARWAR2021HAPPYFISHBUSINESSINTERFACE&95AC2bxgV9eXamNB0gbhvZ7IbexVG0nP

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