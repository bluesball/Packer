packer {
  required_plugins {
    proxmox = {
      version = " >= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

source "proxmox-iso" "ubuntu-server-2204" {
  
  # Conexão com o proxmox
  proxmox_url               = "${var.proxmox_api_url }"
  username                  = "${var.proxmox_api_token_id}"
  token                     = "${var.proxmox_api_token_secret}"
  insecure_skip_tls_verify  = true
  
  # Definições da VM
  node                      = "pve1"
  vm_name                   = "${var.px_vmname}"
  vm_id                     = "9000"
  template_name            = "${var.px_vmname}"
  template_description     = "Ubuntu-22.04"

  # Imagem do S.O a ser usada
  iso_storage_pool          = "."
  iso_file                  = "local:iso/ubuntu-22.04-live-server-amd64.iso"
  iso_checksum              = "84aeaf7823c8c61baa0ae862d0a06b03409394800000b3235854a6b38eb4856f" #ubuntu-22.04-live-server-amd64.iso
  unmount_iso              = true
  
  # Config de sistema da VM
  qemu_agent               = true

  # Config de Disco
  scsi_controller     = "virtio-scsi-pci"

  disks {
    type              = "scsi"
    disk_size         = "32G"
    storage_pool      = "standard"
    storage_pool_type = "lvm"
    #type              = "virtio"
  }

  # CPU e RAM Config
  memory                   = 2048
  cores                    = 2
  sockets                  = 1

  # VM Network Settings
  network_adapters {
    model                   = "virtio"
    bridge                  = "vmbr0"
    firewall                = "false"
    } 

  # Cloud-Init
  cloud_init = true
  cloud_init_storage_pool = "local-lvm"

  # PACKER Boot Commands
  boot_command = [
    "<esc><wait>",
    "e<wait>",
    "<down><down><down><end>",
    "<bs><bs><bs><bs><wait>",
    "ip=${var.ip_add}::${var.ip_gateway}:${var.ip_mask}::::${var.ip_dns} ",
    "autoinstall ds=nocloud-net\\;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ ---<wait>",
    "<f10><wait>"
  ]
  boot = "c"
  boot_wait = "5s"

  # PACKER Autoinstall
  http_directory            = "./http"
  # Caso precise setar o IP e porta no boot coomand (http://{{ .HTTPIP }}:{{ .HTTPPort }})
  http_bind_address         = "IP da maquina que tá executando o Packer"
  http_port_min             = porta
  http_port_max             = porta

  communicator              = "ssh"
  ssh_username              = "ubuntu"
  ssh_private_key_file      = "caminho/para/a/chave/privada"
  ssh_timeout               = "30m"
  ssh_pty                   = true
  ssh_handshake_attempts    = 20
  
   

}

build {

    name = "ubuntu-server-template"
    sources = ["source.proxmox-iso.ubuntu-server-2204"]

    
    provisioner "shell" {
        inline = [
            "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "sudo rm /etc/ssh/ssh_host_*",
            "sudo truncate -s 0 /etc/machine-id",
            "sudo apt -y autoremove --purge",
            "sudo apt -y clean",
            "sudo apt -y autoclean",
            "sudo cloud-init clean",
            "sudo rm -f /etc/cloud/cloud.cfg.d/subiquity-disable-cloudinit-networking.cfg",
            "sudo sync"
        ]
    }

    provisioner "file" {
      source = "files/99-pve.cfg"
      destination = "/tmp/99-pve.cfg" 
    }

    provisioner "shell" {
        inline = [ "sudo cp /tmp/99-pve.cfg /etc/cloud/cloud.cfg.d/99-pve.cfg" ]
    }

    provisioner "shell" {
      script = "script/install.sh"

    }
}