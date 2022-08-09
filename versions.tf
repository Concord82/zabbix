terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "2.9.3"
    }
    local = {
      source = "hashicorp/local"
      version = "~>2.1.0"
    }
  }
  required_version = "~> 1.1.2"
  experiments      = [module_variable_optional_attrs]
}
