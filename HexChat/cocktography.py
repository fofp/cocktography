#-*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
import StringIO
import regex as re
import hexchat
import os

__module_name__ = str("cocktography")
__module_version__ = str("1.1")
__module_description__ = str("Cocktographical library for Hexchat")

events = ("Channel Message","Private Message", "Private Message to Dialog")

cocktographic_map = ".dechoder_ring"

with open(cocktographic_map) as f:
    dechoder_ring = {"out": {dick.strip(): char.strip() for dick, char in itertools.izip_longest(*[f]*2)}}
    dechoder_ring["out"][" "] = " "
    dechoder_ring["out"]["8mD"] = " "
    dechoder_ring["in"] = {char: dick for dick, char in dechoder_ring["out"].iteritems()}


START = dechoder_ring["in"]["start"]
STOP = dechoder_ring["in"]["stop"]
CONT = dechoder_ring["in"]["cont"]
MARK = dechoder_ring["in"]["mark"]

buffer = {}

single_line_re = re.compile(r"{}(.*){}".format(START, STOP))
multi_line_start = re.compile(r"{}(.*){}".format(START, CONT))
multi_line_cont = re.compile(r"{}(.*){}".format(MARK, CONT))
multi_line_end = re.compile(r"{}(.*){}".format(MARK, STOP))

def to_unicode(strng):
    return(strng)
    """Convert a utf-8 encoded string to a Unicode."""
    if isinstance(strng, unicode):
        return strng
    return strng.decode('utf-8', 'replace')


def chunks(s, n):
    """Produce `n`-character chunks from `s`."""
    for start in range(0, len(s), n):
        yield s[start:start+n]



def enchoder(text, split_at=50):
    text = to_unicode(text)
    first_pass = base64.encodestring(text).replace("\n", "")
    mime_encoded = base64.encodestring(first_pass).replace("\n", "")

    cockstring = [dechoder_ring["in"][c] for c in mime_encoded]
    if len(cockstring) < split_at:
        cockstring = " ".join(cockstring)
        return(" ".join([START, cockstring, STOP]))
    else:
        lines = [" ".join(l) for l in chunks(cockstring, split_at)]
        sep = " {}\n{} ".format(CONT, MARK)
        ret = "{} {} {}".format(START, sep.join(lines), STOP)
        return(ret)

def dechoder(text):
    text = to_unicode(text)
    # decodes a message using the dechoder ring
    dechoded = "".join([dechoder_ring["out"][w] for w in text.split()
                        if dechoder_ring["out"][w] not in ["start", "stop", "cont", "mark"]])
    try:
        first_pass = base64.decodestring(dechoded)
    except:
        return(dechoded)
    try:
        decoded = base64.decodestring(first_pass)
    except:
        return(first_pass)
    return(decoded)

def cocktography_cb(word, word_eol, userdata, attr):
    if re.search(r"{}.*{}".format(START,STOP),word[1]):
        hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',dechoder(word[1]),"")
        return hexchat.EAT_HEXCHAT
    if re.search(r"{}.*{}".format(START,CONT),word[1]):
        buffer[word[0]] = word[1]
        return hexchat.EAT_HEXCHAT
    if re.search(r"{}.*{}".format(MARK,CONT),word[1]):
        buffer[word[0]] = buffer[word[0]] + ' ' + word[1]
        return hexchat.EAT_HEXCHAT
    if re.search(r"{}.*{}".format(MARK,STOP),word[1]):
        buffer[word[0]] = buffer[word[0]] + ' ' + word[1]
        hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',dechoder(buffer[word[0]]),"")
        del buffer[word[0]]
        return hexchat.EAT_HEXCHAT
    return hexchat.EAT_NONE


for event in events:
    hexchat.hook_print_attrs(event, cocktography_cb)

def enchode_cb(word, word_eol, userdata):
    s = enchoder(word_eol[1],50)
    buffer["input"] = s.splitlines()
    for dongs in buffer["input"]:
        hexchat.get_context().command('say ' + dongs)
    del buffer["input"]
    hexchat.emit_print("Channel Message",'\0034\002\037' + hexchat.get_info('nick') + '\0034\002\037',word_eol[1],"")
    
    return hexchat.EAT_NONE

def dechode_cb(word, word_eol, userdata):
    hexchat.prnt(dechoder(word[1])) 
    return hexchat.EAT_NONE

hexchat.hook_command("enchode",enchode_cb)
hexchat.hook_command("dechode",dechode_cb)

hexchat.prnt(__module_name__ + " version " + __module_version__ + " loaded")