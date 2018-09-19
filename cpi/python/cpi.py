
import itertools
import os

def anonymous(cls):
    return cls()

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
                                 in self._kontol_from_chode.iteritems()}
        self._unigram_from_chode = {chode: unigram
                                    for unigram, chode
                                    in enumerate(self._unigram_to_chode)}
        self._digram_from_chode = {chode: digram
                                   for digram, chode
                                   in enumerate(self._digram_to_chode)}
        @anonymous
        class KONTOL_CHODES:
            START = self._kontol_to_chode["START"]
            STOP = self._kontol_to_chode["STOP"]
            MARK = self._kontol_to_chode["MARK"]
            CONT = self._kontol_to_chode["CONT"]
        self.KONTOL_CHODES = KONTOL_CHODES
