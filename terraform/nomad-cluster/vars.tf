variable "vsphere_user" {
  description = "vSphere user"
  default = "administrator@vsphere.local"
}

variable "vsphere_password" {
  description = "vsphere password"
}

variable "vsphere_server" {
  description = "vsphere server"
  default = "grtvcenter01.grt.local"
}

variable "root_password" {
  description = "root password"
  default = "password"
}

variable "vm_password" {
  description = "vm root password"
}

variable "template_name" {
  description = "virtual machine template name"
  default = "centos7base"
}
