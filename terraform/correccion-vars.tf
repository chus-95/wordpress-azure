
variable "resource_group" {
  type = string
  description = "Resource group name"
  default = "kubernetes_chus"
}

variable "location" {
  type = string
  description = "Azure Region to create infra"
  default = "West Europe"
}

variable "environment" {
  type = string
  description = "Environment used to deploy"
  default = "CP2"
}

variable "virtual_network" {
  type = string
  description = "Virtual network name"
  default = "terraformnet"
}

variable "virtual_network_address" {
  type = string
  description = "Virtual network address"
  default = ["10.0.0.0/16"]
}


variable "virtual_subnet" {
  type = string
  description = "Virtual subnet name"
  default = "terraformsubnet"
}

variable "virtual_subnet_address" {
  type = string
  description = "Virtual subnet address"
  default = ["10.0.0.0/24"]
}

variable "IP_allocation" {
  type = string
  description = "IP allocation"
  default = "Dynamic"
}

variable "nic_ip_conf" {
  type = string
  description = "IP allocation"
  default = "myipconfiguration1"
}

variable "nic_ip_allocation" {
  type = string
  description = "Nic IP allocation"
  default = "Dynamic"
}

variable "vmachines" {
  type = list(string)
  description = "Number and name machines"
  default = ["master", "worker1"]
}

variable "vmsize" {
  type = list(string)
  description = "Machines to deploy"
  default = ["Standard_D12_v2", "Standard_DS11-1_v2"]
}

variable "admin_ssh_key_user" {
  type = string
  description = "User in azure"
  default = "maria"
}

variable "onDisk_caching" {
  type = string
  description = "Caching on disk"
  default = "ReadWrite"
}

variable "onDisk_storage" {
  type = string
  description = "Storage on disk"
  default = "Standard_LRS"
}

variable "vm_name" {
  type = string
  description = "Name virtual machine"
  default = "centos-8-stream-free"
}
variable "vm_product" {
  type = string
  description = "Product in virtual machine"
  default = "centos-8-stream-free"
}
variable "vm_publisher" {
  type = string
  description = "Publisher in virtual machine"
  default = "cognosys"
}

variable "vm_verion_img" {
  type = string
  description = "Verion image virtual machine"
  default = "1.2019.0810"
}