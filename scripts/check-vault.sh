#!/bin/bash

# Script to check vault encryption status

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}[VAULT-CHECK] Checking vault encryption status...${NC}"

SECRETS_FILE="vars/secrets.yml"
VAULT_PASSWORD_FILE="vars/vault_password.txt"
BECOME_PASSWORD_FILE="vars/become_password.txt"

# Check if secrets file exists
if [ ! -f "$SECRETS_FILE" ]; then
    echo -e "${RED}[VAULT-CHECK] ✗ secrets.yml not found${NC}"
    exit 1
fi

# Check if secrets file is encrypted
if head -1 "$SECRETS_FILE" | grep -q "^\$ANSIBLE_VAULT"; then
    echo -e "${GREEN}[VAULT-CHECK] ✓ secrets.yml is encrypted${NC}"
    ENCRYPTED=true
else
    echo -e "${YELLOW}[VAULT-CHECK] ⚠ secrets.yml is NOT encrypted${NC}"
    ENCRYPTED=false
fi

# Check if vault password file exists
if [ -f "$VAULT_PASSWORD_FILE" ]; then
    echo -e "${GREEN}[VAULT-CHECK] ✓ vault password file exists${NC}"
    
    # Check if it's the default password
    if grep -q "change-this-vault-password-123" "$VAULT_PASSWORD_FILE"; then
        echo -e "${YELLOW}[VAULT-CHECK] ⚠ Using default vault password${NC}"
    fi
    
    # Check file permissions
    VAULT_PERMS=$(stat -c %a "$VAULT_PASSWORD_FILE")
    if [ "$VAULT_PERMS" = "600" ]; then
        echo -e "${GREEN}[VAULT-CHECK] ✓ vault password file has secure permissions${NC}"
    else
        echo -e "${YELLOW}[VAULT-CHECK] ⚠ vault password file permissions: $VAULT_PERMS (should be 600)${NC}"
    fi
else
    echo -e "${RED}[VAULT-CHECK] ✗ vault password file missing${NC}"
fi

# Check if become password file exists
if [ -f "$BECOME_PASSWORD_FILE" ]; then
    echo -e "${GREEN}[VAULT-CHECK] ✓ become password file exists${NC}"
    
    # Check if it's the default password
    if grep -q "change-this-become-password-123" "$BECOME_PASSWORD_FILE"; then
        echo -e "${YELLOW}[VAULT-CHECK] ⚠ Using default become password${NC}"
    fi
    
    # Check file permissions
    PERMS=$(stat -c %a "$BECOME_PASSWORD_FILE")
    if [ "$PERMS" = "600" ]; then
        echo -e "${GREEN}[VAULT-CHECK] ✓ become password file has secure permissions${NC}"
    else
        echo -e "${YELLOW}[VAULT-CHECK] ⚠ become password file permissions: $PERMS (should be 600)${NC}"
    fi
else
    echo -e "${RED}[VAULT-CHECK] ✗ become password file missing${NC}"
fi

# Check git status for secrets file
if git status --porcelain | grep -q "$SECRETS_FILE"; then
    if [ "$ENCRYPTED" = false ]; then
        echo -e "${RED}[VAULT-CHECK] ✗ DANGER: Unencrypted secrets.yml has changes${NC}"
        echo -e "${RED}[VAULT-CHECK] Run 'just encrypt-secrets' before committing${NC}"
        exit 1
    else
        echo -e "${GREEN}[VAULT-CHECK] ✓ Encrypted secrets.yml ready for commit${NC}"
    fi
fi

echo -e "${GREEN}[VAULT-CHECK] All checks passed${NC}"