variable "prefix" {
  type = string
  default = "apis"
}

variable "location" {
  type = string
  default = "eastus2"
}

variable "resourcegroup" {
  type = string
  default = "RSGREU2APISD01"
}

variable "subnet_info" {
  type = object({
    id = string
    })
  sensitive = true
}

variable "vm_info" {
  type = object({
    username=string
    password=string
    })
  sensitive = true
}
