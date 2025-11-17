# Dotfiles

My personal development environment configuration for Zsh, Tmux, and Konsole.

## Contents

- **Zsh** - Shell configuration with Oh My Zsh, custom prompt, and useful plugins
- **Tmux** - Terminal multiplexer with vim-style keybindings and clean status bar
- **Konsole** - KDE terminal emulator profiles and settings

## Features

### Zsh Configuration

- **Oh My Zsh** framework with plugins:
  - `git` - Git aliases and functions
  - `fzf` - Fuzzy finder integration
  - `zsh-syntax-highlighting` - Command syntax highlighting
  - `zsh-autosuggestions` - Fish-like autosuggestions
- **Custom two-line prompt** with:
  - User and hostname
  - Git branch/commit indicator
  - Current directory
  - Conda environment indicator
- **Shell-GPT integration** (Ctrl-L) for AI-assisted shell commands
- **Enhanced history** (10,000 entries, shared across sessions)
- **Auto-CD** - Navigate directories without typing `cd`

### Tmux Configuration

- **Vim-style keybindings** for navigation and copy mode
- **Intuitive split commands**:
  - `prefix + -` - horizontal split
  - `prefix + _` - vertical split
- **Dual prefix support**: C-b (default) and C-a (GNU Screen compatibility)
- **Mouse support** enabled by default
- **10,000 line scrollback** history
- **Clean status bar** with session, date, and time
- **Optional battery indicator** for laptops
- **Clipboard integration** (works with X11, Wayland, macOS, WSL)

### Konsole Configuration

- **Breeze color scheme**
- **Custom window settings** and toolbar configuration
- Optimized for multi-monitor setups

## Quick Start

### One-Line Install

```bash
git clone https://github.com/yourusername/dotfiles.git ~/dotfiles && cd ~/dotfiles && ./setup.sh
```

### Manual Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

2. Run the setup script:
   ```bash
   ./setup.sh
   ```

3. Restart your terminal or source the config:
   ```bash
   source ~/.zshrc
   ```

## What the Setup Script Does

The `setup.sh` script automatically:

1. **Checks dependencies** (git, curl, zsh, tmux)
2. **Installs Oh My Zsh** if not already installed
3. **Installs Zsh plugins**:
   - zsh-syntax-highlighting
   - zsh-autosuggestions
4. **Creates symlinks** for all config files
5. **Backs up existing configs** with timestamps
6. **Handles Konsole configs** gracefully (skips if not on KDE)
7. **Suggests changing default shell** to zsh

The script is **idempotent** - you can run it multiple times safely.

## Manual Setup (Without Script)

If you prefer to set up manually:

```bash
# Zsh
ln -sf ~/dotfiles/zsh/.zshrc ~/.zshrc

# Tmux
ln -sf ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf

# Konsole (KDE only)
ln -sf ~/dotfiles/konsole/Default.profile ~/.local/share/konsole/Default.profile
ln -sf ~/dotfiles/konsole/konsolerc ~/.config/konsolerc
```

## Dependencies

### Required

- **git** - Version control
- **curl** - Downloading Oh My Zsh installer
- **zsh** - Shell (Ubuntu: `sudo apt install zsh`)

### Optional but Recommended

- **tmux** - Terminal multiplexer (`sudo apt install tmux`)
- **fzf** - Fuzzy finder (`sudo apt install fzf`)
- **konsole** - KDE terminal emulator (KDE systems only)
- **xclip** or **wl-copy** - Clipboard integration for tmux

### Zsh Plugin Dependencies

These are installed automatically by the setup script:
- zsh-syntax-highlighting
- zsh-autosuggestions

## Customization

### Zsh

Edit `zsh/.zshrc` to customize:
- Line 11: Change theme (`ZSH_THEME`)
- Line 73: Add/remove Oh My Zsh plugins
- Lines 150-169: Customize prompt colors and format
- Lines 132-133: Modify PATH

### Tmux

Edit `tmux/.tmux.conf` to customize:
- Lines 70-88: Status bar styling and colors
- Lines 148-149: Split pane keybindings
- Lines 152-155: Pane navigation keys
- Lines 77-80: Enable battery indicator (laptops only)

### Konsole

Edit profiles directly in Konsole's settings GUI or modify:
- `konsole/Default.profile` - Color scheme, fonts, etc.
- `konsole/konsolerc` - Window settings

## Tmux Quick Reference

### Session Management
- `prefix + C-c` - New session
- `prefix + C-f` - Find session
- `prefix + BTab` - Last session

### Window Management
- `prefix + C-h/C-l` - Previous/next window
- `prefix + Tab` - Last window
- `prefix + C-S-H/L` - Swap window left/right

### Pane Management
- `prefix + -` - Split horizontal
- `prefix + _` - Split vertical
- `prefix + h/j/k/l` - Navigate panes (vim-style)
- `prefix + H/J/K/L` - Resize panes (vim-style)
- `prefix + z` - Toggle zoom

### Copy Mode
- `prefix + Enter` - Enter copy mode
- `v` - Begin selection
- `y` - Copy selection (to system clipboard)
- `Escape` - Exit copy mode

### Other
- `prefix + r` - Reload config
- `prefix + ?` - Show all keybindings

## Platform Support

- **Linux** (tested on Ubuntu/Debian, should work on Fedora/Arch)
- **macOS** (clipboard and Oh My Zsh work out of the box)
- **WSL** (Windows Subsystem for Linux)

**Note:** Konsole configs only apply to KDE desktop environments.

## Troubleshooting

### Zsh plugins not working

Make sure Oh My Zsh is installed and plugins are in the correct directory:
```bash
ls ~/.oh-my-zsh/custom/plugins/
```

Re-run the setup script if needed: `./setup.sh`

### Tmux clipboard not working

Install clipboard tools:
- **X11:** `sudo apt install xclip`
- **Wayland:** `sudo apt install wl-clipboard`
- **macOS:** Built-in (pbcopy)

### Shell not changing to zsh

Run manually:
```bash
chsh -s $(which zsh)
```

Then log out and back in.

## License

Free to use and modify. No warranty provided.

## Credits

- [Oh My Zsh](https://ohmyz.sh/) - Zsh framework
- [gpakosz/.tmux](https://github.com/gpakosz/.tmux) - Inspiration for tmux config
