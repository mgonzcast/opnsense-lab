Vagrant.configure("2") do |config|

  # -------------------------------------------------------------
  # PLUGIN CHECK AND INSTALLATION
  # -------------------------------------------------------------
  config.vagrant.plugins = ["vagrant-vbguest", "vagrant-reload", "vagrant-vmware-desktop"]
  
  config.vm.guest = :freebsd 
  config.ssh.shell = "sh"

  config.ssh.forward_agent = true

  # ============================================================================
  # BOX CONFIGURATION
  # ============================================================================
  config.vm.box = "opnsense"  
  
  # Default Synced Folders usually break on standard FreeBSD/OPNsense builds
  # without guest tools heavily customized, so it is safest to disable it.
  config.vm.synced_folder ".", "/vagrant", disabled: true

  # -------------------------------------------------------------
  # NETWORK INTERFACES 
  # (eth0 is natively mapped to NAT by Vagrant for SSH access)
  # -------------------------------------------------------------


  config.vm.define "opnsense" do |fw|
    fw.vm.hostname = "opnsense"
    fw.vm.boot_timeout = 300
  
    # ============================================================================
    # SSH CONFIGURATION
    # ============================================================================
    fw.ssh.username = "root"
    fw.ssh.password = "opnsense"
    fw.ssh.insert_key = true
    fw.ssh.forward_agent = true
    #fw.ssh.shell = "sh" # OPNsense defaults to csh/tcsh; force basic sh for Vagrant

  
    # ============================================================================
    # VIRTUALBOX PROVIDER CONFIGURATION
    # ============================================================================
    fw.vm.provider "virtualbox" do |vb|
      vb.name = "opnsense-vm"
      vb.gui = true                           
      vb.cpus = 1
      vb.memory = 1024
      
      # Display and hardware settings
      vb.customize ["modifyvm", :id, "--vram", "16"]
      vb.customize ["modifyvm", :id, "--audio", "none"]
      vb.customize ["modifyvm", :id, "--boot1", "disk"]

      
      # Ensure network mappings match the expected internal networks
      vb.customize ["modifyvm", :id, "--nic2", "intnet"]
      vb.customize ["modifyvm", :id, "--intnet2", "intnet-attack"]
      vb.customize ["modifyvm", :id, "--nic3", "intnet"]
      vb.customize ["modifyvm", :id, "--intnet3", "intnet-target"]
      vb.customize ["modifyvm", :id, "--nic4", "intnet"]
      vb.customize ["modifyvm", :id, "--intnet4", "intnet-siem"]
    end
    
    # ============================================================================
    # VMWARE PROVIDER CONFIGURATION
    # ============================================================================
    fw.vm.provider "vmware_desktop" do |v|
      v.vmx["displayName"] = "opnsense-vm"
      v.gui = true                            
      v.cpus = 1
      v.memory = 1024
      v.allowlist_verified = true
     
      # We need to rearrange order of interfaces since VMWare changes the order
      # Interface 0 - WAN
      v.vmx["ethernet0.virtualDev"] = "e1000"
      v.vmx["ethernet0.connectionType"] = "nat"
      v.vmx["ethernet0.present"] = "TRUE"
      v.vmx["ethernet0.pciSlotNumber"] = "32"
      v.vmx["ethernet0.addressType"] = "generated"
      
      # Interface 1 - intnet-attack LAN segment
      v.vmx["ethernet1.present"] = "TRUE"
      v.vmx["ethernet1.connectionType"] = "pvn"
      v.vmx["ethernet1.pvnID"] = "52 5d ed 5d e8 17 cd bc-96 1b 07 bb fa bd c1 20"
      v.vmx["ethernet1.virtualDev"] = "e1000"
      v.vmx["ethernet1.pciSlotNumber"] = "35"
      v.vmx["ethernet1.addressType"] = "generated"

      # Interface 2 - intnet-target LAN segment
      v.vmx["ethernet2.present"] = "TRUE"
      v.vmx["ethernet2.connectionType"] = "pvn"
      v.vmx["ethernet2.pvnID"] = "52 3d 44 e8 0e 9a 0b ca-29 7a 57 3c 4f 95 14 89"
      v.vmx["ethernet2.virtualDev"] = "e1000"
      v.vmx["ethernet2.pciSlotNumber"] = "34"
      v.vmx["ethernet2.addressType"] = "generated"

      # Interface 3 - intnet-siem LAN segment
      v.vmx["ethernet3.present"] = "TRUE"
      v.vmx["ethernet3.connectionType"] = "pvn"
      v.vmx["ethernet3.pvnID"] = "52 05 1d 2f 2c d7 49 05-4a 4e 1b f4 66 d8 ea 7d"
      v.vmx["ethernet3.virtualDev"] = "e1000"
      v.vmx["ethernet1.pciSlotNumber"] = "33"
      v.vmx["ethernet3.addressType"] = "generated"
    end
    
    # ============================================================================
    # PROVISIONING 
    # ============================================================================
    
  end
end