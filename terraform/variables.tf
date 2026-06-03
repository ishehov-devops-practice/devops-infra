variable "proxmox_api_url" { type = string }
variable "proxmox_api_token_id" { type = string }
variable "proxmox_api_token_secret" {
    type = string
    sensitive = true
}
variable "target_node" {
    type = string
    default = "pve"
}

variable "ssh_public_key" {
  type        = string
  description = "Public SSH key for ansible"
}

variable "k3s_cluster_nodes" {
  type = map(object({
    vmid   = number
    cores  = number
    memory = number
    ip     = string
    gw     = string
  }))
  default = {
    "k3s-master-01" = { vmid = 500, cores = 2, memory = 4096, ip = "192.168.1.170/24", gw = "192.168.1.1" }
    "k3s-worker-01" = { vmid = 501, cores = 2, memory = 4096, ip = "192.168.1.172/24", gw = "192.168.1.1" }
    "k3s-worker-02" = { vmid = 502, cores = 2, memory = 4096, ip = "192.168.1.173/24", gw = "192.168.1.1" }
  }
}