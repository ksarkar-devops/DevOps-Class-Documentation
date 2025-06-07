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
  name     = "RG11"
  location = "eastus2"
  
  tags = {
    Environment = "Terraform Getting Started"
    Team = "DevOps"
  }
}
# Create a HO virtual network
resource "azurerm_virtual_network" "HO" {
  name                = "HO"
  address_space       = ["172.16.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name

}
# Create subnet for HO_subnet
resource "azurerm_subnet" "HO_subnet" {
  name                 = "HO_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.HO.name
  address_prefixes     = ["172.16.10.0/24"]
}


# Create a Branch virtual network
resource "azurerm_virtual_network" "Branch" {
  name                = "Branch"
  address_space       = ["172.20.0.0/16"]
  location            = "eastus2"
  resource_group_name = azurerm_resource_group.rg.name

}
# Create subnet for Branch_subnet
resource "azurerm_subnet" "Branch_subnet" {
  name                 = "Branch_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.Branch.name
  address_prefixes     = ["172.20.10.0/24"]
}


# Create Peering between HOvnet and Branchvnet
resource "azurerm_virtual_network_peering" "peering_hovnet_to_Branchvnet" {
  name                      = "HOvnet-to-Branchvnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.HO.name
  remote_virtual_network_id = azurerm_virtual_network.Branch.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
}

resource "azurerm_virtual_network_peering" "peering_Branchvnet_to_hovnet" {
  name                      = "Branchvnet-to-HOvnet"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.Branch.name
  remote_virtual_network_id = azurerm_virtual_network.HO.id
  allow_forwarded_traffic   = true
  allow_virtual_network_access = true
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

# Associate NSG with the HO_subnet subnet
resource "azurerm_subnet_network_security_group_association" "HO_subnet_nsg" {
  subnet_id                 = azurerm_subnet.HO_subnet.id
  network_security_group_id = azurerm_network_security_group.ssh_nsg.id
}

# Associate NSG with the branch_subnet subnet
resource "azurerm_subnet_network_security_group_association" "branch_subnet_nsg" {
  subnet_id                 = azurerm_subnet.Branch_subnet.id
  network_security_group_id = azurerm_network_security_group.ssh_nsg.id
}

# Create public IP address
resource "azurerm_public_ip" "public_ip_vm1" {
  name                = "myPublicIP_vm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "Development"
  }
}

# Create public IP address
resource "azurerm_public_ip" "public_ip_vm2" {
  name                = "myPublicIP_vm2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"

  tags = {
    Environment = "Development"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic_HO_subnet" {
  name                = "myNIC_HO_subnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfig_HO_subnet"
    subnet_id                     = azurerm_subnet.HO_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_vm1.id
  }

  tags = {
    Environment = "Development"
  }
}

# Create network interface
resource "azurerm_network_interface" "nic_branch_subnet" {
  name                = "myNIC_branch_subnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "myNICConfig_branch_subnet"
    subnet_id                     = azurerm_subnet.Branch_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip_vm2.id
  }

  tags = {
    Environment = "Development"
  }
}

# Create Ubuntu VM in worksSN
resource "azurerm_linux_virtual_machine" "vm1" {
  name                  = "myUbuntuVM1"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_HO_subnet.id]
  size                  = "Standard_B2s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myOSDisk_vm1"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "myUbuntuVM1"
  admin_username = "sysadmin"
  admin_password = "Password123#"
  disable_password_authentication = false

  tags = {
    Environment = "Development"
  }
}

# Create Ubuntu VM in worksSN
resource "azurerm_linux_virtual_machine" "vm2" {
  name                  = "myUbuntuVM2"
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.nic_branch_subnet.id]
  size                  = "Standard_B2s"

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_disk {
    name              = "myOSDisk_vm2"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  computer_name  = "myUbuntuVM2"
  admin_username = "sysadmin"
  admin_password = "Password123#"
  disable_password_authentication = false

  tags = {
    Environment = "Development"
  }
}
