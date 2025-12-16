# Build Instructions for Cocktography Extension

This extension uses a simple Python build script to convert dictionary text files into embedded JavaScript to work around Firefox content script CSP restrictions.

## Prerequisites

- Python 3.6 or higher

## Build Steps

1. Ensure you're in the `firefox/` directory
2. Run the build script:
   ```bash
   python build.py
   ```
3. This generates `dicktionaries.js` from the text files in `dicktionaries/`

## What Gets Generated

The build script (`build.py`) reads three text files:
- `dicktionaries/kontol_chodes.txt` - Cocktography framing markers
- `dicktionaries/cock_bytes.txt` - Thin chode dictionary
- `dicktionaries/rodsetta_stone.txt` - Wide chode dictionary

And converts them into `dicktionaries.js`, which contains a single JavaScript constant:

```javascript
const DICKTIONARIES = {
    kontol_chodes: "...",
    cock_bytes: "...",
    rodsetta_stone: "..."
};
```

## Why This Approach

Originally, the extension loaded these files via `fetch()`, but Firefox's Content Security Policy (CSP) for content scripts blocks this. Embedding them as JavaScript is the only reliable way to include the dictionaries in a content script context.

## Creating the XPI

After running `build.py`, you can package the extension:

```bash
python build_xpi.py
```

Or manually create a ZIP file with all the files and rename it to `.xpi`.

## Files Included in Extension

- `manifest.json` - Extension manifest
- `dicktionaries.js` - Generated dictionary data (from text files)
- `cpi.js` - Cocktography implementation
- `content.js` - Content script for IRCCloud integration
- `content.css` - Styles
- `background.js` - Background script
- `popup.html`, `popup.js` - Settings popup
- `icons/` - Extension icons

## No Obfuscation

All code is unminified and readable. The only "generation" is converting plain text dictionaries to JavaScript strings.
