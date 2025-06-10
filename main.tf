resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.location
}


resource "azurerm_network_security_group" "nsg" {
  name                = "network-security-group"
  location            = var.location
  resource_group_name = var.resource_group_name
  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg ]
}

resource "azurerm_network_security_rule" "ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name
  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg, azurerm_network_security_group.nsg ]
}

resource "azurerm_network_security_rule" "http" {
  name                        = "Allow-HTTP"
  priority                    = 101
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name

  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg, azurerm_network_security_group.nsg ]
}

resource "azurerm_network_security_rule" "all" {
  name                        = "Allow-all"
  priority                    = 103
  direction                   = "Outbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.nsg.name

  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg, azurerm_network_security_group.nsg ]
}

resource "azurerm_virtual_network" "v-net" {
  name = var.azurerm_virtual_network_name
  resource_group_name = var.resource_group_name
  address_space       = ["10.0.0.0/16"]
  location = var.location

  depends_on = [ azurerm_resource_group.rg ]



}

resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "subnet1"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.azurerm_virtual_network_name
  address_prefixes     = ["10.0.1.0/24"]

  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg ]
  
}

resource "azurerm_subnet_network_security_group_association" "nsg-association" {
  subnet_id                 = azurerm_subnet.jenkins_subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


locals {
  vm_name = ["jenkins-master","k8s-vm","jenkins-agent-1"]
  nic_name = ["jenkins-master-nic","k8s-nic","jenkins-agent-1-nic"]
  pip_name = ["jenkins-master-pip","k8s-pip","jenkins-agent-1-pip"]
}


resource "azurerm_network_interface" "nic" {

    count = 3
    resource_group_name = var.resource_group_name
    name = local.nic_name[count.index]
    location = var.location
     ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip[count.index].id

    
  }
  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg ]
 
  
}

resource "azurerm_public_ip" "pip" {
  count = 3
    resource_group_name = var.resource_group_name
    name = local.pip_name[count.index]
    location = var.location
    allocation_method   = "Dynamic"
    sku                 = "Basic"
    depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg ]
}


resource "azurerm_linux_virtual_machine" "vms" {

    count                 = 3
    name                  = local.vm_name[count.index]
    location = var.location
    resource_group_name = var.resource_group_name
    network_interface_ids = [azurerm_network_interface.nic[count.index].id]
    user_data = base64encode(file("install.sh"))

    size = "Standard_B1s"
    admin_username = "keshav"

    os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

    source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "keshav"
    public_key = file("jenkins-key.pub")
  }
  depends_on = [ azurerm_virtual_network.v-net, azurerm_resource_group.rg ]

  
}

output "vm_public_ips" {
  description = "Public IP addresses of all VMs"
  value       = [for i in range(length(azurerm_public_ip.pip)) : azurerm_public_ip.pip[i].ip_address]
}
