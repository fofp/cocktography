# 🍆 Quick Install Guide

## Chrome (Desktop)

1. Open Chrome
2. Go to `chrome://extensions/`
3. Toggle "Developer mode" ON (top-right)
4. Click "Load unpacked"
5. Browse to and select: `cocktography-extension/chrome/`
6. Done! Visit [irccloud.com](https://irccloud.com)

## Firefox Mobile (Android)

### Option 1: Firefox Nightly (Recommended)

1. Install [Firefox Nightly](https://play.google.com/store/apps/details?id=org.mozilla.fenix) on Android
2. Open Firefox Nightly → Settings → About Firefox Nightly
3. Tap the Firefox Nightly logo 5 times to enable "Custom Add-on collection"
4. **For now, use temporary installation via USB debugging (see README.md)**
5. **Future**: Submit to Mozilla Add-ons for permanent installation

### Option 2: USB Debugging (Temporary - Dev Only)

1. Enable USB debugging on Android
2. Connect phone to computer via USB
3. On phone: Firefox → Settings → Enable Remote Debugging
4. On computer: Open Firefox → `about:debugging#/setup`
5. Enable USB debugging, connect to device
6. Click device name → "Load Temporary Add-on"
7. Select any file from `cocktography-extension/firefox/`

## What You Get

- 🍆 Floating encode button in IRCCloud
- Auto-decode of incoming cocktographic messages
- Purple gradient styling for decoded messages
- Settings panel (click extension icon)
- Keyboard shortcut: `Ctrl+Shift+E` to encode

## First Steps

1. Open [irccloud.com](https://irccloud.com) and log in
2. Type a message
3. Click the 🍆 button (bottom-left) or press `Ctrl+Shift+E`
4. Send the encoded message!

**Pro tip:** Use inline flags to customize encoding per message:
- `-s5 Your message` → 5 strokes
- `-m Your message` → Mixed mode
- `-w -s0 Large file` → Wide mode, 0 strokes (fast!)

See README.md for full flag documentation.

## Testing

Send yourself this encoded message to test auto-decode:

```
8=wm=D 8==wD BnmD,~ BnD~; 8nD,`'~ 8==w=D~ 8=mw=D
```

It should auto-decode to: **"Hi"**

---

**Need help?** Check the full README.md for troubleshooting.
