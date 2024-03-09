#coding: utf-8
import sys
import io
import optparse
import os
import os.path
import re
import string
import json
import codecs

def _genModFile(filename,patten):
    # i18n.format("")
    # i18n.format('')
    patten = r"%s\w*?\((\"|\')(.+?)\1" % patten
    lines = {}
    patten = re.compile(patten,re.S)
    try:
        encoding = "utf-8"
        fd = codecs.open(filename,"rb",encoding)
        content = fd.read()
        if not content:
            return {}
        for hit in patten.finditer(content):
            msg = hit.group(2)
            if not lines.has_key(msg):
                lines[msg] = ""
    finally:
        fd.close()
    return lines

def genModFile(files,patten,exts,output,genid):
    dirname = os.path.dirname(output)
    if not os.path.isdir(dirname):
        os.makedirs(dirname)
    encoding = "utf-8"
    fd = codecs.open(output,"wb",encoding)
    lines = {}
    for path in iter(files):
        if os.path.isfile(path):
            filename = path
            _,ext = os.path.splitext(filename)
            if ext not in exts:
                continue
            lines.update(_genModFile(filename,patten))
        else:
            for root,dirs,filenames in os.walk(path):
                for filename in iter(filenames):
                    _,ext = os.path.splitext(filename)
                    if ext not in exts:
                        continue
                    filename = os.path.join(root,filename)
                    lines.update(_genModFile(filename,patten))
    if genid:
        lst = lines.keys()
        lst.sort()
        i = 0
        while i < len(lst):
            line = lst[i]
            lines[line] = i + 1
            i = i + 1
    data = json.dumps(lines,indent=4,sort_keys=True,ensure_ascii=False,encoding="utf-8")
    fd.write(data)
    fd.close()

def main():
    usage = u'''usage: python %prog [options]
    e.g: python %prog /
    e.g: python %prog --genid=False --output=languages/en_US.json --ext=.lua --patten=i18n.format /
    '''
    parser = optparse.OptionParser(usage=usage,version="%prog 0.0.1")
    parser.add_option("-g","--genid",help=u"[optional] id(id)",default=False)
    parser.add_option("-o","--output",help=u"[optional] ",default="languages/zh_CN.json")
    parser.add_option("-e","--ext",help=u"[optional] ",default=".lua")
    parser.add_option("-p","--patten",help=u"[optional] ",default="i18n.format")
    options,args = parser.parse_args()
    files = args
    if len(files) == 0:
        print("no input file")
        exit(0)
    output = options.output
    ext = options.ext
    exts = string.split(ext,",")
    patten = options.patten
    genid = options.genid
    genModFile(files,patten,exts,output,genid)

if __name__ == "__main__":
    main()
