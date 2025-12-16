/**
 * Cocktography JavaScript Implementation
 * Port of the Python CPI library for browser extensions
 */

// Constants
const CyphallicMethod = {
    THIN_CHODE: 1,
    WIDE_CHODE: 2,
    MIXED_CHODE: 3
};

const CockblockType = {
    SINGLETON: 1,
    INITIAL: 2,
    INTERMEDIATE: 3,
    FINAL: 4
};

class ChodeError extends Error {
    constructor(message) {
        super(message);
        this.name = 'ChodeError';
    }
}

class CockblockError extends Error {
    constructor(message) {
        super(message);
        this.name = 'CockblockError';
    }
}

class Cocktography {
    constructor() {
        this.ESCAPE_SENTINEL = '\x0F';
        this.SEPARATOR = ' ';

        // These will be loaded from dicktionary files
        this._kontol_to_chode = null;
        this._unigram_to_chode = null;
        this._digram_to_chode = null;
        this._unigram_from_chode = null;
        this._digram_from_chode = null;
        this.KONTOL_CHODES = null;
        this.COCKBLOCK_PADDING = 0;
        this._RE_COCKBLOCKS = null;
        this._RE_NOT_BASE64 = /[^+/=0-9A-Za-z]/;

        this._initialized = false;
    }

    /**
     * Initialize the library with dicktionary data
     * @param {Object} dicktionaries - Object containing kontol_chodes, cock_bytes, rodsetta_stone as strings
     */
    async initialize(dicktionaries) {
        // Parse kontol chodes
        this._kontol_to_chode = {};
        const kontolLines = dicktionaries.kontol_chodes.trim().split('\n');
        for (const line of kontolLines) {
            if (line.trim()) {
                const [name, chode] = line.trim().split(/\s+/);
                this._kontol_to_chode[name] = chode;
            }
        }

        // Parse thin chodes (cock_bytes.txt)
        this._unigram_to_chode = dicktionaries.cock_bytes.trim().split('\n');

        // Parse wide chodes (rodsetta_stone.txt)
        this._digram_to_chode = dicktionaries.rodsetta_stone.trim().split('\n');

        // Create reverse mappings
        this._unigram_from_chode = {};
        this._unigram_to_chode.forEach((chode, index) => {
            this._unigram_from_chode[chode] = index;
        });

        this._digram_from_chode = {};
        this._digram_to_chode.forEach((chode, index) => {
            this._digram_from_chode[chode] = index;
        });

        // Setup KONTOL_CHODES
        const START = this._kontol_to_chode['START'];
        const STOP = this._kontol_to_chode['STOP'];
        const MARK = this._kontol_to_chode['MARK'];
        const CONT = this._kontol_to_chode['CONT'];

        this.KONTOL_CHODES = {
            START,
            STOP,
            MARK,
            CONT,
            FROM_COCKBLOCK_TYPE: {
                [CockblockType.SINGLETON]: [START, STOP],
                [CockblockType.INITIAL]: [START, CONT],
                [CockblockType.INTERMEDIATE]: [MARK, CONT],
                [CockblockType.FINAL]: [MARK, STOP]
            },
            BEGINNING: [START, MARK],
            ENDING: [CONT, STOP]
        };

        // Create TO_COCKBLOCK_TYPE mapping
        this.KONTOL_CHODES.TO_COCKBLOCK_TYPE = {};
        for (const [type, chodes] of Object.entries(this.KONTOL_CHODES.FROM_COCKBLOCK_TYPE)) {
            const key = chodes.join(',');
            this.KONTOL_CHODES.TO_COCKBLOCK_TYPE[key] = parseInt(type);
        }

        // Calculate padding
        const maxBegin = Math.max(...this.KONTOL_CHODES.BEGINNING.map(c => c.length));
        const maxEnd = Math.max(...this.KONTOL_CHODES.ENDING.map(c => c.length));
        this.COCKBLOCK_PADDING = maxBegin + maxEnd + 4; // +4 for separators

        // Build cockblock regex
        const beginPattern = this.KONTOL_CHODES.BEGINNING.map(c => this._escapeRegex(c)).join('|');
        const endPattern = this.KONTOL_CHODES.ENDING.map(c => this._escapeRegex(c)).join('|');
        const sepPattern = this._escapeRegex(this.SEPARATOR);
        this._RE_COCKBLOCKS = new RegExp(`(${beginPattern})${sepPattern}(.*)${sepPattern}(${endPattern})`);

        this._initialized = true;
    }

    _escapeRegex(str) {
        return str.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
    }

    /**
     * Convert chodes to bytes
     */
    _chodes2bytes(chodes, tolerant = true) {
        const result = [];
        for (const chode of chodes) {
            if (chode in this._unigram_from_chode) {
                result.push(this._unigram_from_chode[chode]);
            } else if (chode in this._digram_from_chode) {
                const digram = this._digram_from_chode[chode];
                result.push((digram >> 8) & 0xFF);
                result.push(digram & 0xFF);
            } else if (!tolerant) {
                throw new ChodeError(`Unknown symbol: ${chode}`);
            }
        }
        return new Uint8Array(result);
    }

    /**
     * Convert bytes to chodes
     */
    _bytes2chodes(bytes, mode, variedUnigramChance = 0.5) {
        const result = [];

        if (mode === CyphallicMethod.THIN_CHODE) {
            for (const byte of bytes) {
                result.push(this._unigram_to_chode[byte]);
            }
        } else if (mode === CyphallicMethod.WIDE_CHODE) {
            let prev = null;
            for (const byte of bytes) {
                if (prev === null) {
                    prev = byte;
                } else {
                    result.push(this._digram_to_chode[(prev << 8) | byte]);
                    prev = null;
                }
            }
            if (prev !== null) {
                result.push(this._unigram_to_chode[prev]);
            }
        } else if (mode === CyphallicMethod.MIXED_CHODE) {
            let prev = null;
            for (const byte of bytes) {
                if (Math.random() < variedUnigramChance) {
                    if (prev === null) {
                        result.push(this._unigram_to_chode[byte]);
                    } else {
                        result.push(this._unigram_to_chode[prev]);
                        prev = byte;
                    }
                } else {
                    if (prev === null) {
                        prev = byte;
                    } else {
                        result.push(this._digram_to_chode[(prev << 8) | byte]);
                        prev = null;
                    }
                }
            }
            if (prev !== null) {
                result.push(this._unigram_to_chode[prev]);
            }
        }
        return result;
    }

    /**
     * Cyphallicize bytes into chodes
     */
    cyphallicize(bytes, mode) {
        return this._bytes2chodes(bytes, mode).join(this.SEPARATOR);
    }

    /**
     * Decyphallicize chodes back to bytes
     */
    decyphallicize(chodes) {
        // Normalize all whitespace to regular spaces before splitting
        // IRCCloud may insert non-breaking spaces (U+00A0, code 160) which break the split
        const normalized = chodes.replace(/[\s ]+/g, ' ');
        return this._chodes2bytes(normalized.split(this.SEPARATOR));
    }

    /**
     * Apply strokes (multiple rounds of base64)
     */
    stroke(text, count) {
        // Convert string to bytes if needed
        let bytes = typeof text === 'string'
            ? new TextEncoder().encode(text)
            : text;

        // Prepend escape sentinel
        const withSentinel = new Uint8Array(bytes.length + 1);
        withSentinel[0] = this.ESCAPE_SENTINEL.charCodeAt(0);
        withSentinel.set(bytes, 1);

        let result = withSentinel;
        for (let i = 0; i < count; i++) {
            // Base64 encode
            const base64 = btoa(String.fromCharCode(...result));
            result = new TextEncoder().encode(base64);
        }

        return result;
    }

    /**
     * Remove strokes (multiple rounds of base64 decode)
     */
    destroke(bytes) {
        let text = bytes;
        let count = 0;

        // Convert to string if needed
        let str = typeof text === 'string'
            ? text
            : new TextDecoder().decode(text);

        // Keep decoding while it's valid base64
        while (str.length > 0 &&
               str.charCodeAt(0) !== this.ESCAPE_SENTINEL.charCodeAt(0) &&
               str.length % 4 === 0 &&
               !this._RE_NOT_BASE64.test(str)) {
            try {
                const decoded = atob(str);
                const bytes = new Uint8Array(decoded.length);
                for (let i = 0; i < decoded.length; i++) {
                    bytes[i] = decoded.charCodeAt(i);
                }
                text = bytes;
                str = new TextDecoder().decode(bytes);
                count++;
            } catch (e) {
                break;
            }
        }

        // Strip escape sentinel
        if (typeof text !== 'string') {
            text = new TextDecoder().decode(text);
        }
        text = text.replace(/^\x0F/, '');

        return { text, strokes: count };
    }

    /**
     * Find a cockblock in text
     */
    findCockblock(text) {
        const match = text.match(this._RE_COCKBLOCKS);
        if (match) {
            const beginChode = match[1];
            const cyphallic = match[2];
            const endChode = match[3];

            // Determine cockblock type
            const key = [beginChode, endChode].join(',');
            const cbType = this.KONTOL_CHODES.TO_COCKBLOCK_TYPE[key];

            return {
                fullMatch: match[0],
                beginChode,
                cyphallic,
                endChode,
                type: cbType,
                start: match.index,
                end: match.index + match[0].length
            };
        }
        return null;
    }

    /**
     * Create a cockchain (chunked message)
     */
    makeCockchain(chodes, cockblockSize) {
        const maxChodeLength = cockblockSize - this.COCKBLOCK_PADDING;

        // Split by token boundaries (spaces), not character positions
        const glyphs = chodes.split(' ');
        const chunks = [];
        let currentChunk = [];
        let currentLength = 0;

        for (const glyph of glyphs) {
            // Check if adding this glyph (plus space) would exceed limit
            const glyphWithSpace = currentChunk.length > 0 ? glyph.length + 1 : glyph.length;

            if (currentLength + glyphWithSpace <= maxChodeLength) {
                // Fits in current chunk
                currentChunk.push(glyph);
                currentLength += glyphWithSpace;
            } else {
                // Start new chunk
                if (currentChunk.length > 0) {
                    chunks.push(currentChunk.join(' '));
                }
                currentChunk = [glyph];
                currentLength = glyph.length;
            }
        }

        // Add final chunk
        if (currentChunk.length > 0) {
            chunks.push(currentChunk.join(' '));
        }

        if (chunks.length === 0) {
            return '';
        }

        if (chunks.length === 1) {
            // Singleton
            return `${this.KONTOL_CHODES.START} ${chunks[0]} ${this.KONTOL_CHODES.STOP}`;
        }

        // Multiple chunks
        const lines = [];
        lines.push(`${this.KONTOL_CHODES.START} ${chunks[0]} ${this.KONTOL_CHODES.CONT}`);

        for (let i = 1; i < chunks.length - 1; i++) {
            lines.push(`${this.KONTOL_CHODES.MARK} ${chunks[i]} ${this.KONTOL_CHODES.CONT}`);
        }

        lines.push(`${this.KONTOL_CHODES.MARK} ${chunks[chunks.length - 1]} ${this.KONTOL_CHODES.STOP}`);

        return lines.join('\n');
    }

    /**
     * Encode a message
     */
    enchode(text, strokes = 2, mode = CyphallicMethod.THIN_CHODE, cockblockSize = 340) {
        if (!this._initialized) {
            throw new Error('Cocktography not initialized. Call initialize() first.');
        }

        const stroked = this.stroke(text, strokes);
        const cyphallic = this.cyphallicize(stroked, mode);
        return this.makeCockchain(cyphallic, cockblockSize);
    }

    /**
     * Decode a message
     */
    dechode(text, tolerant = true) {
        if (!this._initialized) {
            throw new Error('Cocktography not initialized. Call initialize() first.');
        }

        const results = [];
        let pos = 0;
        let accumulated = null;
        let prevType = null;

        while (pos < text.length) {
            const remaining = text.substr(pos);
            const cockblock = this.findCockblock(remaining);

            if (!cockblock) {
                break;
            }

            const cyphallic = this.decyphallicize(cockblock.cyphallic);
            const cbType = cockblock.type;

            if (cbType === CockblockType.SINGLETON &&
                prevType !== CockblockType.INITIAL &&
                prevType !== CockblockType.INTERMEDIATE) {
                const { text: decoded, strokes } = this.destroke(cyphallic);
                results.push({ text: decoded, strokes });
            } else if (cbType === CockblockType.INITIAL &&
                       prevType !== CockblockType.INITIAL &&
                       prevType !== CockblockType.INTERMEDIATE) {
                accumulated = cyphallic;
            } else if (cbType === CockblockType.INTERMEDIATE &&
                       (prevType === CockblockType.INITIAL ||
                        prevType === CockblockType.INTERMEDIATE)) {
                const combined = new Uint8Array(accumulated.length + cyphallic.length);
                combined.set(accumulated);
                combined.set(cyphallic, accumulated.length);
                accumulated = combined;
            } else if (cbType === CockblockType.FINAL &&
                       (prevType === CockblockType.INITIAL ||
                        prevType === CockblockType.INTERMEDIATE)) {
                const combined = new Uint8Array(accumulated.length + cyphallic.length);
                combined.set(accumulated);
                combined.set(cyphallic, accumulated.length);
                const { text: decoded, strokes } = this.destroke(combined);
                results.push({ text: decoded, strokes });
                accumulated = null;
            } else if (!tolerant) {
                throw new CockblockError(`${prevType} should not appear before ${cbType}`);
            }

            prevType = cbType;
            pos += cockblock.end;
        }

        return results;
    }
}

// Export for use in extensions
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { Cocktography, CyphallicMethod, CockblockType };
}
