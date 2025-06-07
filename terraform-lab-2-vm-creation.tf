# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "RG12"
  location = "eastus2"
  
  tags = {
    Environment = "Terraform Getting Started"
    Team        = "DevOps"
  }
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "myTFVnet"
  address_space       = ["172.16.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet for worksSN
resource "azurerm_subnet" "worksSN" {
  name                 = "worksSN"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.1.0/24"]
}

# Create subnet for AppSN
resource "azurerm_subnet" "AppSN" {
  name                 = "AppSN"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["172.16.2.0/24"]
}

# Create Network Security Group with SSH rule
resource "azurerm_network_security_group" "ssh_nsg" {
  name                = "ssh-access-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Environment = "Development"
  }
}

# Associate NSG with the worksSN subnet
resource "azurerm_subnet_network_security_group_association" "worksSN_nsg" {
  subnet_id                 = azurerm_subnet.worksSN.id
  network_security_group_id = azurerm_network_security_group.ssh_nsg.id
}

# Create public IP address
resource "azurerm_public_ip" "public_ip" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "Development"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic" {
  name                = "myNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfig"
    subnet_id                     = azurerm_subnet.worksSN.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }

  tags = {
    Environment = "Development"
  }
}

# Create Ubuntu VM in worksSN
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "myUbuntuVM"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = "Standard_B2s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myOSDisk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "myUbuntuVM"
  admin_username = "sysadmin"
  admin_password = "Password123#"
  disable_password_authentication = false

  tags = {
    Environment = "Development"
  }
}
