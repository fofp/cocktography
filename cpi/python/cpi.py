import itertools
import os
import random
import re
from enum import Enum

class InvalidCockstring(Exception):
    pass

def _anonymous(cls):
    return cls()

class CyphallicMethod(Enum):
    unigram = 1
    digram = 2
    varied = 3

class CockblockType(Enum):
    singleton = 1
    initial = 2
    intermediate = 3
    final = 4

class Cocktography(object):
    _DEFAULT_KONTOL_CHODES_FILENAME = \
        os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                     "kontol_chodes.txt")
    _DEFAULT_UNIGRAMS_FILENAME = \
        os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                     "cock_bytes.txt")
    _DEFAULT_DIGRAMS_FILENAME = \
        os.path.join(os.path.dirname(os.path.realpath(__file__)),
                                     "rodsetta_stone.txt")

    def __init__(self,
                 kontol_chodes_filename = _DEFAULT_KONTOL_CHODES_FILENAME,
                 unigrams_filename = _DEFAULT_UNIGRAMS_FILENAME,
                 digrams_filename = _DEFAULT_DIGRAMS_FILENAME):
        with open(kontol_chodes_filename) as f:
            self._kontol_from_chode = {chode.strip(): name.strip()
                                       for chode, name
                                       in itertools.izip_longest(*[f]*2)}
        with open(unigrams_filename) as f:
            self._unigram_to_chode = f.read().splitlines()
        with open(digrams_filename) as f:
            self._digram_to_chode = f.read().splitlines()
        self._kontol_to_chode = {name: chode
                                 for chode, name
                                 in self._kontol_from_chode.items()}
        self._unigram_from_chode = {chode: unigram
                                    for unigram, chode
                                    in enumerate(self._unigram_to_chode)}
        self._digram_from_chode = {chode: digram
                                   for digram, chode
                                   in enumerate(self._digram_to_chode)}
        @_anonymous
        class KONTOL_CHODES:
            START = self._kontol_to_chode["START"]
            STOP  = self._kontol_to_chode["STOP"]
            MARK  = self._kontol_to_chode["MARK"]
            CONT  = self._kontol_to_chode["CONT"]
            FROM_COCKBLOCK_TYPE = {
                CockblockType.singleton: (START, STOP),
                CockblockType.initial: (START, CONT),
                CockblockType.intermediate: (MARK, CONT),
                CockblockType.final: (MARK, STOP),
            }
            TO_COCKBLOCK_TYPE = {chodes: type
                                 for type, chodes
                                 in FROM_COCKBLOCK_TYPE.items()}
            BEGINNING = (START, MARK)
            ENDING = (CONT, STOP)
        self.KONTOL_CHODES = KONTOL_CHODES
        self._RE_COCKBLOCKS = re.compile(r"({}).*({})".format(
                r"|".join(map(re.escape, KONTOL_CHODES.BEGINNING)),
                r"|".join(map(re.escape, KONTOL_CHODES.ENDING))))

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
                raise InvalidCockstring("Unknown symbol: {}".format(chode))
        return result

    def _bytes2chodes(self, byte_input, mode, varied_unigram_chance = 0.5):
        result = list()
        if mode == CyphallicMethod.unigram:
            for byte in byte_input:
                result.append(self._unigram_to_chode[byte])
        elif mode == CyphallicMethod.digram:
            prev = None
            for byte in byte_input:
                if prev is None:
                    prev = byte
                else:
                    result.append(self._digram_to_chode[(prev << 8) | byte])
                    prev = None
            if prev is not None:
                result.append(self._unigram_to_chode[prev])
        elif mode == CyphallicMethod.varied:
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
                        result.append(self._digram_to_chode[(prev << 8) | byte])
                        prev = None
            if prev is not None:
                result.append(self._unigram_to_chode[prev])
        return result

    def bytes2chodes(self, byte_input, mode=CyphallicMethod.digram):
        return b" ".join(self._bytes2chodes(bytearray(byte_input), mode))

    def chodes2bytes(self, chodes):
        return self._chodes2bytes(chodes.split())

    def find_cockblock(self, byte_input):
        match = self._RE_COCKBLOCKS.search(byte_input)
        if match:
            groups = match.groups()
            return (match.start(),
                    match.end(),
                    self.KONTOL_CHODES.TO_COCKBLOCK_TYPE[groups])
        else:
            return None
