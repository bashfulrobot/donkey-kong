#!/bin/bash
# Script to completely remove Zsh from the system
# Run this after switching to Fish shell via Ansible

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if user is using Fish shell
check_current_shell() {
    if [[ "$SHELL" != "/usr/bin/fish" ]]; then
        log_warning "Current shell is not Fish ($SHELL)"
        log_warning "Consider running 'just shell' to set up Fish shell first"
        echo
        read -p "Continue with Zsh removal anyway? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborting Zsh removal"
            exit 0
        fi
    else
        log_success "Current shell is Fish - safe to remove Zsh"
    fi
}

# Remove Zsh package
remove_zsh_package() {
    log_info "Removing Zsh package..."
    if dpkg -l | grep -q "^ii.*zsh"; then
        sudo apt remove --purge zsh -y
        log_success "Zsh package removed"
    else
        log_warning "Zsh package not found - may already be removed"
    fi
}

# Remove Zsh configuration files
remove_zsh_config() {
    log_info "Removing Zsh configuration files..."
    
    # Remove Oh My Zsh
    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        rm -rf "$HOME/.oh-my-zsh"
        log_success "Removed ~/.oh-my-zsh"
    fi
    
    # Remove Zsh config files
    for file in ~/.zshrc ~/.zsh_history ~/.zcompdump* ~/.zshenv ~/.zprofile ~/.zlogin ~/.zlogout; do
        if [[ -e $file ]]; then
            rm -f $file
            log_success "Removed $(basename $file)"
        fi
    done
    
    # Remove Zsh directory
    if [[ -d "$HOME/.zsh" ]]; then
        rm -rf "$HOME/.zsh"
        log_success "Removed ~/.zsh directory"
    fi
}

# Remove system Zsh files
remove_system_zsh() {
    log_info "Removing system Zsh files..."
    
    if [[ -d "/etc/zsh" ]]; then
        sudo rm -rf /etc/zsh
        log_success "Removed /etc/zsh"
    fi
    
    if [[ -d "/usr/share/zsh" ]]; then
        sudo rm -rf /usr/share/zsh
        log_success "Removed /usr/share/zsh"
    fi
}

# Remove Zsh from /etc/shells
remove_from_shells() {
    log_info "Removing Zsh entries from /etc/shells..."
    if grep -q "zsh" /etc/shells; then
        sudo sed -i '/zsh/d' /etc/shells
        log_success "Removed Zsh entries from /etc/shells"
    else
        log_warning "No Zsh entries found in /etc/shells"
    fi
}

# Clean up packages
cleanup_packages() {
    log_info "Cleaning up orphaned packages and cache..."
    sudo apt autoremove --purge -y
    sudo apt autoclean
    log_success "Package cleanup completed"
}

# Display final status
show_status() {
    echo
    log_info "=== Zsh Removal Summary ==="
    log_info "Current shell: $SHELL"
    log_info "Available shells:"
    cat /etc/shells | sed 's/^/  /'
    echo
    
    if command -v zsh &> /dev/null; then
        log_warning "Zsh binary still found - manual cleanup may be needed"
    else
        log_success "Zsh completely removed from system"
    fi
}

# Main execution
main() {
    log_info "Starting Zsh removal process..."
    echo
    
    check_current_shell
    remove_zsh_package
    remove_zsh_config
    remove_system_zsh
    remove_from_shells
    cleanup_packages
    show_status
    
    echo
    log_success "Zsh removal completed successfully!"
    log_info "Your system now uses Fish shell with Bash as fallback"
}

# Run main function
main "$@"