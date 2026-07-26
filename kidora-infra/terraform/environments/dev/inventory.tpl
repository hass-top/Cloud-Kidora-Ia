[dev_servers]
kidora-dev-server ansible_host=${dev_server_ip} ansible_user=root ansible_ssh_private_key_file=/home/snofy/.ssh/kidora_ssh

[all:vars]
admin_user=root
