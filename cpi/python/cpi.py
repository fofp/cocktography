import base64
import itertools
import os
import random
import re
import textwrap
from enum import Enum

class ChodeError(ValueError):
    pass

class CockblockError(ValueError):
    pass

def _anonymous(cls):
    return cls()

class CyphallicMethod(Enum):
    little_chodian = 1
    big_chodian = 2
    mixed_chodian = 3

class CockblockType(Enum):
    singleton = 1
    initial = 2
    intermediate = 3
    final = 4

class Cocktography(object):
    _DEFAULT_PATH = os.path.dirname(os.path.realpath(__file__))
    _DEFAULT_KONTOL_CHODES_FILENAME = "kontol_chodes.txt"
    _DEFAULT_LITTLE_CHODIAN_FILENAME = "cock_bytes.txt"
    _DEFAULT_BIG_CHODIAN_FILENAME = "rodsetta_stone.txt"
    ESCAPE_SENTINEL = b"\x0F"
    SEPARATOR = b" "

    def __init__(self,
                 path = _DEFAULT_PATH,
                 kontol_chodes_filename = _DEFAULT_KONTOL_CHODES_FILENAME,
                 little_chodian_filename = _DEFAULT_LITTLE_CHODIAN_FILENAME,
                 big_chodian_filename = _DEFAULT_BIG_CHODIAN_FILENAME):
        with open(os.path.join(path, kontol_chodes_filename)) as f:
            self._kontol_to_chode = {name.strip(): chode.strip()
                                     for chode, name
                                     in itertools.izip_longest(*[f]*2)}
        with open(os.path.join(path, little_chodian_filename)) as f:
            self._unigram_to_chode = f.read().splitlines()
        with open(os.path.join(path, big_chodian_filename)) as f:
            self._digram_to_chode = f.read().splitlines()
        self._unigram_from_chode = {chode: unigram
                                    for unigram, chode
                                    in enumerate(self._unigram_to_chode)}
        self._digram_from_chode = {chode: digram
                                   for digram, chode
                                   in enumerate(self._digram_to_chode)}
        @_anonymous
        class KONTOL_CHODES:
            START = self._kontol_to_chode["START"]
            STOP = self._kontol_to_chode["STOP"]
            MARK = self._kontol_to_chode["MARK"]
            CONT = self._kontol_to_chode["CONT"]
            FROM_COCKBLOCK_TYPE = {
                CockblockType.singleton: (START, STOP),
                CockblockType.initial: (START, CONT),
                CockblockType.intermediate: (MARK, CONT),
                CockblockType.final: (MARK, STOP)}
            TO_COCKBLOCK_TYPE = {
                chodes: type for type, chodes in FROM_COCKBLOCK_TYPE.items()}
            BEGINNING = (START, MARK)
            ENDING = (CONT, STOP)
        self.KONTOL_CHODES = KONTOL_CHODES
        self.COCKBLOCK_PADDING = len(max(KONTOL_CHODES.BEGINNING, key=len)) \
            + len(max(KONTOL_CHODES.ENDING, key=len))
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
        if mode == CyphallicMethod.little_chodian:
            for byte in byte_input:
                result.append(self._unigram_to_chode[byte])
        elif mode == CyphallicMethod.big_chodian:
            prev = None
            for byte in byte_input:
                if prev is None:
                    prev = byte
                else:
                    result.append(self._digram_to_chode[(prev << 8) | byte])
                    prev = None
            if prev is not None:
                result.append(self._unigram_to_chode[prev])
        elif mode == CyphallicMethod.mixed_chodian:
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
        return self.SEPARATOR.join(
            self._bytes2chodes(bytearray(byte_input), mode))

    def decyphallicize(self, chodes):
        return self._chodes2bytes(chodes.split())

    def stroke(self, text, count):
        text = self.ESCAPE_SENTINEL + text
        while count > 0:
            text = base64.standard_b64encode(text)
            count -= 1
        return text

    def destroke(self, text):
        count = 0
        while (len(text) > 0
                and text[0] != self.ESCAPE_SENTINEL
                and len(text) % 4 == 0
                and not self._RE_NOT_BASE64.search(text)):
            text = base64.standard_b64decode(text)
            count += 1
        return text.lstrip(self.ESCAPE_SENTINEL), count

    def find_cockblock(self, text):
        match = self._RE_COCKBLOCKS.search(text)
        if match:
            groups = match.groups()
            return (match.span(), match.span(2),
                self.KONTOL_CHODES.TO_COCKBLOCK_TYPE[groups[0::2]])
        else:
            return None

    def make_cockchain(self, chodes, cockblock_size):
        lines = textwrap.wrap(
            chodes,
            cockblock_size - self.COCKBLOCK_PADDING,
            break_on_hyphens=False,
            break_long_words=False,
            expand_tabs=False)
        sep = self.SEPARATOR + self.KONTOL_CHODES.CONT + b'\n' \
            + self.KONTOL_CHODES.MARK + self.SEPARATOR
        ret = self.KONTOL_CHODES.START + self.SEPARATOR + sep.join(lines) \
            + self.SEPARATOR + self.KONTOL_CHODES.STOP
        return ret.splitlines()

    def enchode(self, bytearray, strokes, mode, cockblock_size):
        return self.make_cockchain(
            self.cyphallicize(self.stroke(bytearray, strokes), mode),
            cockblock_size)

    def dechode(self, bytearray):
        pass #todo