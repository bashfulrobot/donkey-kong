#!/bin/bash
# Comprehensive system update script
# Updates all package managers: apt, snap, npm, etc.

set -e

# Read become password if available
if [ -f "vars/become_password.txt" ]; then
    export SUDO_ASKPASS_PASSWORD=$(cat vars/become_password.txt)
    # Create a simple askpass script
    cat > /tmp/askpass.sh << 'EOF'
#!/bin/bash
echo "$SUDO_ASKPASS_PASSWORD"
EOF
    chmod +x /tmp/askpass.sh
    export SUDO_ASKPASS=/tmp/askpass.sh
    SUDO_CMD="sudo -A"
else
    SUDO_CMD="sudo"
fi

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔄 Starting comprehensive system update...${NC}"
echo

# Update APT packages
echo -e "${YELLOW}📦 Updating APT packages...${NC}"
${SUDO_CMD} apt update
${SUDO_CMD} apt upgrade -y
${SUDO_CMD} apt autoremove -y
${SUDO_CMD} apt autoclean
echo -e "${GREEN}✓ APT packages updated${NC}"
echo

# Update Snap packages
echo -e "${YELLOW}📦 Updating Snap packages...${NC}"
if command -v snap &> /dev/null; then
    ${SUDO_CMD} snap refresh
    echo -e "${GREEN}✓ Snap packages updated${NC}"
else
    echo -e "${YELLOW}⚠ Snap not installed, skipping${NC}"
fi
echo

# Update NPM global packages
echo -e "${YELLOW}📦 Updating NPM global packages...${NC}"
if command -v npm &> /dev/null; then
    # Update specific packages we know about
    if npm list -g @anthropic-ai/claude-code &> /dev/null; then
        ${SUDO_CMD} npm update -g @anthropic-ai/claude-code
        echo -e "${GREEN}✓ Updated @anthropic-ai/claude-code${NC}"
    fi
    
    if npm list -g @google/gemini-cli &> /dev/null; then
        ${SUDO_CMD} npm update -g @google/gemini-cli
        echo -e "${GREEN}✓ Updated @google/gemini-cli${NC}"
    fi
    
    # Update npm itself
    ${SUDO_CMD} npm update -g npm
    echo -e "${GREEN}✓ Updated npm itself${NC}"
else
    echo -e "${YELLOW}⚠ NPM not installed, skipping${NC}"
fi
echo

# Update Flatpak packages (if installed)
echo -e "${YELLOW}📦 Updating Flatpak packages...${NC}"
if command -v flatpak &> /dev/null; then
    flatpak update -y
    echo -e "${GREEN}✓ Flatpak packages updated${NC}"
else
    echo -e "${YELLOW}⚠ Flatpak not installed, skipping${NC}"
fi
echo

echo -e "${GREEN}🎉 All package managers updated successfully!${NC}"
echo -e "${BLUE}💡 You may need to restart applications to use updated versions${NC}"

# Cleanup
if [ -f "/tmp/askpass.sh" ]; then
    rm -f /tmp/askpass.sh
fi