# -*- coding: utf-8 -*-
import argparse

import re
from cpi import cpi

try:
    import weechat
except:
    raise Exception(b'This module must be used with Weechat!')
if __name__ == b'__main__' and __package__ is None:
    from os import sys, path
    sys.path.append(path.dirname(path.dirname(path.abspath(__file__))))

PREFIX_SEPARATOR = b'\t'
ZERO_STROKE_FORMAT = b'{strokes}🐓 {prefix}' + \
    PREFIX_SEPARATOR + b'{dechoded}'
MULTI_STROKE_FORMAT = b'{strokes}🍆 {prefix}' + \
    PREFIX_SEPARATOR + b'{dechoded}'
ALLOW_MIXED_SECURITY = True
RE_host = re.compile(br'(?<=,nick_)[^,]*(?=,|$)')
# globals
api = cpi.Cocktography()
__COCKS = {}


def autococktography(data, modifier, modifier_data, string):
    global api, __COCKS

    def select_format_string(strokes):
        return MULTI_STROKE_FORMAT if strokes > 0 else ZERO_STROKE_FORMAT

    if b'irc_raw' in modifier_data or PREFIX_SEPARATOR not in string:
        return (string)
    prefix, message = string.split(PREFIX_SEPARATOR, 1)
    cockblock_info = api.find_cockblock(message)
    if cockblock_info is not None:
        (cb_begin, cb_end), (cy_begin, cy_end), cb_type = cockblock_info
    else:
        return (string)
    if not ALLOW_MIXED_SECURITY and cb_begin != 0 and cb_end != len(message):
        return (string)
    user = RE_host.search(modifier_data)
    user = user.group(0) if user else b'null'
    cyphallic_text = message[cy_begin:cy_end]
    decyphallicized_text = api.decyphallicize(cyphallic_text)

    def result(text):
        destroked_text, strokes = api.destroke(text)
        return weechat.hook_modifier_exec(
            b'irc_color_decode', b'1',
            select_format_string(strokes).format(
                strokes=strokes,
                prefix=prefix,
                cockstring=text,
                dechoded=message[:cb_begin] + destroked_text +
                message[cb_end:]))

    if cb_type == cpi.CockblockType.SINGLETON:
        return result(decyphallicized_text)
    elif cb_type == cpi.CockblockType.INITIAL:
        __COCKS[user] = decyphallicized_text
        return b''
    elif cb_type == cpi.CockblockType.INTERMEDIATE:
        if user in __COCKS:
            __COCKS[user] = __COCKS[user] + decyphallicized_text
            return b''
        else:
            return (string)
    elif cb_type == cpi.CockblockType.FINAL:
        if user in __COCKS:
            msg = __COCKS[user] + decyphallicized_text
            del __COCKS[user]
            return result(msg)
        else:
            return (string)
    else:
        return (string)
        # raise api.CockblockError(b'Invalid type: {}'.format(cb_type))


def enchoder_cmd(data, buffer, args):
    mode_choices = [
        name for (name, value) in vars(cpi.CyphallicMethod.__class__).items()
        if not callable(value) and not name.startswith(b'__')
    ]
    parser = argparse.ArgumentParser()
    parser.add_argument(b'-s', b'--strokes', default=2, type=int)
    parser.add_argument(
        b'-m',
        b'--mode',
        default=b'THIN_CHODE',
        type=bytes,
        choices=mode_choices)
    parser.add_argument(b'-l', b'--max-length', default=340, type=int)
    try:
        (opts, args) = parser.parse_known_args(args.split())
    except SystemExit:
        weechat.prnt(b'', b'Error: in "{}", invalid options.'.format(args))
        return weechat.WEECHAT_RC_ERROR
    opts = vars(opts)
    text = api.SEPARATOR.join(args)
    enchoded = api.enchode(
        bytearray(text), opts[b'strokes'],
        getattr(cpi.CyphallicMethod, opts[b'mode']), opts[b'max_length'])
    weechat.command(
        buffer, weechat.hook_modifier_exec(b'irc_color_decode', b'1',
                                           enchoded))
    return weechat.WEECHAT_RC_OK


def dechoder_cmd(data, buffer, args):
    dechoded = api.dechode(args)
    for text, strokes in dechoded:
        payload = b'[dechoded {}-strokes] {}'.format(strokes, text)
        weechat.prnt(
            buffer,
            weechat.hook_modifier_exec(b'irc_color_decode', b'1', payload))
    return weechat.WEECHAT_RC_OK


if __name__ == b'__main__':
    weechat.register(b'dechoder', b'Dechoder', b'0.2.0', b'MIT',
                     b'Cocktographic Dechoder', b'', b'')
    weechat.hook_modifier(b'weechat_print', b'autococktography', b'')
    hook = weechat.hook_command(b'dechode', b'You know what this does.', b'',
                                b'Your message', b'', b'dechoder_cmd', b'')
    hook = weechat.hook_command(b'enchode', b'You know what this does.', b'',
                                b'Your message', b'', b'enchoder_cmd', b'')
