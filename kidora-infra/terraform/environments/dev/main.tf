module "ssh_key" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/ssh-key"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "dev_server" {
  source       = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"
  name         = "kidora-dev-server"
  region       = var.region
  plan         = var.plan
  os_id        = var.os_id
  ssh_key_id   = module.ssh_key.ssh_key_id
  firewall_id  = module.firewall.firewall_id
}

module "dev_reserved_ip" {
  source      = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-reserved-ip"
  region      = var.region
  label       = "kidora-dev-reserved-ip"
  instance_id = module.dev_server.server_id
}

module "firewall" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/firewall"
  firewall_name = "kidora-dev-firewall"
  rules = [
    {
      protocol = "tcp"
      port = "22"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "80"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "443"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "6443"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "9090"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "3000"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "8086"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "9000"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "9001"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
    {
      protocol = "tcp"
      port = "27017"
      ip_type = "v4"
      subnet = "0.0.0.0"
      subnet_size = 0
    },
  ]
}

# Generate Ansible inventory from template with the server IP
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/inventory.tpl", {
    dev_server_ip = module.dev_server.ip_address
  })
  filename = abspath("${path.module}/../../../ansible/inventories/dev/hosts.ini")
}

# Ansible trigger has been moved to Ansible playbooks (terraform.yml)
# Run Ansible from your PC with: ansible-playbook playbooks/dev/main.yml
