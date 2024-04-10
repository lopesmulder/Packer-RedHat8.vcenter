packer {
  required_version = ">= 1.10.0"
  required_plugins {
    vmware = {
      version = ">= 1.2.3"
      source  = "github.com/hashicorp/vsphere"
    }
  }
}

source "vmware-iso" "rhel93" {
  username = ""
  password = ""
  vcenter_server      = ""
  insecure_connection = true
  datacenter          = ""
  cluster             = ""
  datastore           = ""
  folder              = ""
  vm_name             = "rhel93tmplt"
  guest_os_type       = "rhel9_64Guest"
  firmware            = "bios"
  vm_version          = "19"
  CPUs                = 2
  cpu_cores           = 1
  RAM                 = 4096
  network_adapters {
    network_card = "vmxnet3"
    network      = "serviceVMNetwork"
  }
  disk_controller_type = ["pvscsi"]
  storage {
    disk_size             = 40960
    disk_thin_provisioned = true
  }
  iso_paths = [
    "[datastorenl_002] ISO/rhel-9.3-x86_64-dvd.iso"
  ]
  boot_command = [
    "<tab><bs><bs><bs><bs><bs>inst.text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/ks.cfg<enter><wait15s><esc>"
  ]
  boot_wait           = "1m"
  ip_wait_timeout     = "20m"
  http_directory      = "http"
  communicator        = "ssh"
  ssh_port            = 22
  ssh_username        = ""
  ssh_password        = ""
  ssh_timeout         = "30m"
  shutdown_command    = "echo 'axians'|sudo systemctl poweroff"
  shutdown_timeout    = "10m"
  remove_cdrom        = true
  convert_to_template = true
}

build {
  name = "Red Hat Enterprise Linux 9.3"
  sources = [
    "source.vmware-iso.rhel93"
  ]
  provisioner "shell" {
    execute_command = "echo 'axians'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    inline          = [
      "dnf -y update",
      "echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config",
      "echo 'axians ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers"
    ]
  }
  provisioner "shell" {
    execute_command = "echo 'axians'|{{ .Vars }} sudo -S -E bash '{{ .Path }}'"
    scripts         = ["scripts/cleanup.sh"]
  }
}
