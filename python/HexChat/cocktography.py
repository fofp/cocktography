#-*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
import StringIO
import regex as re
import hexchat
import os
from CPI import cocktography

__module_name__ = str("choder")
__module_version__ = str("1.3")
__module_description__ = str("Script that implements Cocktography for HexChat")

events = ("Channel Message","Private Message", "Private Message to Dialog")

buffer = {}

choder = cocktography.Cocktograph()
RE_cocks = re.compile(r"({}|{}).*({}|{})".format(choder.START, choder.MARK, choder.STOP, choder.CONT))

def choder_cb(word, word_eol, userdata, attr):
    text = RE_cocks.search(word[1])
    if not text:
        return hexchat.EAT_NONE
    message = text.group(0)

    if message.startswith(choder.START) or message.startswith(choder.MARK):
        history = ''
        if word[0] in buffer:
            history = buffer[word[0]]
        if message.endswith(choder.STOP):
            if message.startswith(choder.START): # we have a single line enchoded message
                dechoded, _ = choder.dechode(message)
                formatted = RE_cocks.sub(dechoded, word[1])
                hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return hexchat.EAT_HEXCHAT
            else:
                enchoded = "{} {}".format(history, message) if history else message
                dechoded, _ = choder.dechode(enchoded)
                formatted = RE_cocks.sub(dechoded, word[1])
                del buffer[word[0]]
                hexchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return hexchat.EAT_HEXCHAT
        else:
            buffer[word[0]] = "{} {}".format(history, message) if history else message
            return hexchat.EAT_HEXCHAT

for event in events:
    hexchat.hook_print_attrs(event, choder_cb)

def enchode_cb(word, word_eol, userdata):
    input = word_eol[1][:150]
    s = choder.enchode(input,2,340)
    buffer["input"] = s.splitlines()
    for dongs in buffer["input"]:
        hexchat.get_context().command('say ' + dongs)
    del buffer["input"]
    hexchat.emit_print("Channel Message",'\0034\002\037' + hexchat.get_info('nick') + '\0034\002\037',input,"")

    return hexchat.EAT_HEXCHAT

def dechode_cb(word, word_eol, userdata):
    hexchat.prnt(choder.dechode(word[1])[0])
    return hexchat.EAT_HEXCHAT

hexchat.hook_command("enchode",enchode_cb)
hexchat.hook_command("dechode",dechode_cb)

hexchat.prnt(__module_name__ + " version " + __module_version__ + " loaded")
