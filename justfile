# Ansible laptop configuration management

# Run full build
build:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml

# Run specific tags
dev:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags dev

infra:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags infra

offcoms:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags offcoms

shell:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags shell

sys:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags sys

core:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --tags core

# Skip certain tags
build-skip-offcoms:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags offcoms

build-skip-infra:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --skip-tags infra

# Dry run checks
check:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check

check-dev:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags dev

check-infra:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags infra

check-offcoms:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags offcoms

check-shell:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags shell

check-sys:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags sys

check-core:
    ansible-playbook -i inventory/localhost.yml playbooks/main.yml --check --tags core

# Syntax check
syntax:
    ansible-playbook --syntax-check playbooks/main.yml

# Test connectivity
ping:
    ansible all -i inventory/localhost.yml -m ping

# Vault management
edit-secrets:
    ansible-vault edit vars/secrets.yml

encrypt-secrets:
    ansible-vault encrypt vars/secrets.yml

decrypt-secrets:
    ansible-vault decrypt vars/secrets.yml

view-secrets:
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