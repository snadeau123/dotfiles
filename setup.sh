#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════════════════
# Dotfiles Setup Script
# ═══════════════════════════════════════════════════════════════════════════
#
# This script sets up development environment configs:
# - Zsh with Oh My Zsh and plugins
# - Tmux configuration
# - Konsole profiles (KDE only)
#
# Usage: ./setup.sh
#
# ═══════════════════════════════════════════════════════════════════════════

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory (where this script lives)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ───────────────────────────────────────────────────────────────────────────
# Helper Functions
# ───────────────────────────────────────────────────────────────────────────

print_header() {
    echo -e "\n${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════════════════════${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}→${NC} $1"
}

backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$file" "$backup"
        print_warning "Backed up existing file: $file → $backup"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"

    # Create target directory if it doesn't exist
    mkdir -p "$(dirname "$target")"

    # Backup existing file if it exists and isn't a symlink
    backup_file "$target"

    # Remove existing symlink if it exists
    [ -L "$target" ] && rm "$target"

    # Create symlink
    ln -sf "$source" "$target"
    print_success "Linked: $target → $source"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ───────────────────────────────────────────────────────────────────────────
# Installation Functions
# ───────────────────────────────────────────────────────────────────────────

install_oh_my_zsh() {
    print_header "Installing Oh My Zsh"

    # Check if Oh My Zsh is properly installed (not just the directory)
    if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
        print_success "Oh My Zsh already installed"
        return 0
    fi

    # If directory exists but oh-my-zsh.sh doesn't, installation is corrupted
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Incomplete Oh My Zsh installation detected, removing..."
        rm -rf "$HOME/.oh-my-zsh"
    fi

    print_info "Installing Oh My Zsh..."

    # Install oh-my-zsh (unattended)
    if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        if [ -d "$HOME/.oh-my-zsh" ]; then
            print_success "Oh My Zsh installed successfully"
        else
            print_error "Oh My Zsh installation failed - directory not created"
            return 1
        fi
    else
        print_error "Oh My Zsh installation failed - please check your internet connection"
        return 1
    fi
}

install_zsh_plugins() {
    print_header "Installing Zsh Plugins"

    local ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

    # zsh-syntax-highlighting
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
        print_info "Installing zsh-syntax-highlighting..."
        if git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" 2>&1; then
            print_success "zsh-syntax-highlighting installed"
        else
            print_error "Failed to install zsh-syntax-highlighting"
            return 1
        fi
    else
        print_success "zsh-syntax-highlighting already installed"
    fi

    # zsh-autosuggestions
    if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
        print_info "Installing zsh-autosuggestions..."
        if git clone https://github.com/zsh-users/zsh-autosuggestions.git \
            "$ZSH_CUSTOM/plugins/zsh-autosuggestions" 2>&1; then
            print_success "zsh-autosuggestions installed"
        else
            print_error "Failed to install zsh-autosuggestions"
            return 1
        fi
    else
        print_success "zsh-autosuggestions already installed"
    fi
}

setup_zsh() {
    print_header "Setting Up Zsh Configuration"

    # Check if zsh is installed
    if ! command_exists zsh; then
        print_warning "Zsh not found. Please install zsh first:"
        print_info "  Ubuntu/Debian: sudo apt install zsh"
        print_info "  Fedora: sudo dnf install zsh"
        print_info "  macOS: brew install zsh"
        return 1
    fi

    # Install oh-my-zsh
    install_oh_my_zsh

    # Install plugins
    install_zsh_plugins

    # Link zshrc
    create_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"

    # Set zsh as default shell if not already
    local current_shell=$(getent passwd "$USER" | cut -d: -f7)
    local zsh_path=$(which zsh)

    if [ "$current_shell" != "$zsh_path" ]; then
        print_info "Changing default shell to zsh..."
        print_warning "You may need to enter your password"
        if chsh -s "$zsh_path"; then
            print_success "Default shell changed to zsh"
            print_warning "You must LOG OUT and LOG BACK IN for this to take effect!"
        else
            print_error "Failed to change shell. Run manually: chsh -s $zsh_path"
            return 1
        fi
    else
        print_success "Default shell is already zsh"
    fi

    print_success "Zsh setup complete"
}

setup_env() {
    print_header "Setting Up Environment Variables"

    local env_file="$HOME/.dotfiles.env"
    local template_file="$DOTFILES_DIR/zsh/.env.example"

    if [ -f "$env_file" ]; then
        print_success "Environment file already exists: $env_file"
        return 0
    fi

    print_info "Some features require API keys stored in ~/.dotfiles.env"
    print_info "This file is NOT committed to git for security."

    echo ""
    read -p "Do you want to set up environment variables now? (y/N) " -n 1 -r
    echo ""

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Copy template
        cp "$template_file" "$env_file"

        # Ask for OpenRouter API key
        echo ""
        print_info "Enter your OpenRouter API key (or press Enter to skip):"
        read -r api_key

        if [ -n "$api_key" ]; then
            sed -i "s|your-api-key-here|$api_key|" "$env_file"
            print_success "OpenRouter API key saved to $env_file"
        else
            print_warning "Skipped - edit $env_file later to add your OpenRouter API key"
        fi

        # Ask for Cerebras API key
        echo ""
        print_info "Enter your Cerebras API key (or press Enter to skip):"
        read -r cerebras_key

        if [ -n "$cerebras_key" ]; then
            sed -i "s|your-cerebras-api-key-here|$cerebras_key|" "$env_file"
            print_success "Cerebras API key saved to $env_file"
        else
            print_warning "Skipped - edit $env_file later to add your Cerebras API key"
        fi

        # Secure the file permissions
        chmod 600 "$env_file"
        print_success "Set secure permissions (600) on $env_file"
    else
        print_warning "Skipped environment setup"
        print_info "To set up later, copy zsh/.env.example to ~/.dotfiles.env"
    fi
}

setup_tmux() {
    print_header "Setting Up Tmux Configuration"

    # Check if tmux is installed
    if ! command_exists tmux; then
        print_warning "Tmux not found. Please install tmux first:"
        print_info "  Ubuntu/Debian: sudo apt install tmux"
        print_info "  Fedora: sudo dnf install tmux"
        print_info "  macOS: brew install tmux"
        return 1
    fi

    # Link tmux.conf
    create_symlink "$DOTFILES_DIR/tmux/.tmux.conf" "$HOME/.tmux.conf"

    print_success "Tmux setup complete"
}

setup_claude_code_router() {
    print_header "Setting Up Claude Code Router"

    # Check if npm is installed
    if ! command_exists npm; then
        print_warning "npm not found - skipping claude-code-router installation"
        print_info "Install Node.js/npm first, then run: npm install -g @musistudio/claude-code-router"
        return 0
    fi

    # Check if ccr is already installed
    if command_exists ccr; then
        print_success "claude-code-router already installed"
    else
        print_info "Installing claude-code-router..."
        if npm install -g @musistudio/claude-code-router; then
            print_success "claude-code-router installed"
        else
            print_error "Failed to install claude-code-router"
            print_info "Try manually: npm install -g @musistudio/claude-code-router"
            return 1
        fi
    fi

    # Create config directory
    local config_dir="$HOME/.claude-code-router"
    local config_file="$config_dir/config.json"
    local transformer_file="$config_dir/cerebras-transformer.js"

    mkdir -p "$config_dir"

    # Link the custom Cerebras transformer
    create_symlink "$DOTFILES_DIR/claude-code-router/cerebras-transformer.js" "$transformer_file"

    # Create config file if it doesn't exist
    if [ -f "$config_file" ]; then
        print_success "Config file already exists: $config_file"
    else
        print_info "Creating claude-code-router config..."
        # Use $HOME expansion for the transformer path
        cat > "$config_file" << EOF
{
  "LOG": false,
  "LOG_LEVEL": "debug",
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "API_TIMEOUT_MS": "600000",
  "transformers": [
    {
      "path": "$HOME/.claude-code-router/cerebras-transformer.js"
    }
  ],
  "Providers": [
    {
      "name": "cerebras",
      "api_base_url": "https://api.cerebras.ai/v1/chat/completions",
      "api_key": "\${CEREBRAS_API_KEY}",
      "models": [
        "zai-glm-4.7"
      ],
      "transformer": {
        "use": ["cerebras", "maxtoken", {"max_tokens": 120000}]
      }
    }
  ],
  "Router": {
    "default": "cerebras,zai-glm-4.7",
    "background": "cerebras,zai-glm-4.7",
    "think": "cerebras,zai-glm-4.7",
    "longContext": "",
    "longContextThreshold": 50000,
    "webSearch": "",
    "image": ""
  }
}
EOF
        print_success "Created config: $config_file"
    fi

    print_success "Claude Code Router setup complete"
    print_info "Use 'claude-glm-cb' alias to run Claude Code via Cerebras"
}

setup_claude_code() {
    print_header "Setting Up Claude Code"

    local claude_dir="$HOME/.claude"
    mkdir -p "$claude_dir"

    # Link statusline script
    create_symlink "$DOTFILES_DIR/claude/statusline.sh" "$claude_dir/statusline.sh"

    # Add statusLine config to settings.json
    local settings_file="$claude_dir/settings.json"

    if [ -f "$settings_file" ]; then
        # Check if statusLine is already configured
        if jq -e '.statusLine' "$settings_file" >/dev/null 2>&1; then
            print_success "statusLine already configured in settings.json"
        else
            # Merge statusLine into existing settings
            local tmp_file
            tmp_file=$(mktemp)
            jq '. + {"statusLine": {"type": "command", "command": "~/.claude/statusline.sh"}}' "$settings_file" > "$tmp_file" && mv "$tmp_file" "$settings_file"
            print_success "Added statusLine config to existing settings.json"
        fi
    else
        # Create new settings.json with statusLine
        cat > "$settings_file" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
EOF
        print_success "Created settings.json with statusLine config"
    fi

    print_success "Claude Code setup complete"
    print_info "Status bar shows: session name | git branch | context usage | model | directory"
}

setup_cli_ai() {
    print_header "Setting Up CLI AI"

    # Check if pipx is installed
    if ! command_exists pipx; then
        print_warning "pipx not found - skipping cli-ai installation"
        print_info "Install pipx first: pip install --user pipx"
        return 0
    fi

    # Clone or update the repo
    local cli_ai_dir="$HOME/Projects/cli_ai"
    if [ -d "$cli_ai_dir" ]; then
        print_success "cli-ai repo already exists at $cli_ai_dir"
    else
        print_info "Cloning cli-ai..."
        mkdir -p "$HOME/Projects"
        if git clone https://github.com/snadeau123/cli-ai.git "$cli_ai_dir"; then
            print_success "cli-ai cloned to $cli_ai_dir"
        else
            print_error "Failed to clone cli-ai"
            return 1
        fi
    fi

    # Install via pipx
    print_info "Installing cli-ai via pipx..."
    if pipx install --force "$cli_ai_dir" 2>&1 | tail -1; then
        print_success "cli-ai installed via pipx"
    else
        print_error "Failed to install cli-ai"
        return 1
    fi

    # Link config file
    local config_dir="$HOME/.config/cli-ai"
    mkdir -p "$config_dir"
    create_symlink "$DOTFILES_DIR/cli-ai/config.toml" "$config_dir/config.toml"

    print_success "CLI AI setup complete"
    print_info "Use Alt+L in zsh to translate natural language to shell commands"
}

setup_konsole() {
    print_header "Setting Up Konsole Configuration"

    # Check if we're on a system with Konsole
    if ! command_exists konsole; then
        print_warning "Konsole not found - skipping Konsole configuration"
        print_info "This is normal if you're not on KDE or connecting via SSH"
        return 0
    fi

    # Create konsole directories if they don't exist
    mkdir -p "$HOME/.local/share/konsole"
    mkdir -p "$HOME/.config"

    # Link Konsole profile
    create_symlink "$DOTFILES_DIR/konsole/Default.profile" \
        "$HOME/.local/share/konsole/Default.profile"

    # Link custom Breeze color scheme
    create_symlink "$DOTFILES_DIR/konsole/Breeze.colorscheme" \
        "$HOME/.local/share/konsole/Breeze.colorscheme"

    # Link konsolerc
    create_symlink "$DOTFILES_DIR/konsole/konsolerc" \
        "$HOME/.config/konsolerc"

    print_success "Konsole setup complete"
}

check_dependencies() {
    print_header "Checking Dependencies"

    local missing_deps=()

    # Essential tools
    command_exists git || missing_deps+=("git")
    command_exists curl || missing_deps+=("curl")

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies: ${missing_deps[*]}"
        print_info "Please install them first:"
        print_info "  Ubuntu/Debian: sudo apt install ${missing_deps[*]}"
        print_info "  Fedora: sudo dnf install ${missing_deps[*]}"
        print_info "  macOS: brew install ${missing_deps[*]}"
        return 1
    fi

    print_success "All required dependencies found"
}

print_post_install() {
    print_header "Setup Complete!"

    echo -e "${GREEN}Your dotfiles have been installed successfully!${NC}\n"

    echo -e "${BLUE}IMPORTANT - Next steps:${NC}"
    echo -e "  1. ${YELLOW}LOG OUT and LOG BACK IN${NC} to activate zsh as default shell"
    echo -e "  2. After logging back in, tmux will automatically use zsh"

    if command_exists konsole; then
        echo -e "  3. Konsole will open with zsh and your custom profile"
    fi

    echo -e "\n${BLUE}Or to test now without logging out:${NC}"
    echo -e "  ${YELLOW}exec zsh${NC}  # Start a zsh session immediately"

    echo -e "\n${BLUE}Optional dependencies you might want:${NC}"

    if ! command_exists fzf; then
        echo -e "  • fzf (fuzzy finder): ${YELLOW}sudo apt install fzf${NC} or ${YELLOW}brew install fzf${NC}"
    fi

    if ! command_exists tmux; then
        echo -e "  • tmux (terminal multiplexer): ${YELLOW}sudo apt install tmux${NC} or ${YELLOW}brew install tmux${NC}"
    fi

    if [ ! -f "$HOME/.dotfiles.env" ]; then
        echo -e "\n${BLUE}API Keys:${NC}"
        echo -e "  To use claude-* aliases, create ~/.dotfiles.env:"
        echo -e "  ${YELLOW}cp $DOTFILES_DIR/zsh/.env.example ~/.dotfiles.env${NC}"
        echo -e "  Then edit it to add your API keys:"
        echo -e "    • OPENROUTER_API_KEY - for claude-glm, claude-mm, etc."
        echo -e "    • CEREBRAS_API_KEY   - for claude-glm-cb (Cerebras)"
        echo -e "    • GROQ_API_KEY       - for cli-ai (Alt+L shell commands)"
    fi

    echo -e "\n${GREEN}Happy coding!${NC}\n"
}

# ───────────────────────────────────────────────────────────────────────────
# Main Installation Flow
# ───────────────────────────────────────────────────────────────────────────

main() {
    print_header "Dotfiles Setup"
    echo -e "This will install and configure:\n"
    echo -e "  • Zsh with Oh My Zsh and plugins"
    echo -e "  • Tmux configuration"
    echo -e "  • Konsole profiles (if available)"
    echo -e "  • Claude Code Router (for Cerebras inference)"
    echo -e "  • Claude Code status line"
    echo -e "  • CLI AI (natural language shell commands)\n"

    # Ask for confirmation unless --yes flag is provided
    if [[ "$1" != "--yes" && "$1" != "-y" ]]; then
        read -p "Continue? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_warning "Setup cancelled"
            exit 0
        fi
    fi

    # Check dependencies
    check_dependencies || exit 1

    # Setup components
    setup_zsh
    setup_tmux
    setup_konsole
    setup_claude_code_router
    setup_claude_code
    setup_cli_ai
    setup_env

    # Print post-install instructions
    print_post_install
}

# Run main function
main "$@"
