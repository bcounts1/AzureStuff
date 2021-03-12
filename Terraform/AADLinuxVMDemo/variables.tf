variable "subscription_id" {}
variable "client_id" {}
variable "client_secret" {}
variable "tenant_id" {}

variable "location" {
    default = "EastUS"
    description = "Location for Resources"
}

variable "RGname" {
    default = "AADLinuxDemo"
    description = "Resource Group Name"
}
variable "VMname" {
    default = "AADdemoVM"
    description = "VM name"
}