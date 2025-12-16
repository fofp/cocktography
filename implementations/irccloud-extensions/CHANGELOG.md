# Changelog

All notable changes to the Cocktography IRCCloud Extension.

## [1.0.1] - 2025-01-16

### Added
- **Inline flag support** - Override encoding settings per-message with command-line style flags
  - Stroke flags: `-s4`, `--strokes:7` (0-12 strokes)
  - Mode flags: `-t` (thin), `-w` (wide), `-m` (mixed)
  - Long forms: `--thin`, `--wide`, `--mixed`, `--mode:thin`, etc.
  - Flags can be combined: `-s10 -m Secret message`
  - Flags are automatically stripped from encoded output
- Better whitespace normalization to handle IRCCloud's non-breaking spaces (U+00A0)

### Changed
- Moved encode button from bottom-right to bottom-left (better alignment with input)
- Button now uses semi-transparent gradient (40% opacity) so timestamp shows through
- Button size reduced from 50px to 36px for more compact UI
- Tightened CSS spacing for decoded messages (more inline, less padding)
- Improved "Show original" collapsible display (8px collapsed, 13px expanded for readability)

### Fixed
- Fixed non-breaking space corruption in decoding pipeline
- Fixed mixed mode producing incorrect stroke counts (binary data corruption from UTF-8)
- Fixed cockchain completion failures when FINAL message contains non-breaking spaces
- Fixed whitespace normalization applied consistently throughout decode pipeline

### Removed
- Removed all debug logging (`[FINDCOCKBLOCK]`, `[DECODE]`, emoji indicators)
- Removed unused `escapeHtml()` function
- Removed duplicate stroke parsing code in `parseMessageFlags()`
- Cleaned up ~150+ lines of debug code for production release

### Technical Details
- Whitespace normalization: `/[\s\u00A0]+/g` applied before cockblock detection
- Binary-safe destroke: Uses `String.fromCharCode()` instead of `TextDecoder` for base64
- Flag precedence: mixed (3) > wide (2) > thin (1) when multiple mode flags present
- All regex patterns audited for space/non-breaking space compatibility

## [1.0.0] - Initial Release

### Features
- Auto-decode incoming cocktographic messages in IRCCloud
- Floating encode button with keyboard shortcut (Ctrl+Shift+E)
- Configurable stroke count (0-10)
- Multiple chode modes: Thin (1 byte), Wide (2 bytes), Mixed (polymorphic)
- Purple gradient styling for decoded messages
- Collapsible "Show original" to view raw chodes
- Cockchain support for multi-message encoding
- Per-sender cockchain tracking with 60-second timeout
- Chrome and Firefox support
- Settings panel for configuration
