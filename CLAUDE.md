# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is an Ansible repository for configuring a work laptop. The repository is currently minimal with only basic project files.

## Development Commands

Since this is an Ansible project, common commands will likely include:

```bash
# Run ansible playbooks (when created)
ansible-playbook -i inventory playbook.yml

# Check ansible syntax (when playbooks exist)
ansible-playbook --syntax-check playbook.yml

# Run in check mode (dry run)
ansible-playbook -i inventory --check playbook.yml

# Test ansible connectivity
ansible all -i inventory -m ping
```

## Architecture

This repository is intended to contain Ansible playbooks and configuration for laptop setup automation. The structure will likely evolve to include:

- Playbooks for different aspects of laptop configuration
- Inventory files for different environments
- Role definitions for reusable configuration components
- Variable files for environment-specific settings

## Notes

- Repository is currently in initial state with only README and LICENSE
- Ansible configuration files and playbooks will be added as the project develops
- Follow Ansible best practices for role organization and variable management
- Git commits MUST WITHOUT FAIL:
    - NEVER EVER add claude branding to git commit messages as I will be fired
    - follow semver if versioning is requested
    - use conventional commits with emojis
