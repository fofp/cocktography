#-*- coding: utf-8 -*-
from __future__ import unicode_literals
try:
    import regex as re
except:
    import re
try:
    import weechat
except:
    raise Exception("This module must be used with Weechat!")
if __name__ == '__main__' and __package__ is None:
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))
from CPI import cocktography


ENCHODE_MARKER = "\x034"
DISPLAY_PARTIAL_ENCHODED_MESSAGES = True


RE_host = re.compile(r"(?<=,nick_)[^,]*(?=,|$)")


api = cocktography.Cocktograph()

__COCKS = {}


def colorize(text):
    if isinstance(text, unicode):
        text = text.encode('utf-8')
    result = weechat.hook_modifier_exec("irc_color_decode", "1", text)
    result = unicode(result, 'utf-8', errors='ignore')
    return(result)


def format_for_weechat(text, colorize_text=True):
    return(colorize(text).encode('utf-8')
           if colorize_text
           else text.encode('utf-8'))


def autococktography(data, modifier, modifier_data, string):
    global api, __COCKS
    raw_message = unicode(string, 'utf-8')
    if "irc_raw" in modifier_data:
        return(string)
    message = api.get_cockstring(raw_message)
    if not message:
        return(string)
    buffer = weechat.current_buffer()
    user = RE_host.search(modifier_data)
    user = user.group(0) if user else "null"
    if message.startswith(api.START) or message.startswith(api.MARK):
        history = __COCKS.get(user, [])
        if message.endswith(api.STOP):
            if message.startswith(api.START): # we have a single line enchoded message
                enchoded = message
            else:
                enchoded = " ".join(history + [message])
            __COCKS[user] = []
            dechoded = "{}{}\x0F".format(ENCHODE_MARKER, api.dechode(enchoded))
            if DISPLAY_PARTIAL_ENCHODED_MESSAGES:
                dechoded = "\x0315{}\x0F\n{}".format(enchoded, dechoded)
            formatted = raw_message.replace(message, dechoded)
            #print(formatted.encode("utf-8"))
            return(format_for_weechat(formatted))
        else:
            __COCKS[user] = history + [message]
            return ""


def enchoder_cmd(data, buffer, args):
    enchoded = api.enchode(args[:150])
    weechat.command(buffer, format_for_weechat(enchoded))
    return weechat.WEECHAT_RC_OK


def dechoder_cmd(data, buffer, args):
    dechoded = "[dechoded] {}".format(api.dechode(args))
    weechat.prnt(buffer, format_for_weechat(dechoded))
    return weechat.WEECHAT_RC_OK


if __name__ == "__main__":
    weechat.register("dechoder_ring", "Dechoder", "1.0", "GPL3", "Test script", "", "")
    weechat.hook_modifier("weechat_print", "autococktography", "")

    hook = weechat.hook_command("dechode",
        "You know what this does.",
        "",
        "Your message",
        "",
        "dechoder_cmd", "")

    hook = weechat.hook_command("enchode",
        "You know what this does.",
        "",
        "Your message",
        "",
        "enchoder_cmd", "")
