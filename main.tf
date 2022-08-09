locals {
  # публичный ssh ключь для доступа к созданным инстансам 
  # берем из файла с локальной системы
  ssh_public_key = file("~/.ssh/id_rsa.pub")
}


provider "proxmox" {
  # определяем провайдера для создания инстансов
  # в данном случае параметры для подключения к кластеру Proxmox
  pm_api_url = "https://${var.proxmox_ip}:8006/api2/json"  
  pm_api_token_id = "${var.api_token_id}"
  pm_api_token_secret = "${var.api_token_secret}"

  #pm_user = "${var.pm_user}"
  #pm_password = "${var.pm_password}"


  pm_tls_insecure = true
  pm_debug = true
}


resource "proxmox_lxc" "basic"{
  # создаем инстансы в соответствии с параметрами описанными 
  # в файлах переменных
  count = length(var.hosts)
  vmid = "${var.hosts[count.index].vmid}" 
  hostname = "${var.hosts[count.index].name}" 
  target_node = "${var.hosts[count.index].target_node}" 
  ostemplate = var.host_os[var.hosts[count.index].os_template]
  unprivileged = true
  cores = var.hosts[count.index].cores
  memory = var.hosts[count.index].memory


  password     = "cnjhjyf2"
  ssh_public_keys = local.ssh_public_key
  rootfs {
    storage = "pmx-vg"
    size    = var.hosts[count.index].storage_size
  }
  
  dynamic "network" {
    for_each = var.hosts[count.index].network
    
    content {
      name = network.value.name 
      bridge = "vmbr${network.value.bridge}"
      ip = "${network.value.ip}/${network.value.cidr}"
      gw     = network.value.gw 
      ip6    = "auto"

    }
  }
  hastate = "started"
  hagroup = "cl2-ha"
  onboot = "true"
  start = "true"
}


# на основе файла с описанием параметров виртуальных машин создается файл hosts для Ansible
# это позволяет не дублировать описание хостов. Адреса и тип инстансов описывается в файле 
# переменных Terraform, а файл hosts создается динамически на его основе. 
resource "local_file" "ans_conf" {
  content = templatefile("${path.module}/ansible.tftpl", {hosts = "${var.hosts}"})
  filename = "${path.module}/ansible/hosts.yml"
  file_permission = "0644"
  provisioner "local-exec" {
    command = "export ANSIBLE_CONFIG=${path.module}/ansible/ansible.cfg && ansible-playbook ${path.module}/ansible/playbook.yml"
  }
}