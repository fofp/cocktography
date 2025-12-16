# 🍆 Cocktography for IRCCloud

Browser extensions that bring Cocktographic encoding/decoding to IRCCloud's web interface.

## What is Cocktography?

Cocktography is a steganographic encoding system that disguises meaningful conversation as ASCII art spam on IRC. It uses multiple rounds of base64 encoding combined with emoji character substitution (chodes) to hide messages in plain sight.

**Key Features:**
- **Polymorphic encoding**: Same message encodes differently each time
- **Auto-decode**: Automatically decodes incoming cocktographic messages
- **Configurable strokes**: 0-10 rounds of base64 encoding
- **Chode modes**: Thin (1 byte/char), Wide (2 bytes/char), or Mixed
- **Keyboard shortcuts**: Ctrl+Shift+E to encode

## Installation

### Chrome / Edge / Brave

1. Navigate to `cocktography-extension/chrome/` folder
2. Open Chrome and go to `chrome://extensions/`
3. Enable "Developer mode" (toggle in top right)
4. Click "Load unpacked"
5. Select the `chrome` folder
6. Visit IRCCloud and start encoding! 🍆

### Firefox Desktop

1. Navigate to `cocktography-extension/firefox/` folder
2. Open Firefox and go to `about:debugging#/runtime/this-firefox`
3. Click "Load Temporary Add-on"
4. Select any file in the `firefox` folder (e.g., `manifest.json`)
5. Visit IRCCloud and start encoding! 🍆

### Firefox Mobile (Android)

**Prerequisites:** Firefox Nightly or Firefox Beta on Android

1. Enable USB debugging on your Android device
2. Connect device to computer via USB
3. Open Firefox on Android, go to Settings → About Firefox → Tap logo 5 times to enable debugging
4. On computer, open Firefox and go to `about:debugging#/setup`
5. Enable USB debugging and connect to your device
6. Click on your device name
7. In the "Temporary Extensions" section, click "Load Temporary Add-on"
8. Navigate to and select any file in the `firefox` folder
9. The extension will now be loaded on your mobile Firefox!

**Note:** For permanent installation on mobile, you'll need to:
- Submit to Mozilla Add-ons (recommended)
- Or use Firefox Developer Edition with collection support

## Usage

### Encoding Messages

**Method 1: Button**
- Type your message in IRCCloud
- Click the floating 🍆 button (bottom-left)
- Your message is now encoded!

**Method 2: Keyboard**
- Type your message in IRCCloud
- Press `Ctrl+Shift+E`
- Your message is now encoded!

**Method 3: Inline Flags (Advanced)**

You can override the default encoding settings on a per-message basis using inline flags. Just prefix your message with flags:

**Stroke Count Flags:**
- `-s4 Your message` - Use 4 strokes for this message
- `--strokes:7 Your message` - Use 7 strokes for this message
- Valid range: 0-12 strokes

**Mode Flags:**
- `-t Your message` - Use thin mode (1 byte/chode)
- `-w Your message` - Use wide mode (2 bytes/chode)
- `-m Your message` - Use mixed mode (polymorphic)
- Long forms: `--thin`, `--wide`, `--mixed`
- Explicit modes: `--mode:thin`, `--mode:wide`, `--mode:mixed`

**Combining Flags:**

Flags can be combined in any order. If multiple mode flags are present, the highest precedence wins (mixed > wide > thin):

```
-s8 -m Hello, preem choom!
```
→ Encodes with 8 strokes in mixed mode

```
-w -s0 Minimal encoding, wide chodes
```
→ Encodes with 0 strokes in wide mode (fast & efficient!)

```
--strokes:12 --mode:mixed Maximum security message
```
→ Encodes with 12 strokes in mixed mode (maximum obfuscation!)

**Examples:**

- `Hey there!` → Uses your default settings (e.g., 2 strokes, thin mode)
- `-s5 Hey there!` → 5 strokes, thin mode (from defaults)
- `-m Hey there!` → 2 strokes (from defaults), mixed mode
- `-s10 -m Top secret!` → 10 strokes, mixed mode (very secure!)
- `-w -s0 Large file` → 0 strokes, wide mode (2× faster for big messages)

The flags are stripped from your message before encoding, so recipients only see the decoded text without the flags.

### Decoding Messages

Messages are **automatically decoded** when you receive them! They'll appear with:
- 🍆 icon indicator
- Purple gradient highlight
- Stroke count badge
- Collapsible "Show original" to see the raw chodes

### Settings

Click the extension icon in your browser toolbar to configure:

- **Enable extension**: Turn on/off
- **Auto-decode**: Automatically decode incoming messages
- **Stroke count**: 0-10 (default: 2)
  - More strokes = more obfuscation
  - 0 strokes = minimal encoding
- **Chode mode**:
  - **Thin**: 1 byte per chode (classic)
  - **Wide**: 2 bytes per chode (2× more efficient!)
  - **Mixed**: Random mix (polymorphic)
- **Max message length**: IRC char limit (default: 340)

## How It Works

1. **Your message**: `"ClaudeCode is a preem choom!"`

2. **Stroking** (base64 × N):
   ```
   Stroke 1: Q2xhdWRlQ29kZSBpcyBhIHByZWVtIGNob29tIQ==
   Stroke 2: UTJ4aGRXUmxRMjlrWlNCcGN5QmhJSEJ5WldWdElHTm9iMjl0SVE9PQ==
   ```

3. **Cyphallicization** (char → emoji):
   ```
   Each character becomes a dong emoji (chode)
   8==wD 8====D BmD';, 8=D~~~ ...
   ```

4. **Cockchain** (chunking):
   ```
   8=wm=D [chodes] 8=ww=D   ← Start
   8wmD [more chodes] 8=ww=D ← Middle
   8wmD [final chodes] 8=mw=D  ← End
   ```

## Technical Details

### Chode Efficiency

| Mode | Bytes/Chode | Efficiency | Use Case |
|------|-------------|------------|----------|
| Thin | 1 byte | 256 values | Classic mode |
| Wide | 2 bytes | 65,536 values | Large files (2× faster!) |
| Mixed | Variable | Polymorphic | Maximum security |

### Kontol Chodes (Control Markers)

| Chode | Name | Purpose |
|-------|------|---------|
| `8=wm=D` | START | Begin singleton or chain |
| `8=mw=D` | STOP | End singleton or chain |
| `8=ww=D` | CONT | Continue chain |
| `8wmD` | MARK | Middle of chain |

### File Structure

```
cocktography-extension/
├── cpi.js                    # Core library (ported from Python)
├── chrome/                   # Chrome extension
│   ├── manifest.json
│   ├── content.js           # IRCCloud integration
│   ├── content.css          # Styling
│   ├── popup.html/js        # Settings UI
│   ├── background.js        # Service worker
│   └── dicktionaries/       # Encoding tables (256 + 65,536 chodes)
│       ├── kontol_chodes.txt
│       ├── cock_bytes.txt
│       └── rodsetta_stone.txt
└── firefox/                  # Firefox extension
    └── (same structure, manifest v2)
```

## Troubleshooting

### Extension doesn't load
- Check that all files are present
- Look for errors in browser console (F12)
- Ensure dicktionaries folder is included

### Messages not encoding
- Check if extension is enabled in popup
- Verify you're on irccloud.com
- Try refreshing the page

### Messages not decoding
- Enable "Auto-decode" in settings
- Check browser console for errors
- Verify dicktionaries loaded successfully

### Button not appearing
- Wait a few seconds for IRCCloud to fully load
- Refresh the page
- Check if button is hidden off-screen

## Development

### Building from Source

1. Clone the repository
2. Ensure you have the dicktionaries from the main cocktography project
3. Copy to chrome/firefox folders
4. Load as described in Installation

### Testing

Test encoding/decoding in browser console:

```javascript
// Should see "🍆 Cocktography initialized successfully!"
const encoded = cocktography.enchode("Hello World", 2, 1, 340);
console.log(encoded);

const decoded = cocktography.dechode(encoded, true);
console.log(decoded[0].text); // "Hello World"
```

## Credits

- **Cocktography Protocol**: Original design
- **Python CPI**: Original implementation
- **JavaScript Port**: For browser extensions
- **IRCCloud**: The web IRC client this integrates with

## License

MIT

---

**Happy choding, you preem choom! 🍆**
