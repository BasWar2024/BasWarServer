#encoding=utf-8
import io
import json
import optparse
import urllib
import http.client
import time
import string
import base64
import hmac
from hashlib import sha1

def signature(args,secret):
    # ksort
    arr = []
    for k,v in args.items():
        if str(v) != "":
            arr.append([str(k),str(v)])
    def getkey(elem):
        return elem[0]
    arr.sort(key=getkey)
    strs = []
    for elem in arr:
        strs.append("%s=%s" % (elem[0],elem[1]))
    raw = "&".join(strs)
    hmac_code = hmac.new(secret.encode(),raw.encode(),sha1).digest()
    return base64.b64encode(hmac_code).decode()

def add_app(loginserver,appid,secret,app_config):
    fp = open(app_config,"r",encoding="utf-8")
    app = json.load(fp)
    app["appid"] = appid
    fp.close()
    url = "http://%s/api/app/add" % (loginserver)
    args = {
        "app" : json.dumps(app),
    }
    args["sign"] = signature(args,secret)
    query = json.dumps(args)
    conn = http.client.HTTPConnection(loginserver)
    conn.request("POST",url,query)
    resp = conn.getresponse()
    ok = False
    err = None
    if resp.status == 200:
        response = resp.read()
        response = json.loads(response)
        if response.get("code") == 0:
            ok = True
        else:
            err = "%s|%s" % (response.get("code"),response.get("message"))
    else:
        err = "status=%s" % (resp.status)
    conn.close()
    return app,ok,err

def main():
    usage = "usage: python %prog [options]\n\te.g: python %prog --appid=gg --app=app.config [--loginserver=ip:port]"
    parser = optparse.OptionParser(usage=usage,version="%prog 0.0.1")
    parser.add_option("-a","--app",help="[required] game's app")
    parser.add_option("-i","--appid",help="[required] game's appid")
    parser.add_option("-s","--secret",help="signature secret",default="secret")
    parser.add_option("-H","--loginserver",help="loginserver's ip:port",default="127.0.0.1:4000")
    parser.add_option("-q","--quite",help="quite mode",action="store_true",default=False)
    options,args = parser.parse_args()
    required = ["app","appid"]
    for r in required:
        if options.__dict__.get(r) is None:
            parser.error("option '%s' required" % r)
    app_config = options.app
    loginserver = options.loginserver
    appid = options.appid
    secret = options.secret
    quite = options.quite
    app,ok,err = add_app(loginserver,appid,secret,app_config)
    if not quite:
        print("op=add_app,loginserver=%s,ok=%s,err=%s,app=%s" % (loginserver,ok,err,app))

if __name__ == "__main__":
    main()
