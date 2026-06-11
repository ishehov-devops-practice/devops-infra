resource "proxmox_vm_qemu" "k3s_nodes" {
  for_each    = var.k3s_cluster_nodes
  name        = each.key
  vmid        = each.value.vmid
  target_node = var.target_node
  # Most workable proxmox VM template I can tolerate
  clone       = "golden-template"

  cpu {
    cores   = each.value.cores
    sockets = 1
    type    = "host"
  }

  # specs
  agent    = 1
  scsihw   = "virtio-scsi-pci"
  memory   = each.value.memory
  start_at_node_boot   = true

  # storage
  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0 # net0
    bridge = "vmbr0"
    model  = "virtio"
  }

  # cloud-init config
  os_type      = "cloud-init"
  ipconfig0    = "ip=${each.value.ip},gw=${each.value.gw}"
  ciuser       = "ubuntu"
  sshkeys      = <<EOF
  ${var.ssh_public_key}
  EOF
}

resource "proxmox_vm_qemu" "database_node" {
  name        = "db-prod-01"
  vmid        = 600
  target_node = var.target_node
  clone       = "golden-template"
  
  start_at_node_boot = true

  cpu {
    cores   = 2
    sockets = 1
  }

  memory  = 4096
  agent   = 1
  scsihw   = "virtio-scsi-pci"

  disks {
    scsi {
      scsi0 {
        disk {
          size    = "20G"
          storage = "local-lvm"
        }
      }
    }
    ide {
      ide2 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

  network {
    id     = 0 # net0
    model  = "virtio"
    bridge = "vmbr0"
  }

  ipconfig0 = "ip=192.168.1.174/24,gw=192.168.1.1"
  
  sshkeys = var.ssh_public_key
}