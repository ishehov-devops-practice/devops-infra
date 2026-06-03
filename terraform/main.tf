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