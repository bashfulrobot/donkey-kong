# Ansible laptop configuration management

# Check password files prerequisites before running
check-vault-setup:
    #!/usr/bin/env bash
    if [ ! -f "vars/vault_password.txt" ]; then
        echo "❌ ERROR: vars/vault_password.txt not found!"
        echo "Please run 'just setup-passwords' for first-time setup instructions."
        exit 1
    fi
    if [ ! -s "vars/vault_password.txt" ]; then
        echo "❌ ERROR: vars/vault_password.txt is empty!"
        echo "Please add your vault password to vars/vault_password.txt"
        exit 1
    fi
    if [ ! -f "vars/become_password.txt" ]; then
        echo "❌ ERROR: vars/become_password.txt not found!"
        echo "Please run 'just setup-passwords' for first-time setup instructions."
        exit 1
    fi
    if [ ! -s "vars/become_password.txt" ]; then
        echo "❌ ERROR: vars/become_password.txt is empty!"
        echo "Please add your sudo password to vars/become_password.txt"
        exit 1
    fi

# Run full build (skips downloads/slow operations by default)
build: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 Using configured password files..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags "never"

# Run full build including downloads and slow operations
build-all: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 Using configured password files..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml

# Remove all installed packages and configs
remove: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 Using configured password files..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml -e "package_state=absent service_state=stopped config_state=absent"

# Run specific tags
dev: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags dev 
infra: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags infra 
offcoms: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags offcoms 
shell: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags shell 
sys: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags sys 
core: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 You will be prompted for your sudo password..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags core 
# Skip certain tags
build-skip-offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags offcoms

build-skip-infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags infra

# Remove specific components
remove-dev: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags dev --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

remove-shell: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags shell --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

remove-core: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags core --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

remove-sys: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags sys --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

remove-infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags infra --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

remove-offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags offcoms --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

# Run only downloads and slow operations
downloads: check-vault-setup
    #!/usr/bin/env bash
    echo "🔐 Using configured password files..."
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags "downloads,slow"

# Dry run checks (skips downloads/slow operations by default)
check: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --ask-become-pass --skip-tags "never"

# Dry run including downloads and slow operations
check-all: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check 
check-dev: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags dev 
check-infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags infra 
check-offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags offcoms 
check-shell: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags shell 
check-sys: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags sys 
check-core: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags core 
# Syntax check
syntax:
    ansible-playbook --syntax-check playbooks/main.yml

# Test connectivity
ping:
    ansible all -i inventory/localhost.yml -m ping

# Vault management
edit-secrets: check-vault-setup
    ansible-vault edit vars/secrets.yml

encrypt-secrets: check-vault-setup
    ansible-vault encrypt vars/secrets.yml

decrypt-secrets: check-vault-setup
    ansible-vault decrypt vars/secrets.yml

rekey-secrets: check-vault-setup
    ansible-vault rekey vars/secrets.yml

view-secrets: check-vault-setup
    ansible-vault view vars/secrets.yml

# Check vault encryption status
check-vault:
    ./scripts/check-vault.sh

# First-time setup - configure passwords and encrypt secrets
setup-passwords:
    @echo "🔐 Password Configuration Setup"
    @echo "1. Edit vars/vault_password.txt with your Ansible vault password"
    @echo "2. Edit vars/become_password.txt with your sudo password"
    @echo "3. Edit vars/secrets.yml with your actual secrets"
    @echo "4. Run 'just encrypt-secrets' to encrypt the secrets file"
    @echo "5. Run 'just check-vault' to verify everything is secure"
    @echo ""
    @echo "Note: Password files are automatically used by Ansible (no prompts!)"

# Legacy alias for backward compatibility
setup-vault: setup-passwords

# Update all package managers (apt, snap, npm, flatpak)
update-all:
    #!/usr/bin/env bash
    ./scripts/update-all.sh

# Pre-commit safety check
pre-commit-check:
    @echo "Running pre-commit security checks..."
    ./scripts/check-vault.sh
    @echo "✓ Safe to commit"