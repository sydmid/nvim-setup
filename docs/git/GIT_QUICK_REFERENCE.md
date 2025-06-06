# 🎯 GIT WORKFLOW QUICK REFERENCE

## 🚀 **ESSENTIAL KEYMAPS**

### **Daily Operations**
```
<leader>gs  │ Git Status (Neogit)
<leader>gc  │ Git Commit
<leader>gp  │ Git Push
<leader>gd  │ Git Diff (Diffview)
<leader>gg  │ LazyGit (Full TUI)
```

### **Hunk Operations (Gitsigns)**
```
<leader>hj  │ Next Hunk
<leader>hk  │ Previous Hunk
<leader>hs  │ Stage Hunk
<leader>hr  │ Reset Hunk
<leader>hp  │ Preview Hunk
<leader>hb  │ Blame Line
```

### **Telescope Git Pickers**
```
<leader>gB  │ Git Branches (Checkout/Delete)
<leader>gC  │ Git Commits (View/Reset)
<leader>gS  │ Git Status Files (Stage/Unstage)
<leader>gT  │ Git Stashes (Apply/Drop)
<leader>gF  │ Browse Files in Commit
<leader>gf  │ Git Blame Current File
<leader>gR  │ Git Remotes (Fetch/Push)
<leader>gt  │ Create Git Stash
```

### **File History & Diff**
```
<leader>gh  │ Git File History
<leader>gH  │ Current File History
<leader>gm  │ Git Diff HEAD~1
<leader>gM  │ Git Diff Staged
<leader>gq  │ Close Diffview
```

## ⚡ **WORKFLOW PATTERNS**

### **Quick Commit**
```
<leader>hs → <leader>gc → <leader>gp
(Stage hunk → Commit → Push)
```

### **Review Changes**
```
<leader>gd → <leader>gS → <leader>gC
(View diff → Check status → Browse commits)
```

### **Branch Work**
```
<leader>gB → <leader>gt → <leader>gg
(Switch branch → Stash changes → Complex operations)
```

### **Code Investigation**
```
<leader>gf → <leader>gh → <leader>gF
(Blame file → File history → Browse commits)
```

## 🎨 **TELESCOPE SHORTCUTS**

### **In Git Branches (`<leader>gB`)**
- `Enter` → Checkout branch
- `Ctrl+D` → Delete branch

### **In Git Commits (`<leader>gC`)**
- `Enter` → View in Diffview
- `Ctrl+R` → Reset to commit

### **In Git Status (`<leader>gS`)**
- `Enter` → Open file
- `Ctrl+S` → Stage file
- `Ctrl+U` → Unstage file

### **In Git Stashes (`<leader>gT`)**
- `Enter` → Apply stash
- `Ctrl+D` → Drop stash

### **In Git Remotes (`<leader>gR`)**
- `Enter` → Fetch from remote
- `Ctrl+P` → Push to remote

## 🌟 **PRO TIPS**

1. **Start with `<leader>gs`** - Always check status first
2. **Use `<leader>hj/hk`** for quick hunk navigation while coding
3. **`<leader>gd`** shows all changes beautifully in Diffview
4. **`<leader>gg`** for complex operations or learning
5. **All pickers support `Esc`** to close instantly
6. **Combine tools** - e.g., telescope to find, diffview to review
7. **`<leader>gf`** for blame + jump to commit in one step

## 🎯 **WORKFLOW LEVELS**

| Level | Tools | When to Use |
|-------|--------|-------------|
| **Quick** | Gitsigns | While coding, small changes |
| **Normal** | Neogit + Telescope | Regular Git operations |
| **Advanced** | Diffview | Code review, merge conflicts |
| **Expert** | LazyGit | Complex operations, learning |

**Remember: Use leader keys `<leader>g*` and `<leader>h*` for all Git operations - no delays, pure speed!** ⚡
