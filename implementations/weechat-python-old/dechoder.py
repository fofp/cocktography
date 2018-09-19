#-*- coding: utf-8 -*-
from __future__ import unicode_literals
import argparse

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


ZERO_STROKE_FORMAT = "{strokes}🐓 {prefix}\t\x0314{cockstring}\x0F\t{dechoded}"
MULTI_STROKE_FORMAT = "{strokes}🍆 {prefix}\t\x0314{cockstring}\x0F\t{dechoded}"

ALLOW_MIXED_SECURITY = True


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
    if "irc_raw" in modifier_data or "\t" not in raw_message:
        return(string)
    prefix, message = raw_message.split("\t", 1)
    cockstring = api.get_cockstring(message)
    if not ALLOW_MIXED_SECURITY and cockstring is not message:
        return(string)
    if not cockstring:
        return(string)
    user = RE_host.search(modifier_data)
    user = user.group(0) if user else "null"
    if cockstring.startswith(api.START) or cockstring.startswith(api.MARK):
        history = __COCKS.get(user, [])
        if cockstring.endswith(api.STOP):
            if cockstring.startswith(api.START): # we have a single line enchoded message
                enchoded = cockstring
            else:
                enchoded = " ".join(history + [cockstring])
            __COCKS[user] = []
            dechoded, strokes = api.dechode(enchoded)

            dechoded_with_message = message.replace(cockstring, dechoded)
            if strokes > 0:
                fstring = MULTI_STROKE_FORMAT
            else:
                fstring = ZERO_STROKE_FORMAT
            formatted = fstring.format(strokes=strokes, prefix=prefix,
                                       cockstring=message.replace(cockstring, enchoded),
                                       dechoded=dechoded_with_message)
            return(format_for_weechat(formatted))
        else:
            __COCKS[user] = history + [cockstring]
            return ""


def enchoder_cmd(data, buffer, args):
    args = args.decode("utf-8")
    parser = argparse.ArgumentParser()
    parser.add_argument('--strokes', default=2, type=int)
    try:
        (opts, args) = parser.parse_known_args(args.split())
    except SystemExit:
        weechat.prnt('', 'Error: in "{}", invalid options.'.format(args))
        return weechat.WEECHAT_RC_ERROR
    opts = vars(opts)
    text = " ".join(args)
    enchoded = api.enchode(text, strokes=opts['strokes'])
    weechat.command(buffer, format_for_weechat(enchoded))
    return weechat.WEECHAT_RC_OK


def dechoder_cmd(data, buffer, args):
    dechoded = "[dechoded] {}".format(api.dechode(args))
    weechat.prnt(buffer, format_for_weechat(dechoded))
    return weechat.WEECHAT_RC_OK


if __name__ == "__main__":
    weechat.register("dechoder", "Dechoder", "0.1.1", "MIT", "Test script", "", "")
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
