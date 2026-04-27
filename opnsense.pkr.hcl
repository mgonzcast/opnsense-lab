packer {
  required_plugins {
    virtualbox = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    vmware = {
      version = "~> 1.0"
      source  = "github.com/hashicorp/vmware"
    }
  }
}

# ==============================================================================
# VARIABLES
# ==============================================================================

variable "iso_urls" {
  type    = list(string)
  default = ["isos/OPNsense-25.1-dvd-amd64.iso"]
}

variable "iso_checksum" {
  type    = string
  default = "sha256:E4C178840AB1017BF80097424DA76D896EF4183FE10696E92F288D0641475871"
}

variable "vm_name" {
  type    = string
  default = "opnsense"
}

variable "disk_size" {
  type    = number
  default = 15360
}

variable "memory" {
  type    = string
  default = "3072"
}

variable "cpus" {
  type    = string
  default = "1"
}

variable "ssh_username" {
  type    = string
  default = "root"
}

variable "ssh_password" {
  type    = string
  default = "opnsense"
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_wait_timeout" {
  type    = string
  default = "10000s"
}

variable "boot_wait" {
  type    = string
  default = "3s"
}

variable "boot_command" {
  type    = list(string)
  default = [
    "1",
    "<wait3m>",
    "root<enter><wait>", "opnsense<enter>", 
#    "<wait>1<enter><wait3s>",
#    "N<enter><wait>",
#    "N<enter><wait>",
#    "em0<enter><wait>",
#    "em1<enter><wait>",
#    "<enter><wait>",
#    "y<enter>",
    "8<enter>",
    "opnsense-installer<enter><wait3s>",
    "<enter><wait3s>",
    "<enter><wait3s>",
    "<enter><wait3s>",
    "<spacebar><wait><enter><wait3s>",
    "<left><enter><wait3s>",
    "<wait5m><down><enter><wait3s>",
    "<enter><wait3m>",
    "root<enter><wait>", "opnsense<enter><wait>", "<wait>8<enter>",
    "<wait>dhclient em0<enter><wait10>",
    "echo 'PasswordAuthentication yes' >> /usr/local/etc/ssh/sshd_config<enter>",
    "echo 'PermitRootLogin yes' >> /usr/local/etc/ssh/sshd_config<enter>",
    #"service openssh enable<enter>",
    "service openssh onerestart<enter>"
    #"curl http://{{ .HTTPIP }}:{{ .HTTPPort }}/config-OPNSense.xml | sed '/^$/d' > /root/config-OPNSense.xml<enter><wait30s>"
  ]

}

# ==============================================================================
# VIRTUALBOX SOURCE
# ==============================================================================
source "virtualbox-iso" "opnsense" {
  vm_name                 = var.vm_name
  guest_os_type           = "FreeBSD_64"
  iso_urls                = var.iso_urls
  iso_checksum            = var.iso_checksum
  disk_size               = var.disk_size
  
  #http_directory          = "http"
  #http_port_min           = 8100
  
  boot_wait               = var.boot_wait
  boot_command            = var.boot_command

  ssh_username            = var.ssh_username
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_wait_timeout        = var.ssh_wait_timeout
  
  shutdown_command        = "shutdown -p now"
  output_directory        = "output-virtualbox"
  virtualbox_version_file = ".vbox_version"
  guest_additions_mode    = "disable"

  vboxmanage = [
    ["modifyvm", "{{.Name}}", "--memory", var.memory],
    ["modifyvm", "{{.Name}}", "--cpus", var.cpus],
    ["modifyvm", "{{.Name}}", "--boot1", "disk"],
    ["modifyvm", "{{.Name}}", "--boot2", "dvd"],
    
    # Interface 1 (LAN - em0)
    ["modifyvm", "{{.Name}}", "--nat-localhostreachable1", "on"],    
    ["modifyvm", "{{.Name}}", "--nic1", "nat"]

   

  ]


}

# ==============================================================================
# VMWARE SOURCE
# ==============================================================================
source "vmware-iso" "opnsense" {
  vm_name                 = var.vm_name
  guest_os_type           = "freebsd-64" 
  iso_urls                = var.iso_urls
  iso_checksum            = var.iso_checksum
  disk_size               = var.disk_size
  
  #http_directory          = "http"
  #http_port_min           = 8100
  
  boot_wait               = var.boot_wait
  boot_command            = var.boot_command

  ssh_username            = var.ssh_username
  ssh_password            = var.ssh_password
  ssh_port                = var.ssh_port
  ssh_wait_timeout        = var.ssh_wait_timeout
  
  shutdown_command        = "shutdown -p now"
  output_directory        = "output-vmware"

  cpus      = var.cpus
  memory    = var.memory
  network_adapter_type = "e1000"

 

}
# ==============================================================================
# BUILD CONFIGURATION
# ==============================================================================
build {
  sources = [
    "source.virtualbox-iso.opnsense",
    "source.vmware-iso.opnsense"
  ]

  # This is my configuration to use when bringing the machine up with Vagrant, you will have to create your configuration file accordingly or remove these lines
  provisioner "file" {
    source      = "config-OPNSense.xml"
    destination = "/tmp/config.xml"
  }

  # Move the file into the correct OPNsense directory inside the VM
  provisioner "shell" {
    execute_command = "chmod +x {{ .Path }}; env {{ .Vars }} sh -c '{{ .Path }}'"
    inline = [
      "cp /tmp/config.xml /conf/config.xml",
      "chmod 644 /conf/config.xml",
      # Cleanup any leftovers
      "rm -f /etc/rc.conf",
      "rm -f /var/db/dhclient.leases.*"
    ]
  }



  # Post-Processor Settings for Vagrant - VirtualBox
  post-processor "vagrant" {
    provider_override   = "virtualbox"
    output              = "opnsense-virtualbox.box"
    keep_input_artifact = false
    only                = ["virtualbox-iso.opnsense"]
  }
  
  # Post-Processor Settings for Vagrant - VMware
  post-processor "vagrant" {
    provider_override   = "vmware"
    output              = "opnsense-vmware.box"
    keep_input_artifact = false
    only                = ["vmware-iso.opnsense"]
  }
}