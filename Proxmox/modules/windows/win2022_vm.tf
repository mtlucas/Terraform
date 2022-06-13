# Proxmox Full-Clone
# ---
# Create a new VM from a clone

resource "proxmox_vm_qemu" "win2022_vm" {
    
    for_each = var.win2022_vms

    name = each.value.name
    desc = each.value.desc
    vmid = each.value.vmid
    target_node = "proxmox"
    onboot = true
    clone = (each.value.clone != null ? each.value.clone : "win2022-base")
    agent = 1
    cores = 1
    sockets = 2
    cpu = "host"
    memory = 2048
    network {
        bridge = "vmbr0"
        model  = "virtio"
    }
    # These values are already set in template
    bios = "ovmf"
    bootdisk = "ide0"
    scsihw = "virtio-scsi-pci"
    # Ignore changes to the network
    ## MAC address is generated on every apply, causing
    ## TF to think this needs to be rebuilt on every apply
    lifecycle {
        ignore_changes = [
            nameserver,
            searchdomain,
            ssh_host,
            ssh_port,
            network,
            disk,
            qemu_os,
            ipconfig0,
            disk_gb
        ]
    }
    # VM Cloud-Init Settings
    # os_type = "cloud-init"
    # (Optional) IP Address and Gateway
    # ipconfig0 = "ip=0.0.0.0/0,gw=0.0.0.0"
    # (Optional) Default User
    # ciuser = "your-username"
    # (Optional) Add your SSH KEY
    # sshkeys = <<EOF
    # #YOUR-PUBLIC-SSH-KEY
    # EOF
}

output "default_ipv4_address" {
  value = {
      for instance in proxmox_vm_qemu.win2022_vm:
      instance.name => instance.default_ipv4_address
  }
}
