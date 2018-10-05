import base64
import itertools
import os
import random
import re
import textwrap


class ChodeError(ValueError):
    pass


class CockblockError(ValueError):
    pass


def _anonymous(cls):
    return cls()


@_anonymous
class CyphallicMethod:
    THIN_CHODE = 1
    WIDE_CHODE = 2
    MIXED_CHODE = 3


@_anonymous
class CockblockType:
    SINGLETON = 1
    INITIAL = 2
    INTERMEDIATE = 3
    FINAL = 4


class Cocktography(object):
    _DEFAULT_PATH = os.path.dirname(os.path.realpath(__file__))
    _DEFAULT_KONTOL_CHODES_FILENAME = "kontol_chodes.txt"
    _DEFAULT_THIN_CHODE_FILENAME = "cock_bytes.txt"
    _DEFAULT_WIDE_CHODE_FILENAME = "rodsetta_stone.txt"
    ESCAPE_SENTINEL = b"\x0F"
    SEPARATOR = b" "

    def __init__(self,
                 path=_DEFAULT_PATH,
                 kontol_chodes_filename=_DEFAULT_KONTOL_CHODES_FILENAME,
                 thin_chode_filename=_DEFAULT_THIN_CHODE_FILENAME,
                 wide_chode_filename=_DEFAULT_WIDE_CHODE_FILENAME):
        with open(os.path.join(path, kontol_chodes_filename)) as f:
            self._kontol_to_chode = {
                name.strip(): chode.strip()
                for chode, name in itertools.izip_longest(*[f] * 2)
            }
        with open(os.path.join(path, thin_chode_filename)) as f:
            self._unigram_to_chode = f.read().splitlines()
        with open(os.path.join(path, wide_chode_filename)) as f:
            self._digram_to_chode = f.read().splitlines()
        self._unigram_from_chode = {
            chode: unigram
            for unigram, chode in enumerate(self._unigram_to_chode)
        }
        self._digram_from_chode = {
            chode: digram
            for digram, chode in enumerate(self._digram_to_chode)
        }

        @_anonymous
        class KONTOL_CHODES:
            START = self._kontol_to_chode["START"]
            STOP = self._kontol_to_chode["STOP"]
            MARK = self._kontol_to_chode["MARK"]
            CONT = self._kontol_to_chode["CONT"]
            FROM_COCKBLOCK_TYPE = {
                CockblockType.SINGLETON: (START, STOP),
                CockblockType.INITIAL: (START, CONT),
                CockblockType.INTERMEDIATE: (MARK, CONT),
                CockblockType.FINAL: (MARK, STOP)
            }
            TO_COCKBLOCK_TYPE = {
                chodes: cb_type
                for cb_type, chodes in FROM_COCKBLOCK_TYPE.items()
            }
            BEGINNING = (START, MARK)
            ENDING = (CONT, STOP)

        self.KONTOL_CHODES = KONTOL_CHODES
        self.COCKBLOCK_PADDING = len(max(
            KONTOL_CHODES.BEGINNING, key=len)) + len(
                max(KONTOL_CHODES.ENDING, key=len))
        self._RE_COCKBLOCKS = re.compile(r"({0}){2}(.*){2}({1})".format(
            r"|".join(map(re.escape, KONTOL_CHODES.BEGINNING)),
            r"|".join(map(re.escape, KONTOL_CHODES.ENDING)),
            re.escape(self.SEPARATOR)))
        self._RE_NOT_BASE64 = re.compile(r"[^+/=0-9A-Za-z]")

    def _chodes2bytes(self, chodes, tolerant=True):
        result = bytearray()
        for chode in chodes:
            if chode in self._unigram_from_chode:
                result.append(self._unigram_from_chode[chode])
            elif chode in self._digram_from_chode:
                digram = self._digram_from_chode[chode]
                result.append(digram >> 8)
                result.append(digram & 0xFF)
            elif not tolerant:
                raise ChodeError("Unknown symbol: {}".format(chode))
        return result

    def _bytes2chodes(self, byte_input, mode, varied_unigram_chance=0.5):
        result = list()
        if mode == CyphallicMethod.THIN_CHODE:
            for byte in byte_input:
                result.append(self._unigram_to_chode[byte])
        elif mode == CyphallicMethod.WIDE_CHODE:
            prev = None
            for byte in byte_input:
                if prev is None:
                    prev = byte
                else:
                    result.append(self._digram_to_chode[(prev << 8) | byte])
                    prev = None
            if prev is not None:
                result.append(self._unigram_to_chode[prev])
        elif mode == CyphallicMethod.MIXED_CHODE:
            prev = None
            for byte in byte_input:
                if random.random() < varied_unigram_chance:
                    if prev is None:
                        result.append(self._unigram_to_chode[byte])
                    else:
                        result.append(self._unigram_to_chode[prev])
                        prev = byte
                else:
                    if prev is None:
                        prev = byte
                    else:
                        result.append(
                            self._digram_to_chode[(prev << 8) | byte])
                        prev = None
            if prev is not None:
                result.append(self._unigram_to_chode[prev])
        return result

    def cyphallicize(self, byte_input, mode):
        return self.SEPARATOR.join(self._bytes2chodes(byte_input, mode))

    def decyphallicize(self, chodes):
        return self._chodes2bytes(chodes.split())

    def stroke(self, text, count):
        text = self.ESCAPE_SENTINEL + text
        while count > 0:
            text = base64.standard_b64encode(text)
            count -= 1
        return bytearray(text)

    def destroke(self, text):
        count = 0
        while (len(text) > 0 and text[0] != self.ESCAPE_SENTINEL
               and len(text) % 4 == 0
               and not self._RE_NOT_BASE64.search(text)):
            text = base64.standard_b64decode(text)
            count += 1
        return text.lstrip(self.ESCAPE_SENTINEL), count

    def find_cockblock(self, text):
        match = self._RE_COCKBLOCKS.search(text)
        if match:
            groups = match.groups()
            return match.span(), match.span(
                2), self.KONTOL_CHODES.TO_COCKBLOCK_TYPE[groups[0::2]]
        else:
            return None

    def make_cockchain(self, chodes, cockblock_size):
        lines = textwrap.wrap(
            chodes,
            cockblock_size - self.COCKBLOCK_PADDING,
            break_on_hyphens=False,
            break_long_words=False,
            expand_tabs=False)
        sep = self.SEPARATOR + self.KONTOL_CHODES.CONT + \
            b'\n' + self.KONTOL_CHODES.MARK + self.SEPARATOR
        return self.KONTOL_CHODES.START + self.SEPARATOR + sep.join(lines) + \
            self.SEPARATOR + self.KONTOL_CHODES.STOP

    def enchode(self, byte_input, strokes, mode, cockblock_size):
        return self.make_cockchain(
            self.cyphallicize(self.stroke(byte_input, strokes), mode),
            cockblock_size)

    def dechode(self, byte_input, tolerant=False):
        ret = list()
        pos = 0
        val = b""
        prev_cb_type = None
        for (__, cb_end), (cy_begin, cy_end), cb_type in iter(
                lambda: self.find_cockblock(byte_input[pos:]), None):
            cyphallic_text = self.decyphallicize(byte_input[cy_begin:cy_end])
            if cb_type == CockblockType.SINGLETON and prev_cb_type not in (
                    CockblockType.INITIAL, CockblockType.INTERMEDIATE):
                ret.append(self.destroke(cyphallic_text))
            elif cb_type == CockblockType.INITIAL and prev_cb_type not in (
                    CockblockType.INITIAL, CockblockType.INTERMEDIATE):
                val = cyphallic_text
            elif cb_type == CockblockType.INTERMEDIATE and prev_cb_type in (
                    CockblockType.INITIAL, CockblockType.INTERMEDIATE):
                val = val + self.SEPARATOR + cyphallic_text
            elif cb_type == CockblockType.FINAL and prev_cb_type in (
                    CockblockType.INITIAL, CockblockType.INTERMEDIATE):
                ret.append(
                    self.destroke(val + self.SEPARATOR + cyphallic_text))
                val = b""
            elif not tolerant:
                raise CockblockError("{} should not appear before {}".format(
                    prev_cb_type, cb_type))
            pos = cb_end
        return ret
