module "ssh_key" {
  source     = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/ssh-key"
  key_name   = var.ssh_key_name
  public_key = var.ssh_public_key
}

module "prod_servers" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-server"

  for_each = {
    app        = "kidora-prod-app"
    database   = "kidora-prod-db"
    monitoring = "kidora-prod-monitoring"
  }

  name       = each.value
  region     = var.region
  plan       = var.plan
  os_id      = var.os_id
  vpc_id     = module.network.vpc_id
  firewall_id = module.firewall.firewall_id
  ssh_key_id = module.ssh_key.ssh_key_id
}


module "firewall" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/firewall"
  firewall_name = "kidora-prod-firewall"
  rules = [
    {
      protocol="tcp"
      port="22"
      ip_type="v4"
      subnet="YOUR_ADMIN_IP"
      subnet_size=32
    },
    {
      protocol="tcp"
      port="80"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=0
    },
    {
      protocol="tcp"
      port="443"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=0
    },
    {
      protocol="tcp"
      port="6443"
      ip_type="v4"
      subnet="0.0.0.0"
      subnet_size=24
    }
  ]
}

module "network" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/network"
  region = "fra"
  name   = "kidora-prod-network"
}

module "load_balancer" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/load-balancer"
  name   = "kidora-prod-lb"
  region = var.region
}

module "volume" {
  source = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/volume"
  name   = "kidora-prod-db-volume"
  region = var.region
  size   = var.volume_size
}

module "object_storage" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/object-storage"
  name    = "kidora-prod-storage"
  region  = var.region
  cluster = var.storage_cluster
}

module "prod_reserved_ips" {
  for_each = {
    app        = "kidora-prod-app"
    database   = "kidora-prod-db"
    monitoring = "kidora-prod-monitoring"
  }

  source      = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/vultr-reserved-ip"
  region      = var.region
  label       = each.key
  instance_id = module.prod_servers[each.key].server_id
}

module "dns" {
  source  = "git::https://github.com/Moenes25/Cloud-Kidora-Ia.git//kidora-infra/terraform/modules/dns"
  domain  = var.dns_domain
  records = var.dns_records != [] ? var.dns_records : [
    {
      name     = "app"
      type     = "A"
      data     = module.prod_reserved_ips["app"].reserved_ip_address
      ttl      = 300
    }
  ]
}

resource "null_resource" "git_clone_repo" {
  provisioner "local-exec" {
    command = <<EOT
      if [ ! -d "/tmp/infra-repo/.git" ]; then
        git clone https://github.com/Moenes25/Cloud-Kidora-Ia.git /tmp/infra-repo
      else
        cd /tmp/infra-repo && git pull
      fi
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}

resource "local_file" "ansible_inventory" {
  filename = "/tmp/infra-repo/kidora-infra/ansible/inventories/prod/hosts.ini"
  content = templatefile("/tmp/infra-repo/kidora-infra/terraform/environments/prod/inventory.tpl", {
    app_ip        = module.prod_servers["app"].ip_address
    database_ip   = module.prod_servers["database"].ip_address
    monitoring_ip = module.prod_servers["monitoring"].ip_address
  })

  depends_on = [null_resource.git_clone_repo]
}

resource "null_resource" "ansible_trigger" {
  depends_on = [module.prod_servers, local_file.ansible_inventory]
  
  triggers = {
    inventory_hash = filesha256(local_file.ansible_inventory.filename)
  }
  
  provisioner "local-exec" {
    command = "sleep 45 && ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ${local_file.ansible_inventory.filename} /tmp/infra-repo/kidora-infra/ansible/playbooks/main.yml --tags production"
  }
}
