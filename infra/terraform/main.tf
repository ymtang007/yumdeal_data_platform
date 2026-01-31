resource "azurerm_resource_group" "res-0" {
  location = "eastus"
  name     = "yumdeal-prod"
}
resource "azurerm_ssh_public_key" "res-1" {
  location            = "eastus2"
  name                = "yumdeal-vm-D2s_key"
  public_key          = var.ssh_public_key
  resource_group_name = azurerm_resource_group.res-0.name
  tags = var.common_tags
}
resource "azurerm_linux_virtual_machine" "res-2" {
  admin_username        = var.vm_admin_username
  location              = "eastus2"
  name                  = "yumdeal-vm-D2s"
  network_interface_ids = [azurerm_network_interface.res-3.id]
  resource_group_name   = azurerm_resource_group.res-0.name
  size                  = "Standard_D2s_v3" 
  tags = var.common_tags
  zone = "1"
  additional_capabilities {
  }
  admin_ssh_key {
    public_key = var.ssh_public_key
    username   = var.vm_admin_username
  }
  boot_diagnostics {
  }
  identity {
    type = "SystemAssigned"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}
resource "azurerm_network_interface" "res-3" {
  location            = "eastus2"
  name                = "yumdeal-vm-d2s43_z1"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = var.common_tags
  ip_configuration {
    name                          = "ipconfig1"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.res-10.id
    subnet_id                     = azurerm_subnet.res-12.id
  }
}
resource "azurerm_network_interface_security_group_association" "res-4" {
  network_interface_id      = azurerm_network_interface.res-3.id
  network_security_group_id = azurerm_network_security_group.res-5.id
}
resource "azurerm_network_security_group" "res-5" {
  location            = "eastus2"
  name                = "yumdeal-vm-D2s-nsg"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = var.common_tags
}
resource "azurerm_network_security_rule" "res-6" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "8080"
  direction                   = "Inbound"
  name                        = "AllowAirflow"
  network_security_group_name = "yumdeal-vm-D2s-nsg"
  priority                    = 330
  protocol                    = "*"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = var.admin_ip_address
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-5,
  ]
}
resource "azurerm_network_security_rule" "res-7" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "8000"
  direction                   = "Inbound"
  name                        = "AllowFastAPI"
  network_security_group_name = "yumdeal-vm-D2s-nsg"
  priority                    = 310
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-5,
  ]
}
resource "azurerm_network_security_rule" "res-8" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "443"
  direction                   = "Inbound"
  name                        = "AllowHTTPS"
  network_security_group_name = "yumdeal-vm-D2s-nsg"
  priority                    = 320
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = "*"
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-5,
  ]
}
resource "azurerm_network_security_rule" "res-9" {
  access                      = "Allow"
  destination_address_prefix  = "*"
  destination_port_range      = "22"
  direction                   = "Inbound"
  name                        = "default-allow-ssh"
  network_security_group_name = "yumdeal-vm-D2s-nsg"
  priority                    = 300
  protocol                    = "Tcp"
  resource_group_name         = azurerm_resource_group.res-0.name
  source_address_prefix       = var.admin_ip_address
  source_port_range           = "*"
  depends_on = [
    azurerm_network_security_group.res-5,
  ]
}
resource "azurerm_public_ip" "res-10" {
  allocation_method   = "Static"
  domain_name_label   = "yumdeal-prod"
  location            = "eastus2"
  name                = "yumdeal-vm-D2s-ip"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = var.common_tags
  zones = ["1"]
}
resource "azurerm_virtual_network" "res-11" {
  address_space       = ["10.0.0.0/16"]
  location            = "eastus2"
  name                = "yumdeal-vm-D2s-vnet"
  resource_group_name = azurerm_resource_group.res-0.name
  tags = var.common_tags
}
resource "azurerm_subnet" "res-12" {
  address_prefixes     = ["10.0.0.0/24"]
  name                 = "default"
  resource_group_name  = azurerm_resource_group.res-0.name
  virtual_network_name = "yumdeal-vm-D2s-vnet"
  depends_on = [
    azurerm_virtual_network.res-11,
  ]
}
resource "azurerm_storage_account" "res-13" {
  account_replication_type        = "LRS"
  account_tier                    = "Standard"
  allow_nested_items_to_be_public = false
  is_hns_enabled                  = true
  location                        = "eastus2"
  name                            = "yumdealrawdata"
  resource_group_name             = azurerm_resource_group.res-0.name
}
resource "azurerm_storage_container" "res-15" {
  name               = "raw-prod"
  storage_account_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.res-0.name}/providers/Microsoft.Storage/storageAccounts/yumdealrawdata"
  depends_on = [
    # One of azurerm_storage_account.res-13,azurerm_storage_account_queue_properties.res-18 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_container" "res-16" {
  name               = "raw-uat"
  storage_account_id = "/subscriptions/${var.azure_subscription_id}/resourceGroups/${azurerm_resource_group.res-0.name}/providers/Microsoft.Storage/storageAccounts/yumdealrawdata"
  depends_on = [
    # One of azurerm_storage_account.res-13,azurerm_storage_account_queue_properties.res-18 (can't auto-resolve as their ids are identical)
  ]
}
resource "azurerm_storage_account_queue_properties" "res-18" {
  storage_account_id = azurerm_storage_account.res-13.id
  hour_metrics {
    version = "1.0"
  }
  logging {
    delete  = false
    read    = false
    version = "1.0"
    write   = false
  }
  minute_metrics {
    version = "1.0"
  }
}
