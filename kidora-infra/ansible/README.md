# Ansible-Terraform Integration

This directory now supports **triggering Terraform from Ansible** on your local PC.

## Usage

### Provision Infrastructure

**IMPORTANT:** All commands must be run from the `ansible/` root directory, not from the `playbooks/` or `playbooks/dev/` subdirectories.

```bash
cd /home/snofy/Desktop/tunis_stage/infra/Cloud-Kidora-Ia/kidora-infra/ansible
ansible-playbook playbooks/main.yml
```

### Remove Infrastructure

Destroy all Terraform-managed resources:

```bash
cd /home/snofy/Desktop/tunis_stage/infra/Cloud-Kidora-Ia/kidora-infra/ansible
ansible-playbook playbooks/terraform-remove.yml
```

## How It Works

1. **terraform.yml** - First playbook that:
   - Runs `terraform init`, `terraform plan`, and `terraform apply` locally
   - Extracts the provisioned server IP from Terraform outputs
   - Adds the server to dynamic inventory
   - Waits for SSH to be ready
   - Passes the host to subsequent playbooks

2. **terraform-remove.yml** - Destroys all Terraform-managed resources
3. **All other playbooks** - Execute on the provisioned server via SSH

## Directory Structure

```
ansible/
├── ansible.cfg              # Ansible configuration
├── playbooks/
│   ├── terraform.yml        # Terraform orchestration (NEW)
│   ├── main.yml             # Main entry point (UPDATED)
│   ├── docker.yml
│   ├── k3s.yml
│   └── ... (other playbooks)
├── roles/
├── inventories/
│   ├── dev/
│   │   ├── hosts.ini        # Inventory still used for group vars
│   │   └── group_vars/
│   └── ...
```

## Prerequisites

- Terraform CLI installed locally
- Ansible installed locally
- SSH key configured at `~/.ssh/id_rsa` (configure path in `ansible.cfg`)
- Vultr API token configured in `terraform/environments/dev/terraform.tfvars`

## Notes

- Terraform runs on your local machine (localhost)
- Ansible provisions the remote server after Terraform creates it
- The server IP is automatically extracted and passed to Ansible dynamically
- SSH host key checking is disabled in `ansible.cfg` for automation