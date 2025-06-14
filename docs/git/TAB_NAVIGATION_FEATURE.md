# 🔄 Tab Navigation for Telescope Git Log Explorer

## ✨ **NEW FEATURE: Enhanced `<leader>gl` with Tab Navigation**

The telescope container that opens with `<leader>gl` now supports seamless Tab navigation between the results list and preview window.

## 🎯 **How It Works**

### **1. Git Log Explorer (`<leader>gl`)**
- Press `<leader>gl` to open the enhanced git log explorer
- **Press `Tab`** to move focus from results list to preview window
- **Press `Tab` again** to return to results list
- Navigate through commits and see live previews

### **2. File Browser (After selecting a commit)**
- Select a commit and press `Enter` to browse files in that commit
- **Press `Tab`** to move focus between file list and file preview
- **Press `Tab` again** to return to file list
- Use `Ctrl+D` to diff any file against current version

## 🚀 **Workflow Example**

```bash
# 1. Open enhanced git log
<leader>gl

# 2. Browse commits (use j/k or arrow keys)
j j j  # Move down through commits

# 3. Switch to preview to read commit details
<Tab>  # Focus preview window
j j j  # Scroll through commit message and changes

# 4. Switch back to results to select different commit
<Tab>  # Focus results list
k k k  # Move to different commit

# 5. Select commit to browse its files
<Enter>  # Opens file browser for that commit

# 6. Browse files in the commit
j j j  # Navigate through files

# 7. Switch to preview to see file content
<Tab>  # Focus preview window
j j j  # Scroll through file content

# 8. Switch back to file list
<Tab>  # Focus file list

# 9. Diff a file against current version
<Ctrl+D>  # Shows diff of selected file
```

## 🎨 **Visual Experience**

- **Seamless Focus Switching**: No jarring transitions
- **Consistent Navigation**: Same Tab behavior in both commit log and file browser
- **Enhanced Exploration**: Perfect for code archaeology and understanding changes
- **Keyboard-First**: Never need to touch the mouse

## 🔧 **Technical Implementation**

The feature uses Telescope's internal API to:
1. Get the current picker instance
2. Extract the prompt window and preview window IDs
3. Set up bidirectional Tab key mappings
4. Handle focus switching without disrupting picker state

## 💡 **Pro Tips**

1. **Use Tab liberally** - It's designed for frequent switching
2. **Combine with j/k navigation** - Tab to switch focus, j/k to navigate within
3. **Great for code reviews** - Browse commits, Tab to preview, find interesting changes
4. **Perfect for debugging** - Follow the history of a bug through commits and files

## 🎯 **Integration**

This feature works seamlessly with all existing git workflow tools:
- **Gitsigns**: For quick hunk operations
- **Neogit**: For comprehensive git interface
- **Diffview**: For detailed diff viewing
- **LazyGit**: For complex operations

**The enhanced `<leader>gl` with Tab navigation makes git log exploration a first-class citizen in your Neovim workflow!** 🌟
