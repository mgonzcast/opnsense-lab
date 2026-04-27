# opnsense-lab
This is part of the Kali lab and oilrig lab to automate the deployment of the Oilrig lab

To connect all the LANs of the lab you need a router. This router has 3 isolated LANs and a WAN connection using DHCP
The WAN connection is only connected to the Internet in case there is a need to download files (i.e.: for deploying Caldera)

This is for Virtualbox and Vmware Workstation.

You need to create an isos folder and download the corresponding OPNSense iso file.

The Packer file creates the base box using only network interface (LAN)
At the end of the provisioning I copy a file called config-OPNSense.xml to /conf/config.xml
The configuration contained there is my configuration to be loaded by Vagrant
It is not cleanest way to do it
Vagrant and Vmware messes up with network interfaces order, so you need to set it up using pciSlotNumber so MAC addresses and LANs are in the right order

For bringing everything you need to run:

```
packer build opnsense.pkr.hcl
vagrant box add opnsense opnsense-vmware.box
vagrant box add opnsense opnsense-virtualbox.box
```

Unfortunately Vagrant doesn´t allow to deploy Virtualbox and Vmware at the same time so you need to destroy before any VM and then bring up the VM:

```
vagrant destroy opnsense -f
vagrant up opnsense --provider=virtualbox  # or --provider=vmware_desktop
```
