data "azurerm_resource_group" "existing" {
  name = "${var.network-rg}"
}

data "azurerm_virtual_network" "existing" {
  name                = "project-network"
  resource_group_name = data.azurerm_resource_group.existing.name
}

data "azurerm_subnet" "existing" {
  name                 = "app-subnet-1"
  virtual_network_name = data.azurerm_virtual_network.existing.name
  resource_group_name  = data.azurerm_resource_group.existing.name
}

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-k8s-resources"
  location = var.location
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_D2_v2"
    type       = "VirtualMachineScaleSets"
    vnet_subnet_id = data.azurerm_subnet.existing.id
  }

  network_profile {
    network_plugin = "azure"
    service_cidr = "172.16.0.0/16"
    dns_service_ip = "172.16.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }


  tags = {
    Environment = "Production"
  }
}

// resource "azurerm_kubernetes_cluster_node_pool" "example1" {
//   name                  = "example1"
//   kubernetes_cluster_id = azurerm_kubernetes_cluster.example.id
//   vm_size               = "Standard_D2_v2"
//   node_count            = 1
// }


provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.example.kube_config.0.host
  username               = azurerm_kubernetes_cluster.example.kube_config.0.username
  password               = azurerm_kubernetes_cluster.example.kube_config.0.password
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config.0.cluster_ca_certificate)
}

resource "kubernetes_namespace" "example" {
  metadata {
    name = "example"
  }
}

// resource "kubernetes_deployment" "example" {
//   metadata {
//     name = "nginx-deployment"
//     namespace = kubernetes_namespace.example.metadata.0.name
//     labels = {
//       App = "Nginx"
//     }
//   }

//   spec {
//     replicas = 3
//     selector {
//       match_labels = {
//         App = "Nginx"
//       }
//     }
//     template {
//       metadata {
//         labels = {
//           App = "Nginx"
//         }
//       }
//       spec {
//         container {
//           image = "nginx:1.15.8"
//           name  = "nginx"

//           port {
//             container_port = 80
//           }
//         }
//       }
//     }
//   }
// }

// resource "kubernetes_service" "example" {
//   metadata {
//     name = "nginx-service"
//     namespace = kubernetes_namespace.example.metadata.0.name
//   }
//   spec {
//     selector = {
//       App = "${kubernetes_deployment.example.metadata.0.labels["App"]}"
//     }
//     port {
//       port        = 80
//       target_port = 80
//     }

//     type = "LoadBalancer"
//   }
// }

// output "load_balancer_ip" {
//   value = kubernetes_service.example.status.0.load_balancer.0.ingress.0.ip
//   sensitive = true
// }


// output "client_certificate" {
//   value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
//   sensitive = true
// }

// output "kube_config" {
//   value = azurerm_kubernetes_cluster.example.kube_config_raw
//   sensitive = true
// }
#