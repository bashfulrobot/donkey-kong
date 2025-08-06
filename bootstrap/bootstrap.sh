#!/bin/bash

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

# Check if running on Ubuntu 24.04
check_ubuntu_version() {
    if ! grep -q "Ubuntu 24.04" /etc/os-release; then
        log_error "This script is designed for Ubuntu 24.04"
        exit 1
    fi
    log_success "Ubuntu 24.04 detected"
}

# Update package lists
update_packages() {
    log_info "Updating package lists..."
    sudo apt update
    log_success "Package lists updated"
}

# Update system packages to latest within same major release
upgrade_system() {
    log_info "Upgrading system packages to latest versions..."
    log_warning "This may take several minutes depending on available updates..."
    
    # Upgrade all packages while keeping current release
    sudo apt upgrade -y
    
    # Remove unnecessary packages
    sudo apt autoremove -y
    
    # Clean package cache
    sudo apt autoclean
    
    log_success "System packages updated successfully"
}

# Install curl
install_curl() {
    if command -v curl &> /dev/null; then
        log_warning "curl is already installed"
        curl --version
    else
        log_info "Installing curl..."
        sudo apt install -y curl
        log_success "curl installed successfully"
    fi
}

# Install git
install_git() {
    if command -v git &> /dev/null; then
        log_warning "Git is already installed"
        git --version
    else
        log_info "Installing git..."
        sudo apt install -y git
        log_success "Git installed successfully"
    fi
}

# Install git-crypt
install_git_crypt() {
    if command -v git-crypt &> /dev/null; then
        log_warning "git-crypt is already installed"
        git-crypt --version
    else
        log_info "Installing git-crypt..."
        sudo apt install -y git-crypt
        log_success "git-crypt installed successfully"
    fi
}

# Install ansible
install_ansible() {
    if command -v ansible &> /dev/null; then
        log_warning "Ansible is already installed"
        ansible --version
    else
        log_info "Installing ansible..."
        sudo apt install -y ansible
        log_success "Ansible installed successfully"
    fi
}

# Install helix editor
install_helix() {
    if command -v hx &> /dev/null; then
        log_warning "Helix is already installed"
        hx --version
    else
        log_info "Installing helix editor..."
        
        # Get the latest version
        HELIX_VERSION=$(curl -s "https://api.github.com/repos/helix-editor/helix/releases/latest" | grep -Po '"tag_name": "\K[0-9.]+')
        log_info "Latest Helix version: $HELIX_VERSION"
        
        # Download the release
        log_info "Downloading Helix $HELIX_VERSION..."
        wget -qO /tmp/helix.tar.xz "https://github.com/helix-editor/helix/releases/latest/download/helix-$HELIX_VERSION-x86_64-linux.tar.xz"
        
        # Create installation directory and extract
        log_info "Installing to /opt/helix..."
        sudo mkdir -p /opt/helix
        sudo tar xf /tmp/helix.tar.xz --strip-components=1 -C /opt/helix
        
        # Create symbolic link
        sudo ln -s /opt/helix/hx /usr/local/bin/hx
        
        # Clean up
        rm -f /tmp/helix.tar.xz
        
        log_success "Helix editor installed successfully"
        hx --version
    fi
}

# Install just
install_just() {
    if command -v just &> /dev/null; then
        log_warning "just is already installed"
        just --version
    else
        log_info "Installing just..."
        # Download and install just from GitHub releases
        JUST_VERSION=$(curl -s https://api.github.com/repos/casey/just/releases/latest | grep -Po '"tag_name": "\K.*?(?=")')
        curl -L "https://github.com/casey/just/releases/download/${JUST_VERSION}/just-${JUST_VERSION}-x86_64-unknown-linux-musl.tar.gz" | tar -xz -C /tmp
        sudo mv /tmp/just /usr/local/bin/
        sudo chmod +x /usr/local/bin/just
        log_success "just installed successfully"
    fi
}

# Clone the repository
clone_repository() {
    local repo_dir="$HOME/dev/kong/hardware"
    
    if [ -d "$repo_dir/donkey-kong" ]; then
        log_warning "Repository already exists at $repo_dir/donkey-kong"
        return
    fi
    
    log_info "Creating directory structure..."
    mkdir -p "$repo_dir"
    
    log_info "Cloning repository from github.com/bashfulrobot/donkey-kong..."
    cd "$repo_dir"
    git clone https://github.com/bashfulrobot/donkey-kong.git
    log_success "Repository cloned successfully to $repo_dir/donkey-kong"
}

# Main execution
main() {
    log_info "Starting bootstrap process for Ubuntu 24.04..."
    
    check_ubuntu_version
    update_packages
    upgrade_system
    install_curl
    install_git
    install_git_crypt
    install_ansible
    install_helix
    install_just
    clone_repository
    
    log_success "Bootstrap process completed successfully!"
    log_info "You can now navigate to ~/dev/kong/hardware/donkey-kong to start working with the repository"
}

# Run main function
main "$@"