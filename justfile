# Ansible laptop configuration management

# Check vault prerequisites before running
check-vault-setup:
    #!/usr/bin/env bash
    if [ ! -f "vars/vault_password.txt" ]; then
        echo "❌ ERROR: vars/vault_password.txt not found!"
        echo "Please run 'just setup-vault' for first-time setup instructions."
        exit 1
    fi
    if [ ! -s "vars/vault_password.txt" ]; then
        echo "❌ ERROR: vars/vault_password.txt is empty!"
        echo "Please add your vault password to vars/vault_password.txt"
        exit 1
    fi

# Run full build (skips downloads/slow operations by default)
build: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --ask-become-pass --skip-tags "never"

# Run full build including downloads and slow operations
build-all: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --ask-become-pass

# Remove all installed packages and configs
remove: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --ask-become-pass -e "package_state=absent service_state=stopped config_state=absent"

# Run specific tags
dev: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags dev --ask-become-pass

infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags infra --ask-become-pass

offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags offcoms --ask-become-pass

shell: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags shell --ask-become-pass

sys: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags sys --ask-become-pass

core: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags core --ask-become-pass

# Skip certain tags
build-skip-offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags offcoms --ask-become-pass

build-skip-infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags infra --ask-become-pass

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
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --ask-become-pass --tags "downloads,slow"

# Dry run checks (skips downloads/slow operations by default)
check: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --ask-become-pass --skip-tags "never"

# Dry run including downloads and slow operations
check-all: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --ask-become-pass

check-dev: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags dev --ask-become-pass

check-infra: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags infra --ask-become-pass

check-offcoms: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags offcoms --ask-become-pass

check-shell: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags shell --ask-become-pass

check-sys: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags sys --ask-become-pass

check-core: check-vault-setup
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags core --ask-become-pass

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

# First-time setup - encrypt secrets after editing them
setup-vault:
    @echo "1. Edit vars/vault_password.txt with your password"
    @echo "2. Edit vars/secrets.yml with your actual secrets"
    @echo "3. Run 'just encrypt-secrets' to encrypt the file"
    @echo "4. Run 'just check-vault' to verify everything is secure"

# Pre-commit safety check
pre-commit-check:
    @echo "Running pre-commit security checks..."
    ./scripts/check-vault.sh
    @echo "✓ Safe to commit"