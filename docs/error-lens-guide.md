# 🔍 Error Lens - ThePrimeagen Style

Beautiful inline error display for Neovim, inspired by VS Code's Error Lens extension and ThePrimeagen's minimalist approach to IDE functionality.

## ✨ Features

- **🎯 Inline Diagnostics**: Shows LSP errors, warnings, hints, and info directly in your code
- **🎨 Theme Integration**: Seamlessly matches your no-clown-fiesta color scheme
- **⚡ Performance**: Throttled updates and smart buffer management
- **🔧 Customizable**: Easy to toggle on/off and configure
- **📚 LSP Integration**: Works with all your existing LSP servers
- **🚀 ThePrimeagen Style**: Minimal, efficient, and gets out of your way

## 🎮 Key Mappings

### Error Lens Controls
- `<leader>el` - Toggle Error Lens on/off
- `<leader>ee` - Enable Error Lens
- `<leader>ed` - Disable Error Lens
- `<leader>er` - Refresh Error Lens for current buffer

### Enhanced Diagnostic Navigation
- `<leader>en` - Next diagnostic (with Error Lens sync)
- `<leader>ep` - Previous diagnostic (with Error Lens sync)
- `<D-]>` - Next diagnostic (Cmd+] with Error Lens sync)
- `<D-[>` - Previous diagnostic (Cmd+[ with Error Lens sync)

## 💻 Commands

- `:ErrorLensToggle` - Toggle Error Lens functionality
- `:ErrorLensEnable` - Enable Error Lens
- `:ErrorLensDisable` - Disable Error Lens
- `:ErrorLensRefresh` - Refresh current buffer
- `:ErrorLensStatus` - Show current status

## 🎨 Visual Design

The Error Lens uses your existing theme colors:

- **🔴 Errors**: `#b46958` (Red) with `■` prefix
- **🟡 Warnings**: `#F4BF75` (Yellow) with `▲` prefix
- **🔵 Info**: `#BAD7FF` (Blue) with `●` prefix
- **🟢 Hints**: `#88afa2` (Cyan) with `◆` prefix

## 🔧 Configuration

The Error Lens is designed to work out of the box with sensible defaults that match ThePrimeagen's philosophy of minimal configuration. However, you can customize it by modifying the config in `lua/plugins/error-lens.lua`.

### Default Settings

```lua
M.config = {
  enabled = true,
  auto_adjust = true,
  throttle_ms = 50,

  format = {
    max_width = 80,
    wrap_text = true,
    spacing = 2,          -- spaces between code and diagnostic
    right_align = false,  -- ThePrimeagen style: left-aligned
  }
}
```

## 🚀 Integration

### LSP Saga Integration
The Error Lens works seamlessly with your existing LSP Saga setup:
- Floating diagnostics remain unchanged
- Diagnostic navigation is enhanced with Error Lens sync
- No conflicts with existing diagnostic UI

### Performance
- **Throttled Updates**: 50ms throttling prevents excessive redraws
- **Smart Buffer Detection**: Automatically excludes special buffers
- **Lazy Loading**: Only activates when LSP is attached
- **Memory Efficient**: Proper cleanup on buffer changes

## 🎯 ThePrimeagen Philosophy

This implementation follows ThePrimeagen's core principles:

1. **Minimal Configuration**: Works great out of the box
2. **Performance First**: Optimized for speed and responsiveness
3. **Visual Clarity**: Clear, concise error display without clutter
4. **Keyboard Driven**: All functionality accessible via keymaps
5. **Integration Focused**: Enhances existing tools rather than replacing them

## 🔄 Architecture Integration

Your Error Lens integrates perfectly with your existing Neovim configuration:

- **Mason**: Auto-installs LSP servers that provide diagnostics
- **LSP Config**: Enhanced diagnostic configuration with Error Lens support
- **LSP Saga**: Complementary floating diagnostics for detailed views
- **Telescope**: Buffer diagnostics with enhanced navigation
- **Which-Key**: All keymaps properly documented and discoverable

## 🎪 Demo

When enabled, you'll see inline diagnostics like this:

```typescript
function example() {
  let unused = "variable";     ■ Variable 'unused' is declared but never used
  console.log(missing);        ■ Cannot find name 'missing'
  return 42;                   ▲ Function lacks return type annotation
}
```

The diagnostics appear inline with your code, using subtle styling that doesn't interfere with your coding flow - exactly the way ThePrimeagen would want it!

---

*"The best tools are the ones that get out of your way and let you focus on what matters: writing great code."* - Inspired by ThePrimeagen's philosophy
