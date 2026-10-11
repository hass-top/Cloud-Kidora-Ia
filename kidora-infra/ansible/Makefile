# =============================================================================
#  Kidora - Ansible entry points
# =============================================================================
#  Use these targets instead of calling ansible-playbook directly.
#  Run them from inside the WSL shell (they rely on /bin/bash and the venv).
#
#  WHY THIS FILE IS NOT JUST A CONVENIENCE WRAPPER
#  ----------------------------------------------
#  This checkout lives on /mnt/c, a WSL drvfs mount where every directory is
#  mode 0777. Ansible refuses to read ansible.cfg from a world-writable
#  working directory. In ansible/config/manager.py, find_ini_config_file():
#
#      perms = os.stat(cwd)
#      if perms.st_mode & stat.S_IWOTH:
#          warn_cmd_public = True      # <- the [WARNING] you would have seen
#      else:
#          potential_paths.append(cwd_cfg)
#
#  So a bare `ansible-playbook playbooks/staging/main.yml` runs with NO config
#  at all. The first thing to break is roles_path:
#
#      [ERROR]: The role 'common' was not found in:
#               .../playbooks/staging/roles:/home/you/.ansible/roles:...
#
#  which is confusing because roles/common/ does exist - it is just not on the
#  search path. Everything else in the file is lost too (private_key_file,
#  become, ssh_args, fact_caching, ...), so fixing roles_path alone would just
#  move the failure to the SSH connection.
#
#  ANSIBLE_CONFIG is exempt from that permission test - it is appended to the
#  candidate list before the check - so exporting it restores the whole file.
#  That is the single line this Makefile exists to guarantee.
#
#  To fix the cause rather than the symptom, move the repo into the WSL ext4
#  filesystem (~/kidora-infra). /mnt/c is also very slow for the thousands of
#  small file reads Ansible performs per run.
# =============================================================================

SHELL := /bin/bash
.SHELLFLAGS := -e -o pipefail -c
.DEFAULT_GOAL := help

ROOT := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))

# Restores roles_path, private_key_file, become, ssh_args, fact_caching, ...
export ANSIBLE_CONFIG := $(ROOT)/ansible.cfg

VENV        := $(ROOT)/.venv
ANSIBLE     := $(VENV)/bin/ansible-playbook
ANSIBLE_INV := $(VENV)/bin/ansible-inventory
ANSIBLE_CFG := $(VENV)/bin/ansible-config
VAULT       := $(VENV)/bin/ansible-vault
GALAXY      := $(VENV)/bin/ansible-galaxy

PB          := $(ROOT)/playbooks
INV         := $(ROOT)/inventories
STAGING_INV := $(INV)/staging/hosts.ini
STAGING_PB  := $(PB)/staging

# Forwarded to ansible-playbook, e.g.
#   make staging EXTRA_ARGS='--check --diff'
#   make staging EXTRA_ARGS='--tags preflight --ask-vault-pass'
EXTRA_ARGS ?=

.PHONY: help check check-venv syntax inventory staging preflight docker \
		tailscale monitoring app edge verify collections vault-edit

help: ## Show this help
	@echo "Kidora Ansible targets (run from inside WSL):"
	@echo
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "  Forward extra flags with EXTRA_ARGS='...', e.g."
	@echo "    make staging EXTRA_ARGS='--check --diff'"
	@echo "    make staging EXTRA_ARGS='--tags preflight --ask-vault-pass'"

check-venv: ## Fail early with a clear message if the project venv is missing
	@test -x "$(ANSIBLE)" || { \
		echo "ERROR: $(ANSIBLE) not found."; \
		echo "       Create it with: python3 -m venv .venv && .venv/bin/pip install ansible"; \
		echo "       then run: make collections"; \
		exit 1; }

check: check-venv ## Prove ansible.cfg is actually being honoured
	@test -f "$(ANSIBLE_CONFIG)" || { echo "MISSING: $(ANSIBLE_CONFIG)"; exit 1; }
	@echo "ANSIBLE_CONFIG = $(ANSIBLE_CONFIG)"
	@if $(ANSIBLE_CFG) dump | grep -Fq "$(ROOT)/roles"; then \
		echo "OK: roles_path resolves to $(ROOT)/roles"; \
	else \
		echo "FAIL: roles_path is unset - ansible.cfg was ignored."; \
		echo "      Do not bypass make with a bare ansible-playbook call."; \
		exit 1; \
	fi
	@$(ANSIBLE_CFG) dump | grep -F 'DEFAULT_PRIVATE_KEY_FILE' || true

syntax: check-venv ## Parse the staging entry point without touching any host
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/main.yml --syntax-check $(EXTRA_ARGS)

inventory: check-venv ## Show the staging inventory tree
	cd $(ROOT) && $(ANSIBLE_INV) -i $(STAGING_INV) --graph

staging: check-venv ## Deploy the whole 3-server staging stack (00 -> 40)
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/main.yml $(EXTRA_ARGS)

preflight: check-venv ## 00 - hardening and firewall only
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/00-preflight.yml $(EXTRA_ARGS)

docker: check-venv ## 10 - Docker engine and the deploy user
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/10-docker.yml $(EXTRA_ARGS)

tailscale: check-venv ## 15 - join the servers to the private tailnet
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/15-tailscale.yml $(EXTRA_ARGS)

monitoring: check-venv ## 20 - Prometheus, Grafana, Alertmanager, exporters
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/20-monitoring.yml $(EXTRA_ARGS)

app: check-venv ## 30 - MongoDB, MinIO and the four product images
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/30-app.yml $(EXTRA_ARGS)

edge: check-venv ## 40 - nginx, certificate, then the TLS vhosts
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/40-edge.yml $(EXTRA_ARGS)

verify: check-venv ## Post-deployment verification
	cd $(ROOT) && $(ANSIBLE) -i $(STAGING_INV) $(STAGING_PB)/verify.yml $(EXTRA_ARGS)

collections: ## Install the Galaxy collections this repo needs
	cd $(ROOT) && $(GALAXY) collection install -r $(ROOT)/requirements.yml

vault-edit: check-venv ## Edit the staging vault
	cd $(ROOT) && $(VAULT) edit $(INV)/staging/group_vars/vault.yml
