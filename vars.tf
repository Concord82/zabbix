variable "proxmox_ip" {
    description = "Proxmox server address"  
    type        = string  
}

variable "api_token_id" {
    description = "Proxmox API token Id"  
    type        = string  
}

variable "api_token_secret" {
    description = "Proxmox API token secret"
    type        = string  
}

variable "pm_user" {
    type = string
}

variable "pm_password" {
    type = string
}

variable "hosts" {
    type = list(
        object(
            {
                name = string
                vmid = number
                target_node = string
                os_template = string
                # Характеристики контейнера
                cores = number
                memory = number
                storage_size = string
                # параметры сети
                network = list(object({
                    name = string
                    bridge = number
                    ip = string
                    cidr = string
                    gw = optional(string)
                },))
                
            }
        )
    )
}

variable "host_os" {
    description = "host os map"
    type = map
}

#variable "ssh_public_key" {}