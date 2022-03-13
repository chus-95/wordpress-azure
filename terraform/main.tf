# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.99.0"
    }
  }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group

resource "azurerm_resource_group" "rg" {
    name     =  var.resource_group
    location = var.location

    tags = {
        environment = "CP2"
    }

}

# Creación de red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
        
resource "azurerm_virtual_network" "vnet" {
    name                = "terraformnet"
    address_space       = ["10.0.0.0/16"]
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = "CP2"
    }
}

# Creación de subnet
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "subnet" {
    name                   = "terraformsubnet"
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.vnet.name
    address_prefixes       = ["10.0.0.0/24"]

}

# IP pública
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "myPublicIp1" {
  count               = length(var.vmachines)
  name                = "terraformIp-${var.vmachines[count.index]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"

    tags = {
        environment = "CP2"
    }

}# Security group
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group

resource "azurerm_network_security_group" "mySecGroup" {
    count               = length(var.vmachines)
    name                = "terraformSsh-${var.vmachines[count.index]}"
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "CP2"
    }
}

# Create NIC
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface

resource "azurerm_network_interface" "nic" {
  count               = length(var.vmachines)
  name                = "terraformnic-${var.vmachines[count.index]}" 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

    ip_configuration {
    name                           = "myipconfiguration1"
    subnet_id                      = azurerm_subnet.subnet.id
    private_ip_address_allocation  = "Dynamic"
    #private_ip_address             = "10.0.1.10"
    public_ip_address_id           = element(azurerm_public_ip.myPublicIp1.*.id, count.index)
  }

    tags = {
        environment = "CP2"
    }

}


# Vinculamos el security group al interface de red
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "mySecGroupAssociation1" {
    count                     = length(var.vmachines)
    network_interface_id      = azurerm_network_interface.nic[count.index].id
    network_security_group_id = azurerm_network_security_group.mySecGroup[count.index].id

}

# Creat Storage account
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account


resource "random_id" "randomId" {
    keepers={
        #Generates a new ID only when a new resource group is defined
        resource_group=azurerm_resource_group.rg.name
    }

    byte_length = 8
}

#Storage account should hace unique name, so we create a random numbers to add in the name
resource "azurerm_storage_account" "stAccount" {
    name                     = "diag${random_id.randomId.hex}"
    resource_group_name      = azurerm_resource_group.rg.name
    location                 = azurerm_resource_group.rg.location
    account_tier             = "Standard"
    account_replication_type = "LRS"

    tags = {
        environment = "CP2"
    }

}

resource "tls_private_key" "example_ssh" {
    algorithm = "RSA"
    rsa_bits = 4096
}

output "tls_private_key" { 
    value = tls_private_key.example_ssh.private_key_pem 
    sensitive = true
}

# Creamos una máquina virtual
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine

resource "azurerm_linux_virtual_machine" "myVM1" {
    count               = length(var.vmachines)
    name                = "terraformVM-${var.vmachines[count.index]}"
    resource_group_name = azurerm_resource_group.rg.name
    location            = azurerm_resource_group.rg.location
    size                = var.vmsize[count.index]
    admin_username      = "maria"
    network_interface_ids = [element(azurerm_network_interface.nic.*.id, count.index)]
    disable_password_authentication = true
    

    admin_ssh_key {
        username = "maria"
        #public_key = tls_private_key.example_ssh.public_key_openssh
        public_key = file("~/.ssh/id_rsa.pub")
        
    }


    os_disk {
        caching              = "ReadWrite"
        storage_account_type = "Standard_LRS"
    }

    plan {
        name      = "centos-8-stream-free"
        product   = "centos-8-stream-free"
        publisher = "cognosys"
    }

    source_image_reference {
        publisher = "cognosys"
        offer     = "centos-8-stream-free"
        sku       = "centos-8-stream-free"
        version   = "1.2019.0810"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }

    tags = {
        environment = "CP2"
    }

}


























