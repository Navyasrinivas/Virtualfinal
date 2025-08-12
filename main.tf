terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "existing" {
  name = "rg-cp-navya-kongala"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "windows-vnetfinal2"
  address_space       = ["10.0.0.0/16"]
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  tags = {
    Environment = "Dev"
    Owner       = "Navya"
    Department  = "delivery"
  }
}

resource "azurerm_subnet" "subnet" {
  name                 = "windows-subnetfinal2"
  resource_group_name  = data.azurerm_resource_group.existing.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]

  tags = {
    Environment = "Dev"
    Owner       = "Navya"
    Department  = "delivery"
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "windows-nicfinal2"
  location            = data.azurerm_resource_group.existing.location
  resource_group_name = data.azurerm_resource_group.existing.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Environment = "Dev"
    Owner       = "Navya"
    Department  = "delivery"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "windows-vmfinal2"
  resource_group_name = data.azurerm_resource_group.existing.name
  location            = data.azurerm_resource_group.existing.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  admin_password      = "P@ssw0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  tags = {
    Environment = "Dev"
    Owner       = "Navya"
    Department  = "delivery"
  }
}
