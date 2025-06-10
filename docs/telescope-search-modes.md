# 🔍 Telescope Search Modes

Your telescope live grep now supports both literal and regex search modes to solve the special character escaping issue.

## 🎯 **SEARCH KEYMAPS**

### **Literal Search (No Escaping Needed)**
```
<D-S-f>       │ Live grep with literal search (normal mode)
<D-S-f>       │ Search selected text literally (visual mode)
<leader>fs    │ Find string in cwd (literal search)
```

### **Regex Search (For Advanced Patterns)**
```
<D-A-S-f>     │ Live grep with regex search (normal mode)
<D-A-S-f>     │ Search selected text with regex (visual mode)
<leader>fS    │ Find string in cwd (regex search)
```

## ✨ **WHAT'S FIXED**

- **No more escaping**: Characters like `(`, `)`, `[`, `]`, `{`, `}`, `^`, `$` are treated literally
- **Default behavior**: `<D-S-f>` now uses literal search by default
- **Fallback option**: Use `<D-A-S-f>` when you need regex patterns
- **Consistent experience**: Both normal and visual mode selections work seamlessly

## 🚀 **USAGE EXAMPLES**

### Before (Required Escaping)
```
Search: function(param)  → Had to type: function\(param\)
Search: [config]         → Had to type: \[config\]
```

### After (No Escaping)
```
Search: function(param)  → Just type: function(param)
Search: [config]         → Just type: [config]
```

## 📝 **NOTES**

- Literal search uses ripgrep's `--fixed-strings` flag
- Regex search maintains full ripgrep regex functionality
- Selected text in visual mode automatically works with both modes
- The prompt title shows which search mode you're using
