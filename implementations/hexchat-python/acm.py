# -*- coding: utf-8 -*-
import re
try:
    import hexchat
except:
    raise Exception(b'This module must be used with HexChat!')
if __name__ == b'__main__' and __package__ is None:
    from inspect import getsourcefile
    from os import sys, path
    sys.path.append(path.join(hexchat.get_info(b'configdir'), b'addons'))
from cpi import cpi

ZERO_STROKE_FORMAT = b'{strokes}🐓 {nick}'
MULTI_STROKE_FORMAT = b'{strokes}🍆 {nick}'
ALLOW_MIXED_SECURITY = True
RE_CMD = re.compile(
    br'-(?:(?:s(?P<strokes>\d+))|(?P<mode>[mtw])|(?:l(?P<length>\d+)))+ *')
# globals
api = cpi.Cocktography()
__COCKS = {}


def sformat(nick, strokes):
    fmt = MULTI_STROKE_FORMAT if strokes > 0 else ZERO_STROKE_FORMAT
    return fmt.format(nick=nick, strokes=strokes)


def autococktography_cmsg(word, word_eol, userdata):
    return autococktography(b'Channel Message', word[0], word[1])


def autococktography_caction(word, word_eol, userdata):
    return autococktography(b'Channel Action', word[0], word[1])


def autococktography_pmsg(word, word_eol, userdata):
    return autococktography(b'Private Message', word[0], word[1])


def autococktography_paction(word, word_eol, userdata):
    return autococktography(b'Private Action', word[0], word[1])


def autococktography_pdmsg(word, word_eol, userdata):
    return autococktography(b'Private Message to Dialog', word[0], word[1])


def autococktography_pdaction(word, word_eol, userdata):
    return autococktography(b'Private Action to Dialog', word[0], word[1])


def autococktography(event, nick, message):
    global api, __COCKS
    cockblock_info = api.find_cockblock(message)
    if cockblock_info is not None:
        (cb_begin, cb_end), (cy_begin, cy_end), cb_type = cockblock_info
    else:
        return hexchat.EAT_NONE
    if not ALLOW_MIXED_SECURITY and cb_begin != 0 and cb_end != len(message):
        return hexchat.EAT_NONE
    cock_key = b'/'.join([hexchat.get_info(b'gtkwin_ptr'), event, nick])
    cyphallic_text = message[cy_begin:cy_end]
    decyphallicized_text = api.decyphallicize(cyphallic_text)

    def result(text):
        destroked_text, strokes = api.destroke(text)
        hexchat.emit_print(
            event, sformat(nick, strokes),
            str(message[:cb_begin] + destroked_text + message[cb_end:]), b'')
        return hexchat.EAT_HEXCHAT

    if cb_type == cpi.CockblockType.SINGLETON:
        return result(decyphallicized_text)
    elif cb_type == cpi.CockblockType.INITIAL:
        __COCKS[cock_key] = decyphallicized_text
        return hexchat.EAT_HEXCHAT
    elif cb_type == cpi.CockblockType.INTERMEDIATE:
        if cock_key in __COCKS:
            __COCKS[cock_key] = __COCKS[cock_key] + decyphallicized_text
            return hexchat.EAT_HEXCHAT
        else:
            return hexchat.EAT_NONE
    elif cb_type == cpi.CockblockType.FINAL:
        if cock_key in __COCKS:
            msg = __COCKS[cock_key] + decyphallicized_text
            del __COCKS[cock_key]
            return result(msg)
        else:
            return hexchat.EAT_NONE
    else:
        return hexchat.EAT_NONE
        # raise api.CockblockError(b'Invalid type: {}'.format(cb_type))


def enchode(word, word_eol, userdata):
    # Usage
    #  /enchode [-flags] [/me]
    # Flags
    #  sN: strokes, where N is the number of strokes to apply
    #  lN: length, where N is the maximum length message to output
    # The following three flags are mutually exclusive:
    #  m: mixed chodes
    #  t: thin chodes
    #  w: wide chodes
    cmds = {
        b'say ': {b'event': b'Channel Message',
                  b'fmt': b'QUOTE PRIVMSG {} :{}'},
        b'me ': {b'event': b'Channel Action',
                 b'fmt': b'QUOTE PRIVMSG {} :\x01ACTION {}\x01'}
    }
    cmd = b'say '
    flags = {b'strokes': 2, 'mode': b't', b'length': 340}
    modes = {
        b'm': cpi.CyphallicMethod.MIXED_CHODE,
        b't': cpi.CyphallicMethod.THIN_CHODE,
        b'w': cpi.CyphallicMethod.WIDE_CHODE
    }
    args = word_eol[1]
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
            cmd = b'me '
        else:
            hexchat.prnt(
                b'"{0}" not allowed here. Did you mean "/{0}"?'.format(
                    args[:args.find(b' ')]))
            return None
    text = api.enchode(
        bytearray(args), flags[b'strokes'], modes[flags[b'mode']],
        flags[b'length'])
    target = hexchat.get_info('channel')
    for line in text.splitlines():
        hexchat.command(cmds[cmd][b'fmt'].format(target, line))
    hexchat.emit_print(cmds[cmd][b'event'],
                       sformat(hexchat.get_info(b'nick'), flags[b'strokes']),
                       args)
    return hexchat.EAT_HEXCHAT


def dechode(word, word_eol, userdata):
    dechoded = api.dechode(word_eol[1])
    for text, strokes in dechoded:
        payload = b'[dechoded {}-strokes] {}'.format(strokes, text)
        hexchat.prnt(payload)
    return hexchat.EAT_HEXCHAT


__module_name__ = b'acm'
__module_version__ = b'1.3'
__module_description__ = b'Auto-Cocktographic Messaging'

hexchat.hook_print(b'Channel Message', autococktography_cmsg)
hexchat.hook_print(b'Channel Action', autococktography_caction)
hexchat.hook_print(b'Private Message', autococktography_pmsg)
hexchat.hook_print(b'Private Action', autococktography_paction)
hexchat.hook_print(b'Private Message to Dialog', autococktography_pdmsg)
hexchat.hook_print(b'Private Action to Dialog', autococktography_pdaction)

hexchat.hook_command(b'enchode', enchode)
hexchat.hook_command(b'dechode', dechode)

hexchat.prnt(b'{} version {} loaded'.format(__module_name__,
                                            __module_version__))
