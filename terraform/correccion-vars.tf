variable "vmachines" {
  type = list(string)
  description = "vmachines"
  default = ["master", "worker1"]
}

variable "vmsize" {
  type = list(string)
  description = "vmsize"
  default = ["Standard_D12_v2", "Standard_DS11-1_v2"]
}


variable "location" {
  type = string
  description = "Región de Azure donde crearemos la infraestructura"
  default = "West Europe"
}

variable "resource_group" {
  type = string
  description = "Nombre para la resource group"
  default = "kubernetes_chus"
}



# Check machines: https://azureprice.net/
variable "vm_size" {
  type = string
  description = "Tamaño de la máquina virtual"
  default = "Standard_D1_v2" # 3.5 GB, 1 CPU 
}
#Para los workers puede estar bien usar la propuesta: Standard_DS11-1_v2 #14 GB, 1 CPU 
#Para el master Standard_D12_v2 # 28 GB, 4 CPU 
##Para la primera prueba que hagamos yo pondría: 2 workers + 1nf + master cada uno con Standard_D1_v2

