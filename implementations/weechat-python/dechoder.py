# -*- coding: utf-8 -*-
import re
try:
    import weechat
except:
    raise Exception(b'This module must be used with Weechat!')
if __name__ == b'__main__' and __package__ is None:
    from os import sys, path
    sys.path.append(path.dirname(path.abspath(__file__)))
from cpi import cpi

PREFIX_SEPARATOR = b'\t'
ZERO_STROKE_FORMAT = b'{strokes}🐓 {prefix}' + \
    PREFIX_SEPARATOR + b'{dechoded}'
MULTI_STROKE_FORMAT = b'{strokes}🍆 {prefix}' + \
    PREFIX_SEPARATOR + b'{dechoded}'
ALLOW_MIXED_SECURITY = True
RE_HOST = re.compile(br'(?<=,nick_)[^,]*(?=,|$)')
RE_CMD = re.compile(
    br'-(?:(?:s(?P<strokes>\d+))|(?P<mode>[mtw])|(?:l(?P<length>\d+)))+ *')
# globals
api = cpi.Cocktography()
__COCKS = {}


def autococktography(data, modifier, modifier_data, string):
    global api, __COCKS

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
    cock_key = RE_HOST.search(modifier_data)
    cock_key = cock_key.group(0) if cock_key else b'null'
    cyphallic_text = message[cy_begin:cy_end]
    decyphallicized_text = api.decyphallicize(cyphallic_text)

    def result(text):
        destroked_text, strokes = api.destroke(text)
        msg_format = MULTI_STROKE_FORMAT if strokes > 0 else ZERO_STROKE_FORMAT
        return weechat.hook_modifier_exec(
            b'irc_color_decode', b'1',
            msg_format.format(
                strokes=strokes,
                prefix=prefix,
                cockstring=text,
                dechoded=message[:cb_begin] + destroked_text +
                message[cb_end:]))

    if cb_type == cpi.CockblockType.SINGLETON:
        return result(decyphallicized_text)
    elif cb_type == cpi.CockblockType.INITIAL:
        __COCKS[cock_key] = decyphallicized_text
        return b''
    elif cb_type == cpi.CockblockType.INTERMEDIATE:
        if cock_key in __COCKS:
            __COCKS[cock_key] = __COCKS[cock_key] + decyphallicized_text
            return b''
        else:
            return (string)
    elif cb_type == cpi.CockblockType.FINAL:
        if cock_key in __COCKS:
            msg = __COCKS[cock_key] + decyphallicized_text
            del __COCKS[cock_key]
            return result(msg)
        else:
            return (string)
    else:
        return (string)
        # raise api.CockblockError(b'Invalid type: {}'.format(cb_type))


def enchoder_cmd(data, buffer, args):
    # Usage
    #  /enchode [-flags] [/me]
    # Flags
    #  sN: strokes, where N is the number of strokes to apply
    #  lN: length, where N is the maximum length message to output
    # The following three flags are mutually exclusive:
    #  m: mixed chodes
    #  t: thin chodes
    #  w: wide chodes
    cmd = b'/say '
    flags = {b'strokes': 2, 'mode': b't', b'length': 340}
    modes = {
        b'm': cpi.CyphallicMethod.MIXED_CHODE,
        b't': cpi.CyphallicMethod.THIN_CHODE,
        b'w': cpi.CyphallicMethod.WIDE_CHODE
    }
    if args[0:2] == b'--':
        args = args[1:]
    else:
        matches = RE_CMD.match(args)
        if matches:
            groups = matches.groupdict()
            for key in set(groups).intersection(flags):
                val = groups[key]
                if val is not None:
                    flags[key] = int(val) if val.isdigit() else val
            args = args[matches.end(0):]
    if args[0:2] == b'//':
        args = args[1:]
    elif args[0] == b'/':
        if args[0:4] == b'/me ':
            args = args[4:]
            cmd = b'/me '
        else:
            weechat.prnt(
                b'', b'"{0}" not allowed here. Did you mean "/{0}"?'.format(
                    args[:args.find(b' ')]))
            return weechat.WEECHAT_RC_ERROR
    for line in api.enchode(
        bytes(args), flags[b'strokes'], modes[flags[b'mode']],
            flags[b'length']):
        line = weechat.hook_modifier_exec(b'irc_color_decode', b'1', line)
        weechat.command(buffer, cmd + line)
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
