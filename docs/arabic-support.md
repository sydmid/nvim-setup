# Arabic Language Support in Neovim

This integration provides Arabic language support for Neovim, including right-to-left text direction, Arabic shaping, and keyboard mapping.

## Features

- Right-to-left text direction for Arabic content
- Arabic character shaping and combining
- Arabic keyboard mapping (Microsoft Arabic keyboard layout)
- Commands for toggling Arabic mode
- Support for UTF-8 encoding

## Usage

### Commands

- `:Arabic` - Enable Arabic mode (sets encoding, RTL, keyboard mapping)
- `:NoArabic` - Disable Arabic mode
- `:ArabicToggle` - Toggle Arabic mode on/off

### Keyboard Shortcuts

- `<leader>ar` - Toggle Arabic mode on/off
- `CTRL-^` in insert mode - Toggle Arabic keyboard mapping

### Arabic Keyboard Layout

The keyboard mapping follows the Microsoft Arabic keyboard layout, which is the de facto standard in the Arab world.

## Requirements

- UTF-8 compatible terminal
- Arabic fonts that support both ISO-8859-6 (U+0600-U+06FF) and Presentation Form-B (U+FE70-U+FEFF)

## Notes

- For Bidirectional text support, set `'termbidi'` if your terminal supports it
- Numbers in Arabic mode are entered from left to right

## Known Limitations

- If you insert a haraka (e.g., Fatha) between LAM and ALEF, the appropriate combining will not occur
- Terminal emulators may have varying levels of Arabic text rendering support