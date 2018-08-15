#-*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
import StringIO
import re
import xchat
import os
from CPI import cocktography

__module_name__ = str("choder")
__module_version__ = str("1.3")
__module_description__ = str("Script that implements Cocktography for XChat")

events = ("Channel Message","Private Message", "Private Message to Dialog")

choder = cocktography.Cocktograph()

RE_cocks = re.compile(r"({}|{}).*({}|{})".format(choder.START, choder.MARK, choder.STOP, choder.CONT))
buffer = {}

def cocktography_cb(word, word_eol, userdata):
    text = RE_cocks.search(word[1])
    if not text:
        return xchat.EAT_NONE
    message = text.group(0)

    if message.startswith(choder.START) or message.startswith(choder.MARK):
        history = ''
        if word[0] in buffer:
            history = buffer[word[0]]
        if message.endswith(choder.STOP):
            if message.startswith(choder.START): # we have a single line enchoded message
                dechoded, _ = choder.dechode(message)
                formatted = RE_cocks.sub(dechoded, word[1])
                xchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return xchat.EAT_XCHAT
            else:
                enchoded = "{} {}".format(history, message) if history else message
                dechoded, _ = choder.dechode(enchoded)
                formatted = RE_cocks.sub(dechoded, word[1])
                del buffer[word[0]]
                xchat.emit_print("Channel Message",'\0034\002\037' + word[0] + '\0034\002\037',formatted,"")
                return xchat.EAT_XCHAT
        else:
            buffer[word[0]] = "{} {}".format(history, message) if history else message
            return xchat.EAT_XCHAT

for event in events:
    xchat.hook_print(event, cocktography_cb)

def enchode_cb(word, word_eol, userdata):
    input = word_eol[1][:150]
    s = choder.enchode(input,2,340)
    buffer["input"] = s.splitlines()
    for dongs in buffer["input"]:
        xchat.get_context().command('say ' + dongs)
    del buffer["input"]
    xchat.emit_print("Channel Message",'\0034\002\037' + xchat.get_info('nick') + '\0034\002\037',input,"")

    return xchat.EAT_XCHAT

def dechode_cb(word, word_eol, userdata):
    xchat.prnt(choder.dechode(word[1])[0])
    return xchat.EAT_XCHAT

xchat.hook_command("enchode",enchode_cb)
xchat.hook_command("dechode",dechode_cb)

xchat.prnt(__module_name__ + " version " + __module_version__ + " loaded")
