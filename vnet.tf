 #### Création du Réseau Virtuel (Vnet) 
 resource "azurerm_virtual_network" "test" {
   name                = "Vnet"
   address_space       = ["10.0.0.0/16"]
   location            = azurerm_resource_group.Kubernetes.location
   resource_group_name = azurerm_resource_group.Kubernetes.name
 }

#### Création du Subnet (/24 sur le /16 du Vnet)
 resource "azurerm_subnet" "test" {
   name                 = "subNet"
   resource_group_name  = azurerm_resource_group.Kubernetes.name
   virtual_network_name = azurerm_virtual_network.test.name
   address_prefixes     = ["10.0.2.0/24"]
 }

#### Création des Ip publiques que l'on attribuera aux VM's
 resource "azurerm_public_ip" "test" {
   count                        = 3
   name                         = "Public_IP-${count.index}"
   location                     = azurerm_resource_group.Kubernetes.location
   resource_group_name          = azurerm_resource_group.Kubernetes.name
   allocation_method            = "Static"

   depends_on = [azurerm_resource_group.Kubernetes]
 }
#### Création de nos 3 interfaces réseau à l'aide de "count"
  resource "azurerm_network_interface" "test" {
   count               = 3
   name                = "Network_Interface-${count.index}"
   location            = azurerm_resource_group.Kubernetes.location
   resource_group_name = azurerm_resource_group.Kubernetes.name

   ip_configuration {
     name                          = "testConfiguration"
     subnet_id                     = azurerm_subnet.test.id
     private_ip_address_allocation = "Dynamic"
     public_ip_address_id          = azurerm_public_ip.test["${count.index}"].id
   }
   depends_on = [azurerm_resource_group.Kubernetes]
 }

#### Création du NSG
 resource "azurerm_network_security_group" "allowedports" {
   name = "allowedports"
   resource_group_name = azurerm_resource_group.Kubernetes.name
   location = azurerm_resource_group.Kubernetes.location
  
   security_rule {
       name = "http"
       priority = 100
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "80"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "https"
       priority = 200
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "443"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "ssh"
       priority = 300
       direction = "Inbound"
       access = "Allow"
       protocol = "Tcp"
       source_port_range = "*"
       destination_port_range = "22"
       source_address_prefix = "*"
       destination_address_prefix = "*"
   }

   security_rule {
       name = "all"
       priority = 400
       direction = "Inbound"
       access = "Allow"
       protocol = "*"
       source_port_range = "*"
       destination_port_range = "*"
       source_address_prefix = "10.0.0.0/16"
       destination_address_prefix = "VirtualNetwork"
   }
}