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
    if [ "$SHELL" != "$(which zsh)" ]; then
        print_info "Changing default shell to zsh..."
        print_warning "You may need to enter your password"
        chsh -s "$(which zsh)" || print_warning "Failed to change shell. Run manually: chsh -s \$(which zsh)"
    fi

    print_success "Zsh setup complete"
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

    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "  2. If tmux is running, reload config: ${YELLOW}tmux source ~/.tmux.conf${NC}"

    if command_exists konsole; then
        echo -e "  3. Restart Konsole to apply the new profile"
    fi

    echo -e "\n${BLUE}Optional dependencies you might want:${NC}"

    if ! command_exists fzf; then
        echo -e "  • fzf (fuzzy finder): ${YELLOW}sudo apt install fzf${NC} or ${YELLOW}brew install fzf${NC}"
    fi

    if ! command_exists tmux; then
        echo -e "  • tmux (terminal multiplexer): ${YELLOW}sudo apt install tmux${NC} or ${YELLOW}brew install tmux${NC}"
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
    echo -e "  • Konsole profiles (if available)\n"

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

    # Print post-install instructions
    print_post_install
}

# Run main function
main "$@"
