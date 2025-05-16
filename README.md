# Ansible project

## Overview
This guide explains how to deploy and manage PostgreSQL using Ansible playbooks in this project.

## Project Structure

```
ansible/
├── backup-pg.yaml          # PostgreSQL backup playbook
├── config.yaml             # System and PostgreSQL configuration playbook
├── deploy_postgres.yaml    # PostgreSQL installation and setup playbook
├── inventories/            # Host inventory definitions
│   └── openstack.yaml      # OpenStack VM inventory 
├── roles/                  # Ansible roles
│   └── pg_install/         # PostgreSQL installation role
└── backups/                # Local directory for database backups
```

## Prerequisites

- Ansible 2.9 or higher
- SSH access to target VM(s)
- Python 3 and `python3-psycopg2` package on the control machine

## Setup Instructions

### 1. Configure Inventory

Edit the `inventories/openstack.yaml` file with your VM details:

```yaml
all:
  hosts:
    vm1:
      ansible_host: YOUR_VM_IP
      ansible_user: root
      ansible_port: 22
      ansible_password: "YOUR_PASSWORD"
```

### 2. Create Backup Directory

```bash
mkdir -p ansible/backups
```

### 3. Install Required Ansible Collections

```bash
ansible-galaxy collection install community.postgresql ansible.posix
```

## Deployment Workflow

### Step 1: Deploy PostgreSQL

```bash
ansible-playbook -i inventories/openstack.yaml deploy_postgres.yaml
```

This playbook:
- Installs PostgreSQL 15 on the target VM
- Creates a database user with credentials defined in the playbook
- Configures PostgreSQL for external connections
- Sets up proper permissions

### Step 2: Optimize System and PostgreSQL Configuration

```bash
ansible-playbook -i inventories/openstack.yaml config.yaml
```

This playbook:
- Configures VM cache management with optimized settings for database workloads
- Dynamically allocates PostgreSQL shared buffers based on available memory:
  - Uses 15% of total memory if VM has ≤ 1024MB RAM
  - Uses 25% of total memory if VM has > 1024MB RAM
- Restarts PostgreSQL to apply changes

### Step 3: Backup PostgreSQL Database

```bash
ansible-playbook -i inventories/openstack.yaml backup-pg.yaml
```

This playbook:
- Creates a backup directory on the remote VM
- Dumps the PostgreSQL database to a SQL file
- Transfers the backup file to your local `backups/` directory

## Configuration Details

### PostgreSQL Settings

The deployment configures:
- PostgreSQL to listen on all interfaces (`0.0.0.0`)
- User authentication via password (MD5)
- Dynamically sized shared buffers based on VM memory
- Optimized VM cache pressure settings (90)

### Security Considerations

For production environments:
- Use Ansible Vault to encrypt sensitive data
- Replace default passwords with strong, unique passwords
- Restrict PostgreSQL access to specific IP addresses
- Consider using SSH keys instead of passwords for authentication

## Troubleshooting

If you encounter errors:
- Verify network connectivity to the target VM
- Ensure proper SSH access permissions
- Check that required collections are installed
- Verify PostgreSQL service status on the remote VM