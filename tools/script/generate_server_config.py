#coding=utf-8
import io
import json
import optparse
import time
import json
import os
import os.path
import string
import sys
from importlib import reload
reload(sys)
#sys.setdefaultencoding('utf-8')

def gen_template(server):
    items = server.items()
    sorted(items)
    # items.sort()
    module = server["type"]
    template = [
        'include "common.config"',
        'start = "app/%s/main"' % module,
    ]
    for k,v in items:
        tv = type(v)
        if tv == int:
            template.append('%s = %%(%s)s' % (k,k))
        #elif tv == unicode or tv == str:
        elif tv == str:
            template.append('%s = "%%(%s)s"' % (k,k))
    return "\n".join(template)

def writeto(filename,startline,endline,line):
    lines = []
    if os.path.isfile(filename):
        fp = open(filename,"r",encoding="utf-8")
        lines = fp.read().splitlines()
        fp.close()
    startline_pos = -1
    endline_pos = -1
    if startline in lines:
        startline_pos = lines.index(startline)
        if endline in lines[startline_pos+1:]:
            endline_pos = lines.index(endline,startline_pos+1)
    status = ""
    if startline_pos != -1 and endline_pos != -1:
        lines = lines[:startline_pos] + [startline,line,endline] + lines[endline_pos+1:]
        status = "updated"
    else:
        lines = [startline,line,endline]
        status = "new"
    data = "\n".join(lines)

    #fp = open(filename,"w",encoding="utf-8")
    #fp.write(data)
    fp = open(filename,"wb")
    fp.write(data.encode("utf-8"))
    fp.close()
    return status


def generate_server_config(out,servers_config):
    fp = open(servers_config,"r",encoding="utf-8")
    servers = json.load(fp)
    fp.close()
    out = os.path.expanduser(out)
    if not os.path.exists(out):
        os.makedirs(out)
    new = {}
    updated = {}
    nodes = []
    startline = "-- auto generate DO NOT EDIT!!!"
    endline = "-- auto generate DO NOT EDIT!!!"
    for serverid,server in servers.items():
        server["id"] = serverid
        nodes.append("""
        %s = {
            address = "%s:%s",
            index = %s,
            name = "%s",
            type = "%s",
        },""" % (serverid,server["cluster_ip"],server["cluster_port"],server["index"],server["name"],server["type"]))
        template = gen_template(server)
        line = template % (server)
        filename = os.path.join(out,serverid) + ".config"
        status = writeto(filename,startline,endline,line)
        if status == "updated":
            updated[serverid] = True
        else:
            new[serverid] = True
    filename = "%s/nodes.lua" % (out)
    line = "return {\n" + "\n".join(nodes) + "\n}"
    writeto(filename,startline,endline,line)
    return new,updated

def main():
    usage = "usage: python %prog [options]\n\te.g: python %prog --config=servers.main.config [--out=../../server/src/config]"
    parser = optparse.OptionParser(usage=usage,version="%prog 0.0.1")
    parser.add_option("-c","--config",help="[required] servers config file")
    parser.add_option("-o","--out",help="[optional] output dirname",default="../../server/src/config")
    parser.add_option("-q","--quite",help="[optional] quite mode",action="store_true",default=False)
    options,args = parser.parse_args()
    required = ["config"]
    for r in required:
        if options.__dict__.get(r) is None:
            parser.error("option '%s' required" % r)
    out = options.out
    servers_config = options.config
    quite = options.quite
    new,updated = generate_server_config(out,servers_config)
    if not quite:
        print("op=generate_server_config,out=%s" % (out))
        for serverid in iter(new):
            print("[new] %s" % serverid)
        for serverid in iter(updated):
            print("[updated] %s" % serverid)

if __name__ == "__main__":
    main()
