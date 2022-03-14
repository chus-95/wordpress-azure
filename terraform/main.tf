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
        environment = var.environment
    }

}

# Network creation
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network
        
resource "azurerm_virtual_network" "vnet" {
    name                = var.virtual_network
    address_space       = var.virtual_network_address
    location            = azurerm_resource_group.rg.location
    resource_group_name = azurerm_resource_group.rg.name

    tags = {
        environment = var.environment
    }
}

# Subnet creation
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet

resource "azurerm_subnet" "subnet" {
    name                   = var.virtual_subnet
    resource_group_name    = azurerm_resource_group.rg.name
    virtual_network_name   = azurerm_virtual_network.vnet.name
    address_prefixes       =var.virtual_subnet_address

}

# Public IP 
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip

resource "azurerm_public_ip" "myPublicIp1" {
  count               = length(var.vmachines)
  name                = "terraformIp-${var.vmachines[count.index]}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = var.IP_allocation
  sku                 = "Basic"

    tags = {
        environment = var.environment
    }

}

# Security group
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
        environment = var.environment
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
    name                           = var.nic_ip_conf
    subnet_id                      = azurerm_subnet.subnet.id
    private_ip_address_allocation  = var.nic_ip_allocation
    #private_ip_address             = "10.0.1.10"
    public_ip_address_id           = element(azurerm_public_ip.myPublicIp1.*.id, count.index)
  }

    tags = {
        environment = var.environment
    }

}

# Link the security group to the network interface
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association

resource "azurerm_network_interface_security_group_association" "mySecGroupAssociation1" {
    count                     = length(var.vmachines)
    network_interface_id      = azurerm_network_interface.nic[count.index].id
    network_security_group_id = azurerm_network_security_group.mySecGroup[count.index].id

}

# Create Storage account
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
        environment = var.environment
    }

}

# Virtual machine creation
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
        username = var.admin_ssh_key_user
        #public_key = tls_private_key.example_ssh.public_key_openssh
        public_key = file("~/.ssh/id_rsa.pub")
        
    }

    os_disk {
        caching              = var.onDisk_caching
        storage_account_type = var.onDisk_storage
    }

    plan {
        name      = var.vm_name
        product   = var.vm_product
        publisher = var.vm_publisher
    }

    source_image_reference {
        publisher = var.vm_publisher
        offer     = var.vm_name
        sku       = var.vm_name
        version   = var.vm_verion_img
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.stAccount.primary_blob_endpoint
    }

    tags = {
        environment = var.environment
    }

}