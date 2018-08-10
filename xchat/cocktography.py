#-*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
import StringIO
import regex as re
import hexchat
import os

__module_name__ = str("cocktography")
__module_version__ = str("1.2")
__module_description__ = str("Cocktographical library for XChat")

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

RE_cocks = re.compile(r"({}|{}).*({}|{})".format(START, MARK, STOP, CONT))

buffer = {}

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

def break_lines(text, split_at=340):
    '''text should be a space-separated string of unbreakable symbols
    returns
        lines: list of space-separated strings, shorter than split_at
    '''
    lines = []
    current_line = []
    for symb in text.split(" "):
        new_line = " ".join(current_line+[symb])
        if len(new_line) > split_at:
            lines.append(" ".join(current_line))
            current_line = []
        current_line.append(symb)
    lines.append(" ".join(current_line))
    return lines


def enchode(text, split_at=340):
    text = to_unicode(text)
    first_pass = base64.encodestring(text).replace("\n", "")
    mime_encoded = base64.encodestring(first_pass).replace("\n", "")

    cockstring = " ".join([dechoder_ring["in"][c] for c in mime_encoded])
    if len(cockstring) < split_at:
        return(" ".join([START, cockstring, STOP]))
    else:
        lines = break_lines(cockstring, split_at)
        sep = " {}\n{} ".format(CONT, MARK)
        ret = "{} {} {}".format(START, sep.join(lines), STOP)
        return(ret)


def dechode(text):
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
    return(to_unicode(decoded.encode('string_escape')))


def cocktography_cb(word, word_eol, userdata):
    text = RE_cocks.search(word[1])
    if not text:
        return hexchat.EAT_NONE
    message = text.group(0)

    if message.startswith(START) or message.startswith(MARK):
        history = ''
        if word[0] in buffer:
            history = buffer[word[0]]
        if message.endswith(STOP):
            if message.startswith(START): # we have a single line enchoded message
                dechoded = dechode(message)
                formatted = RE_cocks.sub(dechoded, word[1])
                hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return hexchat.EAT_HEXCHAT
            else:
                enchoded = "{} {}".format(history, message) if history else message
                dechoded = dechode(enchoded)
                formatted = RE_cocks.sub(dechoded, word[1])
                del buffer[word[0]]
                hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return hexchat.EAT_HEXCHAT
        else:
            buffer[word[0]] = "{} {}".format(history, message) if history else message
            return hexchat.EAT_HEXCHAT

for event in events:
    hexchat.hook_print(event, cocktography_cb)

def enchode_cb(word, word_eol, userdata):
    input = word_eol[1][:150]
    s = enchode(input)
    buffer["input"] = s.splitlines()
    for dongs in buffer["input"]:
        hexchat.get_context().command('say ' + dongs)
    del buffer["input"]
    hexchat.emit_print("Channel Message",'\0034\002\037' + hexchat.get_info('nick') + '\0034\002\037',input,"")
    
    return hexchat.EAT_HEXCHAT

def dechode_cb(word, word_eol, userdata):
    hexchat.prnt(dechode(word[1])) 
    return hexchat.EAT_HEXCHAT

hexchat.hook_command("enchode",enchode_cb)
hexchat.hook_command("dechode",dechode_cb)

hexchat.prnt(__module_name__ + " version " + __module_version__ + " loaded")