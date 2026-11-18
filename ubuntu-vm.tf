resource "proxmox_download_file" "ubuntu" {
  content_type = "import"
  datastore_id = "local"
  file_name    = "ubuntu-26.04-server-cloudimg-amd64.qcow2"
  node_name    = "lab"
  url          = "https://cloud-images.ubuntu.com/releases/26.04/release/ubuntu-26.04-server-cloudimg-amd64.img"
}

resource "proxmox_virtual_environment_vm" "vm1" {
  name      = "vm1"
  node_name = "lab"

  disk {
    datastore_id = "local-lvm"
    import_from  = proxmox_download_file.ubuntu.id
    interface    = "scsi0"
    size         = 20
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi1"
    size         = 20
  }

  network_device {
    bridge = "vmbr0"
  }

  cpu {
    cores = 2
    type  = "host"
  }

  memory {
    dedicated = 2048
  }

  operating_system {
    type = "l26"
  }

  initialization {
    ip_config {
      ipv4 {
        address = "192.168.50.150/24"
        gateway = "192.168.50.1"
      }
    }

    user_account {
      username = "root"
      keys     = [trimspace(file("~/.ssh/id_ed25519.pub"))]
    }
  }
}
