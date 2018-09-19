# -*- coding: utf-8 -*-
from __future__ import unicode_literals
import itertools
import base64
try:
    import regex as re
except:
    import re
import os
import textwrap


COCKTOGRAPIC_MAP = os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                "dechoder_ring")


class InvalidCockstring(Exception):
    pass


def to_unicode(strng):
    """Convert a utf-8 encoded string to a Unicode."""
    if isinstance(strng, unicode):
        return strng
    return strng.decode('utf-8', 'replace')


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
        self.dechoder_ring["out"]["8wm===D"] = "\x0F"
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

    def enchode(self, text, strokes=2, split_at=340,
                return_list=False, marker="\x0F"):
        """Enchode a message.

        accepts:
            str text: String to enchode
            int strokes: Number of base64 passes
            int split_at: Number of characters to split lines at
            bool return_list: Default False, if True return a list
                              instead of a string
            str marker: Marker for beginning of enchoded text

        returns:
            Enchoded string, with newlines at split_lines

        """
        text = marker + to_unicode(text)
        if strokes > 0:
            text = text.encode("utf-8")
            for _ in range(strokes):
                text = base64.encodestring(text).replace("\n", "")
        else:
            text = text.encode('ascii', 'replace').decode()

        cockstring = " ".join([self.dechoder_ring["in"][c] for c in text])
        if len(cockstring) < split_at:
            return(" ".join([self.START, cockstring, self.STOP]))
        else:
            lines = textwrap.wrap(cockstring, split_at, break_long_words=False,
                                  break_on_hyphens=False)
            sep = " {}\n{} ".format(self.CONT, self.MARK)
            ret = "{} {} {}".format(self.START, sep.join(lines), self.STOP)
            if return_list:
                return(ret.split("\n"))
            else:
                return(ret)

    def dechode(self, text, limit=15, force_security=False,
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
            tuple (Unencoded string, strokes)

        """
        text = to_unicode(text)
        if not text.startswith(self.START):
            raise InvalidCockstring("{} does not start with {}".format(text, self.START))
        if not text.endswith(self.STOP):
            raise InvalidCockstring("{} does not end with {}".format(text, self.STOP))
        symbols = text.split()
        if ignore_invalid:
            symbols = [s for s in symbols if s in self.dechoder_ring["out"].keys()]
        dechoded = "".join([self.dechoder_ring["out"][w] for w in text.split()
                            if w not in self.CONTROL_CODES])
        strokes = 0
        final_dechode = dechoded
        for i in range(limit):
            try:
                if to_unicode(dechoded).startswith(marker):
                    strokes = i
                    final_dechode = dechoded
                    break
                if i == 2:
                    strokes = 2
                    final_dechode = dechoded
                dechoded = base64.decodestring(dechoded)
            except Exception as e:
                break
        result = to_unicode(final_dechode).lstrip(marker)
        return(result, strokes)

    def get_cockstring(self, text):
        """Get cockstring from text."""
        text = to_unicode(text)
        result = self.RE_cocks.search(text)
        return(result.group(0) if result else None)
