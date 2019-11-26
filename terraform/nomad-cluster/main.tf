terraform {
  backend "local" {}
}

provider "vsphere" {
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"
  vsphere_server = "${var.vsphere_server}"

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = "GRT"
}

data "vsphere_datastore" "datastore" {
  name          = "Local_Storage"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_compute_cluster" "cluster" {
  name          = "GRT-Cluster"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "${var.template_name}"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "nomadserver" {
  name       = "nomadserver"
  num_cpus   = 2
  memory     = 4096

  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "nomadserver"
        domain    = "grt.local"
      }

      network_interface {}
      dns_server_list = ["10.0.0.200"]
      ipv4_gateway = "10.0.0.1"
    }

  }

  provisioner "puppet-bolt" {
    username = "root"
    password = "${var.vm_password}"
    use_sudo = true
    plan    = "bolt_hashistack::nomad"
    parameters  = {
      consul_servers = vsphere_virtual_machine.consulserver.default_ip_address
    }
    connection {
      type = "ssh"
      host = "${self.default_ip_address}"
      user = "root"
      password = "${var.vm_password}"
      timeout  = "5m"
    }
  }
}

resource "vsphere_virtual_machine" "nomadclient" {
  name       = "nomadclient${count.index +1}"
  count      = 1
  num_cpus   = 2
  memory     = 4096

  resource_pool_id = "${data.vsphere_compute_cluster.cluster.resource_pool_id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"

  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"
  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"

    customize {
      linux_options {
        host_name = "nomadclient${count.index +1}"
        domain    = "grt.local"
      }

      network_interface {}
      dns_server_list = ["10.0.0.200"]
      ipv4_gateway = "10.0.0.1"
    }

  }

  provisioner "puppet-bolt" {
    username = "root"
    password = "${var.vm_password}"
    use_sudo = true
    plan     = "bolt_hashistack::nomad_client"
    module_path = "~/.puppetlabs/bolt-code/modules:~/.puppetlabs/bolt-code/site-modules"
    parameters  = {
      servers = vsphere_virtual_machine.nomadserver.default_ip_address
      consul_servers = vsphere_virtual_machine.consulserver.default_ip_address
      version = "1.6.1"
    }
    connection {
      type = "ssh"
      host = "${self.default_ip_address}"
      user = "root"
      password = "${var.vm_password}"
      timeout  = "5m"
    }
  }
}

output "nomad_url" {
  value = "http://${vsphere_virtual_machine.nomadserver.default_ip_address}:4646"
}