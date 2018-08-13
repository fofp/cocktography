# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
try:
    import regex as re
except:
    import re
import os


COCKTOGRAPIC_MAP = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                "dechoder_ring")


def to_unicode(strng):
    """Convert a utf-8 encoded string to a Unicode."""
    if isinstance(strng, unicode):
        return strng
    return strng.decode('utf-8', 'replace')


def chunks(s, n):
    """Produce `n`-character chunks from `s`."""
    for start in range(0, len(s), n):
        yield s[start:start+n]


def break_lines(text, split_at=340):
    """Format a space-separated string into a list of lines.

    accepts
        test: list or space-separated string of symbols
        split_at: amount of characters per line, including spaces,
                  to split at
    returns
         list of space-separated strings, shorter than split_at
    """
    if type(text) == str or type(text) == unicode:
        text = text.split(" ")
    lines = []
    current_line = []
    for symb in text:
        new_line = " ".join(current_line+[symb])
        if len(new_line) > split_at:
            lines.append(" ".join(current_line))
            current_line = []
        current_line.append(symb)
    lines.append(" ".join(current_line))
    return lines


class Cocktograph(object):
    """Cocktographic API.

    api = Cocktograph()
    api.enchode("chodes", rounds=2)
        output:
            8=wm=D 8==D~~ 8wD~ 8mD~~~ 8==D 8===D 8===D~ 8w===D~ 8w==D 8mD~~ 8w=D~ 8==D 8==w=D~ 8=mw=D
    api.dechode("8=wm=D 8==D~~ 8wD~ 8mD~~~ 8==D 8===D 8===D~ 8w===D~ 8w==D 8mD~~ 8w=D~ 8==D 8==w=D~ 8=mw=D")
        output:
            chodes

    """

    def __init__(self, cocktographic_map=COCKTOGRAPIC_MAP):
        """Initialize the CPI (Cocktographic Programming Interface).

        arguments:
            cocktographic_map: location of the cocktographic map as an absolute path
                default: This file's location

        """
        with open(cocktographic_map) as f:
            self.dechoder_ring = {"out": {dick.strip(): char.strip()
                                          for dick, char
                                          in itertools.izip_longest(*[f]*2)}}

        self.dechoder_ring["out"][" "] = " "
        self.dechoder_ring["out"]["8mD"] = " "
        self.dechoder_ring["in"] = {char: dick
                                    for dick, char
                                    in self.dechoder_ring["out"].iteritems()}

        self.START = self.dechoder_ring["in"]["start"]
        self.STOP = self.dechoder_ring["in"]["stop"]
        self.CONT = self.dechoder_ring["in"]["cont"]
        self.MARK = self.dechoder_ring["in"]["mark"]

        self.CONTROL_CODES = [self.START, self.STOP, self.CONT, self.MARK]

        self.RE_cocks = re.compile(r"({}|{})[8=mwD~ ]*({}|{})".format(self.START,
                                                                      self.MARK,
                                                                      self.STOP,
                                                                      self.CONT))


    def enchode(self, text, passes=2, split_at=340, marker="\x0F"):
        """Enchode a message.

        accepts:
            str text: String to enchode
            int passes: Number of base64 passes
            int split_at: Number of characters to split lines at
            str marker: Marker for beginning of enchoded text

        returns:
            Enchoded string, with newlines at split_lines

        """
        text = marker + to_unicode(text)
        text = text.encode("utf-8")
        for _ in range(passes):
            text = base64.encodestring(text).replace("\n", "")

        cockstring = " ".join([self.dechoder_ring["in"][c] for c in text])
        if len(cockstring) < split_at:
            return(" ".join([self.START, cockstring, self.STOP]))
        else:
            lines = break_lines(cockstring, split_at)
            sep = " {}\n{} ".format(self.CONT, self.MARK)
            ret = "{} {} {}".format(self.START, sep.join(lines), self.STOP)
            return(ret)

    def dechode(self, text, limit=5, force_security=False,
                ignore_invalid=True, marker="\x0F"):
        """Dechode a message.

        accepts:
            str text: String to dechode
            bool force_security: Error out on unencoded strings like:
                START this wasn't encoded STOP
                If True, dechode will only work on base64 encoded strings eg
                START Y29ja3M= STOP
            bool ignore_invalid: If False, error out on invalid symbols.
        returns:
            Unencoded string

        """
        text = to_unicode(text)
        symbols = text.split()
        if ignore_invalid:
            symbols = [s for s in symbols if s in self.dechoder_ring["out"].keys()]
        dechoded = "".join([self.dechoder_ring["out"][w] for w in text.split()
                            if w not in self.CONTROL_CODES])
        for _ in range(limit):
            try:
                dechoded = base64.decodestring(dechoded)
                if to_unicode(dechoded).startswith(marker):
                    break
            except Exception as e:
                break
        return(to_unicode(dechoded).lstrip(marker))

    def get_cockstring(self, text):
        """Get cockstring from text."""
        text = to_unicode(text)
        result = self.RE_cocks.search(text)
        return(result.group(0) if result else None)
