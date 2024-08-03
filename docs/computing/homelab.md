# Homelab Environment Setup

This repository contains Ansible scripts to set up and manage my macOS environment.

## Prerequisites

### Install Ansible on macOS

To get started, you need to install Ansible. You can do this via Homebrew by running the following command:

```bash
brew install ansible
```

## Repository Structure

Here's the structure of this repository:

- `README.md`: Instructions on installing and using Ansible.
- `playbooks/`: Directory for Ansible playbooks.
- `.environment`: Placeholder for environment variables.
- `ansible.cfg`: Configuration file for Ansible settings.

## Ansible Configuration

Create an `ansible.cfg` file in the root of the repository with the following configurations:

```ini
[defaults]
inventory = ./hosts
host_key_checking = False
retry_files_enabled = False
```

## Playbook to Initialize Environment

### Creating the Playbook

Create a playbook named `initialize.yml` in the `playbooks` directory. This playbook will create a marker file to indicate that the environment has been initialized.

```yaml
---
- name: Initialize Homelab Environment
  hosts: localhost
  connection: local
  tasks:
    - name: Create marker file
      file:
        path: "~/initialized_homelab"
        state: touch
```

### Running the Playbook

To run the playbook and initialize your environment, execute the following command:

```bash
ansible-playbook playbooks/initialize.yml
```

## Setting Up the `.environment` File

The `.environment` file will store environment variables. You'll link this file with your shell profile to ensure it loads automatically.

### Modify Shell Profile

Add the following lines to your shell’s profile file (e.g., `.zshrc` or `.bash_profile`):

```bash
if [ -f "$HOME/.environment" ]; then
    source "$HOME/.environment"
fi
```

This integration will load your custom environment variables every time a new shell session starts.
