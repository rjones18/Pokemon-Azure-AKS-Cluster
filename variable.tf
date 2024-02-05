variable "prefix" {
  description = "A prefix used for all resources in this example"
  type        = string
}

variable "location" {
  description = "The Azure Region in which all resources in this example should be provisioned"
  type        = string
}

variable "network-rg" {
  description = "Resource Group for my network"
  type        = string
}