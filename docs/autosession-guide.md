# AutoSession Plugin - Usage Guide

## Overview
AutoSession provides seamless automatic session management for your Neovim configuration. It automatically saves and restores your workspace state including open buffers, window layouts, and working directories.

## Key Features
- 🔄 **Automatic session save/restore** - No manual intervention needed
- 📂 **Git branch awareness** - Sessions include branch names for better organization
- 🎯 **Intelligent directory filtering** - Avoids sessions in temporary directories
- 🔍 **Telescope integration** - Beautiful session picker with search
- ⚡ **Smart argument handling** - Works correctly when opening files or directories
- 🛡️ **Error recovery** - Continues working even if session restore encounters issues

## Keybindings

### Primary Session Commands (Workspace prefix)
| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ws` | `:SessionSave` | Save current session |
| `<leader>wr` | `:SessionRestore` | Restore session for current directory |
| `<leader>wR` | `:SessionSearch` | Open Telescope session picker |
| `<leader>wd` | `:SessionDelete` | Delete current session |
| `<leader>wS` | `:SessionSave {name}` | Save session with custom name |
| `<leader>wD` | `:SessionDelete {name}` | Delete specific session |
| `<leader>wt` | `:SessionToggleAutoSave` | Toggle automatic saving on/off |
| `<leader>wp` | `:SessionPurgeOrphaned` | Clean up orphaned sessions |

### Alternative Session Commands (Session prefix)
| Key | Command | Description |
|-----|---------|-------------|
| `<leader>ss` | `:SessionSave` | Save current session (alias) |
| `<leader>sr` | `:SessionRestore` | Restore session (alias) |
| `<leader>sf` | `:SessionSearch` | Find session with Telescope (alias) |

## How It Works

### Automatic Behavior
1. **On Startup**: AutoSession automatically restores the last session for your current working directory
2. **On Exit**: Automatically saves your current session (buffers, windows, tabs, etc.)
3. **Directory Changes**: Optionally handles changing directories within Neovim

### Session Storage
- Sessions are stored in: `~/.local/share/nvim/sessions/`
- Session names include git branch when available (e.g., `project-main.vim`)
- Control files are stored in: `~/.local/share/nvim/auto_session/`

### Intelligent Filtering
AutoSession won't create sessions in these directories:
- `~/` (Home directory)
- `~/Projects` `~/Downloads` `~/Desktop` `~/Documents`
- `/tmp` `/` `/Users`

This prevents cluttering your session list with temporary or system directories.

## Workflow Examples

### Basic Project Workflow
```bash
# 1. Navigate to your project
cd ~/my-project

# 2. Start Neovim
nvim

# 3. Work on your project (open files, split windows, etc.)
# AutoSession automatically saves when you exit

# 4. Next time you open Neovim in this directory, everything is restored!
```

### Session Management Workflow
```vim
" Save current work as a specific session
:SessionSave feature-branch-work

" List and switch between sessions
<leader>wR  " Opens Telescope picker

" Restore a specific session
:SessionRestore feature-branch-work

" Clean up old sessions
<leader>wp  " Purge orphaned sessions
```

### Git Branch Integration
When working with git, AutoSession automatically includes the branch name:
```bash
# On main branch
cd ~/my-project
nvim  # Creates session: my-project-main.vim

# Switch branches
git checkout feature-xyz
nvim  # Creates session: my-project-feature-xyz.vim
```

## Session Picker (Telescope)
Use `<leader>wR` to open the session picker with these features:
- **Search**: Type to filter sessions by name
- **Preview**: See session details
- **Actions**:
  - `<Enter>`: Load session
  - `<C-D>`: Delete session
  - `<C-S>`: Switch to previous session
  - `<C-Y>`: Copy session
  - `<Esc>` or `q`: Close picker

## Advanced Configuration

### Smart File Arguments
AutoSession handles command-line arguments intelligently:
- `nvim` - Restores session for current directory
- `nvim .` - Restores session for current directory
- `nvim file.txt` - Opens file, no session restore (but can save on exit if multiple buffers)
- `nvim dir/` - Restores session for that directory

### Integration with Other Plugins
AutoSession is configured to work seamlessly with:
- **Oil.nvim**: Automatically closes before saving sessions
- **Telescope**: Beautiful session picker interface
- **Which-Key**: Proper key binding descriptions
- **Lualine**: Status line integration (optional)

### Suppressed File Types
Sessions won't include these buffer types:
- `alpha`, `dashboard` - Start screens
- `gitcommit`, `gitrebase` - Git operations
- `help` - Help windows
- `lazy`, `mason` - Plugin managers
- `oil`, `NvimTree`, `neo-tree` - File explorers
- `terminal`, `toggleterm` - Terminal windows
- `TelescopePrompt`, `trouble` - Popup interfaces

## Troubleshooting

### Session Won't Restore
1. Check if you're in a suppressed directory (home, downloads, etc.)
2. Verify session exists: `:SessionSearch`
3. Check for errors: `:checkhealth auto-session`

### Session Contains Unwanted Buffers
AutoSession automatically filters out temporary and auxiliary buffers. If you're still seeing unwanted content, check the `bypass_save_filetypes` configuration.

### Performance Issues
- Large sessions can take time to restore
- Use `:SessionPurgeOrphaned` to clean up old sessions
- Consider using `suppressed_dirs` for directories with many temporary files

## Tips and Best Practices

### Project Organization
- Use one session per project/branch combination
- Let AutoSession handle naming automatically for branch-based work
- Use custom names (`<leader>wS`) for experimental or temporary work

### Workflow Optimization
- Use `<leader>wR` to quickly switch between projects
- Set up project-specific sessions with `:SessionSave project-name`
- Clean up old sessions regularly with `<leader>wp`

### Integration with Terminal Workflow
AutoSession works great with your terminal management system:
1. Start project session
2. Use terminal shortcuts (`<leader>t1`, `<leader>t2`, etc.) to launch services
3. Session automatically includes terminal states

## Status and Notifications
AutoSession provides helpful notifications:
- 💾 "Session saved: {name}" - When session is saved
- 🔄 "Session restored: {name}" - When session is restored
- 🗑️ "Session deleted: {name}" - When session is deleted
- ⚠️ "Auto-save disabled" - When auto-save encounters errors

## Commands Reference
| Command | Description |
|---------|-------------|
| `:SessionSave [name]` | Save session (optional custom name) |
| `:SessionRestore [name]` | Restore session (optional specific session) |
| `:SessionDelete [name]` | Delete session (optional specific session) |
| `:SessionSearch` | Open Telescope session picker |
| `:SessionToggleAutoSave` | Toggle automatic saving |
| `:SessionDisableAutoSave` | Disable auto-save |
| `:SessionPurgeOrphaned` | Remove orphaned sessions |

---

AutoSession integrates seamlessly with your existing Neovim workflow, providing powerful session management without getting in your way. The combination of automatic behavior and manual controls gives you the best of both worlds.
